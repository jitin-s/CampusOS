# CampusOS --- End-to-End (E2E) Test Scenarios

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Execution Context:** Manual Test Scripts & Automated Verification Benchmarks

---

## Scenario 1: Lost & Found Lifecycle
**Goal**: Verify item reporting, deterministic smart matching, ownership claim, verification, and recovery.

```
Student Reports Lost Item ──> Found Item Logged ──> Smart Matching Engine (>=90%)
                                                           │
Recovered <── Approved Claim <── Ownership Verification <──┘
```

### Preconditions
- User `student1@campusos.internal` (Arjun Mehta) logged in on Client Device A.
- User `staff1@campusos.internal` (Librarian Desk) logged in on Device B.
- Backend database initialized with location `Central Library - 2nd Floor`.

### Step-by-Step Test Procedure
1. **Lost Item Reporting**:
   - Device A: Navigate to `/student/lost-found` -> tap `I Lost Something`.
   - Fill in:
     - Item Category: `Electronics`
     - Item Name: `Casio fx-991CW Scientific Calculator`
     - Brand: `Casio`
     - Color: `Black`
     - Location: `Central Library - 2nd Floor (Reading Hall)`
     - Date/Time: Today, 10:00 AM
     - Description: `Black scientific calculator with solar panel and silver keys.`
   - Tap `Submit Report`.
   - **Verification**: Item created with status `lost`. User redirected to item summary screen.
2. **Found Item Submission**:
   - Device B: Navigate to `/student/lost-found` -> tap `I Found Something`.
   - Fill in:
     - Item Category: `Electronics`
     - Item Name: `Casio Scientific Calculator`
     - Brand: `Casio`
     - Color: `Black`
     - Location: `Central Library - 2nd Floor`
     - Date/Time: Today, 11:15 AM
     - Description: `Found on table 14 near window. Has a small sticker residue on back.`
   - Tap `Submit Report`.
   - **Verification**: Found item created with status `found`.
3. **Smart Matching Execution**:
   - Device A: Navigate to `/student/lost-found/matches` or open item detail.
   - **Verification**:
     - System displays match card with score **>= 90%** (e.g., `94% Potential Match`).
     - Explainable attributes present:
       - `✓ Same Category (Electronics)`
       - `✓ Same Brand (Casio)`
       - `✓ Same Color (Black)`
       - `✓ Matching Location (Central Library - 2nd Floor)`
       - `✓ Matching Time Window (< 2 hours difference)`
4. **Claim Submission & Ownership Verification**:
   - Device A: Tap `Claim Item`.
   - Fill in Ownership Question:
     - Prompt: *"Does this item have any distinguishing private markings or serial numbers?"*
     - Answer: *"There is a sticker residue on the bottom back cover."*
   - Tap `Submit Claim`.
   - **Verification**: Claim record created with status `pending_verification`.
5. **Approval & Recovery**:
   - Device B (or Admin): Navigate to `/admin/lost-found` -> Claims tab.
   - Inspect claim answer -> Click `Approve Claim`.
   - Device A receives claim approval notification.
   - Student picks up item from library desk; Staff marks `Recovered`.
   - **Verification**: Both lost and found items update status to `recovered`.

---

## Scenario 2: CampusFix Complete Issue Workflow
**Goal**: Verify reporting, NLP classification, priority computation, admin assignment, technician resolution, and student verification.

```
Student Reports Issue ──> Intelligence (Category/Dept/Priority) ──> Admin Dashboard
                                                                          │
Closed <── Student Verifies <── Technician Resolves <── Assigned to Staff ─┘
```

### Preconditions
- User `student2@campusos.internal` (Priya Sharma) logged in on Mobile.
- User `admin@campusos.internal` (Campus Admin) logged in on Desktop.
- User `staff_tech@campusos.internal` (IT Technician Suresh) available.

### Step-by-Step Test Procedure
1. **Issue Creation**:
   - Student Mobile: Navigate to `/student/issues` -> tap `Report Campus Issue`.
   - Select Location: `Academic Block B - Room 204`.
   - Enter Description: `"The ceiling projector in room 204 keeps turning off automatically after 2 minutes of class."`
   - Upload Image: `projector_error.jpg` (or simulated image attachment).
   - Tap `Submit Issue`.
2. **Intelligence Processing**:
   - System passes description through Intelligence Engine.
   - **Verification**:
     - `category` automatically inferred as `Equipment`.
     - `type` identified as `Projector`.
     - `department_id` mapped to `IT Support`.
     - `priority` assigned as `HIGH` (due to active classroom instruction impact).
     - Issue status set to `reported`.
3. **Admin Triaging & Assignment**:
   - Admin Desktop: Open `/admin/dashboard` -> Priority Queue.
   - **Verification**: Issue appears at the top of the High-Priority list.
   - Admin opens ticket `#1042` and assigns to `Suresh (IT Support)`.
   - Issue status updates to `assigned`.
   - **Verification on Student Mobile**: Stepper highlights:
     `Reported [✓] -> Verified [✓] -> Assigned [✓] -> In Progress [ ] -> Resolved [ ]`
4. **Technician Resolution**:
   - Technician logs in or Admin marks `in_progress` -> then `resolved`.
   - Technician enters notes: `"Replaced HDMI connector and cleaned projector cooling fan filter."`
   - Technician uploads resolution proof (`after_image_url`).
   - Ticket status becomes `resolved`, timestamp `resolved_at` recorded.
5. **Student Verification & Closure**:
   - Student Mobile receives update: *"Your issue in Room 204 has been marked resolved. Please confirm."*
   - Student taps `Verify Resolution`.
   - Status updates to `student_verified` -> `closed`.
   - Admin Analytics reflects:
     - `Active Issues` decrements by 1.
     - `Resolved Today` increments by 1.
     - Average resolution time recalculates dynamically.

---

## Scenario 3: Digital Queue Management
**Goal**: Verify queue discovery, token generation, live position calculation, and counter advancement.

```
Student Joins Queue ──> Sequential Token Generated ──> Realtime Position Updates
                                                               │
Service Finished <── Admin Advances ("Now Serving") <──────────┘
```

### Preconditions
- Service `Accounts Office - Fee Clearance Desk` has active status `is_active = true`.
- Current token serving: `#22`. Waiting tokens: `#23`, `#24`, `#25`, `#26`.

### Step-by-Step Test Procedure
1. **Queue Discovery & Token Generation**:
   - Student Mobile: Navigate to `/student/queue`.
   - Select `Accounts Office - Fee Clearance Desk`.
   - Current displayed state: `Now Serving: #22 | Waiting Count: 4`.
   - Tap `Join Queue`.
   - **Verification**:
     - New token `#27` generated.
     - Student screen displays:
       - `Your Token: #27`
       - `Now Serving: #22`
       - `People Ahead: 4`
       - `Estimated Wait: ~12 mins`
       - Status badge: `Waiting in line`
2. **Queue Advancement (Token Called)**:
   - Admin Desktop: Navigate to `/admin/queues/accounts-office`.
   - Admin clicks `Call Next` 4 times until `#26` is served.
   - Admin calls `#27`.
   - **Verification**:
     - Token `#27` status updates to `called`.
     - Student UI vibrates/alerts with state: `"Your Token #27 is now being served at Desk 2!"`
     - "People Ahead" updates to `0`.
3. **Queue Completion**:
   - Admin completes service and clicks `Mark Served`.
   - Token `#27` status updates to `served` with timestamp `served_at`.
   - Student UI transitions to completed card with "Service Complete" feedback.

---

## Scenario 4: Campus Notices & Announcements
**Goal**: Verify administrative notice publishing with category tags, urgency levels, and immediate student delivery.

```
Admin Publishes Notice ──> Category & Priority Tagged ──> Student Feed Alert
                                                                 │
Dismissed / Acknowledged <── Detail & Deadline Card <────────────┘
```

### Preconditions
- User `admin@campusos.internal` authenticated.
- Student logged in and viewing `/student/home`.

### Step-by-Step Test Procedure
1. **Notice Creation**:
   - Admin Desktop: Navigate to `/admin/notices` -> tap `Create Notice`.
   - Fill in:
     - Title: `End-Semester Examination Schedule - Winter 2026`
     - Category: `Examination`
     - Priority: `Critical`
     - Deadline: `2026-10-15 17:00`
     - Body: `The final timetable for Winter 2026 examinations has been published. Check hall ticket details before the deadline.`
   - Tap `Publish Notice`.
2. **Student Feed Delivery**:
   - Student Mobile: Refresh or view `/student/home` and `/student/notices`.
   - **Verification**:
     - Notice appears pinned to top under `Important Notices`.
     - High-contrast visual priority indicator (e.g., Red/Orange accent badge `CRITICAL`).
     - Category tag `Examination` and countdown to deadline displayed.
   - Student taps notice: Full modal opens with readable markdown text and action buttons.

---

## Scenario 5: Admin Command Center & Campus Intelligence View
**Goal**: Verify that admin overview aggregates operational data into live intelligence KPIs, hotspot analysis, and queue oversight.

### Preconditions
- Demo dataset pre-seeded (50+ issues, 10+ queues, 20+ lost/found records).

### Step-by-Step Test Procedure
1. **Command Center Access**:
   - Admin logs into `/admin/dashboard`.
   - **Verification of KPI Cards**:
     - `Active Issues`: Reflects count of issues with status != `closed`.
     - `Critical Issues`: Count of issues where `priority = CRITICAL` or `HIGH`.
     - `Resolved Today`: Count of issues resolved within past 24 hours.
     - `Recovery Rate`: Computed as `(Recovered Items / Total Lost Items) * 100%`.
2. **Problem Hotspots & Recurring Issues**:
   - Admin checks `Problem Hotspots` widget.
   - **Verification**:
     - Identifies clusters (e.g., `Hostel Block C - Plumbing Leak`, `Academic Block A - Wi-Fi Down`).
     - Aggregates multiple reports into a single cluster record with occurrence count.
3. **Queue Health Overview**:
   - Admin checks `Live Counter Status`.
   - Shows active queues, current waiting numbers, and bottlenecks.
4. **Role Enforcement Negative Test**:
   - Student Arjun logs into `/student/home` and tries modifying browser URL to `/admin/dashboard`.
   - **Verification**: Router guards intercept the request, deny access, and redirect safely back to `/student/home` without data leakage.
