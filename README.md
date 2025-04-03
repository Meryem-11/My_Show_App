# My_Show_App

---->  Backend - Node.js & SQLite

Le backend repose sur Node.js avec Express pour créer une API REST connectée à une base de données SQLite. Il gère les requêtes HTTP (GET,

POST, PUT, DELETE) pour la gestion des shows.

Serveur et API : Un serveur Express est configuré pour traiter les requêtes et interagir avec la base SQLite.

Gestion des données : Chaque show stocké en base possède un titre, une description, une catégorie et une image.

Lancement : Le serveur est démarré simplement et devient accessible pour l’application frontend.

----> Frontend - Flutter

L’application mobile, développée avec Flutter, offre une interface fluide et réactive qui communique avec l’API backend.

Page de Connexion : L’utilisateur s’authentifie via email et mot de passe. Un token est généré pour sécuriser les requêtes.

Page d’Accueil : Affiche la liste des shows avec une navigation via Drawer et BottomNavigationBar.

Page de Profil : Permet de consulter et modifier les informations personnelles.

Ajout d’un Show : L’utilisateur peut ajouter un show avec un titre, une description, une catégorie et une image, envoyés au backend 

via une requête POST.

VIDEO DEMONSTRATIVE ( envoyée par mail ) .














