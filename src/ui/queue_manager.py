import os
import redis
from rq import Queue
from dotenv import load_dotenv

load_dotenv()

# Redis Configuration
REDIS_URL = os.environ.get('REDIS_URL', 'redis://localhost:6379/0')

# Initialize Redis connection
try:
    redis_conn = redis.from_url(REDIS_URL)
    # Ping to verify connection
    redis_conn.ping()
    print(f"Connected to Redis at {REDIS_URL}")
except Exception as e:
    print(f"Warning: Could not connect to Redis: {e}")
    redis_conn = None

# Initialize RQ Queue
# We'll use a single queue named 'heatwave-tasks'
task_queue = Queue('heatwave-tasks', connection=redis_conn) if redis_conn else None

def get_job_status(job_id):
    """Retrieve job status and results."""
    if not redis_conn:
        return {'status': 'error', 'message': 'Redis not connected'}
    
    job = task_queue.fetch_job(job_id)
    if not job:
        return {'status': 'not_found'}
    
    return {
        'id': job.get_id(),
        'status': job.get_status(),
        'result': job.result,
        'enqueued_at': job.enqueued_at.isoformat() if job.enqueued_at else None,
        'started_at': job.started_at.isoformat() if job.started_at else None,
        'ended_at': job.ended_at.isoformat() if job.ended_at else None,
        'exc_info': job.exc_info
    }
