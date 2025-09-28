# Using Volumes in Podman

[← Back to Playground](../playground.md)

This guide demonstrates different types of volume usage in Podman with practical examples.

## Table of Contents
- [Volume Types](#volume-types)
- [Named Volumes Example](#named-volumes-example)
- [Bind Mounts Example](#bind-mounts-example)
- [Complete Application with Volumes](#complete-application-with-volumes)
- [Volume Management Commands](#volume-management-commands)

## Volume Types

Podman supports three main types of volume mounts:

1. **Named Volumes**: Managed by Podman, stored in Podman's storage area
2. **Bind Mounts**: Direct mapping from host filesystem to container
3. **tmpfs Mounts**: Temporary filesystem in memory

## Named Volumes Example

# Create named volumes
```bash
podman volume create web-logs
podman volume create web-content
```

### 2. Inspect Dockerfile
- [Dockerfile](../playground/use-volumes/Dockerfile)

### 3. Build and Run with Named Volumes
```bash
cd ./use-volumes/

# Build the image
podman build -t web-volume-demo .

# Run container with named volumes
podman run -d \
  --name web-app \
  -p 8080:80 \
  -v web-content:/var/www/html \
  -v web-logs:/var/log/nginx \
  -v ./config/nginx.conf:/etc/nginx/nginx.conf:ro \
  web-volume-demo

# Test the application
curl http://localhost:8080
curl http://localhost:8080/health
```

### Check volumes
```bash
podman volume ls
podman volume inspect web-logs
podman volume inspect web-content
```

### Clean up
```bash
podman stop web-app
podman rm web-app
podman volume rm web-logs
podman volume rm web-content
```



## Bind Mounts Example

### 1. Create Host Directories
```bash
mkdir -p volumes-example/bind-mount/{content,logs,config}
cd volumes-example/bind-mount
```

### 2. Create Content
```html
<!-- content/index.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Bind Mount Demo</title>
</head>
<body>
    <h1>🔗 Bind Mount Example</h1>
    <p>This content is directly mounted from the host filesystem!</p>
    <p>Edit this file on the host and refresh to see changes immediately.</p>
</body>
</html>
```

### 3. Run with Bind Mounts
```bash
# Get absolute paths
CONTENT_DIR=$(pwd)/content
LOGS_DIR=$(pwd)/logs
CONFIG_DIR=$(pwd)/config

# Create nginx config
cat > config/nginx.conf << 'EOF'
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

# Run with bind mounts
podman run -d \
  --name bind-mount-demo \
  -p 8081:80 \
  -v $CONTENT_DIR:/var/www/html:Z \
  -v $LOGS_DIR:/var/log/nginx:Z \
  -v $CONFIG_DIR/nginx.conf:/etc/nginx/nginx.conf:ro,Z \
  web-volume-demo

# Test the application
curl http://localhost:8081

# View logs in real-time
tail -f logs/access.log
```

## Complete Application with Volumes

### 1. Create docker-compose.yml
```yaml
# docker-compose.yml
version: '3.8'

services:
  web-app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: volume-demo-web
    ports:
      - "8082:80"
    volumes:
      # Named volume for logs
      - web-logs:/var/log/nginx
      # Bind mount for content (allows live editing)
      - ./content:/var/www/html:Z
      # Bind mount for config
      - ./config/nginx.conf:/etc/nginx/nginx.conf:ro,Z
    networks:
      - demo-network

  log-viewer:
    image: registry.access.redhat.com/ubi9/ubi:latest
    container_name: volume-demo-logs
    volumes:
      - web-logs:/logs:ro
    command: tail -f /logs/access.log
    depends_on:
      - web-app
    networks:
      - demo-network

volumes:
  web-logs:
    driver: local

networks:
  demo-network:
    driver: bridge
```

### 2. Start Complete Stack
```bash
# Start services
podman-compose up --build -d

# Check containers
podman-compose ps

# View logs from log-viewer container
podman-compose logs log-viewer

# Generate some traffic
for i in {1..10}; do curl -s http://localhost:8082/ > /dev/null; done

# Stop services
podman-compose down
```

## Volume Management Commands

### Inspect and Manage Volumes
```bash
# List all volumes
podman volume ls

# Inspect volume details
podman volume inspect web-logs

# Check volume usage
podman system df

# Remove unused volumes
podman volume prune

# Remove specific volume
podman volume rm web-logs

# Backup volume data
podman run --rm -v web-logs:/data -v $(pwd):/backup registry.access.redhat.com/ubi9/ubi:latest tar czf /backup/web-logs-backup.tar.gz -C /data .

# Restore volume data
podman volume create web-logs-restored
podman run --rm -v web-logs-restored:/data -v $(pwd):/backup registry.access.redhat.com/ubi9/ubi:latest tar xzf /backup/web-logs-backup.tar.gz -C /data
```

### Advanced Volume Operations
```bash
# Create volume with specific options
podman volume create --driver local --opt type=tmpfs --opt device=tmpfs --opt o=size=100m temp-volume

# Mount volume in multiple containers
podman run -d --name app1 -v shared-data:/app/data registry.access.redhat.com/ubi9/ubi:latest sleep infinity
podman run -d --name app2 -v shared-data:/app/data registry.access.redhat.com/ubi9/ubi:latest sleep infinity

# Check which containers use a volume
podman volume inspect shared-data

# Copy data between containers via volumes
podman run --rm -v shared-data:/source -v backup-data:/dest registry.access.redhat.com/ubi9/ubi:latest cp -r /source/. /dest/
```

## Best Practices

### 1. SELinux Considerations
```bash
# Use :Z flag for bind mounts to relabel for container access
-v /host/path:/container/path:Z

# Use :z flag for sharing between multiple containers
-v /host/path:/container/path:z
```

### 2. Permission Management
```bash
# Fix ownership for rootless containers
podman unshare chown -R 33:33 /host/path  # www-data user

# Check container user ID
podman run --rm registry.access.redhat.com/ubi9/ubi:latest id
```

### 3. Performance Considerations
```bash
# Use named volumes for better performance
-v volume-name:/path

# Use tmpfs for temporary data
--tmpfs /tmp:rw,noexec,nosuid,size=100m
```

## Troubleshooting

### Common Issues
```bash
# Check volume mount points
podman inspect <container-name> | grep -A 10 -B 10 Mounts

# Debug permission issues
podman exec -it <container-name> ls -la /mounted/path

# Check SELinux contexts
ls -Z /host/path
```

### Cleanup
```bash
# Remove all stopped containers
podman container prune

# Remove unused volumes
podman volume prune

# Remove all unused data
podman system prune -a --volumes
```

[← Back to Playground](../playground.md)
