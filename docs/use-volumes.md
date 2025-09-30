# Using Volumes in Podman

[← Back to Playground](../playground.md)

This guide demonstrates different types of volume usage in Podman with practical examples.

## Table of Contents
- [Why Use Volumes?](#why-use-volumes)
- [Volume Types](#volume-types)
- [Named Volumes Example](#named-volumes-example)
- [Bind Mounts Example](#bind-mounts-example)

## Why Use Volumes?
1. Data Persistence
Survive container lifecycle: Data persists even when containers are stopped, removed, or recreated
Stateful applications: Essential for databases, logs, user data, and application state
Updates and rollbacks: Maintain data integrity during application updates
2. Data Sharing
Multi-container access: Multiple containers can read/write to the same volume
Microservices communication: Share data between different services
Backup and restore: Centralized data management across container instances
3. Performance Optimization
Native filesystem: Better I/O performance compared to bind mounts
Container layer bypass: Direct access to host storage without container filesystem overhead
Reduced image size: Keep large datasets separate from container images
4. Security and Isolation
Controlled access: Podman manages volume permissions and SELinux contexts
Isolation: Separate application logic from data storage
Root/rootless compatibility: Works seamlessly in both execution modes

## Volume Types

Podman supports three main types of volume mounts:

1. **Named Volumes**: Managed by Podman, stored in Podman's storage area
2. **Bind Mounts**: Direct mapping from host filesystem to container
3. **tmpfs Mounts**: Temporary filesystem in memory

## Prerequisites
We use a simple Nginx web server application for demonstration. The application serves static HTML content and logs access requests.

### 1. Inspect Dockerfile
- [Dockerfile](../playground/use-volumes/Dockerfile)

### 2. Build image 
```bash
cd ./use-volumes/

# Build the image
podman build -t web-volume-demo .
```


## Named Volumes Example

### 1. Create named volumes
```bash
podman volume create web-logs
podman volume create web-content
```

### 2. Run container with named volumes
```bash
podman run -d \
  --name web-app \
  -p 8080:80 \
  -v web-content:/var/www/html \
  -v web-logs:/var/log/nginx \
  -v ./config/nginx.conf:/etc/nginx/nginx.conf:ro \
  web-volume-demo
```

### 3. Test the application
```bash
curl http://localhost:8080
curl http://localhost:8080/health

# http://localhost:8080 in your browser
```

### 4. Check volumes
```bash
podman volume ls
podman volume inspect web-logs
podman volume inspect web-content
```

### 5. Check volume contents
```bash
podman run --rm -v web-content:/data registry.access.redhat.com/ubi9/ubi:latest ls -la /data
podman run --rm -v web-logs:/data registry.access.redhat.com/ubi9/ubi:latest ls -la /data
```

### 6. Generate some traffic
```bash
for i in {1..10}; do curl -s http://localhost:8080/ > /dev/null; done

# Check logs
podman run --rm -v web-logs:/data registry.access.redhat.com/ubi9/ubi:latest sh -c "ls -la /data && echo '--- access.log content ---' && cat /data/access.log"
```

### 7. Stop container, start it again and verify data persistence
```bash
podman stop web-app
podman start web-app

# Check logs
podman run --rm -v web-logs:/data registry.access.redhat.com/ubi9/ubi:latest sh -c "ls -la /data && echo '--- access.log content ---' && cat /data/access.log"
```

## Bind Mounts Example

### 1. Create Host Directories
```bash
mkdir -p $(pwd)/bind-mount/{content,logs,config}
```

### 2. Create Content and config files

- Create HTML content
```bash
cat > bind-mount/content/index.html << 'EOF'
<!-- content/index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Bind Mount Demo</title>
</head>
<body>
    <h1>Bind Mount Example</h1>
    <p>This content is directly mounted from the host filesystem!</p>
    <p>Edit this file on the host and refresh to see changes immediately.</p>
</body>
</html>
EOF
```

- Create nginx config
```bash
cat > bind-mount/config/nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    server {
        listen 80;
        root /var/www/html;
        index index.html;
        
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
}
EOF
```

### 3. List Directory Structure
```bash
tree bind-mount
```

### 4. Run with Bind Mounts
```bash
# Get absolute paths
CONTENT_DIR=$(pwd)/bind-mount/content
LOGS_DIR=$(pwd)/bind-mount/logs
CONFIG_DIR=$(pwd)/bind-mount/config
```

### 5. Run container with bind mounts
```bash
podman run -d \
  --name bind-web-app \
  -p 8081:80 \
  -v $CONTENT_DIR:/var/www/html \
  -v $LOGS_DIR:/var/log/nginx \
  -v $CONFIG_DIR/nginx.conf:/etc/nginx/nginx.conf:ro \
  web-volume-demo
```

### 6. Test the application
```bash
curl http://localhost:8081

# http://localhost:8080 in your browser
```

### 7. Stop container, start it again and verify data persistence
```bash
podman stop bind-web-app
podman start bind-web-app

# Check files
```

### 8. Generate some traffic and check logs in real-time
```bash
for i in {1..100}; do curl -s http://localhost:8081/ > /dev/null; done

tail -f logs/access.log
```

## 8. Clean up

```bash
# Named volume cleanup
podman container stop web-app
podman container rm web-app
podman volume rm web-logs
podman volume rm web-content

# Bind Mounts cleanup
podman container stop bind-web-app
podman container rm bind-web-app

cd ..
rm -rf bind-mount/

podman image rm web-volume-demo
```

[← Back to Playground](../playground.md)
