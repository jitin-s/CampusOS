# CampusOS --- Environment Configuration Specification

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative References:**  
- [02_SRD.md Section 12](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md#L365-L382)

---

## 1. Environment Variable Schema

CampusOS requires minimal external configuration to maintain security and simplicity.

### 1.1 Client Configuration (Safe for Flutter / Web)
These values are injected at build time into Flutter Web and Android:

| Variable Name | Required | Description | Example |
| :--- | :--- | :--- | :--- |
| `SUPABASE_URL` | **Yes** | Public Supabase HTTPS endpoint | `https://abcdefghijkl.supabase.co` |
| `SUPABASE_ANON_KEY` | **Yes** | Public Anon API Key protected by Row-Level Security | `eyJhbGciOiJIUzI1Ni...` |
| `CAMPUS_ID` | **Optional** | Default campus UUID for single-institution demo | `c0000001-0000-0000-0000-000000000001` |
| `APP_ENVIRONMENT` | **Optional** | Runtime environment tag | `development` / `staging` / `production` |

### 1.2 Administrative / Backend Secrets (NEVER in Flutter)
| Variable Name | Required | Description | Where Allowed |
| :--- | :--- | :--- | :--- |
| `SUPABASE_SERVICE_ROLE_KEY` | **No** (DB Migrations only) | Admin database bypass key | **CI/CD secret store ONLY**; NEVER commit or bundle! |

---

## 2. `.env.example` Template

Create a file named `.env.example` in the root and in the Task 1 directory for onboarding:

```ini
# CampusOS Client Environment Configuration Template
# Copy this file to .env and fill in your Supabase project credentials.
# DO NOT COMMIT .env TO VERSION CONTROL.

SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
CAMPUS_ID=c0000001-0000-0000-0000-000000000001
APP_ENVIRONMENT=development
```

---

## 3. Flutter Build Injection Syntax

When compiling for Web or Android, provide environment variables using `--dart-define`:

### Web Debug:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL="https://your-project-ref.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

### Web Production Release:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL="https://your-project-ref.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

### Accessing in Dart:
```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String defaultCampusId = String.fromEnvironment(
    'CAMPUS_ID',
    defaultValue: 'c0000001-0000-0000-0000-000000000001',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
```
