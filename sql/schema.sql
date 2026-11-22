
-- Schéma analytique : données FHIR (HAPI) mises à plat pour PostgreSQL.
-- Une table par type de ressource. Les colonnes *_id reprennent les références FHIR
-- (ex. "Patient/1157" -> patient_id = '1157').
--
-- Les id sont en TEXT : en FHIR, un id est une chaîne de caractères,
-- même si HAPI attribue ici des nombres.
 
CREATE TABLE IF NOT EXISTS patients (
    id              TEXT PRIMARY KEY,
    family_name     TEXT,
    given_name      TEXT,
    gender          TEXT,
    birth_date      DATE,
    deceased_date   TIMESTAMPTZ,      -- vide si le patient est vivant
    city            TEXT
);
 
CREATE TABLE IF NOT EXISTS encounters (
    id              TEXT PRIMARY KEY,
    patient_id      TEXT NOT NULL REFERENCES patients(id),
    class           TEXT,             -- ex. AMB (ambulatoire), EMER (urgence), IMP (hospitalisation)
    type            TEXT,             -- libellé du type de consultation
    start_date      TIMESTAMPTZ,
    end_date        TIMESTAMPTZ
);
 
-- Une ligne par mesure. Une Observation FHIR avec des "component"
-- (ex. tension artérielle : systolique + diastolique) donne une ligne par component.
CREATE TABLE IF NOT EXISTS observations (
    id              TEXT PRIMARY KEY, -- id FHIR, ou "<id FHIR>-<n°>" pour un component
    fhir_id         TEXT NOT NULL,    -- id de l'Observation dans HAPI
    patient_id      TEXT NOT NULL REFERENCES patients(id),
    encounter_id    TEXT REFERENCES encounters(id),   -- peut être vide
    category        TEXT,             -- ex. vital-signs, laboratory, survey
    code            TEXT,             -- code LOINC
    display         TEXT,             -- libellé lisible
    value           NUMERIC,          -- valeur numérique (valueQuantity)
    unit            TEXT,
    value_text      TEXT,             -- valeur codée ou texte (valueCodeableConcept, valueString)
    effective_date  TIMESTAMPTZ       -- date clinique de la mesure
);
 
CREATE TABLE IF NOT EXISTS conditions (
    id              TEXT PRIMARY KEY,
    patient_id      TEXT NOT NULL REFERENCES patients(id),
    encounter_id    TEXT REFERENCES encounters(id),
    code            TEXT,             -- code SNOMED CT
    display         TEXT,
    onset_date      TIMESTAMPTZ,      -- début du diagnostic
    abatement_date  TIMESTAMPTZ       -- fin du diagnostic (vide si toujours actif)
);