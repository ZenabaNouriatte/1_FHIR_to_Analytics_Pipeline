# Projet 1 — Synthea -> HAPI FHIR -> Python -> PostgreSQL -> Metabase
#
# Exemples :
#   make up            démarre les conteneurs
#   make run           pipeline complet avec 10 patients
#   make run N=50      pipeline complet avec 50 patients

N ?= 10
PYTHON       = .venv/bin/python
FHIR_URL     = http://localhost:8080/fhir
METABASE_URL = http://localhost:3000

.PHONY: help up down venv generate reset-hapi wait-hapi load extract run urls

help:
	@echo "Commandes disponibles :"
	@echo "  make up           Démarre HAPI FHIR, PostgreSQL et Metabase"
	@echo "  make down         Arrête et supprime les conteneurs (les données HAPI sont perdues)"
	@echo "  make venv         Crée l'environnement Python et installe les dépendances (une fois)"
	@echo "  make generate     Génère N patients avec Synthea (défaut : N=$(N))"
	@echo "  make reset-hapi   Recrée le conteneur HAPI FHIR (le vide de ses données)"
	@echo "  make load         Charge les Bundles Synthea dans HAPI FHIR"
	@echo "  make extract      Extrait les données de HAPI vers PostgreSQL"
	@echo "  make run          Tout enchaîne : generate, reset-hapi, load, extract"
	@echo "  make urls         Affiche les adresses des services"
	@echo ""
	@echo "Exemples :"
	@echo "  make run          Pipeline complet avec 10 patients (valeur par défaut)"
	@echo "  make run N=50     Pipeline complet avec 50 patients"
	@echo "  make generate N=5 Génère seulement 5 patients, sans les charger"

up:
	docker compose up -d
	@$(MAKE) --no-print-directory urls

down:
	docker compose down

venv:
	python3 -m venv .venv
	$(PYTHON) -m pip install -r requirements.txt

# Supprime l'ancienne sortie pour ne pas mélanger anciens et nouveaux patients
generate:
	rm -rf synthea/output
	cd synthea && java -jar synthea-with-dependencies.jar -p $(N)

# HAPI garde ses données dans le conteneur : le recréer = repartir de zéro (évite les doublons)
reset-hapi:
	docker compose up -d --force-recreate hapi_fhir

wait-hapi:
	@echo "Attente de HAPI FHIR..."
	@until curl -sf $(FHIR_URL)/metadata > /dev/null; do sleep 5; done
	@echo "HAPI FHIR est prêt."

load: wait-hapi
	./scripts/load_to_hapi.sh

extract:
	$(PYTHON) scripts/extract_fhir_to_postgres.py

run: generate reset-hapi load extract urls

urls:
	@echo ""
	@echo "Serveur FHIR (interface web) : http://localhost:8080"
	@echo "API FHIR                     : $(FHIR_URL)"
	@echo "Metabase                     : $(METABASE_URL)"
	