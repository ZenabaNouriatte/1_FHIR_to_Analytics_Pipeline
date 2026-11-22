 
N ?= 10
PYTHON       = .venv/bin/python
FHIR_URL     = http://localhost:8080/fhir
METABASE_URL = http://localhost:3000
 
# Affiche un titre d'étape en gras bleu. Usage : $(call title,Texte du titre)
# (pas de virgule dans le texte : make s'en sert pour séparer les arguments)
define title
	@printf "\n\033[1;34m==================================================\033[0m\n"
	@printf "\033[1;34m  %s\033[0m\n" "$(1)"
	@printf "\033[1;34m==================================================\033[0m\n"
endef
 
.PHONY: help up down venv generate reset-hapi wait-hapi load extract check run urls
 
help:
	@echo "Commandes disponibles :"
	@echo "  make up           Démarre HAPI FHIR, PostgreSQL et Metabase"
	@echo "  make down         Arrête et supprime les conteneurs (les données HAPI sont perdues)"
	@echo "  make venv         Crée l'environnement Python et installe les dépendances (une fois)"
	@echo "  make generate     Génère N patients avec Synthea (défaut : N=$(N))"
	@echo "  make reset-hapi   Recrée le conteneur HAPI FHIR (le vide de ses données)"
	@echo "  make load         Charge les Bundles Synthea dans HAPI FHIR"
	@echo "  make extract      Extrait les données de HAPI vers PostgreSQL"
	@echo "  make check        Contrôle de réconciliation (complétude et qualité)"
	@echo "  make run          Tout enchaîne : generate, reset-hapi, load, extract, check"
	@echo "  make urls         Affiche les adresses des services"
	@echo ""
	@echo "Exemples :"
	@echo "  make run          Pipeline complet avec 10 patients (valeur par défaut)"
	@echo "  make run N=50     Pipeline complet avec 50 patients"
	@echo "  make generate N=5 Génère seulement 5 patients, sans les charger"
 
up:
	$(call title,Démarrage des conteneurs)
	docker compose up -d
	@$(MAKE) --no-print-directory urls
 
down:
	$(call title,Arrêt des conteneurs)
	docker compose down
 
venv:
	$(call title,Création de l'environnement Python)
	python3 -m venv .venv
	$(PYTHON) -m pip install -r requirements.txt
 
# Supprime l'ancienne sortie pour ne pas mélanger anciens et nouveaux patients
generate:
	$(call title,Génération de $(N) patients avec Synthea)
	rm -rf synthea/output
	cd synthea && java -jar synthea-with-dependencies.jar -p $(N)
 
# HAPI garde ses données dans le conteneur : le recréer = repartir de zéro (évite les doublons)
reset-hapi:
	$(call title,Remise à zéro de HAPI FHIR)
	docker compose up -d --force-recreate hapi_fhir
 
wait-hapi:
	@echo "Attente de HAPI FHIR..."
	@until curl -sf $(FHIR_URL)/metadata > /dev/null; do sleep 5; done
	@echo "HAPI FHIR est prêt."
 
load: wait-hapi
	$(call title,Chargement des Bundles dans HAPI FHIR)
	./scripts/load_to_hapi.sh
 
extract:
	$(call title,Extraction HAPI FHIR vers PostgreSQL)
	$(PYTHON) scripts/extract_fhir_to_postgres.py
 
check:
	$(call title,Contrôle de réconciliation)
	$(PYTHON) scripts/check_quality.py
 
run: generate reset-hapi load extract check urls
 
urls:
	$(call title,Accès aux services)
	@echo "Serveur FHIR (interface web) : http://localhost:8080"
	@echo "API FHIR                     : $(FHIR_URL)"
	@echo "Metabase                     : $(METABASE_URL)"