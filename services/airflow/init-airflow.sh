#!/bin/bash

# Initialisation de la base de données
airflow db init

# Créer un utilisateur admin
airflow users create --username admin --firstname Admin --lastname User --email admin@example.com --role Admin --password adminpassword

# Démarrer le webserver
airflow webserver
