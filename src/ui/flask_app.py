"""
heatWave Flask backend — lightweight replacement for Streamlit.
Provides JSON API routes for PDF upload, parsing, seeding, and generation.
Works both as a regular Python app and inside a PyInstaller .exe.
"""
import io
import sys
import os
import json
import math
import tempfile
from pathlib import Path
from datetime import datetime

from flask import Flask, request, jsonify, send_file, render_template, session
from flask_session import Session
from werkzeug.middleware.proxy_fix import ProxyFix
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env

# Queue and tasks
from src.ui.queue_manager import task_queue, get_job_status, redis_conn
from src.ui.tasks import parse_pdf_task, seeding_task, generate_pdf_task

# ---------------------------------------------------------------------------
# Resolve paths for both dev and frozen (PyInstaller) mode
# ---------------------------------------------------------------------------
if getattr(sys, 'frozen', False):
    # Running as PyInstaller exe — _MEIPASS or _internal contains bundled data
    _BASE_DIR = Path(sys._MEIPASS) if hasattr(sys, '_MEIPASS') else Path(os.path.dirname(sys.executable)) / '_internal'
    _TEMPLATE_DIR = _BASE_DIR / 'src' / 'ui' / 'templates'
else:
    _BASE_DIR = Path(__file__).resolve().parent.parent.parent  # project root
    _TEMPLATE_DIR = Path(__file__).resolve().parent / 'templates'

app = Flask(__name__, template_folder=str(_TEMPLATE_DIR))
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB max upload

# ---------------------------------------------------------------------------
# Reverse Proxy Support
# ---------------------------------------------------------------------------
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

# ---------------------------------------------------------------------------
# Rate Limiting
# ---------------------------------------------------------------------------
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"],
    storage_uri=os.environ.get('REDIS_URL', 'memory://'),
)

# ---------------------------------------------------------------------------
# Configure Flask-Session (multi-user isolation)
# ---------------------------------------------------------------------------
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'heatwave-dev-secret-key-123')

if redis_conn:
    app.config['SESSION_TYPE'] = 'redis'
    app.config['SESSION_REDIS'] = redis_conn
else:
    app.config['SESSION_TYPE'] = 'filesystem'
    app.config['SESSION_FILE_DIR'] = tempfile.gettempdir() + '/heatwave_sessions'
    os.makedirs(app.config['SESSION_FILE_DIR'], exist_ok=True)

app.config['SESSION_PERMANENT'] = False
app.config['SESSION_USE_SIGNER'] = True

Session(app)


# ---------------------------------------------------------------------------
# Import project modules (same ones Streamlit used)
# ---------------------------------------------------------------------------
from src.parser.extractor import extract_text_from_pdf, parse_events_from_text
from src.seeding.seeder import seed_event, format_heat_sheet
from src.core.pdf_generator import generate_full_meet_pdf, generate_heat_sheet_pdf
from src.models.schemas import Entry, RelayEntry


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------
@app.route('/')
def index():
    """Serve the single-page UI."""
    return render_template('index.html')


@app.route('/api/upload', methods=['POST'])
@limiter.limit("10 per minute")
def upload_pdf():
    """Upload and parse a psych-sheet PDF."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    pdf_file = request.files['file']
    if pdf_file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400

    try:
        pdf_bytes = pdf_file.read()
        
        if task_queue:
            # Asynchronous mode (Server)
            job = task_queue.enqueue(
                parse_pdf_task, 
                args=(pdf_bytes, pdf_file.filename),
                job_timeout='5m'
            )
            return jsonify({
                'success': True,
                'async': True,
                'job_id': job.get_id()
            })
        else:
            # Synchronous fallback (Desktop)
            result = parse_pdf_task(pdf_bytes, pdf_file.filename)
            if not result['success']:
                return jsonify({'error': result.get('error', 'Unknown error')}), 500
            
            # Store parsed events in session
            session['events'] = result['raw_events']
            session['heat_sheets'] = None

            return jsonify({
                'success': True,
                'async': False,
                'filename': result['filename'],
                'event_count': result['event_count'],
                'total_entries': result['total_entries'],
                'events': result['events_summary'],
            })

    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@app.route('/api/generate', methods=['POST'])
@limiter.limit("5 per minute")
def generate():
    """Seed events and generate heat sheets."""
    if session.get('events') is None:
        return jsonify({'error': 'No events parsed yet. Upload a PDF first.'}), 400

    data = request.get_json(silent=True) or {}
    num_lanes = int(data.get('lanes', 8))

    try:
        if task_queue:
            # Asynchronous mode
            job = task_queue.enqueue(
                seeding_task,
                args=(session['events'], num_lanes),
                job_timeout='5m'
            )
            return jsonify({
                'success': True,
                'async': True,
                'job_id': job.get_id()
            })
        else:
            # Synchronous fallback
            result = seeding_task(session['events'], num_lanes)
            if not result['success']:
                return jsonify({'error': result.get('error', 'Unknown error')}), 500

            session['heat_sheets'] = result['heat_sheets']

            return jsonify({
                'success': True,
                'async': False,
                'total_heats': result['total_heats'],
                'total_entries': result['total_entries'],
                'events': result['summary'],
            })

    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@app.route('/api/download/full', methods=['GET'])
def download_full_pdf():
    """Download the full meet heat-sheet PDF."""
    if session['heat_sheets'] is None:
        return jsonify({'error': 'No heat sheets generated yet.'}), 400

    meet_title = request.args.get('title', 'Swimming Meet')
    meet_date = request.args.get('date', datetime.now().strftime('%m/%d/%Y'))

    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            pdf_path = Path(tmpdir) / 'Full_Meet_Heatsheets.pdf'
            generate_full_meet_pdf(
                session['heat_sheets'],
                str(pdf_path),
                meet_title=meet_title,
                meet_date=meet_date,
            )
            pdf_bytes = pdf_path.read_bytes()

        safe_title = meet_title.replace(' ', '_')
        return send_file(
            io.BytesIO(pdf_bytes),
            mimetype='application/pdf',
            as_attachment=True,
            download_name=f'HeatSheet_{safe_title}.pdf',
        )

    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@app.route('/api/download/event/<int:event_num>', methods=['GET'])
def download_event_pdf(event_num):
    """Download the heat-sheet PDF for a single event."""
    if session['heat_sheets'] is None:
        return jsonify({'error': 'No heat sheets generated yet.'}), 400

    meet_title = request.args.get('title', 'Swimming Meet')
    meet_date = request.args.get('date', datetime.now().strftime('%m/%d/%Y'))

    hs = next((h for h in session['heat_sheets'] if h.event.number == event_num), None)
    if hs is None:
        return jsonify({'error': f'Event {event_num} not found.'}), 404

    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            pdf_path = Path(tmpdir) / f'Event_{event_num:02d}_Heatsheet.pdf'
            generate_heat_sheet_pdf(
                hs,
                str(pdf_path),
                meet_title=meet_title,
                meet_date=meet_date,
            )
            pdf_bytes = pdf_path.read_bytes()

        return send_file(
            io.BytesIO(pdf_bytes),
            mimetype='application/pdf',
            as_attachment=True,
            download_name=f'Event_{event_num:02d}_Heatsheet.pdf',
        )

    except Exception as exc:
        return jsonify({'error': str(exc)}), 500


@app.route('/api/status', methods=['GET'])
def status():
    """Return current session status for the frontend."""
    has_events = session.get('events') is not None
    has_heats = session.get('heat_sheets') is not None
    return jsonify({
        'has_events': has_events,
        'has_heats': has_heats,
        'event_count': len(session['events']) if has_events else 0,
        'heat_sheet_count': len(session['heat_sheets']) if has_heats else 0,
    })


@app.route('/api/jobs/<job_id>', methods=['GET'])
def job_status(job_id):
    """Check the status of a background job."""
    status_info = get_job_status(job_id)
    return jsonify(status_info)


@app.route('/api/jobs/<job_id>/apply', methods=['POST'])
def apply_job_result(job_id):
    """
    Take the result of a finished job and apply it to the user's session.
    This is necessary because workers don't share the Flask session.
    """
    status_info = get_job_status(job_id)
    if status_info['status'] != 'finished':
        return jsonify({'error': 'Job not finished or not found'}), 400
    
    result = status_info['result']
    if not result.get('success'):
        return jsonify({'error': result.get('error', 'Job failed')}), 500

    # Apply based on what kind of job it was
    if 'raw_events' in result:
        session['events'] = result['raw_events']
        session['heat_sheets'] = None
    elif 'heat_sheets' in result:
        session['heat_sheets'] = result['heat_sheets']
    
    return jsonify({'success': True})


# ---------------------------------------------------------------------------
# Standalone usage (for development without pywebview)
# ---------------------------------------------------------------------------
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
