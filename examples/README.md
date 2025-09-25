# Podman Examples

This directory contains comprehensive examples of using Podman for container management and deployment.

## 🚀 Quick Start

### Option 1: Single Container
```bash
cd examples/webapp
./podman-helper.sh run
```
Access: http://localhost:5000

### Option 2: Docker Compose (Multi-container)
```bash
cd examples/webapp
./podman-helper.sh compose-up
```
Access: http://localhost:80

### Option 3: Podman Pod (Kubernetes-style)
```bash
cd examples/webapp
./podman-helper.sh pod-start
```
Access: http://localhost:8080

## 📁 File Structure

```
examples/webapp/
├── Containerfile           # Container image definition
├── docker-compose.yml      # Multi-container setup
├── create-pod.sh          # Podman pod creation script
├── podman-helper.sh       # Helper script for all operations
├── app.py                 # Python Flask web application
├── requirements.txt       # Python dependencies
├── init.sql              # Database initialization
├── nginx.conf            # Nginx reverse proxy config
└── templates/
    └── index.html        # Web application template
```

## 🐋 Container Technologies Demonstrated

### 1. **Containerfile**
- Multi-stage builds
- Non-root user security
- Health checks
- Proper layer caching

### 2. **Docker Compose**
- Multi-container applications
- Service dependencies
- Persistent volumes
- Custom networks
- Environment variables

### 3. **Podman Pods**
- Kubernetes-style pods
- Shared networking
- Container lifecycle management
- Port mapping

## 🛠️ Helper Script Usage

The `podman-helper.sh` script provides easy management:

```bash
# Build image
./podman-helper.sh build

# Run single container
./podman-helper.sh run

# Start compose services
./podman-helper.sh compose-up

# Stop compose services
./podman-helper.sh compose-down

# Start pod
./podman-helper.sh pod-start

# Stop pod
./podman-helper.sh pod-stop

# Show status
./podman-helper.sh status

# Show logs
./podman-helper.sh logs [container-name]

# Cleanup everything
./podman-helper.sh cleanup

# Show help
./podman-helper.sh help
```

## 🗄️ Services Included

### Web Application (Flask)
- **Port**: 5000 (container), 8080 (pod), 80 (compose)
- **Features**: 
  - Visitor counter with Redis
  - Database connectivity check
  - Health check endpoint (`/health`)
  - System info endpoint (`/info`)

### PostgreSQL Database
- **Port**: 5432
- **Credentials**: 
  - Database: `webapp_db`
  - User: `webapp`
  - Password: `secret`

### Redis Cache
- **Port**: 6379
- **Purpose**: Session storage and caching

### Nginx Reverse Proxy (Compose only)
- **Port**: 80
- **Purpose**: Load balancing and SSL termination

## 🔧 Development Workflow

### 1. Development Mode
```bash
# Run with hot reload
export FLASK_ENV=development
./podman-helper.sh run
```

### 2. Production Mode
```bash
# Full stack with compose
./podman-helper.sh compose-up
```

### 3. Kubernetes-style Deployment
```bash
# Pod deployment
./podman-helper.sh pod-start
```

## 📊 Monitoring and Health

### Health Check Endpoints
- `/health` - Application health status
- `/info` - Container and environment information

### Monitoring Commands
```bash
# Container stats
podman stats

# Container logs
podman logs -f webapp-standalone

# Pod status
podman pod ps
```

## 🔒 Security Features

- **Non-root containers**: All containers run as non-root users
- **Minimal base images**: Using Alpine and slim variants
- **Health checks**: Automatic container health monitoring
- **Network isolation**: Custom networks for service communication

## 🚨 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   sudo netstat -tulpn | grep :5000
   ./podman-helper.sh cleanup
   ```

2. **Database connection failed**
   ```bash
   # Check if PostgreSQL is running
   podman ps | grep postgres
   
   # Check logs
   ./podman-helper.sh logs webapp-db
   ```

3. **Permission denied**
   ```bash
   # Make scripts executable
   chmod +x *.sh
   ```

## 📝 Customization

### Environment Variables
- `FLASK_ENV`: development/production
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string

### Volumes
- `./logs`: Application logs
- `postgres_data`: Database persistent storage
- `redis_data`: Redis persistent storage

## 🔄 CI/CD Integration

The Containerfile and scripts are ready for CI/CD integration:

```bash
# Build and test
podman build -t webapp:test .
podman run --rm webapp:test python -m pytest

# Deploy
podman tag webapp:test registry.example.com/webapp:latest
podman push registry.example.com/webapp:latest
```

## 📚 Learn More

- [Podman Official Documentation](https://docs.podman.io/)
- [Container Best Practices](https://docs.podman.io/en/latest/Tutorials.html)
- [Pod Management](https://docs.podman.io/en/latest/pods.html)
