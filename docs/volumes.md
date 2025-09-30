# Podman Volumes

[← Back to Playground](../playground.md)

## Table of Contents
- [Why Use Volumes?](#why-use-volumes)
- [Volume Mount Options](#volume-mount-options)
- [Volume Performance Tips](#volume-performance-tips)
- [Playground - Using Volumes](use-volumes.md)

## Why Use Volumes?

1. Data Persistence
Survive container lifecycle: Data persists even when containers are stopped, removed, or recreated
Stateful applications: Essential for databases, logs, user data, and application state
Updates and rollbacks: Maintain data integrity during application updates
2. Data Sharing
Multi-container access: Multiple containers can read/write to the same volume
Microservices communication: Share data between different services
Backup and restore: Centralized data management across container instances
3. Performance Optimization
Native filesystem: Better I/O performance compared to bind mounts
Container layer bypass: Direct access to host storage without container filesystem overhead
Reduced image size: Keep large datasets separate from container images
4. Security and Isolation
Controlled access: Podman manages volume permissions and SELinux contexts
Isolation: Separate application logic from data storage
Root/rootless compatibility: Works seamlessly in both execution modes

### Podman supports three main types of volume mounts:

1. **Named Volumes**: Managed by Podman, stored in Podman's storage area
2. **Bind Mounts**: Direct mapping from host filesystem to container
3. **tmpfs Mounts**: Temporary filesystem in memory

## Volume Mount Options

### SELinux Context Options
- `:Z` - Relabel shared volume content to match the container's SELinux context
- `:z` - Relabel private volume content to match the container's SELinux context

### Access Mode Options  
- `:ro` - Read-only mount
- `:rw` - Read-write mount (default)

### Other Options
- `:nodev` - Do not interpret character/block special devices
- `:nosuid` - Do not allow set-user-ID or set-group-ID bits
- `:noexec` - Do not allow execution of binaries

## Volume Performance Tips

1. **Use named volumes for better performance** than bind mounts
2. **Use :Z or :z SELinux labels** on SELinux-enabled systems
3. **Avoid mounting large directory trees** as bind mounts
4. **Use tmpfs for temporary data** that doesn't need persistence
5. **Regular cleanup** of unused volumes to save disk space

[← Back to Playground](../playground.md)
