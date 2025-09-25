# Playground

## Images
Build once, use anywhere

Podman image is a file which contains all necessary dependency and configurations which are required to run application


```
A Podman image is a lightweight, standalone, executable package that includes everything needed to run an application: code, runtime, system tools, libraries, and settings. It's essentially the same as a Docker image, since Podman is compatible with the Open Container Initiative (OCI) standard.

Key Characteristics:
- Immutable: Once built, the image content doesn't change
- Layered: Built in layers for efficient storage and sharing
- Portable: Runs consistently across different environments
- OCI-compliant: Compatible with Docker and other container runtimes

Image vs Container:
Image: The blueprint/template (like a class in programming)
Container: Running instance of an image (like an object)
```

```bash
# list images
podman image ls


```


## Containers
Docker containers is basically a running instance an image

## Volumes

## Kind
