# Running a web server container - Nginx

[← Back to Playground](../docs/playground.md)


### Inspect Dockerfile
- [Dockerfile](../playground/web-server/Dockerfile)

### Build image
```bash
  cd ./playground/web-server

  # create image
  podman build -t web-server:latest .

  # create image without using cache
  podman build -t web-server:latest . --no-cache 
```

### Show images
```bash
  podman image ls | grep web-server
```

### Run container
```bash
  podman container run -d -p 8080:8080 --name web-server-container web-server:latest
```
- Show running containers
```bash
  podman container ps
```

### View nginx page (running container)
```
curl http://localhost:8080

# For browser access, open:
# http://localhost:8080
```

### Stop container
```bash
podman stop web-server-container
```

### List all containers (including stopped)
```bash
podman container ps -a
```

### Remove container
```bash
podman container rm web-server-container
```

### Remove image
```bash
# Remove by image name
podman image rm web-server:latest

# Remove by image ID
podman image rm ID_OF_IMAGE
```

[← Back to Playground](../docs/playground.md)
