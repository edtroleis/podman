# Images and Containers

[← Back to User Guide](./user-guide.md)

## Table of Contents
- [Overview](#overview)
- [Create a Podman image](#create-a-podman-image)
- [Working with Images and Containers](#working-with-images-and-containers)
- [Best Practices](#best-practices)

## Overview

Build once, use anywhere.

Podman image is a file which contains all necessary dependency and configurations which are required to run application

A Podman image is a lightweight, standalone, executable package that includes everything needed to run an application: code, runtime, system tools, libraries, and settings. It's essentially the same as a Docker image, since Podman is compatible with the Open Container Initiative (OCI) standard.

Key Characteristics:
- Immutable: Once built, the image content doesn't change
- Layered: Built in layers for efficient storage and sharing
- Portable: Runs consistently across different environments
- OCI-compliant: Compatible with Docker and other container runtimes

Image vs Container:
- Image: The blueprint/template (like a class in programming)
- Container: Running instance of an image (like an object)

## Working with Images and Containers

### Create a Podman image

```bash
  # create image
  podman build -t ImageName:Tag .

  # create image without using cache
  podman build -t ImageName:Tag . --no-cache
```

### Show images
```bash
  podman image ls
  podman image ls | grep ImageName:Tag
```

### Run a container
```bash
  podman container run -d -p PortFromMyComputer:PortContainer --name ContainerName ImageName:Tag

  podman container run -d -p 8080:80 --name ContainerName ImageName:Tag
```

### Show running containers
```bash
  podman container ls
  podman container ls -a
```

### Stop containers
```bash
podman container stop ContainerName
```

### Remove containers
```bash
podman container rm ContainerName

podman container rm -f ContainerName   # force remove
```

### Remove images
```bash
# Remove by specific image
podman image rm ImageName:Tag

# Remove by image ID
podman image rm abc123def456

# Force removal (even if containers are using it)
podman image rm -f ImageName:Tag

# Remove unused images
podman image prune

# Remove all unused images (dangling and unused)
podman image prune -a
```

### Inspect images and details
```bash
# Show layer hierarchy in tree format
podman image tree localhost/ImageName:Tag

# Show history/layers with commands that created them
podman image history localhost/ImageName:Tag

# Show layer SHA256 hashes
podman image inspect localhost/ImageName:Tag --format='{{.RootFS.Layers}}'

# Inspect full image metadata in JSON
podman image inspect localhost/ImageName:Tag --format='{{json .RootFS}}'
podman image inspect localhost/ImageName:Tag
podman image inspect localhost/ImageName:Tag --format='{{.Id}}'
podman image inspect localhost/ImageName:Tag --format='{{json .Config}}'
podman image inspect localhost/ImageName:Tag --format='{{.Config.User}}'
podman image inspect localhost/ImageName:Tag --format='{{.Config.ExposedPorts}}'

# Get detailed about digests
podman images --digests
```

### Tagging Images
```bash
# Create additional tag for existing image
podman tag localhost/ImageName:Tag registry.example.com/ImageName:1.0.0
```

### Pushing Images
```bash
# Push to registry (requires login)
podman login registry.example.com
podman push registry.example.com/ImageName:Tag
```

### Flattening Podman images

```bash
# Create and run a container from the image
podman run --name ContainerName localhost/ImageName:Tag

# Export the container to a tar file (flattens all layers)
podman export ContainerName > Export-ContainerName.tar

# Verify the tar file
ls -lh Export-ContainerName.tar

# Import the tar file as a new image
cat Export-ContainerName.tar | podman import - My-ImageName:Tag

# Verify the new flattened image
podman image ls | grep -E "(ImageName|My-ImageName)"

# Compare the image trees of the original and flattened images
podman image tree ImageName:Tag
podman image tree My-ImageName:Tag

# Clean up the temporary container
podman stop ContainerName && podman rm ContainerName

# Remove the tar file if no longer needed
rm Export-ContainerName.tar
```

### Images import/export
```bash
# Save one or more images to a tar file
podman save localhost/ImageName:tag > /tmp/Export-ImageName.tar

# Load an image from a tar file
podman load < /tmp/Export-ImageName.tar

# Alternative: Load and tag in one command
podman load local/My-Import-ImageName:Tag < /tmp/Export-ImageName.tar

# If you need to tag the loaded image with a different name
podman tag localhost/My-Import-ImageName:tag my-registry.com/New-ImageName:Tag

# Check the loaded image
podman image ls | grep New-ImageName

# Clean up the tar file after loading
rm /tmp/Export-ImageName.tar
```

### Working with Image Registries
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

### Filter images
```bash
podman image ls --filter "dangling=false"
```

## Best Practices

### Image Naming
- Use descriptive names: `webapp:v1.0` not `img1`
- Include version tags: `myapp:1.0.0`, `myapp:latest`
- Use registry prefixes: `registry.com/team/app:tag`

### Image Size Optimization:
- Use minimal base images (Alpine, scratch)
- Multi-stage builds to reduce final size
- Remove package caches: `RUN apt-get clean`
- Use .containerignore files

### Security
- Regular image updates: `podman pull image:latest`
- Scan for vulnerabilities: `podman run --rm quay.io/security/scanner`
- Use official/verified images when possible
- Don't run as root user in containers

### Organization:
- Tag images consistently
- Use semantic versioning
- Clean up old images regularly
- Document image contents and usage

[← Back to User Guide](./user-guide.md)
