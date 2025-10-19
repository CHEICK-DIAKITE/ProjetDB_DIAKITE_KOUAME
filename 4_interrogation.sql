

-- Requêtes de type : Projections et Sélections
-- (Utilisation de SELECT, FROM, WHERE, ORDER BY, DISTINCT, LIKE, IN, BETWEEN)


-- Requête 1 : Lister tous les contenus de science-fiction pour adultes (16+)
-- Objectif : Obtenir une liste de contenus comparables à "Chronique d'Andromède".
SELECT 
    titre_contenu, 
    pays_origine, 
    date_mise_en_ligne
FROM CONTENU
WHERE 
    genre_principal = 'Sci-Fi' 
    AND classification_age IN ('16+', '18+')
ORDER BY 
    date_mise_en_ligne DESC;

-- Requête 2 : Extraire le titre et le résumé de la série "Chronique d'Andromède"
-- Objectif : Confirmer les informations de base sur le contenu analysé.
SELECT 
    titre_contenu, 
    resume_contenu
FROM CONTENU
WHERE 
    titre_contenu LIKE 'Chronique d''Andromède%'; -

-- Requête 3 : Lister les utilisateurs qui se sont inscrits en 2023
-- Objectif : Analyser le comportement d'une cohorte récente d'utilisateurs.
SELECT 
    email_utilisateur, 
    date_inscription
FROM UTILISATEUR
WHERE 
    date_inscription BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY 
    date_inscription;

-- Requête 4 : Afficher la liste unique des pays d'origine des contenus
-- Objectif : Avoir une vue d'ensemble de la diversité géographique du catalogue.
SELECT DISTINCT 
    pays_origine
FROM CONTENU
ORDER BY 
    pays_origine;

-- Requête 5 : Trouver tous les acteurs dont le nom de famille est "Smith"
-- Objectif : Recherche spécifique pour la gestion des talents.
SELECT 
    id_acteur, 
    nom_acteur
FROM ACTEUR
WHERE 
    nom_acteur LIKE '% Smith';



-- Requêtes de type : Fonctions d'Agrégation
-- (Utilisation de COUNT, AVG, SUM, GROUP BY, HAVING)


-- Requête 6 : Compter le nombre de contenus par genre principal
-- Objectif : Comprendre la composition du catalogue.
SELECT 
    genre_principal, 
    COUNT(id_contenu) AS nombre_de_contenus
FROM CONTENU
GROUP BY 
    genre_principal
ORDER BY 
    nombre_de_contenus DESC;

-- Requête 7 : Calculer la progression de visionnage moyenne pour "Chronique d'Andromède"
-- Objectif : Évaluer si les spectateurs regardent la série jusqu'à la fin.
SELECT 
    C.titre_contenu,
    AVG(V.pourcentage_progression) AS progression_moyenne
FROM VISIONNER V
JOIN CONTENU C ON V.id_contenu = C.id_contenu
WHERE 
    C.titre_contenu = 'Chronique d''Andromède'
GROUP BY 
    C.titre_contenu;

-- Requête 8 : Compter le nombre d'utilisateurs actifs par type d'abonnement
-- Objectif : Quantifier la base d'abonnés par segment de valeur.
SELECT 
    A.type_abonnement,
    COUNT(S.id_utilisateur) AS nombre_utilisateurs_actifs
FROM SOUSCRIRE S
JOIN ABONNEMENT A ON S.id_abonnement = A.id_abonnement
WHERE 
    S.statut = 'actif'
GROUP BY 
    A.type_abonnement;

-- Requête 9 : Identifier les réalisateurs ayant produit plus de 5 contenus
-- Objectif : Repérer les collaborateurs les plus prolifiques de la plateforme.
SELECT 
    R.nom_realisateur,
    COUNT(C.id_contenu) AS nombre_contenus_realises
FROM REALISATEUR R
JOIN CONTENU C ON R.id_realisateur = C.id_realisateur
GROUP BY 
    R.nom_realisateur
HAVING 
    COUNT(C.id_contenu) > 5;

-- Requête 10 : Calculer la durée totale (en minutes) de contenu disponible par genre
-- Objectif : Évaluer le volume d'heures de visionnage potentiel par catégorie.
SELECT 
    genre_principal,
    SUM(duree_minutes) AS duree_totale_minutes
FROM CONTENU
GROUP BY 
    genre_principal
ORDER BY 
    duree_totale_minutes DESC;



-- Requêtes de type : Jointures
-- (Utilisation de INNER JOIN, LEFT JOIN, multiples jointures)


-- Requête 11 (Multiple INNER JOIN) : Lister les abonnés Premium qui ont visionné "Chronique d'Andromède"
-- Objectif : Vérifier si la série est populaire auprès du segment d'abonnés le plus rentable.
SELECT 
    U.email_utilisateur,
    P.nom_profil,
    A.type_abonnement
FROM UTILISATEUR U
JOIN PROFIL P ON U.id_utilisateur = P.id_utilisateur
JOIN VISIONNER V ON P.id_utilisateur = V.id_utilisateur AND P.id_profil = V.id_profil
JOIN CONTENU C ON V.id_contenu = C.id_contenu
JOIN SOUSCRIRE S ON U.id_utilisateur = S.id_utilisateur
JOIN ABONNEMENT A ON S.id_abonnement = A.id_abonnement
WHERE 
    C.titre_contenu = 'Chronique d''Andromède'
    AND A.type_abonnement = 'Premium'
    AND S.statut = 'actif';

-- Requête 12 (Simple INNER JOIN) : Afficher chaque contenu avec le nom de son réalisateur
-- Objectif : Obtenir une liste de base du catalogue avec ses créateurs.
SELECT 
    C.titre_contenu,
    R.nom_realisateur
FROM CONTENU C
INNER JOIN REALISATEUR R ON C.id_realisateur = R.id_realisateur;

-- Requête 13 (LEFT JOIN) : Lister TOUS les acteurs et les contenus dans lesquels ils jouent (s'il y en a)
-- Objectif : Identifier les acteurs "libres" qui ne sont pas encore distribués dans un contenu.
SELECT 
    A.nom_acteur,
    C.titre_contenu
FROM ACTEUR A
LEFT JOIN JOUER_DANS JD ON A.id_acteur = JD.id_acteur
LEFT JOIN CONTENU C ON JD.id_contenu = C.id_contenu
ORDER BY 
    A.nom_acteur;

-- Requête 14 (Multiple INNER JOIN) : Trouver les contenus favoris d'un utilisateur spécifique (ex: id_utilisateur = 10)
-- Objectif : Analyse du comportement d'un utilisateur individuel.
SELECT 
    U.email_utilisateur,
    P.nom_profil,
    C.titre_contenu
FROM UTILISATEUR U
JOIN PROFIL P ON U.id_utilisateur = P.id_utilisateur
JOIN FAVORIS F ON P.id_utilisateur = F.id_utilisateur AND P.id_profil = F.id_profil
JOIN CONTENU C ON F.id_contenu = C.id_contenu
WHERE 
    U.id_utilisateur = 10;
    
-- Requête 15 (INNER JOIN) : Lister tous les rôles principaux par contenu
-- Objectif : Identifier rapidement l'acteur principal de chaque film/série.
SELECT
    C.titre_contenu,
    A.nom_acteur
FROM JOUER_DANS JD
JOIN CONTENU C ON JD.id_contenu = C.id_contenu
JOIN ACTEUR A ON JD.id_acteur = A.id_acteur
WHERE
    JD.role_principal = 'O'; -- En supposant que 'O' signifie 'Oui'



-- Requêtes de type : Requêtes Imbriquées
-- (Utilisation de (NOT) IN, (NOT) EXISTS, ANY, ALL)


-- Requête 16 (Subquery avec IN) : Trouver tous les contenus joués par l'acteur principal de "Chronique d'Andromède"
-- Objectif : Mesurer l'attrait global de l'acteur principal en dehors de la série phare.
SELECT 
    titre_contenu, 
    genre_principal
FROM CONTENU
WHERE id_contenu IN (
    SELECT id_contenu
    FROM JOUER_DANS
    WHERE id_acteur = (
        SELECT id_acteur 
        FROM JOUER_DANS 
        WHERE role_principal = 'O' 
        AND id_contenu = (SELECT id_contenu FROM CONTENU WHERE titre_contenu = 'Chronique d''Andromède')
    )
);

-- Requête 17 (Subquery avec NOT EXISTS) : Trouver les utilisateurs qui n'ont jamais rien mis en favoris
-- Objectif : Identifier les utilisateurs peu engagés avec les fonctionnalités de la plateforme.
SELECT 
    email_utilisateur
FROM UTILISATEUR U
WHERE NOT EXISTS (
    SELECT 1
    FROM FAVORIS F
    JOIN PROFIL P ON F.id_utilisateur = P.id_utilisateur AND F.id_profil = P.id_profil
    WHERE P.id_utilisateur = U.id_utilisateur
);

-- Requête 18 (Subquery avec EXISTS) : Lister les utilisateurs ayant au moins un profil avec restriction d'âge "18+"
-- Objectif : Segmenter les comptes ayant un accès total au catalogue.
SELECT 
    email_utilisateur
FROM UTILISATEUR U
WHERE EXISTS (
    SELECT 1
    FROM PROFIL P
    WHERE P.id_utilisateur = U.id_utilisateur
    AND P.restriction_age_profil = '18+'
);

-- Requête 19 (Subquery avec ALL) : Trouver le ou les contenus plus longs que TOUS les films du genre "Drame"
-- Objectif : Identifier les contenus aux formats exceptionnels (ex: documentaires fleuves, intégrales).
SELECT 
    titre_contenu, 
    duree_minutes
FROM CONTENU
WHERE duree_minutes > ALL (
    SELECT duree_minutes
    FROM CONTENU
    WHERE genre_principal = 'Drame' AND duree_minutes IS NOT NULL
);

-- Requête 20 (Subquery avec ANY) : Trouver les réalisateurs qui ont réalisé AU MOINS UN film d'action
-- Objectif : Identifier les réalisateurs spécialisés ou ayant touché à ce genre populaire.
SELECT nom_realisateur
FROM REALISATEUR
WHERE id_realisateur = ANY (
    SELECT id_realisateur
    FROM CONTENU
    WHERE genre_principal = 'Action'
);