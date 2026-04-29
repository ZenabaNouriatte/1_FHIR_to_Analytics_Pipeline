
# 🗺️ Feuille de Route Personnelle
## Healthcare Interoperability Series — Projet #1
### Legacy-to-FHIR Foundation Pipeline
 
---
 
## Pourquoi ce projet existe
 
Tu construis une série de 3 projets qui racontent une progression :
comprendre la donnée de santé → connecter des systèmes → concevoir des plateformes.
 
Ce premier projet répond à une question simple :
 
> **Comment une donnée clinique brute devient une information exploitable ?**
 
C'est la fondation. Sans elle, les projets suivants n'ont pas de sens.
 
---
 
## Ce que tu vas construire
 
Un pipeline de bout en bout qui :
 
1. **Génère** des patients fictifs avec leurs données médicales (diagnostics, prescriptions, mesures)
2. **Stocke** ces données dans un serveur FHIR — le standard moderne de l'interopérabilité en santé
3. **Extrait** ces données vers une base relationnelle classique pour l'analyse
4. **Visualise** les données dans un dashboard clinique
À la fin, tu as un environnement qui tourne en une commande, des données cliniques qui circulent d'un bout à l'autre, et un dashboard qu'on peut montrer.
 
---
 
## Ce que ce projet te rapporte
 
Après ce projet, tu seras capable de :
 
- Lire et comprendre un bundle FHIR R4 sans aide
- Interagir avec une API FHIR (envoyer, récupérer, rechercher des ressources)
- Expliquer comment une donnée médicale est structurée selon le standard FHIR
- Construire un pipeline données de santé de zéro
- Parler de tout ça en entretien avec des exemples concrets
---
 
## Les outils — ce qu'ils font en une phrase
 
| Outil | Ce qu'il fait dans ce projet |
|---|---|
| **Synthea** | Génère des patients fictifs réalistes au format FHIR |
| **HAPI FHIR Server** | Serveur qui stocke les ressources FHIR et expose une API REST |
| **PostgreSQL** | Base de données classique pour l'analyse |
| **Metabase ou Grafana** | Dashboard connecté à PostgreSQL |
| **Docker Compose** | Lance tout l'environnement en une seule commande |
| **Python** | Scripts de connexion entre les blocs |
 
Tu n'as pas besoin de tout maîtriser avant de commencer. Tu apprendras en faisant.
 
---
 
## Compétences à avoir / acquérir
 
### Avant de commencer — lire seulement
- Comprendre ce qu'est un Bundle FHIR : un conteneur qui regroupe plusieurs ressources médicales (patient + diagnostics + mesures) dans un seul fichier JSON
- Savoir faire une requête HTTP POST en Python avec la librairie `requests`
- Savoir lancer un `docker-compose up`
### Pendant le projet — tu apprendras en faisant
- La syntaxe des requêtes de recherche FHIR (différente d'une API classique)
- Comment aplatir un JSON imbriqué en table SQL
- Comment les ressources FHIR se référencent entre elles
### Indicateur que tu as réussi
> Tu peux expliquer à voix haute, sans regarder le code, comment une donnée part de Synthea et arrive dans le dashboard.
 
---
 
## Feuille de Route
 
### 🟦 Étape 1 — Poser l'environnement
**Ce qu'il faut faire :** Lancer tous les outils ensemble via Docker Compose et vérifier que chacun répond.
 
**Résultat attendu :** HAPI FHIR Server accessible dans le navigateur, PostgreSQL connecté, Metabase/Grafana qui démarre.
 
---
 
### 🟦 Étape 2 — Générer et observer des données
**Ce qu'il faut faire :** Utiliser Synthea pour créer une dizaine de patients fictifs. Ouvrir les fichiers générés et les lire.
 
**Résultat attendu :** Tu comprends la structure d'un fichier Bundle. Tu sais identifier les ressources `Patient`, `Observation`, `Condition` à l'intérieur.
 
> 💡 Prends le temps ici. Comprendre le Bundle avant de coder te fera gagner beaucoup de temps ensuite.
 
---
 
### 🟦 Étape 3 — Envoyer les données dans le serveur FHIR
**Ce qu'il faut faire :** Écrire un script Python qui lit les fichiers Synthea et les poste sur HAPI FHIR Server via l'API REST.
 
**Résultat attendu :** Les patients sont visibles dans le serveur FHIR. Tu peux les retrouver via une requête GET dans le navigateur ou Postman.
 
---
 
### 🟦 Étape 4 — Extraire les données vers PostgreSQL
**Ce qu'il faut faire :** Écrire un script Python qui appelle l'API FHIR, récupère les ressources, et les insère dans des tables PostgreSQL.
 
**Résultat attendu :** Tu as des tables `patients`, `observations`, `conditions` remplies. Une requête SQL simple te retourne des résultats.
 
---
 
### 🟦 Étape 5 — Construire le dashboard
**Ce qu'il faut faire :** Connecter Metabase ou Grafana à PostgreSQL et créer quelques visualisations cliniques.
 
**Résultat attendu :** Un dashboard avec au minimum 3 graphiques — par exemple la répartition par âge, les diagnostics les plus fréquents, les types de mesures enregistrées.
 
---
 
### 🟦 Étape 6 — Documenter et publier
**Ce qu'il faut faire :** Compléter le README public du repo, noter ce que tu as appris, pousser sur GitHub.
 
**Résultat attendu :** Un repo propre, un README qui explique le projet clairement, un historique de commits lisible.
 
---
 
## Ce que ce projet ne fait pas — et c'est volontaire
 
Ce projet utilise des données déjà en format FHIR (générées par Synthea).
 
Il ne traite pas de données legacy HL7 v2. Il ne gère pas la transformation entre formats.
 
C'est exactement ce que le **Projet #2** va introduire.
 
---
 
## Lien avec le Projet #2
 
Le Projet #1 répond à la question : *"Je comprends comment fonctionne FHIR."*
 
Le Projet #2 va poser la vraie question du terrain hospitalier :
 
> **Comment intégrer un système legacy qui ne parle pas FHIR ?**
 
Dans le Projet #2, tu vas :
- Recevoir des messages au format **HL7 v2** — le format encore dominant dans 80% des hôpitaux français
- Utiliser **Mirth Connect** pour les transformer en ressources FHIR
- Envoyer le résultat vers le même serveur HAPI FHIR que tu auras construit ici
C'est pour ça que ce premier projet est indispensable : il construit le socle sur lequel tout le reste s'appuie.
 
---
 
*Série Healthcare Interoperability — Projet 1 sur 3*
