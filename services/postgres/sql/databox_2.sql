-- Suppression des tables si elles existent (pour le développement/test)
DROP TABLE IF EXISTS LIGNES_COMMANDE;
DROP TABLE IF EXISTS COMMANDES;
DROP TABLE IF EXISTS BOITES;
DROP TABLE IF EXISTS MATIERE_COULEURS;
DROP TABLE IF EXISTS COULEURS;
DROP TABLE IF EXISTS MATIERES;
DROP TABLE IF EXISTS CLIENTS;

-- Création de la table CLIENTS
CREATE TABLE CLIENTS (
    id_client VARCHAR(6) PRIMARY KEY,
    nom_client VARCHAR(255),
    email_client VARCHAR(255),
    adresse_client TEXT,
    CONSTRAINT chk_id_client CHECK (id_client ~ '^[a-z]{2}-\d+$')
);

-- Création de la table MATIERES
CREATE TABLE MATIERES (
    id_matiere SERIAL PRIMARY KEY,
    nom_matiere VARCHAR(255) UNIQUE
);

-- Création de la table COULEURS
CREATE TABLE COULEURS (
    id_couleur SERIAL PRIMARY KEY,
    nom_couleur VARCHAR(255) UNIQUE
);

-- Création de la table MATIERE_COULEURS
CREATE TABLE MATIERE_COULEURS (
    id_matiere INT,
    id_couleur INT,
    PRIMARY KEY (id_matiere, id_couleur),
    FOREIGN KEY (id_matiere) REFERENCES MATIERES(id_matiere),
    FOREIGN KEY (id_couleur) REFERENCES COULEURS(id_couleur)
);

-- Création de la table BOITES
CREATE TABLE BOITES (
    id_boite SERIAL PRIMARY KEY,
    id_matiere INT,
    id_couleur INT,
    longueur_mm INT NOT NULL CHECK (longueur_mm <= 1000),
    largeur_mm INT NOT NULL CHECK (largeur_mm <= 1000),
    hauteur_mm INT NOT NULL CHECK (hauteur_mm <= 1000),
    surface_exterieure_mm2 DECIMAL(15,2),
    FOREIGN KEY (id_matiere) REFERENCES MATIERES(id_matiere),
    FOREIGN KEY (id_couleur) REFERENCES COULEURS(id_couleur)
);

-- Création de la table COMMANDES
CREATE TABLE COMMANDES (
    id_commande SERIAL PRIMARY KEY,
    id_client VARCHAR(6),
    date_commande DATE,
    FOREIGN KEY (id_client) REFERENCES CLIENTS(id_client)
);

-- Création de la table LIGNES_COMMANDE
CREATE TABLE LIGNES_COMMANDE (
    id_commande INT,
    id_boite INT,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(10,2),
    taux_remise DECIMAL(5,2),
    PRIMARY KEY (id_commande, id_boite),
    FOREIGN KEY (id_commande) REFERENCES COMMANDES(id_commande),
    FOREIGN KEY (id_boite) REFERENCES BOITES(id_boite)
);

-- Fonction pour calculer la surface extérieure
CREATE OR REPLACE FUNCTION calculer_surface_exterieure(longueur INT, largeur INT, hauteur INT)
RETURNS DECIMAL(15,2) AS $$
BEGIN
    RETURN 2 * (longueur * largeur + longueur * hauteur + largeur * hauteur);
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour la surface extérieure automatiquement
CREATE OR REPLACE FUNCTION maj_surface_boite()
RETURNS TRIGGER AS $$
BEGIN
    NEW.surface_exterieure_mm2 := calculer_surface_exterieure(NEW.longueur_mm, NEW.largeur_mm, NEW.hauteur_mm);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maj_surface_boite_trigger
BEFORE INSERT OR UPDATE ON BOITES
FOR EACH ROW
EXECUTE FUNCTION maj_surface_boite();

-- Vue pour simplifier l'accès aux informations des boîtes avec matière et couleur
CREATE OR REPLACE VIEW boites_details AS
SELECT
    b.id_boite,
    m.nom_matiere,
    c.nom_couleur,
    b.longueur_mm,
    b.largeur_mm,
    b.hauteur_mm,
    b.surface_exterieure_mm2
FROM
    BOITES b
JOIN
    MATIERES m ON b.id_matiere = m.id_matiere
JOIN
    COULEURS c ON b.id_couleur = c.id_couleur;

-- Insertion de données avec variation statistique

-- Insertion de matières
INSERT INTO MATIERES (nom_matiere) VALUES
('Plastique'), ('Bois'), ('Métal'), ('Carton'), ('Verre'), ('Céramique'), ('Tissu');

-- Insertion de couleurs
INSERT INTO COULEURS (nom_couleur) VALUES
('Rouge'), ('Bleu'), ('Vert'), ('Jaune'), ('Noir'), ('Blanc'), ('Violet');

-- Insertion de clients
INSERT INTO CLIENTS (id_client, nom_client, email_client, adresse_client) VALUES
('ab-123', 'Alice Smith', 'alice@example.com', '123 Rue Principale'),
('cd-456', 'Bob Johnson', 'bob@example.com', '456 Avenue du Chêne'),
('ef-789', 'Charlie Brown', 'charlie@example.com', '789 Boulevard des Roses'),
('gh-101', 'Diana Prince', 'diana@example.com', '101 Rue de la Paix'),
('ij-112', 'Evan Davis', 'evan@example.com', '112 Avenue des Lilas'),
('kl-131', 'Fiona Green', 'fiona@example.com', '131 Rue des Érables'),
('mn-415', 'George White', 'george@example.com', '415 Boulevard du Soleil');

-- Insertion de boîtes avec distribution variée
INSERT INTO BOITES (id_matiere, id_couleur, longueur_mm, largeur_mm, hauteur_mm) VALUES
(1, 1, 100, 150, 50),  
(2, 3, 200, 200, 100),  
(3, 5, 300, 150, 200),  
(4, 2, 250, 250, 250),  
(5, 6, 150, 150, 150),  
(6, 4, 100, 100, 100),  
(7, 7, 200, 100, 50);

-- Insertion de commandes pour chaque client
DO $$
DECLARE
    client_id VARCHAR(6);
    i INT;
BEGIN
    FOR client_id IN SELECT id_client FROM CLIENTS LOOP
        FOR i IN 1..7 LOOP
            INSERT INTO COMMANDES (id_client, date_commande)
            VALUES (client_id, '2024-01-01'::DATE + (i || ' days')::INTERVAL);
        END LOOP;
    END LOOP;
END $$ LANGUAGE plpgsql;

-- Insertion de lignes de commande avec vérification des doublons et distribution réaliste
DO $$
DECLARE
    commande_id INT;
    boite_id INT;
    j INT;
    quantite INT;
    prix DECIMAL(10,2);
    remise DECIMAL(5,2);
BEGIN
    FOR commande_id IN SELECT id_commande FROM COMMANDES LOOP
        FOR j IN 1..7 LOOP
            boite_id := (random() * 6 + 1)::INT;  -- Sélection aléatoire d'une boîte
            quantite := CASE 
                WHEN random() < 0.7 THEN (random() * 3 + 1)::INT  
                ELSE (random() * 10 + 1)::INT  
            END;
            prix := 10.00 + (random() * 10.00);  
            remise := CASE 
                WHEN quantite > 5 THEN 0.10  
                ELSE 0.00 
            END;
            
            -- Vérifier si la combinaison (id_commande, id_boite) existe déjà
            IF NOT EXISTS (
                SELECT 1 FROM LIGNES_COMMANDE WHERE id_commande = commande_id AND id_boite = boite_id
            ) THEN
                INSERT INTO LIGNES_COMMANDE (id_commande, id_boite, quantite, prix_unitaire, taux_remise)
                VALUES (commande_id, boite_id, quantite, prix, remise);
            END IF;
        END LOOP;
    END LOOP;
END $$ LANGUAGE plpgsql;

-- Vérification des données insérées
SELECT * FROM boites_details;
SELECT * FROM LIGNES_COMMANDE;


