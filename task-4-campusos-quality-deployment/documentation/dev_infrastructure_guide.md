# CampusOS --- Development Infrastructure & Onboarding Guide

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Target:** Engineering Team (Jitin, Kartike, Arko, Ansh)

---

## 1. Development Principles & Team Roles

CampusOS is developed as a modular monolith under four strict task ownership boundaries:
- **Task 1 (Jitin)**: Flutter multiplatform application & Supabase integration (`task-1-campusos-fullstack/`)
- **Task 2 (Kartike)**: Pure intelligence algorithms & matching engine (`task-2-campus-intelligence/`)
- **Task 3 (Arko)**: UX, user flows & design system (`task-3-campusos-product-experience/`)
- **Task 4 (Ansh)**: Quality assurance, security audit, deployment & demo data (`task-4-campusos-quality-deployment/`)

---

## 2. Tooling Prerequisites

### 2.1 Frontend & Mobile
- **Flutter SDK**: Version 3.19.x or later (Channel stable).
- **Dart SDK**: 3.3.x or later.
- **Chrome**: For local Flutter Web debugging (`flutter run -d chrome`).
- **Android Studio / Command Line Tools**: For Android APK builds (`flutter run -d android`).

### 2.2 Backend & Data
- **Supabase CLI** or **Supabase Cloud Project**:
  - Local Supabase instance: `supabase start`
  - Or remote Supabase project connected via `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- **Python 3.10+**: For running the automated verification suite:
  ```bash
  python task-4-campusos-quality-deployment/tests/automated_verification_runner.py
  ```

---

## 3. Local Development Quickstart

### Step 1: Clone and Checkout Phase Branch
```bash
git clone https://github.com/AnshX2428/CampusOS.git
cd CampusOS
git checkout -b task-X/phase-Y-<name>
```

### Step 2: Initialize Environment Variables
Create a local `.env` file (do NOT commit this file to git):
```ini
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

### Step 3: Run Frontend Locally
```bash
# Debug in Chrome
flutter run -d chrome --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# Release build validation
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## 4. Pre-Commit Verification Workflow

Before pushing code or opening a Pull Request, run the local verification suite:

1. **Format Code**:
   ```bash
   dart format .
   ```
2. **Static Analysis**:
   ```bash
   flutter analyze
   ```
3. **Execute Automated Quality Harness**:
   ```bash
   python task-4-campusos-quality-deployment/tests/automated_verification_runner.py
   ```
4. **Run Unit / Widget Tests**:
   ```bash
   flutter test
   ```

All four checks MUST pass with zero errors.
