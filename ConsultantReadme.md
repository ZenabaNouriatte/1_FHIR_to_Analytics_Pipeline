# Healthcare Interoperability Series #1
## Legacy-to-FHIR Foundation Pipeline
 
---
 
## Problem Statement
 
Hospital systems often rely on legacy HL7 v2 messages, while modern applications increasingly consume FHIR APIs. This project demonstrates how legacy clinical data can be transformed into interoperable FHIR resources and used for downstream analytics.
 
---
 
## Business Problem
 
Healthcare organizations face challenges when:
 
- Legacy hospital systems emit HL7 v2 messages incompatible with modern platforms
- Modern applications require standardized FHIR APIs to consume clinical data
- Clinical data is siloed and difficult to reuse for analytics or secondary use
- Data interoperability creates bottlenecks across care coordination workflows
**Goal:** Build an end-to-end interoperability pipeline bridging legacy and modern standards — from raw clinical data generation to a functional analytics dashboard.
 
---
 
## Architecture Overview
 
```
Synthea
  │
  │  Synthetic Clinical Data (FHIR R4 JSON)
  ▼
HAPI FHIR Server
  │
  │  FHIR Resources via REST API
  │  Patient · Observation · Encounter · Condition
  ▼
PostgreSQL
  │
  │  Structured relational tables
  ▼
Clinical Dashboard (Metabase / Grafana)
```
 
> Architecture diagram — *to be added*
 
---
 
## Technical Scope
 
**Components:**
 
- Synthetic clinical data generation using Synthea
- FHIR resource ingestion via HAPI FHIR Server REST API
- Patient / Observation / Encounter / Condition modeling
- Relational persistence in PostgreSQL
- Clinical metrics visualization via Metabase or Grafana
- Fully containerized environment via Docker Compose
**Standards Used:**
 
- FHIR R4 resources
- RESTful FHIR APIs
- JSON (bundle serialization)
- SQL (analytical queries)
**Sample FHIR Resources handled:**
 
- `Patient`
- `Observation`
- `Encounter`
- `Condition`
- `MedicationRequest`
---
 
## Example Use Case
 
**Scenario:** A hospital needs an analytical view of its patient population to identify chronic conditions and track clinical indicators over time.
 
This project demonstrates:
 
- Ingestion of synthetic patient data in FHIR R4 format
- Transformation and persistence of nested FHIR resources into relational tables
- REST-based querying of FHIR resources using standard search parameters
- Dashboard visualization of clinical indicators (age distribution, top diagnoses, observation types)
---
 
## Design Decisions
 
| Decision | Choice | Tradeoff |
|---|---|---|
| Data source | Synthea (synthetic FHIR R4) | Safe for learning — no HL7 v2 transformation in this project |
| FHIR server | HAPI FHIR (open source) | Lightweight vs enterprise stack (Azure Health, AWS HealthLake) |
| Storage | PostgreSQL | Simple relational model vs data lake complexity |
| Dashboard | Metabase / Grafana | Open source, Docker-native vs BI enterprise tools |
| Infrastructure | Docker Compose only | Reproducible local environment — no cloud dependency |
 
---
 
## Skills Practiced
 
- ✔ FHIR R4 resource modeling
- ✔ RESTful FHIR API interaction (POST, GET, search parameters)
- ✔ Clinical data pipeline design
- ✔ JSON to relational mapping
- ✔ Docker Compose orchestration
- ✔ SQL analytics on healthcare data
- ✔ Healthcare interoperability foundations
**Target role alignment:**
 
- FHIR Engineer (foundations)
- Integration Engineer (junior)
- Technical Deployment Consultant
---
 
## Future Improvements
 
**Planned in Series #2 — Interoperability Engine:**
 
- Introduce Mirth Connect as HL7 v2 → FHIR mapping engine
- Receive real HL7 v2 ADT and ORU messages from Synthea legacy mode
- Add transformation rules, validation, and error handling channels
- Simulate a real DPI ↔ FHIR server integration scenario
**Planned in Series #3 — Clinical Data Platform:**
 
- Event-driven architecture patterns
- Advanced observability and monitoring
- Scalable clinical data platform design
- IHE workflow integration patterns
---
 
## Repository Roadmap
 
This project is part of the **Healthcare Interoperability Series**:
 
| # | Project | Focus | Status |
|---|---|---|---|
| **#1** | Legacy-to-FHIR Foundation Pipeline | Data modeling · FHIR basics · REST API | ← current |
| #2 | Interoperability Engine | HL7 v2 · Mirth Connect · mapping · routing | planned |
| #3 | Event-Driven Clinical Data Platform | Event patterns · observability · architecture | planned |
 
---
 
## Lessons Learned
 
*To be completed during and after the build.*
 
- ...
---
 
## Author
 
Built as part of a personal learning path in healthcare interoperability engineering.
 
**Zenaba Mogne**
Cloud Engineering — École 42 Paris (RNCP Level 7)
[LinkedIn](#) · [GitHub](#)
