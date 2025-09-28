FROM registry.access.redhat.com/ubi9/ubi:latest

# Install required packages and add PostgreSQL official repository
RUN dnf update -y && \
    dnf install -y wget glibc-langpack-en && \
    dnf clean all

# Install PostgreSQL from official PostgreSQL repository
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    dnf install -y postgresql15-server postgresql15-contrib && \
    dnf clean all && \
    rm -rf /var/cache/yum

# Set environment variables
ENV POSTGRES_DB=appdb
ENV POSTGRES_USER=appuser  
ENV POSTGRES_PASSWORD=apppass
ENV PGDATA=/var/lib/pgsql/15/data
ENV PATH=/usr/pgsql-15/bin:$PATH

# Create directories (postgres user already exists from package installation)
RUN mkdir -p /var/lib/pgsql/15/data /var/run/postgresql /docker-entrypoint-initdb.d && \
    chown -R postgres:postgres /var/lib/pgsql /var/run/postgresql && \
    chmod 755 /var/lib/pgsql && \
    chmod 700 /var/lib/pgsql/15/data

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose PostgreSQL port
EXPOSE 5432

# Set entrypoint and command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
