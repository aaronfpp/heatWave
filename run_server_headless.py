#!/usr/bin/env python
"""
Headless server launcher for heatWave.

Runs the Flask server without GUI, perfect for server deployment.
Opens browser automatically for easy access.

Usage:
    python run_server_headless.py          # development
    python run_server_headless.py --port 8080  # custom port
    python run_server_headless.py --host 0.0.0.0  # bind to all interfaces
"""
import sys
import os
import argparse
import threading
import logging
import webbrowser
import time
from pathlib import Path

# Suppress noisy logs
logging.getLogger('werkzeug').setLevel(logging.WARNING)


def _resolve_paths():
    """Set the working directory correctly for both dev and frozen modes."""
    if getattr(sys, 'frozen', False):
        # Running as PyInstaller .exe — chdir to the exe's folder
        app_dir = os.path.dirname(sys.executable)
        os.chdir(app_dir)

        # Ensure the project root is importable (for `from src.…` imports)
        internal_dir = os.path.join(app_dir, '_internal')
        if internal_dir not in sys.path:
            sys.path.insert(0, internal_dir)
    else:
        # Running as script — make sure project root is on sys.path
        project_root = os.path.dirname(os.path.abspath(__file__))
        if project_root not in sys.path:
            sys.path.insert(0, project_root)


def _start_flask(host='127.0.0.1', port=5000):
    """Start the Flask server."""
    from src.ui.flask_app import app
    print(f"🚀 Starting heatWave server on http://{host}:{port}")
    print(f"📁 Working directory: {os.getcwd()}")
    print(f"🔧 User isolation: Enabled")
    print(f"📊 Queue management: Enabled")
    print()
    app.run(host=host, port=port, debug=False, use_reloader=False)


def main():
    parser = argparse.ArgumentParser(description='heatWave Headless Server')
    parser.add_argument('--host', default='127.0.0.1',
                       help='Host to bind to (default: 127.0.0.1)')
    parser.add_argument('--port', type=int, default=5000,
                       help='Port to bind to (default: 5000)')
    parser.add_argument('--no-browser', action='store_true',
                       help='Do not open browser automatically')
    parser.add_argument('--quiet', action='store_true',
                       help='Suppress startup messages')

    args = parser.parse_args()

    _resolve_paths()

    # Check for icon
    icon_path = Path('assets/icon.ico')
    if icon_path.exists():
        print(f"✅ Found icon: {icon_path.absolute()}")
    else:
        print(f"⚠️  Icon not found: {icon_path}")

    if not args.quiet:
        print("🏊 heatWave - Heat Sheet Generator (Headless Server)")
        print("=" * 55)
        print(f"Host: {args.host}")
        print(f"Port: {args.port}")
        print()

    # Start Flask server
    server_thread = threading.Thread(
        target=_start_flask,
        args=(args.host, args.port),
        daemon=True,
    )
    server_thread.start()

    # Open browser
    if not args.no_browser:
        url = f'http://{args.host}:{args.port}'
        if not args.quiet:
            print(f"🌐 Opening browser to {url}")
        time.sleep(1)
        try:
            webbrowser.open(url)
        except Exception as e:
            print(f"⚠️  Could not open browser: {e}")

    if not args.quiet:
        print("✅ Server started successfully!")
        print("💡 Press Ctrl+C to stop the server")
        print()

    try:
        server_thread.join()   # keep alive
    except KeyboardInterrupt:
        print("\n👋 Server stopped.")


if __name__ == '__main__':
    main()