#!/bin/bash

# Podman Helper Scripts
# Common operations for managing containers and pods

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to build the webapp image
build_image() {
    print_status "Building webapp image..."
    podman build -t localhost/webapp:latest -f Containerfile .
    print_success "Image built successfully"
}

# Function to run a single container
run_container() {
    print_status "Running webapp container..."
    podman run -d \
        --name webapp-standalone \
        -p 5000:5000 \
        -e FLASK_ENV=development \
        localhost/webapp:latest
    print_success "Container started at http://localhost:5000"
}

# Function to start compose services
start_compose() {
    print_status "Starting services with docker-compose..."
    podman-compose up -d
    print_success "All services started"
}

# Function to stop compose services
stop_compose() {
    print_status "Stopping docker-compose services..."
    podman-compose down
    print_success "All services stopped"
}

# Function to create and start pod
start_pod() {
    print_status "Creating and starting pod..."
    ./create-pod.sh
}

# Function to stop and remove pod
stop_pod() {
    print_status "Stopping and removing pod..."
    podman pod stop webapp-pod 2>/dev/null || true
    podman pod rm webapp-pod 2>/dev/null || true
    print_success "Pod removed"
}

# Function to show status
show_status() {
    print_status "Current Podman status:"
    echo ""
    echo "🖼️  Images:"
    podman images | head -10
    echo ""
    echo "📦 Containers:"
    podman ps -a
    echo ""
    echo "🏗️  Pods:"
    podman pod ps
    echo ""
    echo "🗄️  Volumes:"
    podman volume ls
    echo ""
    echo "🌐 Networks:"
    podman network ls
}

# Function to cleanup everything
cleanup() {
    print_warning "This will remove all containers, pods, and unused images"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        
        # Stop and remove all containers
        podman container stop --all 2>/dev/null || true
        podman container rm --all 2>/dev/null || true
        
        # Stop and remove all pods
        podman pod stop --all 2>/dev/null || true
        podman pod rm --all 2>/dev/null || true
        
        # Remove unused images
        podman image prune -f
        
        # Remove unused volumes
        podman volume prune -f
        
        print_success "Cleanup completed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Function to show logs
show_logs() {
    local container_name=${1:-webapp-standalone}
    print_status "Showing logs for $container_name..."
    podman logs -f $container_name
}

# Main menu
case "${1:-help}" in
    build)
        build_image
        ;;
    run)
        build_image
        run_container
        ;;
    compose-up)
        start_compose
        ;;
    compose-down)
        stop_compose
        ;;
    pod-start)
        build_image
        start_pod
        ;;
    pod-stop)
        stop_pod
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    cleanup)
        cleanup
        ;;
    help|*)
        echo "🐋 Podman Helper Script"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  build        - Build the webapp image"
        echo "  run          - Build and run single container"
        echo "  compose-up   - Start all services with docker-compose"
        echo "  compose-down - Stop all services"
        echo "  pod-start    - Create and start pod"
        echo "  pod-stop     - Stop and remove pod"
        echo "  status       - Show current status"
        echo "  logs [name]  - Show container logs"
        echo "  cleanup      - Remove all containers and unused images"
        echo "  help         - Show this help"
        ;;
esac
