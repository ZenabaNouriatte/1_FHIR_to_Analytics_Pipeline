
# 🗺️ Feuille de Route Personnelle
## Healthcare Interoperability Series — Projet #1
### Legacy-to-FHIR Foundation Pipeline
 
# Healthcare Interoperability Series #1

# Legacy-to-FHIR Foundation Pipeline

## Problem Statement

Les systèmes de santé génèrent une quantité importante de données cliniques.

Cependant, ces données sont souvent :

- dispersées dans plusieurs systèmes
- difficiles à exploiter
- peu adaptées à l'analyse

Avant de pouvoir connecter des hôpitaux, construire des plateformes cloud ou utiliser l'IA, il faut comprendre comment les données médicales sont structurées.

Ce projet répond à une question fondamentale :

> Comment une donnée clinique devient-elle une information exploitable ?

---

# Business Problem

Imaginons une plateforme de suivi de patients diabétiques.

Les professionnels de santé souhaitent :

- suivre l'évolution de la glycémie des patients
- identifier les patients à risque
- visualiser rapidement les indicateurs importants
- préparer les consultations grâce à des données fiables

Avant toute analyse avancée, les données doivent être :

1. structurées
2. stockées
3. accessibles

---

# Project Goal

Construire un pipeline de données de santé de bout en bout permettant de :

- générer des patients fictifs
- stocker leurs données au format FHIR
- extraire les données vers une base analytique
- visualiser des indicateurs cliniques

---

# Architecture Overview

```text
                    ┌──────────────┐
                    │   Synthea    │
                    │ Patient Data │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ HAPI FHIR    │
                    │ Server       │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ PostgreSQL   │
                    │ Analytics DB │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Dashboard    │
                    │ Metabase     │
                    └──────────────┘
```

---

# Technologies Used

| Tool | Purpose |
|--------|----------|
| Synthea | Generate realistic synthetic patients |
| HAPI FHIR Server | Store FHIR resources |
| PostgreSQL | Analytics database |
| Metabase | Clinical dashboard |
| Docker Compose | Local environment |
| Python | Data ingestion and extraction |

---

# Healthcare Standards Used

- FHIR R4
- REST API
- JSON

FHIR resources used:

- Patient
- Observation
- Condition
- Encounter

---

# Clinical Use Case

This project simulates a diabetes monitoring platform.

Example indicators:

- Average blood glucose levels
- Number of observations per patient
- Most common diagnoses
- Patients requiring attention

---

# Learning Objectives

After completing this project, I should be able to:

## FHIR

- Read and understand a Bundle
- Navigate between resources
- Query a FHIR API
- Explain the role of Patient, Observation and Condition resources

## Data Engineering

- Extract data from an API
- Transform nested JSON structures
- Load data into PostgreSQL
- Build analytical views

## Healthcare Interoperability

- Understand how clinical data is structured
- Explain why FHIR exists
- Understand the difference between operational and analytical systems

---

# Success Criteria

The project is successful if I can explain without looking at the code:

1. How Synthea generates patients
2. How resources are stored in HAPI FHIR
3. How data is extracted into PostgreSQL
4. How clinical indicators are displayed in the dashboard

---

# Roadmap

## Phase 1 — Environment Setup

### Goal

Launch the complete environment.

### Tasks

- Create Docker Compose stack
- Start PostgreSQL
- Start HAPI FHIR Server
- Start Metabase

### Expected Outcome

All services are accessible locally.

---

## Phase 2 — Understanding FHIR Data

### Goal

Explore generated clinical data.

### Tasks

- Generate synthetic patients using Synthea
- Open Bundle files
- Identify Patient resources
- Identify Observation resources
- Identify Condition resources

### Expected Outcome

Understand the structure of a FHIR Bundle.

---

## Phase 3 — FHIR Data Ingestion

### Goal

Load FHIR resources into HAPI.

### Tasks

- Build Python ingestion script
- POST resources through REST API
- Validate imported resources

### Expected Outcome

Patients are visible in the FHIR server.

---

## Phase 4 — Analytics Extraction

### Goal

Move healthcare data into PostgreSQL.

### Tasks

- Query FHIR API
- Extract Patient data
- Extract Observation data
- Load PostgreSQL tables

### Expected Outcome

Analytics-ready database.

---

## Phase 5 — Clinical Dashboard

### Goal

Visualize healthcare insights.

### Tasks

Create dashboards displaying:

- Average blood glucose values
- Observation counts
- Diagnosis distribution
- Patient population overview

### Expected Outcome

Operational healthcare dashboard.

---

## Phase 6 — Documentation & Publishing

### Goal

Publish a professional GitHub repository.

### Tasks

- Complete README
- Add architecture diagrams
- Add lessons learned
- Publish source code

### Expected Outcome

Portfolio-ready project.

---

# Tradeoffs

| Decision | Choice | Tradeoff |
|-----------|---------|-----------|
| Data Source | Synthea | Safe but simplified |
| FHIR Server | HAPI | Lightweight vs enterprise solution |
| Database | PostgreSQL | Simpler than a data lake |

---

# Future Improvements

Implemented in Project #2:

- HL7 v2 messages
- Mirth Connect
- HL7 → FHIR transformation
- Integration Engine concepts

Implemented in Project #3:

- Event-driven architecture
- Cloud deployment
- AI-assisted workflows
- Observability platform

---

# Series Progression

Healthcare Interoperability Series

- Project #1 → Understanding Healthcare Data ← Current Project
- Project #2 → Connecting Healthcare Systems
- Project #3 → Designing Healthcare Platforms
---
 
*Série Healthcare Interoperability — Projet 1 sur 3*
