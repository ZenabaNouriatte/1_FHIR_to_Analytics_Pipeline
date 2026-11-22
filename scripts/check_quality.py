"""
Contrôle de réconciliation après le chargement HAPI FHIR -> PostgreSQL.

1. Complétude : chaque ressource présente dans HAPI est-elle bien dans PostgreSQL ?
2. Qualité : champs vides, valeurs manquantes, unités incohérentes, dates incohérentes.

Code de sortie :
    0 = complétude OK (des avertissements de qualité sont possibles)
    1 = erreur de complétude (des données ont été perdues)

Usage (depuis la racine du dépôt) :
    .venv/bin/python scripts/check_quality.py
"""

import os
import sys

import psycopg
import requests
from dotenv import load_dotenv

load_dotenv()

FHIR_URL = os.getenv("FHIR_URL", "http://localhost:8080/fhir")

DB_PARAMS = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "dbname": os.getenv("POSTGRES_DB"),
}

# Type de ressource FHIR -> table PostgreSQL
RESOURCES = {
    "Patient": "patients",
    "Encounter": "encounters",
    "Observation": "observations",
    "Condition": "conditions",
}


def hapi_count(resource_type):
    """Nombre de ressources d'un type dans HAPI (sans les télécharger)."""
    response = requests.get(
        f"{FHIR_URL}/{resource_type}?_summary=count",
        headers={"Accept": "application/fhir+json"},
        timeout=60,
    )
    response.raise_for_status()
    return response.json()["total"]


def sql_value(cur, query):
    """Exécute une requête qui renvoie une seule valeur."""
    cur.execute(query)
    return cur.fetchone()[0]


def check_completeness(cur):
    """Compare HAPI et PostgreSQL. Renvoie le nombre d'écarts."""
    print("Complétude (HAPI -> PostgreSQL)")
    errors = 0
    for resource_type, table in RESOURCES.items():
        in_hapi = hapi_count(resource_type)
        in_pg = sql_value(cur, f"SELECT COUNT(*) FROM {table}")
        status = "OK" if in_hapi == in_pg else "ÉCART"
        if status != "OK":
            errors += 1
        print(f"  {resource_type:<12} {in_pg:>7} / {in_hapi:<7} {status}")
    return errors


def check_quality(cur):
    """Contrôles de qualité. Renvoie le nombre d'avertissements."""
    print("\nQualité")
    warnings = 0

    checks = [
        ("Patients sans sexe ou date de naissance",
         "SELECT COUNT(*) FROM patients WHERE gender IS NULL OR birth_date IS NULL"),
        ("Observations sans code",
         "SELECT COUNT(*) FROM observations WHERE code IS NULL"),
        ("Conditions sans code",
         "SELECT COUNT(*) FROM conditions WHERE code IS NULL"),
        ("Consultations avant la naissance du patient",
         """SELECT COUNT(*) FROM encounters e JOIN patients p ON p.id = e.patient_id
            WHERE e.start_date::date < p.birth_date"""),
        ("Consultations qui finissent avant de commencer",
         "SELECT COUNT(*) FROM encounters WHERE end_date < start_date"),
    ]
    for label, query in checks:
        count = sql_value(cur, query)
        if count > 0:
            warnings += 1
        print(f"  {label:<48} {count:>6}")

    # Observations sans valeur numérique : on affiche les codes les plus touchés
    missing = sql_value(cur, "SELECT COUNT(*) FROM observations WHERE value IS NULL")
    print(f"  {'Observations sans valeur numérique':<48} {missing:>6}")
    if missing > 0:
        warnings += 1
        cur.execute("""
            SELECT code, display, COUNT(*) AS nb
            FROM observations
            WHERE value IS NULL
            GROUP BY code, display
            ORDER BY nb DESC
            LIMIT 3
        """)
        for code, display, nb in cur.fetchall():
            print(f"      dont {(code or '-'):<8} {(display or '')[:40]:<40} {nb:>6}")

    # Un même code LOINC mesuré dans plusieurs unités : valeurs non comparables
    cur.execute("""
        SELECT code, display, STRING_AGG(DISTINCT unit, ', ')
        FROM observations
        WHERE unit IS NOT NULL
        GROUP BY code, display
        HAVING COUNT(DISTINCT unit) > 1
    """)
    multi_units = cur.fetchall()
    print(f"  {'Codes mesurés dans plusieurs unités':<48} {len(multi_units):>6}")
    if multi_units:
        warnings += 1
        for code, display, units in multi_units[:3]:
            print(f"      {(code or '-'):<8} {(display or '')[:30]:<30} ({units})")

    return warnings


def main():
    with psycopg.connect(**DB_PARAMS) as conn:
        with conn.cursor() as cur:
            errors = check_completeness(cur)
            warnings = check_quality(cur)

    print()
    if errors:
        print(f"Résultat : ÉCHEC ({errors} écart(s) de complétude, {warnings} avertissement(s))")
        sys.exit(1)
    print(f"Résultat : OK ({warnings} avertissement(s))")


if __name__ == "__main__":
    main()