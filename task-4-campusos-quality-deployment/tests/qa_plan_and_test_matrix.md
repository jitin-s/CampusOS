# CampusOS --- Phase-2 QA Plan & Comprehensive Test Matrix

**Document Version:** 2.0  
**Phase:** Task 4 / Phase 2 — Quality Assurance  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative References:**  
- [01_PRD.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/01_PRD.md)
- [02_SRD.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md)
- [03_ARCHITECTURE.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/03_ARCHITECTURE.md)
- [04_UX_DESIGN.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/04_UX_DESIGN.md)

---

## 1. Executive QA Plan & Scope

The Phase-2 QA suite establishes the formal verification protocols for the entire CampusOS MVP. This plan tests full closed-loop lifecycles rather than isolated components, enforcing the core mechanism:
`Discover / Report / Request → Classify → Prioritize → Route → Assign → Track → Resolve → Verify → Analyze`.

### 1.1 Core Test Dimensions
Each workflow is systematically evaluated against 14 critical dimensions:
1. **Valid Input**: Happy-path data formats, boundary limits.
2. **Invalid Input**: Malformed types, invalid formats, unparseable dates.
3. **Empty Input**: Missing mandatory form values, blank descriptions.
4. **Duplicate Requests**: Double-clicks, concurrent queue joins, redundant ticket reporting.
5. **Unauthorized Access**: Unauthenticated API/route requests redirected to login.
6. **Incorrect Role**: Students accessing admin dashboards, technicians publishing campus notices.
7. **Missing Data**: Records lacking `campus_id`, location reference, or reporter foreign keys.
8. **Failed Network Requests**: Offline mode, HTTP 500/503 responses, connection timeouts.
9. **Loading States**: Shimmer/skeleton screens, disabled submit buttons, no infinite spinners.
10. **Failed Submissions**: Graceful inline error banners with retry capability.
11. **Invalid Status Transitions**: Enforcing strict workflow state machine graphs.
12. **Responsive Web & PWA**: Mobile (360-430px), tablet, desktop (1280px+), manifest, service worker.
13. **Security Issues**: SQL injection, XSS script injection, cross-campus horizontal privilege escalation.
14. **Secret Exposure**: Pre-commit scanning for leaked tokens and private keys.

---

## 2. Detailed Test Matrix by Domain

### 2.1 CampusFix (Issue Management)
Lifecycle: `Reported → Verified → Assigned → In Progress → Resolved → Student Verified → Closed`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-CF-01** | Valid Input | Student submits issue with category, location, text description, and photo. | Issue created with status `reported`, auto-classified, prioritized, and routed to correct department. | Critical |
| **TC-CF-02** | Empty Input | Student attempts to submit issue with blank description or unselected location. | Form submission blocked; inline validation highlights required fields in red. | High |
| **TC-CF-03** | Invalid Input | Student inputs description exceeding 1000 characters or binary garbage. | Client limits character counter to 1000; server rejects excess payload cleanly. | Medium |
| **TC-CF-04** | Duplicate Request | Student double-taps "Submit Issue" button rapidly. | UI disables button on first tap (`isSubmitting = true`); exactly 1 issue record created. | High |
| **TC-CF-05** | Unauthorized | Unauthenticated user navigates directly to `/student/issues/create`. | Intercepted by auth guard; redirected to `/login` with return URL. | Critical |
| **TC-CF-06** | Incorrect Role | Student attempts to change issue status to `assigned` or reassign technician. | RLS policy denies update; returns HTTP 403 / permission error. | Critical |
| **TC-CF-07** | Network Timeout | Device disconnects during issue image upload. | Loading spinner dismisses after 10s; shows "Upload timed out. Tap to retry". | High |
| **TC-CF-08** | Loading State | Fetching issues list on 3G network. | Shimmer skeleton cards displayed; layout preserves position until data loads. | Medium |
| **TC-CF-09** | Invalid Transition | Admin attempts to move issue directly from `reported` to `closed` without resolution. | State machine rejects illegal transition; error: "Issue must be resolved before closing". | High |
| **TC-CF-10** | Student Verify | Technician marks `resolved`; student taps `Verify Resolution`. | Status transitions to `student_verified` -> `closed`; analytics increments resolved count. | Critical |
| **TC-CF-11** | Security / XSS | Student submits description: `<script>alert('xss')</script> Projector broken`. | Text is sanitized and rendered as literal string; script does not execute. | Critical |

---

### 2.2 Lost & Found
Lifecycle: `Report → Match → Claim → Verify → Recover`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-LF-01** | Valid Match | Student reports lost Casio calculator; Admin submits matching found Casio calculator. | Match calculated with score >= 90%; lists matched attributes explainably. | Critical |
| **TC-LF-02** | Borderline Match | Lost blue backpack at Sports Ground vs found black backpack in Library. | Score computed <= 30%; classified as "Low match"; does not trigger false match alert. | High |
| **TC-LF-03** | Empty Input | User submits lost item with blank item name or category. | Submission prevented with "Item name and category are required". | High |
| **TC-LF-04** | Claim Submission | Student submits ownership answer to a matched item. | Claim created in `pending_verification` state; sensitive details hidden from public view. | Critical |
| **TC-LF-05** | Duplicate Claim | User attempts to submit multiple simultaneous claims on the same found item. | System restricts user to 1 active claim per item. | Medium |
| **TC-LF-06** | Incorrect Role | Student attempts to approve their own claim or mark item `recovered` directly. | RLS denies update; only staff/admin role can approve ownership and mark recovered. | Critical |
| **TC-LF-07** | Invalid Transition | User attempts to transition an item from `lost` directly to `recovered` without a claim. | Blocked by state machine; items require verified claim or manual staff clearance. | High |
| **TC-LF-08** | Secret / Privacy | Public lost & found item list query inspected via browser network console. | Hidden ownership verification answers and reporter private contact info are stripped. | Critical |

---

### 2.3 Digital Queue System
Lifecycle: `Join → Token → Position → Serving → Completed`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-QU-01** | Valid Join | Student joins active Accounts Office queue. | Token generated sequentially (e.g. `#27`); displays ahead count and estimated wait time. | Critical |
| **TC-QU-02** | Duplicate Join | Student taps "Join Queue" while already holding an active waiting token in that queue. | Prevented; modal shows: "You already hold token #27 in this queue." | High |
| **TC-QU-03** | Inactive Queue | Student attempts to join a closed queue (`is_active = false`). | Join button disabled; status badge shows "Counter Closed". | High |
| **TC-QU-04** | Admin Advance | Admin clicks "Call Next Token" on counter dashboard. | Token status transitions to `called`; next waiting token advances position count. | Critical |
| **TC-QU-05** | Incorrect Role | Student attempts to invoke `callNextToken` or modify queue counter. | Forbidden by server policy; only counter staff/admin can advance tokens. | Critical |
| **TC-QU-06** | Invalid Transition | Admin attempts to advance a token that is already `served` or `cancelled`. | Rejected by queue state machine. | Medium |
| **TC-QU-07** | Network Drop | Realtime connection drops while student is waiting in queue. | UI shows subtle "Reconnecting..." indicator; falls back to periodic polling every 10s. | High |

---

### 2.4 Campus Notices Bulletin
Lifecycle: `Admin Publish → Student View & Filter`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-NO-01** | Valid Publish | Admin creates Examination notice with deadline and Critical priority. | Notice appears at top of student home feed with red badge; deadline formatted clearly. | Critical |
| **TC-NO-02** | Category Filter | Student filters notices by "Fees" or "Hostel". | Only matching categorized notices displayed; empty state rendered if none match. | High |
| **TC-NO-03** | Empty Form | Admin attempts to publish notice with blank title or empty body. | Publish blocked; form highlights required fields. | Medium |
| **TC-NO-04** | Incorrect Role | Student attempts to call notice creation API or access `/admin/notices/create`. | Route guard redirects to `/student/home`; API rejects mutation with 403. | Critical |
| **TC-NO-05** | Expired Deadline | Notice deadline passes current system time. | Notice visually marked "Deadline Passed"; moves to archived tab in admin view. | Medium |

---

### 2.5 My Activity Timeline
Lifecycle: `Active Requests → Completed History`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AC-01** | Unified Feed | Student views `/student/activity`. | Unified chronological timeline displays user's issues, queue tokens, and claims. | Critical |
| **TC-AC-02** | State Segregation | Student switches filter between "Active" and "Completed". | "Active" tab displays pending issues and waiting tokens; "Completed" shows resolved items. | High |
| **TC-AC-03** | Empty Timeline | Newly registered student with zero requests opens My Activity. | Renders clean empty state with quick action buttons: "Report an issue" / "Join a queue". | Medium |
| **TC-AC-04** | Privacy Isolation | Student A views activity timeline. | Only Student A's own activity cards are rendered; zero leak of Student B's activity. | Critical |

---

### 2.6 Admin Command Center & Analytics
Lifecycle: `Overview → Triaging → Hotspots → Metrics`

| Test ID | Condition | Test Scenario | Expected Outcome | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AD-01** | Overview KPIs | Admin opens dashboard. | Metric cards accurately reflect: Active Issues, Critical Issues, Resolved Today, Recovery Rate. | Critical |
| **TC-AD-02** | Problem Hotspots | Multiple students report Wi-Fi failure in Academic Block A. | Cluster widget aggregates reports into "Academic Block A Network Cluster (3 reports)". | High |
| **TC-AD-03** | Cross-Campus Isolation | Admin for Campus A queries issues. | All returned issues belong to Campus A (`campus_id = c0000001-...`); Campus B issues excluded. | Critical |
| **TC-AD-04** | Role Guard | Student attempts URL manipulation to access `/admin/dashboard`. | Router guard intercepts navigation; immediately redirects to `/student/home`. | Critical |
