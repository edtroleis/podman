# Run a simple container - Hello World

[← Back to Playground](../docs/playground.md)

## Create a Podman image
Inspect [Dockerfile](../playground/simple-container/Dockerfile)

### Build image
```bash
  cd ./playground/simple-container

  podman build -t hello-world .
```

### Show images
```bash
  podman image ls
```

### Run container
```bash
  podman container run --rm hello-world
```

[← Back to Playground](../docs/playground.md)
