CREATE DATABASE Primefix_bd;
USE Primefix_bd;


-- 1. TABLE ABONNEMENT

CREATE TABLE ABONNEMENT (
    id_abonnement INT PRIMARY KEY,
    type_abonnement VARCHAR(50) NOT NULL,
	montant_mensuel INT NOT NULL);

-- 2. TABLE REALISATEUR

CREATE TABLE REALISATEUR (
    id_realisateur INT PRIMARY KEY,
    nom_realisateur VARCHAR(50) NOT NULL);
 
 -- 3. TABLE ACTEUR
 
CREATE TABLE ACTEUR (
    id_acteur INT PRIMARY KEY,
    nom_acteur VARCHAR(50) NOT NULL);
    
-- 4. TABLE UTILISATEUR

CREATE TABLE UTILISATEUR (
    id_utilisateur INT PRIMARY KEY,
    email_utilisateur VARCHAR(50) NOT NULL,
    mot_de_passe VARCHAR(50) NOT NULL,
    date_inscription DATE NOT NULL);
    
-- 5. TABLE PROFIL

CREATE TABLE PROFIL (
    id_utilisateur INT NOT NULL,
    id_profil INT NOT NULL,
    nom_profil VARCHAR(50) NOT NULL,
    restriction_age_profil VARCHAR(50) NOT NULL,
    
    -- Clé primaire composée
    PRIMARY KEY (id_utilisateur, id_profil),
    
    -- Clé étrangère
    FOREIGN KEY (id_utilisateur) 
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE);
        
-- 6. TABLE CONTENU

CREATE TABLE CONTENU (
    id_contenu INT PRIMARY KEY,
    titre_contenu VARCHAR(50) NOT NULL,
    genre_principal VARCHAR(50) NOT NULL,
    pays_origine VARCHAR(50) NOT NULL,
    duree_minutes INT NOT NULL,
    classification_age VARCHAR(50) NOT NULL,
    type_contenu VARCHAR(50) NOT NULL,
    resume_contenu VARCHAR(500),
    date_mise_en_ligne DATE NOT NULL,
    id_realisateur INT NOT NULL,
    
    -- Clé étrangère
    FOREIGN KEY (id_realisateur) 
        REFERENCES REALISATEUR(id_realisateur)
        ON DELETE RESTRICT
        ON UPDATE CASCADE);
        
-- 7. TABLE SOUSCRIRE

CREATE TABLE SOUSCRIRE (
    id_utilisateur INT  NOT NULL,
    id_abonnement INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    statut VARCHAR(50) NOT NULL,
    
    -- Clé primaire
    PRIMARY KEY (id_utilisateur, id_abonnement, date_debut),
    
    -- Clés étrangères
    FOREIGN KEY (id_utilisateur) 
        REFERENCES UTILISATEUR(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_abonnement) 
        REFERENCES ABONNEMENT(id_abonnement)
        ON DELETE RESTRICT
        ON UPDATE CASCADE);

-- 8. TABLE JOUER_DANS
CREATE TABLE JOUER_DANS (
    id_contenu INT NOT NULL,
    id_acteur INT NOT NULL,
    role_principal VARCHAR(50) NOT NULL,
    
    -- Clé primaire composée
    PRIMARY KEY (id_contenu, id_acteur),
    
    -- Clés étrangères
    FOREIGN KEY (id_contenu) 
        REFERENCES CONTENU(id_contenu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_acteur) 
        REFERENCES ACTEUR(id_acteur)
        ON DELETE CASCADE
        ON UPDATE CASCADE);
        
-- 9. TABLE VISIONNER

CREATE TABLE VISIONNER (
    id_contenu INT  NOT NULL,
    id_utilisateur INT  NOT NULL,
    id_profil INT  NOT NULL,
    pourcentage_progression FLOAT NOT NULL,
    
    -- Clé primaire composée (permet plusieurs visionnages du même contenu)
    PRIMARY KEY (id_contenu, id_utilisateur, id_profil),
    
    -- Clés étrangères
    FOREIGN KEY (id_contenu) 
        REFERENCES CONTENU(id_contenu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_utilisateur, id_profil) 
        REFERENCES PROFIL(id_utilisateur, id_profil)
        ON DELETE CASCADE
        ON UPDATE CASCADE);
        
-- 10. TABLE FAVORIS

CREATE TABLE FAVORIS (
    id_contenu INT  NOT NULL,
    id_utilisateur INT  NOT NULL,
    id_profil INT  NOT NULL,
    
    -- Clé primaire composée
    PRIMARY KEY (id_contenu, id_utilisateur, id_profil),
    
    -- Clés étrangères
    FOREIGN KEY (id_contenu) 
        REFERENCES CONTENU(id_contenu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_utilisateur, id_profil) 
        REFERENCES PROFIL(id_utilisateur, id_profil)
        ON DELETE CASCADE
        ON UPDATE CASCADE);
        
        
-- ===============================================
-- FIN DU SCRIPT
-- ===============================================