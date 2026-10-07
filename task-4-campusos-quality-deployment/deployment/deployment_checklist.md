# CampusOS --- Deployment Checklist

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Target:** Final Hackathon Release (Flutter Web & PWA)

---

## 1. Pre-Deployment Pre-Flight Checks

- [ ] **Branch Status**: Current branch is clean and merged with latest accepted PRs from Tasks 1, 2, and 3.
- [ ] **Tests Passing**:
  - `python task-4-campusos-quality-deployment/tests/automated_verification_runner.py` exits with status `0`.
  - All unit/widget tests passing (`flutter test` or Dart test runners).
- [ ] **Static Analysis**:
  - `flutter analyze` reports zero errors and zero critical warnings.
- [ ] **Secret Audit**:
  - Verified no `.env` or private keys are tracked by Git (`git status --ignored`).
  - No `service_role` Supabase key present in client code.
- [ ] **Backend Database Migration & Seeding**:
  - Supabase database schema deployed (`shared/database-schema/`).
  - Demo dataset seeded (`task-4-campusos-quality-deployment/demo-data/seed_data.sql`).
  - Supabase Auth users created for demo credentials.

---

## 2. Flutter Web / PWA Build Phase

- [ ] **Environment Variable Injection**:
  - Production `SUPABASE_URL` and `SUPABASE_ANON_KEY` prepared.
- [ ] **Execute Release Build**:
  ```bash
  flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
  ```
- [ ] **Build Artifact Verification**:
  - Directory `build/web/` contains:
    - `index.html`
    - `main.dart.js` (or compiled WASM modules)
    - `manifest.json`
    - `flutter_service_worker.js` (if configured)
    - `assets/` directory
- [ ] **PWA Configuration Check**:
  - `manifest.json` specifies correct `short_name: "CampusOS"`, `theme_color`, and icon sizes (192x192, 512x512).
  - Web icons present in `build/web/icons/`.

---

## 3. Hosting & Deployment Execution

- [ ] **Platform Deployment**:
  - Deploy `build/web/` to target hosting provider (e.g., Vercel, Netlify, Cloudflare Pages, Firebase Hosting, or Docker/Nginx).
- [ ] **SPA Routing Fallback**:
  - Server redirects all sub-routes (`/student/**`, `/admin/**`) to `/index.html` (HTTP 200) instead of returning HTTP 404.
- [ ] **HTTPS Enforcement**:
  - SSL/TLS certificate active and valid.
  - HTTP requests automatically redirect to HTTPS.
- [ ] **CORS & Headers**:
  - Security headers present (`X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff`).
  - Supabase storage image domains allowed in Content Security Policy (CSP).

---

## 4. Post-Deployment Live Smoke Tests (5-Minute Smoke Suite)

- [ ] **Application Load**:
  - Open live URL in Chrome (desktop) and mobile browser.
  - Initial load renders splash/login screen in under 3 seconds.
- [ ] **Student Login**:
  - Log in as `student@campusos.internal`.
  - Student home loads with active action cards.
- [ ] **Admin Login**:
  - Open incognito window and log in as `admin@campusos.internal`.
  - Admin dashboard displays active issues, queues, and analytics.
- [ ] **PWA Installation**:
  - "Install CampusOS" prompt appears or can be added to Home Screen on mobile.
- [ ] **Core Workflow Sanity**:
  - Report quick test issue -> Appears immediately on Admin dashboard.
  - Join queue -> Token assigned and visible.

---

## 5. Rollback Plan

- If critical regression occurs on production:
  1. Roll back hosting platform to previous successful deployment commit/snapshot.
  2. Verify database records are intact.
  3. Inform team in project channel.
