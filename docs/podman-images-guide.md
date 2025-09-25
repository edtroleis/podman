# Podman Image Management Guide

## 📥 **Pulling Images**
```bash
# Pull from Docker Hub
podman pull nginx:alpine
podman pull python:3.11-slim

# Pull from Red Hat Registry
podman pull registry.redhat.io/rhel8/httpd-24

# Pull from Quay.io
podman pull quay.io/podman/hello:latest
```

## 🔍 **Listing Images**
```bash
# List all local images
podman images

# List images with specific format
podman images --format "table {{.Repository}} {{.Tag}} {{.Size}}"

# List images by repository
podman images python
```

## 🏗️ **Building Images**
```bash
# Build from Containerfile in current directory
podman build -t myapp:latest .

# Build with custom Containerfile name
podman build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
podman build --build-arg VERSION=1.0 -t myapp:v1.0 .
```

## 📊 **Inspecting Images**
```bash
# Get detailed information about an image
podman inspect nginx:alpine

# View image layers
podman history nginx:alpine

# Check image size and details
podman images --digests
```

## 🏷️ **Tagging Images**
```bash
# Create additional tag for existing image
podman tag myapp:latest myapp:v1.0
podman tag myapp:latest localhost/myapp:latest

# Tag for registry push
podman tag myapp:latest registry.example.com/myapp:latest
```

## 📤 **Pushing Images**
```bash
# Push to registry (requires login)
podman login registry.example.com
podman push registry.example.com/myapp:latest

# Push to Docker Hub
podman login docker.io
podman push docker.io/username/myapp:latest
```

## 🗑️ **Removing Images**
```bash
# Remove specific image
podman rmi nginx:alpine

# Remove by image ID
podman rmi abc123def456

# Remove unused images
podman image prune

# Remove all unused images (dangling and unused)
podman image prune -a

# Force removal (even if containers are using it)
podman rmi -f myapp:latest
```

## 🔄 **Image Import/Export**
```bash
# Save image to tar file
podman save -o myapp.tar myapp:latest

# Load image from tar file
podman load -i myapp.tar

# Export container as image
podman export container_name > container.tar
podman import container.tar imported_image:latest
```

## 🏷️ **Working with Image Registries**
```bash
# Login to registry
podman login docker.io
podman login registry.redhat.io
podman login quay.io

# Search for images
podman search nginx
podman search --limit 5 python

# Logout from registry
podman logout docker.io
```

## 📋 **Image Information**
```bash
# Show image layers and commands
podman history myapp:latest

# Get image metadata
podman inspect --format '{{.Config.Cmd}}' nginx:alpine

# Show image creation date
podman inspect --format '{{.Created}}' nginx:alpine

# Show image architecture
podman inspect --format '{{.Architecture}}' nginx:alpine
```

## 🔧 **Advanced Operations**
```bash
# Commit running container to new image
podman commit container_name new_image:latest

# Create image from changes in container
podman diff container_name
podman commit -m "Added custom config" container_name myapp:v2

# Copy files from image without running container
podman run --rm -v $(pwd):/host image:tag cp /app/file /host/
```

## 📈 **Best Practices**

### **Image Naming:**
- Use descriptive names: `webapp:v1.0` not `img1`
- Include version tags: `myapp:1.0.0`, `myapp:latest`
- Use registry prefixes: `registry.com/team/app:tag`

### **Image Size Optimization:**
- Use minimal base images (Alpine, scratch)
- Multi-stage builds to reduce final size
- Remove package caches: `RUN apt-get clean`
- Use .containerignore files

### **Security:**
- Regular image updates: `podman pull image:latest`
- Scan for vulnerabilities: `podman run --rm quay.io/security/scanner`
- Use official/verified images when possible
- Don't run as root user in containers

### **Organization:**
- Tag images consistently
- Use semantic versioning
- Clean up old images regularly
- Document image contents and usage