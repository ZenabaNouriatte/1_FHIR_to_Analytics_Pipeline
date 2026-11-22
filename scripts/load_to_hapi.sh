#!/usr/bin/env bash
# Charge les Bundles générés par Synthea dans HAPI FHIR.
# Ordre : hôpitaux et praticiens d'abord (les patients y font référence), puis patients.
#
# Usage (depuis la racine du dépôt) :
#   ./scripts/load_to_hapi.sh                 # lit synthea/output/fhir
#   ./scripts/load_to_hapi.sh autre/dossier   # lit un autre dossier

set -u
shopt -s nullglob   # un motif sans correspondance devient vide (au lieu de "*.json" littéral)

# Racine du dépôt = dossier parent de scripts/, quel que soit l'endroit d'où on lance le script
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

FHIR_URL="${FHIR_URL:-http://localhost:8080/fhir}"
DATA_DIR="${1:-$REPO_ROOT/synthea/output/fhir}"

if [ ! -d "$DATA_DIR" ]; then
  echo "Dossier introuvable : $DATA_DIR"
  exit 1
fi

ok=0
fail=0

# Envoie un Bundle en POST et affiche le résultat
post_bundle() {
  local file="$1"
  local code
  code=$(curl -s -o /tmp/hapi_response.json -w "%{http_code}" \
    -X POST "$FHIR_URL" \
    -H "Content-Type: application/fhir+json" \
    --data-binary @"$file")

  if [ "$code" = "200" ]; then
    echo "OK    $code  $(basename "$file")"
    ok=$((ok + 1))
  else
    echo "ÉCHEC $code  $(basename "$file")"
    # HAPI renvoie un OperationOutcome qui explique l'erreur
    jq -r '.issue[]?.diagnostics' /tmp/hapi_response.json 2>/dev/null | head -n 3
    fail=$((fail + 1))
  fi
}

# 1. Vérifier que HAPI répond
if ! curl -sf "$FHIR_URL/metadata" > /dev/null; then
  echo "HAPI FHIR ne répond pas sur $FHIR_URL (lancer : docker compose up -d)"
  exit 1
fi

# 2. Hôpitaux et praticiens
for f in "$DATA_DIR"/hospitalInformation*.json "$DATA_DIR"/practitionerInformation*.json; do
  post_bundle "$f"
done

# 3. Patients (tous les autres fichiers)
for f in "$DATA_DIR"/*.json; do
  case "$(basename "$f")" in
    hospitalInformation*|practitionerInformation*) continue ;;
  esac
  post_bundle "$f"
done

echo "---"
echo "Terminé : $ok OK, $fail en échec"

# Code de sortie 1 en cas d'échec : make s'arrête au lieu de lancer l'extraction
if [ "$fail" -gt 0 ]; then
  exit 1
fi