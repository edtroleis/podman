FROM registry.access.redhat.com/ubi9/ubi:latest

# Install nginx
RUN dnf update -y && \
    dnf install -y nginx && \
    dnf clean all

# Create directories for volumes
RUN mkdir -p /var/log/nginx /var/www/html /etc/nginx/conf.d

# Set proper permissions (nginx user already exists in UBI9)
RUN chown -R nginx:nginx /var/log/nginx /var/www/html && \
    chmod 755 /var/www/html

# Copy default page
COPY config/index.html /var/www/html/

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
