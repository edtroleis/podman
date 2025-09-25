# Use Red Hat Universal Base Image 9
FROM registry.access.redhat.com/ubi9/ubi:latest

# Set maintainer label
LABEL maintainer="your-email@example.com" \
      description="UBI 9 example with volume support for file storage"

# Update system and install useful tools
RUN dnf update -y && \
    dnf install -y \
        vim \
        tree \
        curl \
        wget \
        procps-ng \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Create a user for running the application
RUN useradd -m -s /bin/bash appuser

# Create directories for volume mounts
RUN mkdir -p /app/data /app/logs /app/config && \
    chown -R appuser:appuser /app

# Copy sample files
COPY sample-data/ /app/initial-data/
COPY app-script.sh /app/
RUN chmod +x /app/app-script.sh && \
    chown -R appuser:appuser /app

# Create volumes
VOLUME ["/app/data", "/app/logs", "/app/config"]

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Default command
CMD ["/app/app-script.sh"]