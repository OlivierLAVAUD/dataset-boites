import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd
import os
from dotenv import load_dotenv
from urllib.parse import urlparse
from sqlalchemy import create_engine

# Charger les variables d'environnement à partir du fichier .env
load_dotenv()

# Récupérer les variables d'environnement
DATABASE_URL = os.getenv('DATABASE_URL')
print("<",DATABASE_URL, ">")

# Analyser l'URL de la base de données
parsed_url = urlparse(DATABASE_URL)
dbname = parsed_url.path[1:]
user = parsed_url.username
password = parsed_url.password
host = parsed_url.hostname
port = parsed_url.port

# Connexion à la base PostgreSQL avec SQLAlchemy
engine = create_engine(DATABASE_URL)

# Récupération des données
def get_data(query):
    df = pd.read_sql(query, engine)
    return df

df_boites = get_data("SELECT nom_matiere, COUNT(*) as nb_boites FROM boites_details GROUP BY nom_matiere;")
df_couleurs = get_data("SELECT nom_couleur, COUNT(*) as nb_boites FROM boites_details GROUP BY nom_couleur;")
df_commandes = get_data("SELECT date_commande, COUNT(*) as nb_commandes FROM COMMANDES GROUP BY date_commande ORDER BY date_commande;")
df_clients = get_data("SELECT c.nom_client, SUM(l.quantite) as total_boites FROM LIGNES_COMMANDE l JOIN COMMANDES cmd ON l.id_commande = cmd.id_commande JOIN CLIENTS c ON cmd.id_client = c.id_client GROUP BY c.nom_client ORDER BY total_boites DESC;")
df_ventes = get_data("SELECT date_commande, SUM(quantite * prix_unitaire * (1 - taux_remise)) as total_ventes FROM LIGNES_COMMANDE l JOIN COMMANDES c ON l.id_commande = c.id_commande GROUP BY date_commande ORDER BY date_commande;")

# Création des graphiques
fig_matiere = px.bar(df_boites, x='nom_matiere', y='nb_boites', title="Répartition des boîtes par matière")
fig_couleur = px.pie(df_couleurs, names='nom_couleur', values='nb_boites', title="Répartition des boîtes par couleur")
fig_commandes = px.line(df_commandes, x='date_commande', y='nb_commandes', title="Évolution des commandes")
fig_clients = px.bar(df_clients, x='nom_client', y='total_boites', title="Quantité de boîtes commandées par client")
fig_ventes = px.line(df_ventes, x='date_commande', y='total_ventes', title="Valeur totale des ventes par jour")

# Initialisation de l'application Dash
app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Tableau de Bord - Analyse des Commandes"),
    dcc.Graph(figure=fig_matiere),
    dcc.Graph(figure=fig_couleur),
    dcc.Graph(figure=fig_commandes),
    dcc.Graph(figure=fig_clients),
    dcc.Graph(figure=fig_ventes),
])

if __name__ == '__main__':
    app.run_server(debug=True)