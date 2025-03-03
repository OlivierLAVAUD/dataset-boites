FROM postgres:latest

ENV POSTGRES_USER=mon_utilisateur
ENV POSTGRES_PASSWORD=mon_mot_de_passe
ENV POSTGRES_DB=ma_base_de_donnees

COPY init.sql /docker-entrypoint-initdb.d/
