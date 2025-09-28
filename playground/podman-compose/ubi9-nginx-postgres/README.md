# Podman Compose Setup with UBI9

This project demonstrates a complete containerized application setup using Podman Compose with custom images based on Red Hat's Universal Base Image 9 (UBI9).

## Container Management with podman-compose

When using `podman-compose`, containers are managed differently than standalone podman containers. Here are the correct commands to check and manage your containers:

**✅ Recommended Commands:**
```bash
# Check container status (preferred method)
podman-compose ps

# View logs for all services
podman-compose logs

# View logs for specific service
podman-compose logs database
podman-compose logs nginx-app

# Stop all services
podman-compose down

# Restart services
podman-compose restart
```

**⚠️ Note:** Regular `podman ps` may not show podman-compose containers due to different storage contexts or remote service configuration. Always use `podman-compose ps` for reliable container status.

## Architecture

- **Web Server**: Nginx running on UBI9 base image
- **Database**: PostgreSQL running on UBI9 base image
- **Volumes**: Persistent storage for database data and nginx logs
- **Network**: Custom bridge network for service communication

## Directory Structure

```
.
├── docker-compose.yml          # Main compose file
├── nginx/
│   └── Dockerfile             # Nginx container image
├── postgres/
│   ├── Dockerfile             # PostgreSQL container image
│   └── docker-entrypoint.sh   # PostgreSQL initialization script
├── config/
│   ├── nginx.conf             # Main nginx configuration
│   ├── default.conf           # Nginx virtual host configuration
│   ├── postgresql.conf        # PostgreSQL server configuration
│   └── pg_hba.conf           # PostgreSQL authentication configuration
├── init/
│   └── 01-init.sql           # Database initialization SQL
├── html/
│   └── index.html            # Custom web page
└── README.md                 # This file
```

## Prerequisites

- Podman installed on your system
- Podman Compose plugin (or podman-compose)

## Quick Start

1. **Clone or create the directory structure** with all the files provided above.

2. **Build and start the services**:
   ```bash
   podman-compose up --build -d
   ```

3. **Access the application**:
   - Web application: http://localhost:8080
   - PostgreSQL: localhost:5432 (connect as postgres user)
   - Database connection test: `nc -z localhost 5432`

## Services Details

### Nginx Service
- **Base Image**: registry.access.redhat.com/ubi9/ubi:latest
- **Port**: 8080 (host) → 80 (container)
- **Volumes**:
  - Configuration files mounted from `./config/`
  - HTML files mounted from `./html/`
  - Logs persisted in named volume `nginx-logs`

### PostgreSQL Service
- **Base Image**: registry.access.redhat.com/ubi9/ubi:latest
- **PostgreSQL Version**: 15 (installed from official PostgreSQL repository)
- **Port**: 5432 (host) → 5432 (container)
- **Database**: appdb
- **User**: appuser
- **Password**: apppass
- **Data Path**: /var/lib/pgsql/15/data
- **Volumes**:
  - Configuration files mounted from `./config/`
  - Initialization scripts mounted from `./init/`
  - Data persisted in named volume `postgres-data`

## PostgreSQL Implementation Details

This setup uses **PostgreSQL 15** installed from the official PostgreSQL repository on UBI9:

- **Repository**: https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
- **Installation**: `postgresql15-server` and `postgresql15-contrib` packages
- **Binary Path**: `/usr/pgsql-15/bin/`
- **Data Directory**: `/var/lib/pgsql/15/data`
- **Configuration**: Custom postgresql.conf with corrected `log_statement = 'all'`

### Why This Approach?

- UBI9 base repositories don't include PostgreSQL without Red Hat subscription
- Official PostgreSQL repository provides reliable, up-to-date packages
- No registration or subscription required
- Full PostgreSQL 15 feature set available

## Configuration Files

All configuration is externalized and mounted as volumes:

- **nginx.conf**: Main Nginx configuration with security settings
- **default.conf**: Virtual host configuration with gzip and caching
- **postgresql.conf**: PostgreSQL server configuration
- **pg_hba.conf**: PostgreSQL client authentication
- **01-init.sql**: Database initialization with sample data

## Management Commands

```bash
# Check container status (always use this instead of 'podman ps')
podman-compose ps

# Start services
podman-compose up -d

# Start with rebuild
podman-compose up --build -d

# View logs for all services
podman-compose logs

# View logs for specific service
podman-compose logs database
podman-compose logs nginx-app

# Follow logs in real-time
podman-compose logs -f

# Stop services
podman-compose down

# Stop and remove everything including volumes
podman-compose down -v

# Rebuild images
podman-compose build

# Restart specific service
podman-compose restart database

# Scale services (if needed)
podman-compose up --scale nginx-app=2

# Execute commands in running containers
podman-compose exec database psql -h localhost -U postgres -d appdb
podman-compose exec nginx-app nginx -t

# Connect to database (use postgres user due to authentication setup)
podman-compose exec database psql -h localhost -U postgres -d appdb

# Test database connection from outside
nc -z localhost 5432 && echo "PostgreSQL is accessible"
```

## Why podman-compose ps vs podman ps?

`podman-compose` creates containers with specific labels and may use different storage contexts. The containers exist but might not be visible to regular `podman ps` due to:

- **Remote Podman service**: If Podman is running as a service
- **Different storage backends**: Containers may use different storage locations
- **Label filtering**: `podman-compose` uses specific labels to identify its containers

**Always use `podman-compose ps` to check containers created by podman-compose.**

## Volumes

- **postgres-data**: Persistent PostgreSQL data storage
- **nginx-logs**: Persistent Nginx access and error logs

## Network

Services communicate through a custom bridge network `app-network`, providing isolation from other containers.

## Security Features

- Non-root user execution where possible
- Security headers in Nginx configuration
- Restricted database authentication
- Network isolation
- Configuration externalization

## Customization

- Modify HTML content in `./html/`
- Update Nginx configuration in `./config/nginx.conf` and `./config/default.conf`
- Adjust PostgreSQL settings in `./config/postgresql.conf`
- Add database initialization scripts in `./init/`

## Troubleshooting

1. **Can't see containers with `podman ps`**: Use `podman-compose ps` instead - compose containers may not be visible to regular podman commands
2. **Port conflicts**: Change host ports in docker-compose.yml if needed
3. **Database connection**: Check logs with `podman-compose logs database`
4. **Nginx configuration**: Validate syntax with `podman-compose exec nginx-app nginx -t`
5. **PostgreSQL authentication**: The setup uses peer authentication. Connect as postgres user from within container or use TCP connection from outside
6. **PostgreSQL 15 paths**: PostgreSQL 15 uses `/var/lib/pgsql/15/data` instead of default PostgreSQL paths
7. **UBI9 package conflicts**: Avoid creating users that already exist in UBI9 base packages
8. **Container management**: Always use `podman-compose` commands to manage compose-created containers

## Clean Up

```bash
# Remove containers and networks (keep volumes)
podman-compose down

# Remove everything including volumes
podman-compose down -v

# Remove images
podman rmi $(podman images -q --filter "dangling=true")
```






## Quick Start Commands
```bash
# Build and start services
podman-compose up --build -d

# Access the application
# Web: http://localhost:8080
# Database: localhost:5432 (user: postgres for admin, appuser/apppass for app)
```

## Current Status ✅

This setup has been tested and verified working with:
- ✅ **Nginx Container**: Successfully running and serving content on port 8080
- ✅ **PostgreSQL Container**: Successfully running PostgreSQL 15 on port 5432
- ✅ **Database Initialization**: Custom database `appdb` and user `appuser` created
- ✅ **UBI9 Base Images**: Both services built on Red Hat UBI9 without subscription
- ✅ **Network Connectivity**: Services properly networked and accessible
- ✅ **Configuration Management**: All configs externalized and working
- ✅ **Persistent Storage**: Data volumes working correctly

**Test Commands:**
```bash
# Test Nginx
curl http://localhost:8080

# Test PostgreSQL connectivity  
nc -z localhost 5432

# View all logs
podman-compose logs

# Check container status
podman-compose ps
```
