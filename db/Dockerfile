# Use the official PostgreSQL image
FROM postgres:latest

# Copy the SQL script into the container
COPY sql/databox.sql /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432