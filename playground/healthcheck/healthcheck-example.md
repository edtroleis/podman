# Health Check Example

```bash
# Build the image with Docker format (required for HEALTHCHECK)
podman build -t healthcheck:latest --format docker .

# Run the container
podman run --rm -d -p 8080:8080 --name test-health healthcheck:latest

# Check health status
podman inspect test-health --format='{{.State.Health.Status}}'


# Test the web server
curl http://localhost:8080

# Clean up
podman container stop test-health
```
