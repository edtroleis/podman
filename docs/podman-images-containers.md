# Images and Containers
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

### Create a Podman image
- [Dockerfile](../playground/ex-001-rhel-nginx/Dockerfile)
- Build image
```bash
  cd ./playground/ex-001-rhel-nginx

  # create image
  podman build -t ubi-nginx:latest .

  # create image without using cache
  podman build -t ubi-nginx:latest . --no-cache 
```

### Show images
```bash
  podman image ls
```

### Run container
```bash
  podman container run -d -p 8080:8080 --name ubi-nginx-container ubi-nginx:latest
```
- Show running containers
```bash
  podman ps
```

- Stop container
```bash
podman stop ubi-nginx-container
```

- Remove container
```bash
podman rm ubi-nginx-container
```

# View nginx page (running container)
```
curl http://localhost:8080

# For browser access, open:
# http://localhost:8080
```

### Remove images

```bash
# Remove by specific image
podman image rm ubi-nginx:latest

# Remove by image ID
podman image rm abc123def456

# Remove by specific image
podman rmi ubi-nginx:latest

# Remove by image ID
podman rmi abc123def456

# Remove unused images
podman image prune

# Remove all unused images (dangling and unused)
podman image prune -a

# Force removal (even if containers are using it)
podman rmi -f myapp:latest
```

## Inspect images and details
```bash
# Show layer hierarchy in tree format
podman image tree localhost/ubi-nginx:latest

# Show history/layers with commands that created them
podman image history localhost/ubi-nginx:latest

# Show layer SHA256 hashes
podman image inspect localhost/ubi-nginx:latest --format='{{.RootFS.Layers}}'

# Inspect full image metadata in JSON
podman image inspect localhost/ubi-nginx:latest --format='{{json .RootFS}}'
podman image inspect localhost/ubi-nginx:latest
podman image inspect localhost/ubi-nginx:latest --format='{{.Id}}'
podman image inspect localhost/ubi-nginx:latest --format='{{json .Config}}'
podman image inspect localhost/ubi-nginx:latest --format='{{.Config.User}}'
podman image inspect localhost/ubi-nginx:latest --format='{{.Config.ExposedPorts}}'

# Get detailed about digests
podman images --digests
```

## Tagging Images
```bash
# Create additional tag for existing image
podman tag localhost/ubi-nginx:latest registry.example.com/ubi-nginx:latest:1.0.0
```

## Pushing Images
```bash
# Push to registry (requires login)
podman login registry.example.com
podman push registry.example.com/ubi-nginx:latest

# Push to Docker Hub
podman login docker.io
podman push docker.io/username/ubi-nginx:latest
```

## Flattening Podman images

```bash
# Create and run a container from the image
podman run --name ubi-nginx-temp localhost/ubi-nginx:latest

# Export the container to a tar file (flattens all layers)
podman export ubi-nginx-temp > ubi-nginx-flattened.tar

# Verify the tar file
ls -lh ubi-nginx-flattened.tar

# Import the tar file as a new image
cat ubi-nginx-flattened.tar | podman import - my-ubi-nginx:latest

# Verify the new flattened image
podman image ls | grep -E "(ubi-nginx|my-ubi-nginx)"

# Compare the image trees of the original and flattened images
podman image tree ubi-nginx:latest
podman image tree my-ubi-nginx:latest

# Clean up the temporary container
podman stop ubi-nginx-temp && podman rm ubi-nginx-temp

# Remove the tar file if no longer needed
rm ubi-nginx-flattened.tar
```

## Images import/export
```bash
# Save one or more images to a tar file
podman save localhost/ubi-nginx:latest > /tmp/export-image-ubi-nginx.tar

# Load an image from a tar file
podman load < /tmp/export-image-ubi-nginx.tar

# Alternative: Load and tag in one command
podman load < /tmp/export-image-ubi-nginx.tar

# If you need to tag the loaded image with a different name
podman tag localhost/ubi-nginx:latest my-registry.com/ubi-nginx:v1.0

# Check the loaded image
podman image ls | grep ubi-nginx

# Clean up the tar file after loading
rm /tmp/export-image-ubi-nginx.tar
```

## Working with Image Registries
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

# Filter images
```
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
