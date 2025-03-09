import psycopg2

# Paramètres de connexion (écrits en dur)
DB_HOST = "postgresql"
DB_PORT = "5432"
DB_NAME = "databox_db"
DB_USER = "postgres"
DB_PASSWORD = "admin"

try:
    # Connexion à la base PostgreSQL
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    
    # Création du curseur
    cur = conn.cursor()

    # Requête pour récupérer les noms des tables
    cur.execute("""
        SELECT table_name FROM information_schema.tables
        WHERE table_schema = 'public';
    """)

    # Récupération et affichage des tables
    tables = cur.fetchall()
    print("Tables présentes dans la base de données :")
    for table in tables:
        print("-", table[0])

    # Fermeture du curseur et de la connexion
    cur.close()
    conn.close()

except Exception as e:
    print("Erreur de connexion :", e)
