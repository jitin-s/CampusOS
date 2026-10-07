# CampusOS --- Comprehensive Security Checklist

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative References:**  
- [02_SRD.md Section 12](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md#L365-L382)
- [03_ARCHITECTURE.md Section 9](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/03_ARCHITECTURE.md#L323-L346)

---

## 1. Authentication Security Checks
- [ ] **Password Strength Policy**: Minimum 8 characters; enforced at registration/password reset.
- [ ] **Session Invalidation**: Logging out cleanly revokes JWT tokens and wipes local client storage (no lingering auth state in `localStorage` or `sessionStorage`).
- [ ] **Secure Session Tokens**: Supabase JWT tokens are sent over secure HTTPS headers (`Authorization: Bearer <token>`).
- [ ] **No Hardcoded Accounts**: Demo credentials are seeded via migration/scripts, never hardcoded into UI widget logic.
- [ ] **Re-authentication on Critical Actions**: Administrative permission changes or campus configuration updates require an active authenticated session.

---

## 2. Authorization & Role-Based Access Control (RBAC) Checks
- [ ] **Role Verification at Server/DB Level**:
  - PostgreSQL Row Level Security (RLS) policies verify `auth.uid()` and user role from the `users` table.
  - Client-side navigation guards are backed by server-side RLS; student accounts cannot execute admin queries even with crafted HTTP requests.
- [ ] **Route Isolation**:
  - `/admin/**` routes are blocked from `student` and `faculty` roles.
  - Non-admin attempts to access `/admin/dashboard` trigger an immediate redirect and log an authorization event.
- [ ] **Ownership Verification for Writes**:
  - Students can only edit or cancel their own open issues and queue tokens (`WHERE reporter_id = auth.uid()` or `WHERE user_id = auth.uid()`).
  - Claims can only be approved by authorized staff/admins.

---

## 3. Campus Isolation & Multi-Tenancy Defense
- [ ] **Mandatory `campus_id` Boundary**:
  - Every operational table (`issues`, `lost_items`, `found_items`, `queues`, `notices`) contains `campus_id NOT NULL`.
- [ ] **RLS Tenant Isolation Policy**:
  - Queries automatically include `campus_id = current_user_campus_id()`.
  - A user registered under Campus A can under no circumstances read or mutate data belonging to Campus B.
- [ ] **Zero Cross-Campus Leaks**:
  - Search queries (e.g., lost & found item search) are strictly scoped to the user's active campus ID.

---

## 4. Secret & Credential Management
- [ ] **Zero Secrets in Git**:
  - `.env`, `.env.local`, and private key files are strictly listed in `.gitignore`.
  - No Supabase `service_role` key is EVER placed inside the Flutter codebase or bundled into web assets.
  - Flutter Web only receives the public `SUPABASE_ANON_KEY` and `SUPABASE_URL`.
- [ ] **Pre-commit Automated Scanning**:
  - Local verification script (`automated_verification_runner.py`) scans for leaked JWT tokens, GitHub PATs, and private keys.
- [ ] **Environment Configuration**:
  - All external URLs, keys, and environment variables are injected via `String.fromEnvironment` or `--dart-define` during CI/CD build.

---

## 5. Input Validation & Injection Prevention
- [ ] **SQL Injection Immunity**:
  - Supabase client uses parameterized queries exclusively; no raw string concatenation for SQL queries.
- [ ] **Cross-Site Scripting (XSS) Prevention**:
  - All student descriptions, notice bodies, and claim answers are sanitized before rendering.
  - Flutter widgets automatically escape HTML/script tags when rendering text widgets.
- [ ] **Input Constraints Enforced**:
  - Character limit checks on issue descriptions (e.g., max 1000 characters).
  - Valid category and status enums enforced by database `CHECK` constraints.
  - Whitespace trimming on all text inputs.

---

## 6. File Upload & Storage Security
- [ ] **MIME Type Whitelisting**:
  - Allowed file uploads restricted strictly to image types: `image/jpeg`, `image/png`, `image/webp`.
  - Executable files (`.exe`, `.sh`, `.bat`, `.apk`) and script files (`.js`, `.html`, `.php`) are rejected at the storage bucket policy level.
- [ ] **File Size Caps**:
  - Maximum upload size constrained to 5 MB per image.
- [ ] **Isolated Storage Paths**:
  - Uploaded files stored with randomized UUID filenames (e.g., `uploads/issues/uuid-timestamp.jpg`), preventing directory traversal attacks.
- [ ] **Bucket Permission Rules**:
  - Issues and lost/found photos are in authenticated or restricted public-read buckets; write permissions require active session.

---

## 7. Audit & Incident Logging
- [ ] **Structured Security Logging**:
  - Failed authentication attempts, unauthorized route access, and file upload rejections logged with timestamps and error codes.
  - Passwords, auth tokens, and personally identifiable information (PII) are scrubbed from log outputs.
