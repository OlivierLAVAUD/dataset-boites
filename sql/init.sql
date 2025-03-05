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
    -- Contrainte CHECK avec expression régulière pour l'id_client
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
    longueur_mm INT NOT NULL,
    largeur_mm INT NOT NULL,
    hauteur_mm INT NOT NULL,
    surface_exterieure_mm2 DECIMAL(15,2),
    FOREIGN KEY (id_matiere) REFERENCES MATIERES(id_matiere),
    FOREIGN KEY (id_couleur) REFERENCES COULEURS(id_couleur),
    CONSTRAINT chk_longueur CHECK (longueur_mm <= 1000),
    CONSTRAINT chk_largeur CHECK (largeur_mm <= 1000),
    CONSTRAINT chk_hauteur CHECK (hauteur_mm <= 1000)
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

-- Trigger pour mettre à jour la surface extérieure à l'insertion ou la modification d'une boîte
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

-- Insertion de données exemples (Exemple)
INSERT INTO CLIENTS (id_client, nom_client, email_client, adresse_client) VALUES
('ab-123', 'Alice Smith', 'alice@example.com', '123 Rue Principale'),
('cd-456', 'Bob Johnson', 'bob@example.com', '456 Avenue du Chêne');

INSERT INTO MATIERES (nom_matiere) VALUES ('Plastique'), ('Bois'), ('Métal');

INSERT INTO COULEURS (nom_couleur) VALUES ('Rouge'), ('Bleu'), ('Vert');

INSERT INTO MATIERE_COULEURS (id_matiere, id_couleur) VALUES
(1,1), -- Le plastique peut être Rouge
(1,2), -- Le plastique peut être Bleu
(2,3), -- Le bois peut être Vert
(3,1); -- Le métal peut être Rouge

INSERT INTO BOITES (id_matiere, id_couleur, longueur_mm, largeur_mm, hauteur_mm) VALUES
(1,1,100,150,50);

INSERT INTO COMMANDES (id_client, date_commande) VALUES
('ab-123', '2024-11-15');

INSERT INTO LIGNES_COMMANDE (id_commande, id_boite, quantite, prix_unitaire, taux_remise) VALUES
(1,1,2,15.50,0.10);

-- Exemple d'utilisation de la vue
SELECT * FROM boites_details;

