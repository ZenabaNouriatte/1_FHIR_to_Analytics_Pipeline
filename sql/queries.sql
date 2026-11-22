-- Requêtes d'analyse utilisées dans le tableau de bord Metabase.
-- Base : tables patients, encounters, observations, conditions (voir schema.sql).

-- ========== Indicateurs (visualisation « Nombre ») ==========

-- 1. Nombre de patients
SELECT COUNT(*) AS nb_patients FROM patients;

-- 2. Nombre de consultations
SELECT COUNT(*) AS nb_consultations FROM encounters;

-- 3. Nombre de mesures (Observations)
SELECT COUNT(*) AS nb_observations FROM observations;


-- ========== Graphiques ==========

-- 4. Patients par sexe et tranche d'âge (barres)
SELECT gender,
       CASE
         WHEN date_part('year', age(birth_date)) < 18 THEN '0-17'
         WHEN date_part('year', age(birth_date)) < 40 THEN '18-39'
         WHEN date_part('year', age(birth_date)) < 65 THEN '40-64'
         ELSE '65+'
       END AS tranche_age,
       COUNT(*) AS nb_patients
FROM patients
GROUP BY gender, tranche_age
ORDER BY tranche_age;

-- 5. Consultations par année (ligne)
SELECT date_trunc('year', start_date)::date AS annee,
       COUNT(*) AS nb_consultations
FROM encounters
GROUP BY annee
ORDER BY annee;

-- 6. Types de consultation (camembert)
SELECT class AS type_consultation,
       COUNT(*) AS nb
FROM encounters
GROUP BY class
ORDER BY nb DESC;

-- 7. Les 10 diagnostics les plus fréquents (barres horizontales)
SELECT display AS diagnostic,
       COUNT(*) AS nb
FROM conditions
GROUP BY display
ORDER BY nb DESC
LIMIT 10;

-- 8. Les 10 mesures les plus fréquentes (barres horizontales)
SELECT display AS mesure,
       code AS code_loinc,
       COUNT(*) AS nb
FROM observations
GROUP BY display, code
ORDER BY nb DESC
LIMIT 10;

-- 9. Évolution du poids d'un patient (ligne)
--    LOINC 29463-7 = Body weight. Remplacer l'id par celui d'un patient.
SELECT effective_date,
       value AS poids_kg
FROM observations
WHERE code = '29463-7'
  AND patient_id = '5621'
ORDER BY effective_date;

-- 10. Évolution de la tension artérielle d'un patient (ligne, 2 séries)
--     Issue des "component" de l'Observation 85354-9 :
--     8480-6 = systolique, 8462-4 = diastolique. Remplacer l'id du patient.
SELECT effective_date,
       display AS mesure,
       value   AS mm_hg
FROM observations
WHERE code IN ('8480-6', '8462-4')
  AND patient_id = '5621'
ORDER BY effective_date;

-- 11. Statut tabagique actuel des patients (valeur codée -> value_text)
SELECT DISTINCT ON (patient_id)
       patient_id,
       value_text AS statut_tabagique,
       effective_date
FROM observations
WHERE code = '72166-2'
ORDER BY patient_id, effective_date DESC;