#!/bin/bash

# Podman Pod Configuration Script
# This creates a Kubernetes-style pod with multiple containers

echo "🚀 Creating Podman pod: webapp-pod"

# Create the pod with shared network and storage
podman pod create \
    --name webapp-pod \
    --publish 8080:5000 \
    --publish 5432:5432 \
    --publish 6379:6379 \
    --share net,ipc,uts

echo "✅ Pod created successfully"

# Run the database container in the pod
echo "📊 Starting PostgreSQL container..."
podman run -d \
    --pod webapp-pod \
    --name webapp-db \
    -e POSTGRES_DB=webapp_db \
    -e POSTGRES_USER=webapp \
    -e POSTGRES_PASSWORD=secret \
    -v postgres-data:/var/lib/postgresql/data \
    docker.io/postgres:15-alpine

# Run the Redis container in the pod
echo "🔴 Starting Redis container..."
podman run -d \
    --pod webapp-pod \
    --name webapp-redis \
    -v redis-data:/data \
    docker.io/redis:7-alpine redis-server --appendonly yes

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run the web application container in the pod
echo "🌐 Starting webapp container..."
podman run -d \
    --pod webapp-pod \
    --name webapp-app \
    -e FLASK_ENV=production \
    -e DATABASE_URL=postgresql://webapp:secret@localhost:5432/webapp_db \
    -e REDIS_URL=redis://localhost:6379 \
    -v ./logs:/app/logs \
    localhost/webapp:latest

echo "✅ All containers started in pod: webapp-pod"
echo ""
echo "📋 Pod status:"
podman pod ps

echo ""
echo "📦 Containers in pod:"
podman ps --pod

echo ""
echo "🌐 Access the application at: http://localhost:8080"
