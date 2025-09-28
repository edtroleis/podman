FROM registry.access.redhat.com/ubi9/ubi:latest

# Install nginx and required packages
RUN dnf update -y && \
    dnf install -y nginx && \
    dnf clean all && \
    rm -rf /var/cache/yum

# Create required directories (nginx user/group already exists in UBI9)
RUN mkdir -p /var/log/nginx /var/cache/nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /usr/share/nginx/html && \
    chmod -R 755 /var/log/nginx /var/cache/nginx /usr/share/nginx/html

# Create default index.html
RUN echo '<html><head><title>Welcome to Nginx on UBI9</title></head><body><h1>Welcome to Nginx on UBI9</h1><p>This is a simple nginx application running in a container built from UBI9 base image.</p></body></html>' > /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
