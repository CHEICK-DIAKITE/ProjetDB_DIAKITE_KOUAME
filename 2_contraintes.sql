-- 1. TABLE ABONNEMENT

ALTER TABLE ABONNEMENT ADD (
	CONSTRAINT chk_type_abonnement CHECK (type_abonnement IN ('Basique', 'Standard', 'Premium')),
	CONSTRAINT chk_montant_coherent CHECK (
        (type_abonnement = 'Basique' AND montant_mensuel = 10) OR
        (type_abonnement = 'Standard' AND montant_mensuel = 15) OR
        (type_abonnement = 'Premium' AND montant_mensuel = 20)
    ),
    CONSTRAINT uq_type_abonnement UNIQUE (type_abonnement)
);

-- 2. TABLE REALISATEUR

ALTER TABLE REALISATEUR ADD (
	CONSTRAINT uq_nom_realisateur UNIQUE (nom_realisateur)
);
    
-- 3. TABLE ACTEUR

ALTER TABLE ACTEUR ADD (
    CONSTRAINT uq_nom_acteur UNIQUE (nom_acteur)
);

-- 4. TABLE UTILISATEUR

ALTER TABLE UTILISATEUR ADD (
	CONSTRAINT chk_email_format CHECK (email_utilisateur REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_mot_de_passe_longueur CHECK (LENGTH(mot_de_passe) >= 8),
    CONSTRAINT chk_date_inscription CHECK (date_inscription >= '2020-01-01' AND date_inscription <= CURDATE()),
    CONSTRAINT uq_email_utilisateur UNIQUE (email_utilisateur)
);

-- 5. TABLE PROFIL

ALTER TABLE PROFIL ADD (
    CONSTRAINT chk_restriction_age_profil CHECK (restriction_age_profil IN ('TP', '13+', '16+', '18+')),
    CONSTRAINT chk_id_profil_range CHECK (id_profil BETWEEN 1 AND 5)
);

-- 6. TABLE CONTENU

ALTER TABLE CONTENU ADD (
	CONSTRAINT chk_genre_principal CHECK (genre_principal IN (
        'Action', 'Drame', 'Comédie', 'Science-Fiction', 
        'Horreur', 'Romance', 'Thriller', 'Documentaire', 'Animation')
	),
    CONSTRAINT chk_duree_coherente CHECK (
        (type_contenu = 'Film' AND duree_minutes BETWEEN 20 AND 240) OR
        (type_contenu = 'Série' AND duree_minutes BETWEEN 20 AND 90)
    ),
    CONSTRAINT chk_classification_age CHECK (classification_age IN ('TP', '13+', '16+', '18+')),
    CONSTRAINT chk_type_contenu CHECK (type_contenu IN ('Film', 'Série')),
    CONSTRAINT chk_date_mise_en_ligne CHECK (date_mise_en_ligne >= '2000-01-01' AND date_mise_en_ligne <= CURDATE())
);

-- 7. TABLE SOUSCRIRE

ALTER TABLE SOUSCRIRE ADD (
	CONSTRAINT chk_statut_abonnement CHECK (statut IN ('actif', 'suspendu', 'résilié')),
    CONSTRAINT chk_dates_coherentes CHECK (date_debut < date_fin)
);

-- 8. TABLE JOUER_DANS

ALTER TABLE JOUER_DANS ADD (
CONSTRAINT chk_role_principal CHECK (role_principal IN ('O', 'N'))
);

-- 9. TABLE VISIONNER

ALTER TABLE VISIONNER ADD (
CONSTRAINT chk_pourcentage_progression CHECK (pourcentage_progression BETWEEN 0 AND 100)
);

-- 10. TABLE FAVORIS
-- PAS DE CONTRAINTES 


-- ===============================================
-- CONTRAINTES ADDITIONNELLES (TRIGGERS)
-- ===============================================

-- Trigger pour vérifier qu'un utilisateur n'a pas plus de 5 profils
DELIMITER //
CREATE TRIGGER trg_check_max_profils
BEFORE INSERT ON PROFIL
FOR EACH ROW
BEGIN
    DECLARE nb_profils INT;  
    SELECT COUNT(*) INTO nb_profils 
    FROM PROFIL 
	WHERE id_utilisateur = NEW.id_utilisateur;
    
    IF nb_profils >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un utilisateur ne peut avoir plus de 5 profils';
    END IF;
END//
DELIMITER ;

-- Trigger pour vérifier qu'un seul acteur principal par contenu
DELIMITER //
CREATE TRIGGER trg_check_acteur_principal
BEFORE INSERT ON JOUER_DANS
FOR EACH ROW
BEGIN
    DECLARE nb_principaux INT;
    
    IF NEW.role_principal = 'O' THEN
        SELECT COUNT(*) INTO nb_principaux 
        FROM JOUER_DANS 
        WHERE id_contenu = NEW.id_contenu AND role_principal = 'O';
        
        IF nb_principaux >= 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un contenu ne peut avoir qu''un seul acteur principal';
        END IF;
    END IF;
END//
DELIMITER ;

-- Trigger pour vérifier qu'un utilisateur a un abonnement actif avant de visionner
DELIMITER //
CREATE TRIGGER trg_check_abonnement_actif
BEFORE INSERT ON VISIONNER
FOR EACH ROW
BEGIN
    DECLARE nb_abonnements_actifs INT;
    
    SELECT COUNT(*) INTO nb_abonnements_actifs
    FROM SOUSCRIRE
    WHERE id_utilisateur = NEW.id_utilisateur 
    AND statut = 'actif'
    AND CURDATE() BETWEEN date_debut AND date_fin;
    
    IF nb_abonnements_actifs = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''utilisateur doit avoir un abonnement actif pour visionner du contenu';
    END IF;
END//
DELIMITER ;

-- Trigger pour vérifier la restriction d'âge lors du visionnage
DELIMITER //
CREATE TRIGGER trg_check_restriction_age
BEFORE INSERT ON VISIONNER
FOR EACH ROW
BEGIN
    DECLARE restriction_profil VARCHAR(5);
    DECLARE classification_contenu VARCHAR(5);
    
    SELECT restriction_age_profil INTO restriction_profil
    FROM PROFIL
    WHERE id_utilisateur = NEW.id_utilisateur AND id_profil = NEW.id_profil;
    
    SELECT classification_age INTO classification_contenu
    FROM CONTENU
    WHERE id_contenu = NEW.id_contenu;
    
    -- Vérification hiérarchique : TP < 13+ < 16+ < 18+
    IF (restriction_profil = 'TP' AND classification_contenu != 'TP') OR
       (restriction_profil = '13+' AND classification_contenu IN ('16+', '18+')) OR
       (restriction_profil = '16+' AND classification_contenu = '18+') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le profil n''a pas l''autorisation de visionner ce contenu (restriction d''âge)';
    END IF;
END//
DELIMITER ;

-- Trigger pour vérifier la cohérence des dates de souscription
DELIMITER //
CREATE TRIGGER trg_check_date_souscription
BEFORE INSERT ON SOUSCRIRE
FOR EACH ROW
BEGIN
    DECLARE date_inscription_user DATE;
    
    SELECT date_inscription INTO date_inscription_user
    FROM UTILISATEUR
    WHERE id_utilisateur = NEW.id_utilisateur;
    
    IF NEW.date_debut < date_inscription_user THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de début d''abonnement ne peut être antérieure à la date d''inscription';
    END IF;
END//
DELIMITER ;

-- Trigger pour garantir qu'un utilisateur n'a qu'un seul abonnement actif
DELIMITER //
CREATE TRIGGER trg_check_abonnement_unique_actif
BEFORE INSERT ON SOUSCRIRE
FOR EACH ROW
BEGIN
    DECLARE nb_actifs INT;
    
    IF NEW.statut = 'actif' THEN
        SELECT COUNT(*) INTO nb_actifs
        FROM SOUSCRIRE
        WHERE id_utilisateur = NEW.id_utilisateur 
        AND statut = 'actif'
        AND CURDATE() BETWEEN date_debut AND date_fin;
        
        IF nb_actifs > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un utilisateur ne peut avoir qu''un seul abonnement actif';
        END IF;
    END IF;
END//
DELIMITER ;


-- ===============================================
-- FIN DU SCRIPT
-- ===============================================