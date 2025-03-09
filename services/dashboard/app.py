import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Charger les variables d'environnement à partir du fichier .env
load_dotenv()

# Récupérer les variables d'environnement
DATABASE_URL = os.getenv('DATABASE_URL')

# Connexion à la base PostgreSQL avec SQLAlchemy
engine = create_engine(DATABASE_URL)

# Fonction pour récupérer les données
def get_data(query):
    df = pd.read_sql(query, engine)
    return df

# Charger les requêtes SQL depuis le répertoire 'sql'
queries = {}
for i in range(1, 9):  # Charger les fichiers 1.sql à 8.sql
    file_path = os.path.join('sql', f'{i}.sql')
    with open(file_path, 'r') as file:
        queries[f'query_{i}'] = file.read()

# Exécuter les requêtes et stocker les résultats dans un dictionnaire
df = {}
for name, query in queries.items():
    df[name] = get_data(query)


# Création des graphiques
fig_1 = px.bar(df["query_1"], x='nom_client', y='nombre_commandes', title="Nombre de commandes par client")
fig_2 = px.pie(df["query_2"],  names=df["query_2"].columns[0], values='chiffre_affaires', title="Chiffre d'affaires par client")
fig_3 = px.line(df["query_3"], x='mois', y='chiffre_affaires', title="Chiffre d'affaires par mois en 2024")
fig_4 = px.bar(df["query_4"], x='id_boite', y='quantite_vendue', color='nom_couleur', title="Top 5 des boîtes les plus vendues")

fig_5= px.bar(df["query_5"], x='id_boite', y='chiffre_affaires', color='nom_couleur', title="(Top 5 des boîtes les plus rentables)")

fig_6 = px.bar(df["query_6"], x='nom_matiere', y='chiffre_affaires', color='nom_matiere', title="Nombre total de commandes et chiffre d'affaires par matière(Top 5 des boîtes les plus rentables)")
fig_7 = px.bar(df["query_7"], x='nom_couleur', y='chiffre_affaires', color='nom_couleur', title="Nombre total de commandes et chiffre d'affaires par couleur)")
fig_8 = px.bar(df["query_8"], x='jour_semaine', y='nombre_commandes', color='jour_semaine', title="Saisonalité: Répartition des commandes par jour de la semaine")



# Initialisation de l'application Dash
app = dash.Dash(__name__)

# Création du layout du tableau de bord
app.layout = html.Div([
    html.H1("Tableau de Bord - Analyse des Commandes"),
    dcc.Graph(figure=fig_1),
    dcc.Graph(figure=fig_2),
    dcc.Graph(figure=fig_3),
    dcc.Graph(figure=fig_4),
    dcc.Graph(figure=fig_5),
    dcc.Graph(figure=fig_6),
    dcc.Graph(figure=fig_7),
    dcc.Graph(figure=fig_8),
])
# Lancer l'application
if __name__ == '__main__':
    app.run_server(host='0.0.0.0', port=8085, debug=True)