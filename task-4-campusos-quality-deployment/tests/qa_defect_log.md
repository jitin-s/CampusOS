# CampusOS --- QA Defect & Vulnerability Log

**Document Version:** 2.0  
**Phase:** Task 4 / Phase 2 — Quality Assurance  
**Author:** Ansh (QA & Deployment Lead)  
**Target:** Engineering Team (Jitin, Kartike, Arko)

---

## Defect Summary Dashboard

| Defect ID | Title | Severity | Affected Task | Status |
| :--- | :--- | :--- | :--- | :--- |
| **DEFECT-001** | Race Condition in Concurrent Queue Token Generation | **High** | Task-1 (Backend) | Open |
| **DEFECT-002** | RLS Policy Permitting Student Direct Transition to `closed` | **Critical** | Task-1 (Database/Security) | Open |
| **DEFECT-003** | Case-Sensitivity and Token Collisions in Smart Matching | **High** | Task-2 (Intelligence) | Open |
| **DEFECT-004** | Infinite Spinner on Network Disconnect During Submission | **High** | Task-1 / Task-3 (Frontend UX) | Open |
| **DEFECT-005** | Multi-Tenant Data Leak in Full-Text Search RPC | **Critical** | Task-1 (Backend) | Open |

---

### DEFECT-001: Race Condition in Concurrent Queue Token Generation
- **Affected Task**: Task-1 (Full-Stack Application & Database)
- **Component**: Digital Queue Service / Supabase PostgreSQL
- **Severity**: **High**
- **Reproduction Steps**:
  1. Open two browser sessions with different student accounts on the same counter (`queue-001`).
  2. Simultaneously click "Join Queue" at the exact same millisecond.
  3. Inspect `queue_tokens` table.
- **Expected Behavior**:
  Sequential token issuance (e.g., Student A receives `#27`, Student B receives `#28`).
- **Actual Behavior**:
  Client-side optimistic read-and-increment (`SELECT current_token_number ... THEN UPDATE`) allows race conditions where both students are issued the identical token number `#27`.
- **Recommended Fix**:
  Implement an atomic PostgreSQL stored procedure or use `UPDATE queues SET current_token_number = current_token_number + 1 RETURNING current_token_number;` within an isolated transaction.

---

### DEFECT-002: RLS Policy Permitting Student Direct Transition to `closed`
- **Affected Task**: Task-1 (Full-Stack Database & Security)
- **Component**: PostgreSQL Row-Level Security (`issues` table)
- **Severity**: **Critical**
- **Reproduction Steps**:
  1. Authenticate as student `usr-student-001`.
  2. Capture JWT and issue direct REST API call:
     `PATCH /rest/v1/issues?id=eq.iss-001` with body `{"status": "closed"}`.
  3. Observe response status.
- **Expected Behavior**:
  Server returns HTTP 403 Forbidden. Students can only update status to `student_verified` after an issue has reached `resolved`.
- **Actual Behavior**:
  If the RLS policy only validates `USING (campus_id = current_user_campus_id())` on `UPDATE`, students can bypass the workflow stepper and close or reassign issues arbitrarily.
- **Recommended Fix**:
  Add `WITH CHECK` constraint to the `UPDATE` policy:
  ```sql
  CREATE POLICY "Enforce issue update roles" ON issues FOR UPDATE
  USING (campus_id = current_user_campus_id())
  WITH CHECK (
    (current_user_is_admin()) OR 
    (assigned_to = auth.uid() AND status IN ('in_progress', 'resolved')) OR
    (reporter_id = auth.uid() AND status = 'student_verified')
  );
  ```

---

### DEFECT-003: Case-Sensitivity and Token Collisions in Smart Matching
- **Affected Task**: Task-2 (Campus Intelligence Engine)
- **Component**: `MatchingService`
- **Severity**: **High**
- **Reproduction Steps**:
  1. Student reports lost item with `brand = "CASIO"`.
  2. Finder reports found item with `brand = "Casio"`.
  3. Run matching engine.
- **Expected Behavior**:
  Match score calculates as `94%` (ignoring uppercase/lowercase differences).
- **Actual Behavior**:
  Exact string equality checks fail (`"CASIO" != "Casio"`), penalizing the score down to `74%`, dropping below the high-confidence threshold.
- **Recommended Fix**:
  Ensure all attribute comparisons normalize strings using `.trim().toLowerCase()` and apply word-boundary token matching to prevent false negative score penalties.

---

### DEFECT-004: Infinite Spinner on Network Disconnect During Submission
- **Affected Task**: Task-1 (Frontend) & Task-3 (UX Design)
- **Component**: Issue Reporting Form (`CampusFixFormScreen`)
- **Severity**: **High**
- **Reproduction Steps**:
  1. Open CampusFix Issue Form.
  2. Enter description and select location.
  3. Disconnect network / enable Chrome DevTools "Offline" preset.
  4. Tap "Submit Issue".
- **Expected Behavior**:
  Loading overlay expires after 8-10 seconds; an inline alert banner displays: "Network connection lost. Tap here to retry". Form fields remain intact.
- **Actual Behavior**:
  The submit button displays an indefinite progress spinner; user cannot tap submit or edit fields, forcing a browser reload that wipes form input.
- **Recommended Fix**:
  Wrap repository network futures with `.timeout(const Duration(seconds: 10))` and handle `TimeoutException` in the Controller state notifier by setting state to `FormSubmissionFailure(isOffline: true)`.

---

### DEFECT-005: Multi-Tenant Data Leak in Full-Text Search RPC
- **Affected Task**: Task-1 (Full-Stack Backend)
- **Component**: Search Database Function
- **Severity**: **Critical**
- **Reproduction Steps**:
  1. Log in as North Campus student (`usr-student-north`).
  2. Perform search for "Calculator" across lost items.
- **Expected Behavior**:
  Results return 0 records because the Casio calculator was lost at Main Campus.
- **Actual Behavior**:
  If the search SQL function executes `SELECT * FROM lost_items WHERE to_tsvector(...) @@ to_tsquery(...)` without an explicit `AND campus_id = current_user_campus_id()`, Main Campus items leak across institutions.
- **Recommended Fix**:
  Enforce explicit `campus_id` parameter or inject `current_user_campus_id()` into all custom stored procedures and RPC endpoints.
