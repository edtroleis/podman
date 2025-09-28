#!/bin/bash
set -e

# Set PATH for PostgreSQL 15
export PATH=/usr/pgsql-15/bin:$PATH

# Initialize database if not exists
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Initializing database..."
    su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && initdb --auth-host=md5 --auth-local=peer --username=postgres -D $PGDATA"
    
    # Start PostgreSQL in background for initialization
    su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && pg_ctl -D $PGDATA -w start"
    
    # Create user and database
    su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres" <<-EOSQL
		CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';
		CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};
		GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};
	EOSQL

    # Run initialization scripts if they exist (but don't fail if they have issues)
    if [ -d /docker-entrypoint-initdb.d ]; then
        for f in /docker-entrypoint-initdb.d/*; do
            case "$f" in
                *.sql)    
                    echo "$0: running $f"
                    su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && psql -v ON_ERROR_STOP=1 --username postgres --dbname ${POSTGRES_DB} -f $f" || {
                        echo "Warning: Failed to execute $f as postgres user on ${POSTGRES_DB} database, skipping..."
                    }
                    ;;
                *.sql.gz) 
                    echo "$0: running $f"
                    gunzip -c "$f" | su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && psql -v ON_ERROR_STOP=1 --username postgres --dbname ${POSTGRES_DB}" || {
                        echo "Warning: Failed to execute $f, skipping..."
                    }
                    ;;
                *)        echo "$0: ignoring $f" ;;
            esac
        done
    fi

    # Stop PostgreSQL
    su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && pg_ctl -D $PGDATA -m fast -w stop"
fi

# Apply custom configuration if it exists
if [ -f /etc/postgresql/postgresql.conf ]; then
    cp /etc/postgresql/postgresql.conf "$PGDATA/postgresql.conf"
    chown postgres:postgres "$PGDATA/postgresql.conf"
fi

if [ -f /etc/postgresql/pg_hba.conf ]; then
    cp /etc/postgresql/pg_hba.conf "$PGDATA/pg_hba.conf"
    chown postgres:postgres "$PGDATA/pg_hba.conf"
fi

# Start PostgreSQL in foreground as postgres user
echo "Starting PostgreSQL..."
exec su - postgres -c "export PATH=/usr/pgsql-15/bin:\$PATH && postgres -D $PGDATA"
