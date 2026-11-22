"""
Extraction FHIR -> PostgreSQL.

Lit les ressources Patient, Encounter, Observation et Condition sur HAPI FHIR
(API REST, avec pagination), les met à plat et les insère dans PostgreSQL.

À chaque lancement, les tables sont vidées puis rechargées (rechargement complet).

Usage (depuis la racine du dépôt, venv activé) :
    python scripts/extract_fhir_to_postgres.py
"""

import os

import psycopg
import requests
from dotenv import load_dotenv

load_dotenv()  # lit le fichier .env

FHIR_URL = os.getenv("FHIR_URL", "http://localhost:8080/fhir")
PAGE_SIZE = 500

DB_PARAMS = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "dbname": os.getenv("POSTGRES_DB"),
}


# ---------- 1. Lecture sur HAPI FHIR ----------

def fetch_all(resource_type):
    """Renvoie toutes les ressources d'un type, en suivant les liens 'next'."""
    url = f"{FHIR_URL}/{resource_type}?_count={PAGE_SIZE}"
    while url:
        response = requests.get(url, headers={"Accept": "application/fhir+json"}, timeout=60)
        response.raise_for_status()  # arrête le script si HAPI renvoie une erreur
        bundle = response.json()

        for entry in bundle.get("entry", []):
            yield entry["resource"]

        # Cherche le lien vers la page suivante ; s'il n'y en a pas, on s'arrête
        url = None
        for link in bundle.get("link", []):
            if link["relation"] == "next":
                url = link["url"]


# ---------- 2. Petites fonctions utilitaires ----------

def first(items):
    """Premier élément d'une liste, ou {} si la liste est vide ou absente."""
    return items[0] if items else {}


def ref_id(reference):
    """'Patient/1157' -> '1157'. Renvoie None si pas de référence."""
    if not reference or "reference" not in reference:
        return None
    return reference["reference"].split("/")[-1]


# ---------- 3. Mise à plat : une ressource FHIR -> une ligne SQL ----------

# Chaque fonction renvoie une LISTE de lignes : en général une seule,
# mais une Observation avec des "component" en donne plusieurs.

def flatten_patient(r):
    name = first(r.get("name"))
    return [(
        r["id"],
        name.get("family"),
        first(name.get("given")) or None,
        r.get("gender"),
        r.get("birthDate"),
        r.get("deceasedDateTime"),
        first(r.get("address")).get("city"),
    )]


def flatten_encounter(r):
    encounter_type = first(r.get("type"))
    return [(
        r["id"],
        ref_id(r.get("subject")),
        r.get("class", {}).get("code"),
        first(encounter_type.get("coding")).get("display") or encounter_type.get("text"),
        r.get("period", {}).get("start"),
        r.get("period", {}).get("end"),
    )]


def extract_value(item):
    """
    Lit la valeur d'une Observation (ou d'un component), quel que soit son type FHIR.
    Renvoie (value, unit, value_text).
    """
    if "valueQuantity" in item:                       # ex. 124.5 cm
        quantity = item["valueQuantity"]
        return quantity.get("value"), quantity.get("unit"), None
    if "valueCodeableConcept" in item:                # ex. "Never smoker" (code SNOMED)
        concept = item["valueCodeableConcept"]
        return None, None, concept.get("text") or first(concept.get("coding")).get("display")
    if "valueString" in item:                         # texte libre
        return None, None, item["valueString"]
    return None, None, None                           # pas de valeur (ex. panel avec components)


def flatten_observation(r):
    category = first(first(r.get("category")).get("coding"))
    # Champs communs à toutes les lignes issues de cette Observation
    patient_id = ref_id(r.get("subject"))
    encounter_id = ref_id(r.get("encounter"))
    effective_date = r.get("effectiveDateTime")

    def make_row(row_id, item):
        coding = first(item.get("code", {}).get("coding"))
        value, unit, value_text = extract_value(item)
        return (
            row_id, r["id"], patient_id, encounter_id,
            category.get("code"), coding.get("code"), coding.get("display"),
            value, unit, value_text, effective_date,
        )

    components = r.get("component")
    if components:
        # ex. tension artérielle : une ligne systolique + une ligne diastolique
        return [make_row(f"{r['id']}-{i}", c) for i, c in enumerate(components)]
    return [make_row(r["id"], r)]


def flatten_condition(r):
    coding = first(r.get("code", {}).get("coding"))
    return [(
        r["id"],
        ref_id(r.get("subject")),
        ref_id(r.get("encounter")),
        coding.get("code"),
        coding.get("display"),
        r.get("onsetDateTime"),
        r.get("abatementDateTime"),
    )]


# ---------- 4. Chargement dans PostgreSQL ----------

# Ordre important : les tables référencées (patients, encounters) d'abord
TABLES = [
    ("Patient", "patients", flatten_patient,
     "id, family_name, given_name, gender, birth_date, deceased_date, city"),
    ("Encounter", "encounters", flatten_encounter,
     "id, patient_id, class, type, start_date, end_date"),
    ("Observation", "observations", flatten_observation,
     "id, fhir_id, patient_id, encounter_id, category, code, display,"
     " value, unit, value_text, effective_date"),
    ("Condition", "conditions", flatten_condition,
     "id, patient_id, encounter_id, code, display, onset_date, abatement_date"),
]


def hapi_is_empty():
    """Vrai si HAPI ne contient aucun patient."""
    response = requests.get(
        f"{FHIR_URL}/Patient?_summary=count",
        headers={"Accept": "application/fhir+json"},
        timeout=60,
    )
    response.raise_for_status()
    return response.json()["total"] == 0


def main():
    # Sécurité : si HAPI est vide, on ne touche pas à PostgreSQL
    # (sinon le TRUNCATE viderait les tables et les dashboards)
    if hapi_is_empty():
        print("HAPI FHIR ne contient aucun patient : extraction annulée, PostgreSQL n'a pas été modifié.")
        print("Charger d'abord les données : make load")
        raise SystemExit(1)

    with psycopg.connect(**DB_PARAMS) as conn:
        with conn.cursor() as cur:
            # Rechargement complet : on vide les 4 tables
            cur.execute("TRUNCATE conditions, observations, encounters, patients")

            for resource_type, table, flatten, columns in TABLES:
                rows = [row for r in fetch_all(resource_type) for row in flatten(r)]
                placeholders = ", ".join(["%s"] * len(columns.split(",")))
                cur.executemany(
                    f"INSERT INTO {table} ({columns}) VALUES ({placeholders})",
                    rows,
                )
                print(f"{table:<13} {len(rows):>7} lignes")

        # Sortie du bloc 'with' sans erreur -> COMMIT automatique.
        # En cas d'erreur -> ROLLBACK : la base reste dans son état précédent.
    print("Terminé.")


if __name__ == "__main__":
    main()