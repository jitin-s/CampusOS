# CampusOS --- Task 4: Quality & Deployment

**Task Owner:** Ansh (QA & Deployment Lead)  
**Status:** Phase 2 Complete (Quality Assurance Suite & Validation)

---

## Directory Overview

```text
task-4-campusos-quality-deployment/
├── tests/
│   ├── qa_plan_and_test_matrix.md      # Comprehensive 14-dimension QA test matrix
│   ├── qa_defect_log.md                # Discovered defect & vulnerability log
│   ├── phase2_validation_suite.py      # Executable state machine & RBAC validator
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
│   ├── phase2_expanded_datasets.json   # Multi-campus, multi-status expanded demo data
│   ├── phase2_expanded_datasets.sql    # Multi-campus expanded PostgreSQL SQL seed
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

## How to Run Quality & Verification Suites

### Run Phase 2 QA & MVP Validation Suite:
```bash
python task-4-campusos-quality-deployment/tests/phase2_validation_suite.py
```
Validates:
1. State machine rules (CampusFix, Lost & Found, Queue token progression).
2. Illegal/out-of-order transition blocks.
3. Duplicate request prevention (e.g. concurrent queue tokens).
4. RBAC route enforcement and multi-tenant isolation.
5. Input validation & XSS sanitization.
6. Secret scanning.

### Run Phase 1 Dataset & Matching Engine Benchmark:
```bash
python task-4-campusos-quality-deployment/tests/automated_verification_runner.py
```

