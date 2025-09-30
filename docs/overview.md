# Overview

[← Back to main page](./../README.md)

Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System.

## What is Podman?
Podman (Pod Manager) is a tool for managing containers and images, volumes mounted into those containers, and pods made from groups of containers. It's designed to be a drop-in replacement for Docker with some key architectural differences.

## Key Features

### Daemonless Architecture
No background daemon required (unlike Docker)
Containers run as child processes of Podman
Better security and resource management

### Rootless Containers
Run containers without root privileges
Enhanced security through user namespaces
Ideal for development environments

### Pod Support
Native Kubernetes-style pod support
Multiple containers sharing network and storage
Better container orchestration

### Docker Compatibility
Drop-in replacement for Docker CLI
Same commands: podman run, podman build, etc.
Compatible with Docker images and Dockerfiles

## Podman vs Docker
| Feature               | Podman               | Docker               |
|-----------------------|----------------------|----------------------|
| Architecture           | Daemonless           | Daemon-based         |
| Root Access            | Optional             | Required for daemon  |
| Security               | Rootless by default  | Root daemon          |
| Pods                   | Native support       | Requires compose/swarm|
| systemd Integration    | Built-in             | Third-party          |
| Kubernetes YAML        | Native support       | Limited              |
| Core Components        | Podman               | Docker               |

Podman represents the next generation of container technology, focusing on security, simplicity, and standards compliance while maintaining Docker compatibility for easy migration! 

[← Back to main page](./../README.md)
