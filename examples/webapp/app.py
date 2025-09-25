#!/usr/bin/env python3

import os
import time
from flask import Flask, render_template, jsonify, request
import psycopg2
import redis
from datetime import datetime

app = Flask(__name__)

# Configuration
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://webapp:secret@localhost:5432/webapp_db')
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')

# Initialize Redis connection
try:
    redis_client = redis.from_url(REDIS_URL)
    redis_client.ping()
    print("✅ Redis connection established")
except Exception as e:
    print(f"⚠️  Redis connection failed: {e}")
    redis_client = None

# Database connection
def get_db_connection():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        return conn
    except Exception as e:
        print(f"⚠️  Database connection failed: {e}")
        return None

@app.route('/')
def home():
    # Get visitor count from Redis
    visitor_count = 0
    if redis_client:
        try:
            visitor_count = redis_client.incr('visitor_count')
        except Exception as e:
            print(f"Redis error: {e}")
    
    # Get database info
    db_status = "❌ Disconnected"
    db_info = {}
    
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT version();")
                db_version = cur.fetchone()[0]
                cur.execute("SELECT NOW();")
                db_time = cur.fetchone()[0]
                
                db_status = "✅ Connected"
                db_info = {
                    'version': db_version,
                    'time': db_time
                }
        except Exception as e:
            print(f"Database query error: {e}")
        finally:
            conn.close()
    
    return render_template('index.html', 
                         visitor_count=visitor_count,
                         db_status=db_status,
                         db_info=db_info,
                         current_time=datetime.now())

@app.route('/health')
def health():
    """Health check endpoint for container health checks"""
    status = {
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {}
    }
    
    # Check Redis
    if redis_client:
        try:
            redis_client.ping()
            status['services']['redis'] = 'healthy'
        except Exception as e:
            status['services']['redis'] = f'unhealthy: {e}'
            status['status'] = 'degraded'
    else:
        status['services']['redis'] = 'not configured'
    
    # Check Database
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
            status['services']['database'] = 'healthy'
            conn.close()
        except Exception as e:
            status['services']['database'] = f'unhealthy: {e}'
            status['status'] = 'degraded'
    else:
        status['services']['database'] = 'unhealthy: no connection'
        status['status'] = 'degraded'
    
    return jsonify(status), 200 if status['status'] == 'healthy' else 503

@app.route('/info')
def info():
    """Container and environment information"""
    info_data = {
        'hostname': os.getenv('HOSTNAME', 'unknown'),
        'environment': os.getenv('FLASK_ENV', 'development'),
        'python_version': os.sys.version,
        'flask_version': Flask.__version__,
        'timestamp': datetime.now().isoformat()
    }
    return jsonify(info_data)

if __name__ == '__main__':
    # Wait for services to be ready
    print("🚀 Starting webapp...")
    print(f"📊 Database URL: {DATABASE_URL}")
    print(f"🔴 Redis URL: {REDIS_URL}")
    
    # Run the app
    app.run(host='0.0.0.0', port=5000, debug=os.getenv('FLASK_ENV') == 'development')
