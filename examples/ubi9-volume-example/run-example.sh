#!/bin/bash

# UBI 9 Volume Example - Usage Script
echo "=== UBI 9 Volume Example Usage ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Build the image
print_step "Building UBI 9 volume example image..."
podman build -t ubi9-volume-example:latest .

if [ $? -ne 0 ]; then
    print_error "Failed to build image"
    exit 1
fi

# Step 2: Create named volumes
print_step "Creating named volumes..."
podman volume create ubi9-app-data
podman volume create ubi9-app-logs  
podman volume create ubi9-app-config

# Step 3: Show volume information
print_step "Volume information:"
podman volume ls | grep ubi9-app

# Step 4: Run container with volumes (first time)
print_step "Running container for the first time..."
podman run --rm \
    --name ubi9-volume-demo \
    -v ubi9-app-data:/app/data \
    -v ubi9-app-logs:/app/logs \
    -v ubi9-app-config:/app/config \
    ubi9-volume-example:latest

print_info "First run completed. Data should be initialized."

# Step 5: Run container again to show persistence
print_step "Running container again to demonstrate data persistence..."
podman run --rm \
    --name ubi9-volume-demo-2 \
    -v ubi9-app-data:/app/data \
    -v ubi9-app-logs:/app/logs \
    -v ubi9-app-config:/app/config \
    ubi9-volume-example:latest

print_info "Second run completed. Notice how data persisted!"

# Step 6: Inspect volume contents
print_step "Inspecting volume contents directly..."

# Create a temporary container to explore volumes
print_info "Creating temporary container to explore volume contents..."
podman run -it --rm \
    --name volume-explorer \
    -v ubi9-app-data:/mnt/data \
    -v ubi9-app-logs:/mnt/logs \
    -v ubi9-app-config:/mnt/config \
    registry.access.redhat.com/ubi9/ubi:latest \
    bash -c "
        echo 'Volume Contents:';
        echo '=== Data Volume ===';
        ls -la /mnt/data;
        echo '';
        echo '=== Logs Volume ===';
        ls -la /mnt/logs;
        echo '';
        echo '=== Config Volume ===';
        ls -la /mnt/config;
        cat /mnt/config/app.conf 2>/dev/null || echo 'No config file found';
    "

# Step 7: Optional - run in daemon mode
read -p "Do you want to run the container in daemon mode? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Running container in daemon mode..."
    print_info "Container will run in background and update logs every 30 seconds"
    print_info "Use 'podman logs -f ubi9-daemon' to follow logs"
    print_info "Use 'podman stop ubi9-daemon' to stop the container"
    
    podman run -d \
        --name ubi9-daemon \
        -v ubi9-app-data:/app/data \
        -v ubi9-app-logs:/app/logs \
        -v ubi9-app-config:/app/config \
        ubi9-volume-example:latest \
        --daemon
        
    sleep 2
    print_info "Daemon container started. Showing initial logs..."
    podman logs ubi9-daemon
fi

print_step "Example completed!"
print_info "Volumes created: ubi9-app-data, ubi9-app-logs, ubi9-app-config"
print_info "Use 'podman volume ls | grep ubi9' to see volumes"
print_info "Use 'podman volume rm ubi9-app-data ubi9-app-logs ubi9-app-config' to clean up"