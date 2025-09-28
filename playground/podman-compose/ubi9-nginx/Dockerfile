FROM registry.access.redhat.com/ubi9/ubi:latest

# Install nginx and clean cache
RUN dnf update -y && \
    dnf install -y nginx && \
    dnf clean all

# Create nginx user and set permissions
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/lib/nginx /run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/lib/nginx /run/nginx && \
    chmod -R 755 /var/cache/nginx /var/log/nginx /var/lib/nginx /run/nginx

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy web content
COPY index.html /usr/share/nginx/html/index.html

# Set proper permissions for web content
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 644 /usr/share/nginx/html

# Expose port 8080
EXPOSE 8080

# Switch to nginx user
USER nginx

# Start nginx in foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
