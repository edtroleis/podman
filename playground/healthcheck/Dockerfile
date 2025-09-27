FROM registry.access.redhat.com/ubi9/ubi:latest

# Install python3 for simple web server (curl-minimal is already available)
RUN dnf update -y && \
    dnf install -y python3 && \
    dnf clean all

# Create a simple health endpoint with proper shebang
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'python3 -m http.server 8080' >> /start.sh && \
    chmod +x /start.sh

# Here we set a check every 30 seconds, if the health check command does not respond for more than 3 seconds, it is considered a failure, and use "curl -fs http://localhost/ || exit 1" as a health check command.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fs http://localhost:8080 || exit 1

EXPOSE 8080

CMD ["/start.sh"]
