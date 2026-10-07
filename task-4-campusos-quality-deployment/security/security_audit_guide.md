# CampusOS --- Security Audit & Hardening Guide

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Target:** Engineering Team (Jitin, Kartike, Arko, Ansh)

---

## 1. Overview & Threat Model

CampusOS operates in a multi-user campus environment handling student reports, operational staff assignments, administrative notices, and digital queue tokens. The threat model focuses on four primary risks:

1. **Horizontal Privilege Escalation (Cross-User / Cross-Campus)**: A student attempting to view or modify tickets or queue tokens belonging to another student or another campus.
2. **Vertical Privilege Escalation**: A student accessing `/admin` endpoints, modifying issue status to `resolved` directly, or publishing campus notices.
3. **Secret Leakage in Client Bundles**: Flutter Web applications compile to JavaScript/WASM. Any `service_role` or database admin key embedded in the source code is instantly extractable by anyone using browser DevTools.
4. **Malicious Content / File Upload Exploits**: Uploading executable payloads instead of item photos or injecting XSS payloads into notice descriptions.

---

## 2. Row Level Security (RLS) Implementation Guide

Every PostgreSQL table in Supabase MUST have RLS enabled:

```sql
-- Enable RLS on every table
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE lost_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE found_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE queues ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;
```

### 2.1 Multi-Tenant Campus Isolation Pattern
Create a helper function to retrieve the requesting user's `campus_id` and `role`:

```sql
CREATE OR REPLACE FUNCTION current_user_campus_id()
RETURNS UUID AS $$
  SELECT campus_id FROM users WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_is_admin()
RETURNS BOOLEAN AS $$
  SELECT (role = 'admin') FROM users WHERE id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```

### 2.2 Table Policy Example: Issues
```sql
-- Students can read issues within their campus
CREATE POLICY "Read issues in same campus"
ON issues FOR SELECT
USING (campus_id = current_user_campus_id());

-- Students can insert issues only for their campus and matching reporter_id
CREATE POLICY "Insert own issues"
ON issues FOR INSERT
WITH CHECK (
  campus_id = current_user_campus_id() AND
  reporter_id = auth.uid()
);

-- Only admins or assigned staff can update issue status/assignment
CREATE POLICY "Admin or assigned staff can update issues"
ON issues FOR UPDATE
USING (
  campus_id = current_user_campus_id() AND
  (current_user_is_admin() OR assigned_to = auth.uid())
);
```

---

## 3. Secret Management in Flutter

### 3.1 Strict Separation of Keys
| Key Name | Allowed In Flutter? | Purpose |
| :--- | :--- | :--- |
| `SUPABASE_URL` | **YES** | Public endpoint URL |
| `SUPABASE_ANON_KEY` | **YES** | Public anonymous client key (guarded by RLS) |
| `SUPABASE_SERVICE_ROLE_KEY` | **STRICTLY FORBIDDEN** | Bypasses all RLS policies; NEVER bundle in Flutter! |

### 3.2 Injecting Variables via `--dart-define`
Never commit `.env` files with real keys. Use build flags:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1Ni...
```

Access in Dart via:
```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

---

## 4. File Upload & Storage Policy

Configure Supabase Storage bucket `campus-uploads`:

1. **Max File Size**: 5 MB (`5242880` bytes).
2. **Allowed MIME Types**:
   - `image/jpeg`
   - `image/png`
   - `image/webp`
3. **Storage RLS**:
   - Authenticated users can upload to `issue-photos/{user_id}/*`.
   - Public read allowed for verified image URLs.

---

## 5. Security Pre-Release Audit Script

Run the verification harness before submitting any PR:

```bash
python task-4-campusos-quality-deployment/tests/automated_verification_runner.py
```
This ensures zero secret patterns, regex leaks, or tenant violations exist in the working directory.
