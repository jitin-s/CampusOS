# CampusOS --- Task 4: Quality & Deployment

**Task Owner:** Ansh (QA & Deployment Lead)  
**Status:** Phase 1 Complete (Development Infrastructure)

---

## Directory Overview

```text
task-4-campusos-quality-deployment/
├── tests/
│   ├── qa_checklist.md                 # Full UI, UX & functional checklist
│   ├── mvp_acceptance_checklist.md     # Gate review & acceptance criteria
│   ├── e2e_scenarios.md                # 5 critical end-to-end test scenarios
│   └── automated_verification_runner.py# Executable test & security audit runner
│
├── security/
│   ├── security_checklist.md           # Pre-commit & pre-release security verification
│   └── security_audit_guide.md         # RLS, tenant isolation & secret audit manual
│
├── deployment/
│   ├── deployment_checklist.md         # Step-by-step release checklist
│   ├── flutter_web_pwa_deployment.md   # Flutter Web & PWA hosting guide
│   └── docker/
│       ├── nginx.conf                  # Nginx configuration with SPA & WASM support
│       └── Dockerfile                  # Containerized web deployment template
│
├── demo-data/
│   ├── demo_data_specification.md      # Persona & data schema specification
│   ├── seed_data.json                  # Interconnected JSON demo dataset
│   └── seed_data.sql                   # Supabase / PostgreSQL SQL seed script
│
└── documentation/
    ├── dev_infrastructure_guide.md     # Team onboarding & prerequisites
    ├── branch_protection_and_pr_policy.md# Git branching & review policies
    └── environment_configuration.md    # Environment variables & .env specification
```

---

## How to Run Quality & Verification Checks

From the project root:

```bash
python task-4-campusos-quality-deployment/tests/automated_verification_runner.py
```

This verifies:
1. Demo seed data schema integrity and foreign keys.
2. Mandatory `campus_id` multi-tenant isolation.
3. Deterministic matching logic benchmark (Lost & Found).
4. Issue classification and priority rules.
5. Codebase scan for accidentally exposed secrets.
