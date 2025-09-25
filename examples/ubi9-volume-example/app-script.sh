#!/bin/bash

echo "=== UBI 9 Volume Example Application ==="
echo "Started at: $(date)"

# Create log file
echo "$(date): Application started" >> /app/logs/app.log

# Check if this is the first run by looking for data
if [ ! -f "/app/data/initialized" ]; then
    echo "First run detected - initializing data..."
    
    # Copy initial data to persistent volume
    cp -r /app/initial-data/* /app/data/
    
    # Create configuration file
    cat > /app/config/app.conf << EOF
# Application Configuration
app_name=UBI9-Volume-Example
app_version=1.0.0
data_dir=/app/data
log_dir=/app/logs
created=$(date)
EOF
    
    # Mark as initialized
    touch /app/data/initialized
    echo "$(date): Data initialized" >> /app/logs/app.log
else
    echo "Data already initialized - loading existing data..."
    echo "$(date): Application restarted with existing data" >> /app/logs/app.log
fi

# Display current status
echo ""
echo "=== Current Status ==="
echo "Configuration:"
cat /app/config/app.conf

echo ""
echo "Data directory contents:"
tree /app/data 2>/dev/null || ls -la /app/data

echo ""
echo "Recent logs:"
tail -5 /app/logs/app.log

echo ""
echo "=== Volume Information ==="
df -h | grep -E "(Filesystem|/app)"

# Keep container running for demonstration
if [ "$1" = "--daemon" ]; then
    echo ""
    echo "Running in daemon mode - container will stay alive..."
    echo "$(date): Running in daemon mode" >> /app/logs/app.log
    
    # Update log every 30 seconds to show persistence
    while true; do
        sleep 30
        echo "$(date): Heartbeat - container still running" >> /app/logs/app.log
    done
else
    echo ""
    echo "Application completed. Run with --daemon to keep container alive."
    echo "$(date): Application completed" >> /app/logs/app.log
fi