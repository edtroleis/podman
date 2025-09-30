# UBI9 Nginx with Podman Compose

[← Back to Podman Compose](../../../docs/podman-compose.md)

This example demonstrates how to run an Nginx web server using Red Hat Universal Base Image 9 (UBI9) with Podman Compose.

## Overview

This setup includes:
- **Base Image**: `registry.access.redhat.com/ubi9/ubi:latest`
- **Web Server**: Nginx
- **Orchestration**: Podman Compose
- **Port**: 8080 (host) → 80 (container)

## Files Structure

```
ubi9-nginx/
├── Dockerfile          # Container image definition
├── compose.yml         # Podman compose configuration
├── nginx.conf          # Nginx server configuration
├── index.html          # Web content
└── README.md           # This file
```

## Prerequisites

- Podman installed
- podman-compose installed

## Quick Start

1. **Navigate to the example directory:**
   ```bash
   cd /mnt/e/work/github/podman/playground/podman-compose/ubi9-nginx
   ```

2. **Build and start the service:**
   ```bash
   podman-compose up --build -d
   ```

3. **Access the application:**
   Open your browser and go to: http://localhost:8080

4. **View logs:**
   ```bash
   podman-compose logs nginx
   ```

5. **Stop the service:**
   ```bash
   podman-compose down
   ```

## Detailed Commands

### Build the image manually (optional):
```bash
podman build -t ubi9-nginx .
```

### Run without compose (alternative):
```bash
podman run -d --name ubi9-nginx -p 8080:80 ubi9-nginx
```

### Check container status:
```bash
podman-compose ps
```

### Execute commands inside the container:
```bash
podman exec -it ubi9-nginx bash
```

## Features

- ✅ Uses Red Hat UBI9 base image
- ✅ Runs as non-root user (nginx)
- ✅ Health checks enabled
- ✅ Volume mounts for easy content updates
- ✅ Proper nginx configuration
- ✅ Responsive web interface

## Customization

- **Change content**: Edit `index.html` and restart the service
- **Modify nginx config**: Edit `nginx.conf` and restart the service
- **Change port**: Modify the port mapping in `compose.yml`

## Troubleshooting

1. **Port already in use:**
   ```bash
   # Check what's using port 8080
   sudo netstat -tulpn | grep 8080
   
   # Use a different port in compose.yml
   ports:
     - "8081:80"
   ```

3. **Container not starting:**
   ```bash
   # Check logs
   podman-compose logs nginx
   
   # Check container status
   podman ps -a
   ```

[← Back to Podman Compose](../../../docs/podman-compose.md)
