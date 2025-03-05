# Utiliser l'image officielle de PostgreSQL
FROM postgres:latest

# Copier le script SQL dans le conteneur
COPY sql/databox.sql /docker-entrypoint-initdb.d/

# Exposer le port PostgreSQL
EXPOSE 5432