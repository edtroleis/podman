# Containers - Advanced

[← Back to User Guide](./user-guide.md)

## Table of Contents
- [Working with Containers](#working-with-containers)
- [Volume Mounting](#volume-mounting)
- [Advanced Operations](#advanced-operations)

## Working with Containers

### List Containers
```bash
# show execution containers. Old version -> docker ps
podman container ls

# list all containers. Old version -> docker ps -a
podman container ls -a
```

### Create and Run Containers
```bash
# create and run a container, if image doesn't exit the image will be downloaded. Old version -> podman run
podman container run registry.access.redhat.com/ubi9/ubi:latest

# create and run a container with terminal. Old version -> podman run -it
podman container run -it registry.access.redhat.com/ubi9/ubi:latest /bin/bash

# create and run a container with terminal and remove the container once it is stopped. Old version -> podman run --rm -it
podman container run --rm -it registry.access.redhat.com/ubi9/ubi:latest /bin/bash

# create and run a container as a daemon (background). Old version -> podman run -d
podman container run -d -p 8080:8080 --name ubi-nginx-container ubi-nginx:latest

# create and run a container with bind volume mount
mkdir -p ./nginx-content
echo '<h1>Custom Content</h1>' > ./nginx-content/index.html
podman container run -d -p 8080:8080 --name ubi-nginx-container \
  -v $(pwd)/nginx-content:/usr/share/nginx/html:Z \
  ubi-nginx:latest

# create and run a container with multiple bind volumes
podman container run -d -p 8080:8080 --name ubi-nginx-container \
  -v $(pwd)/nginx-content:/usr/share/nginx/html:Z \
  -v $(pwd)/nginx-logs:/var/log/nginx:Z \
  ubi-nginx:latest

# create a container and set resource limit to the container
podman container run -d -p 8080:8080 -m 128M --cpus 0.5 --name ubi-nginx-container ubi-nginx:latest
```

### Manage Containers
```bash
# start a container
podman container start ubi-nginx-container

# show container logs
podman container logs ubi-nginx-container

# execute a command in a running container
podman container exec -ti ubi-nginx-container /bin/bash

# only create the container
podman container create registry.access.redhat.com/ubi9/ubi:latest

# stop all running containers
podman container stop --all

# remove all containers
podman container rm --all

# volume will be removed automatically once the container has exited
podman run --rm -v /foo busybox

# create, run and set resource limit to the container
podman container run -d -m 128M --cpus 0.5 nginx

# only create the container
podman container create ubuntu

# run a command in a running container
podman container exec -ti CONTAINER_ID COMMAND
podman container exec -it CONTAINER_ID /bin/bash

# run container and attach host port 8080 with container port 80
podman container run -d -p 8080:80 apache:1.0.0

# run container using container expose port and attach with host random port
podman container run -it -P
```

### Remove all containers (various methods)
```bash
# remove all stopped containers
podman container rm --all

# stop all running containers first
podman container stop --all

# force remove all containers (running and stopped)
podman container rm --all --force

# remove all stopped containers
podman container prune

# remove all unused containers, networks, images (with prompt)
podman system prune

# remove everything unused without prompt
podman system prune --all --force
```

## Volume Mounting

### Bind Volumes
```bash
# Prepare content directory
mkdir -p ./nginx-content
echo '<h1>Hello from Bind Volume!</h1>' > ./nginx-content/index.html

# Basic bind volume mount
podman container run -d -p 8080:8080 --name web-server \
  -v $(pwd)/nginx-content:/usr/share/nginx/html:Z \
  ubi-nginx:latest

# Bind mount with different host paths
podman container run -d -p 8080:8080 --name web-server \
  -v /home/user/content:/usr/share/nginx/html:Z \
  ubi-nginx:latest

# Read-only bind mount
podman container run -d -p 8080:8080 --name web-server \
  -v $(pwd)/nginx-content:/usr/share/nginx/html:ro,Z \
  ubi-nginx:latest

# Multiple bind mounts
mkdir -p ./nginx-logs ./nginx-config
podman container run -d -p 8080:8080 --name web-server \
  -v $(pwd)/nginx-content:/usr/share/nginx/html:Z \
  -v $(pwd)/nginx-logs:/var/log/nginx:Z \
  -v $(pwd)/nginx-config:/etc/nginx/conf.d:ro,Z \
  ubi-nginx:latest
```

### Named Volumes
```bash
# Create a named volume
podman volume create nginx-data

# Use named volume
podman container run -d -p 8080:8080 --name web-server \
  -v nginx-data:/usr/share/nginx/html \
  ubi-nginx:latest

# Multiple named volumes
podman volume create nginx-data nginx-logs nginx-config
podman container run -d -p 8080:8080 --name web-server \
  -v nginx-data:/usr/share/nginx/html \
  -v nginx-logs:/var/log/nginx \
  -v nginx-config:/etc/nginx/conf.d \
  ubi-nginx:latest
```

### Mount Options
```bash
# :Z - Relabel shared volume content to match the container's SELinux context
# :z - Relabel private volume content to match the container's SELinux context  
# :ro - Read-only mount
# :rw - Read-write mount (default)

# Example with all options
podman container run -d -p 8080:8080 --name web-server \
  -v /tmp/data:/app/data:rw,Z \
  -v /tmp/config:/app/config:ro,Z \
  ubi-nginx:latest
```

## Advanced Operations
```bash
# Commit running container to new image
podman commit container_name new_image:latest

# Create image from changes in container
podman diff container_name
podman commit -m "Added custom config" container_name myapp:v2

# Copy files from image without running container
podman run --rm -v $(pwd):/host image:tag cp /app/file /host/
```

[← Back to User Guide](./user-guide.md)
