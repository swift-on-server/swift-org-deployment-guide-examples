# Use the official PostgreSQL image (using the "latest" tag)
FROM postgres:latest

# Update package lists, install netcat-openbsd (useful for waiting on network connections), and clean up apt cache
#RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/lib/postgresql

RUN rm -rf data/*

# Copy SSL certificate files into the /certs/ directory in the container
COPY docker/certificates/server.pem docker/certificates/server.key docker/certificates/ca.pem /certs/
# Set ownership to the postgres user and restrict permissions on the private key for security
RUN chown postgres:postgres /certs/* && chmod 600 /certs/server.key

# Copy an initialization script that sets up SSL into the Docker entrypoint directory
# Scripts in this directory are executed when the container is initialized
COPY docker/db/config-ssl.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/config-ssl.sh

# Expose the PostgreSQL default port to allow external connections
EXPOSE 5432
