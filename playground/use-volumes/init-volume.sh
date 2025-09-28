#!/bin/bash
# Initialize volumes with content

echo "🔧 Initializing Podman volumes..."

# Create volumes if they don't exist
podman volume create web-logs 2>/dev/null || echo "Volume web-logs already exists"
podman volume create web-content 2>/dev/null || echo "Volume web-content already exists"

# Copy index.html to web-content volume
echo "📄 Copying index.html to web-content volume..."
podman run --rm \
  -v web-content:/mnt/web-content:Z \
  -v $(pwd)/config:/host-config:Z \
  registry.access.redhat.com/ubi9/ubi:latest \
  cp /host-config/index.html /mnt/web-content/

# Set proper permissions
echo "🔐 Setting proper permissions..."
podman run --rm \
  -v web-content:/mnt/web-content:Z \
  registry.access.redhat.com/ubi9/ubi:latest \
  chmod 644 /mnt/web-content/index.html

echo "✅ Volume initialization complete!"
echo ""
echo "📋 Volume status:"
podman volume ls | grep -E "web-content|web-logs"
echo ""
echo "📁 Content in web-content volume:"
podman run --rm -v web-content:/mnt/web-content:Z registry.access.redhat.com/ubi9/ubi:latest ls -la /mnt/web-content/