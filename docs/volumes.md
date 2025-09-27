# Podman Volumes

Podman supports several types of volume mounts to persist data and share files between the host and containers.

## Types of Volumes

### 1. Named Volumes
Named volumes are managed by Podman and stored in Podman's volume directory.

```bash
# Create a named volume
podman volume create my-data-volume

# List all volumes
podman volume ls

# Inspect a volume
podman volume inspect my-data-volume

# Use named volume in container
podman run -d --name web-server \
  -v my-data-volume:/app/data \
  nginx:latest

# Remove a volume
podman volume rm my-data-volume

# Remove all unused volumes
podman volume prune
```

### 2. Bind Mounts
Bind mounts map a host directory directly to a container path.

```bash
# Basic bind mount
podman run -d --name web-server \
  -v /host/path:/container/path \
  nginx:latest

# Bind mount with SELinux context (recommended)
podman run -d --name web-server \
  -v /host/path:/container/path:Z \
  nginx:latest

# Read-only bind mount
podman run -d --name web-server \
  -v /host/path:/container/path:ro,Z \
  nginx:latest
```

### 3. tmpfs Mounts
Temporary filesystem stored in memory.

```bash
# Mount tmpfs
podman run -d --name temp-app \
  --tmpfs /tmp/cache:rw,noexec,nosuid,size=128m \
  nginx:latest
```

## Volume Mount Options

### SELinux Context Options
- `:Z` - Relabel shared volume content to match the container's SELinux context
- `:z` - Relabel private volume content to match the container's SELinux context

### Access Mode Options  
- `:ro` - Read-only mount
- `:rw` - Read-write mount (default)

### Other Options
- `:nodev` - Do not interpret character/block special devices
- `:nosuid` - Do not allow set-user-ID or set-group-ID bits
- `:noexec` - Do not allow execution of binaries

## Practical Examples

### Example 1: Web Server with Persistent Content

### Example 1: Web Server with Persistent Content

```bash
# Create content directory
mkdir -p ./nginx-content

# Create HTML content using cat
cat > ./nginx-content/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Podman Volume Demo</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        h1 { color: #2c5282; }
    </style>
</head>
<body>
    <h1>Hello from Bind Volume!</h1>
    <p>This content is served from a bind-mounted directory</p>
    <p>Container host: \$(hostname)</p>
    <p>Current user: \$(whoami)</p>
    <p>Created: \$(date)</p>
</body>
</html>
EOF

# Run container with bind volume
podman container run -d -p 8081:8080 --name ubi-nginx-bind-test \
  -v \$(pwd)/nginx-content:/usr/share/nginx/html:Z \
  localhost/ubi-nginx:latest

# Test the content
curl -s http://localhost:8081

# View in browser: http://localhost:8081
```

### Example 2: Database with Persistent Data

```bash
# Create named volume for database
podman volume create postgres-data

# Run PostgreSQL with persistent volume
podman run -d --name postgres-db \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=myapp \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:13

# Connect to database
podman exec -it postgres-db psql -U postgres -d myapp

# Data persists even after container restart
podman stop postgres-db
podman start postgres-db
```

### Example 3: Development Environment with Bind Mounts

```bash
# Create project structure
mkdir -p ./my-app/{src,config,logs}

# Create a simple application
cat > ./my-app/src/app.py << 'EOF'
#!/usr/bin/env python3
import os
import time
from datetime import datetime

print("Application started at:", datetime.now())
print("Container ID:", os.environ.get('HOSTNAME', 'unknown'))

# Write to log file
with open('/app/logs/app.log', 'a') as f:
    f.write(f"{datetime.now()}: Application started\n")

# Keep running
while True:
    time.sleep(30)
    with open('/app/logs/app.log', 'a') as f:
        f.write(f"{datetime.now()}: Heartbeat\n")
EOF

# Create configuration
cat > ./my-app/config/app.conf << 'EOF'
[app]
name=my-development-app
version=1.0.0
debug=true
log_level=INFO
EOF

# Run development container with multiple bind mounts
podman run -d --name dev-app \
  -v \$(pwd)/my-app/src:/app/src:Z \
  -v \$(pwd)/my-app/config:/app/config:ro,Z \
  -v \$(pwd)/my-app/logs:/app/logs:Z \
  python:3.9 \
  python /app/src/app.py

# Monitor logs
tail -f ./my-app/logs/app.log
```

### Example 4: Named Volumes with Multiple Containers

```bash
# Create shared volume
podman volume create shared-data

# Container 1: Writer
podman run -d --name data-writer \
  -v shared-data:/data \
  busybox \
  sh -c 'while true; do echo "\$(date): Data from writer" >> /data/shared.log; sleep 10; done'

# Container 2: Reader
podman run -d --name data-reader \
  -v shared-data:/data:ro \
  busybox \
  sh -c 'while true; do echo "Reading:"; tail -5 /data/shared.log; sleep 15; done'

# Monitor both containers
podman logs -f data-writer &
podman logs -f data-reader &
```

## Volume Management

### List and Inspect Volumes

```bash
# List all volumes
podman volume ls

# Show volume details
podman volume inspect volume_name

# Show volume usage
podman system df

# Find volume location
podman volume inspect volume_name --format '{{.Mountpoint}}'
```

### Backup and Restore Volumes

```bash
# Backup named volume to tar file
podman run --rm \
  -v volume_name:/source:ro \
  -v \$(pwd):/backup \
  busybox \
  tar czf /backup/volume_backup.tar.gz -C /source .

# Restore volume from backup
podman volume create new_volume
podman run --rm \
  -v new_volume:/target \
  -v \$(pwd):/backup \
  busybox \
  tar xzf /backup/volume_backup.tar.gz -C /target
```

### Cleanup

```bash
# Remove specific volume
podman volume rm volume_name

# Remove all unused volumes
podman volume prune

# Force remove all volumes (dangerous!)
podman volume rm \$(podman volume ls -q) -f
```

## Volume Performance Tips

1. **Use named volumes for better performance** than bind mounts
2. **Use :Z or :z SELinux labels** on SELinux-enabled systems
3. **Avoid mounting large directory trees** as bind mounts
4. **Use tmpfs for temporary data** that doesn't need persistence
5. **Regular cleanup** of unused volumes to save disk space

## Troubleshooting

### Common Issues

```bash
# Permission denied errors - check SELinux context
ls -Z /host/path
podman run --rm -v /host/path:/container/path:Z image

# Volume not found
podman volume ls
podman volume inspect volume_name

# SELinux denials  
sudo ausearch -m AVC -ts recent
# Use :Z flag for shared volumes or :z for private
```

