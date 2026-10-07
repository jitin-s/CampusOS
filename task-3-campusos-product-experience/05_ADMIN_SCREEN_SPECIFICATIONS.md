# CampusOS — Admin Screen Specifications

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification for Task-1  
**Source of Truth:** `docs/01_PRD.md`, `docs/03_ARCHITECTURE.md`, `docs/04_UX_DESIGN.md`

---

## 1. Screen Inventory (Admin Scope)

| Screen ID | Screen Name | Route | PRD Ref | Primary User |
| :--- | :--- | :--- | :--- | :--- |
| `SCR-ADM-01` | Admin Overview Dashboard | `/admin/dashboard` | PRD 7, UX 12 | Administrator / Facilities Lead |
| `SCR-ADM-02` | Admin CampusFix Issue Triage | `/admin/issues` | PRD 5.3, SRD 5 | Operations Lead / Dispatcher |
| `SCR-ADM-02A`| Issue Assignment & Status Modal | `/admin/issues/:id/action` | PRD 5.3 | Operations Lead |
| `SCR-ADM-03` | Admin Lost & Found Management| `/admin/lost-found` | PRD 5.2, SRD 4 | Campus Security / Helpdesk Lead |
| `SCR-ADM-03A`| Claim Verification Review Modal| `/admin/lost-found/claim/:id`| SRD 4 | Helpdesk Officer |
| `SCR-ADM-04` | Admin Queue Counter Control | `/admin/queues` | PRD 5.4, SRD 6 | Service Desk Staff / Admin |
| `SCR-ADM-05` | Admin Notices Publisher | `/admin/notices` | PRD 5.5, SRD 7 | Dean / Administrative Officer |
| `SCR-ADM-06` | Campus Intelligence & Analytics | `/admin/analytics` | PRD 7, ARCH 14 | Dean of Operations / Campus Dir |

---

## 2. Detailed Screen Specifications

---

### SCR-ADM-01: Admin Overview Dashboard

* **Purpose:** High-level command center answering the question: **"What needs attention right now across campus?"**
* **User:** Campus Administrator, Dean of Facilities, Shift Supervisors.
* **Layout:** Desktop widescreen layout ($1280\text{px}+$) with 260px fixed left sidebar navigation and 4-column metric grid. Responsive to tablet/mobile via vertical stacking.
* **Primary Action:** Review and click into the **Priority Triage Queue** to resolve urgent operational bottlenecks.
* **Secondary Actions:**
  - Fast-action toolbar: `[+ Publish Urgent Notice]`, `[+ Open New Queue Desk]`.
  - Filter campus view by department or block.
  - Refresh live operational telemetry.
* **Information Displayed:**
  1. **Top KPI Summary Tiles (4 Cards across):**
     - *Critical Issues Today:* Counter (e.g. `3 Active`), with red alert ring if $> 0$.
     - *Active Work Orders:* Total open tickets across departments (e.g. `24 In Progress`).
     - *Resolved Today:* Work orders closed in last 24h (e.g. `18 Closed`).
     - *Lost & Found Recovery Rate:* Percentage indicator (e.g. `78% Recovered`).
  2. **Priority Action Queue (Triage Table):**
     - Top 5 issues ordered strictly by Priority (`CRITICAL`, `HIGH`, `MEDIUM`) and recency.
     - Columns: Issue ID, Category, Location, AI Priority tag, Time elapsed, Quick Action (`Assign`).
  3. **Operational Hotspots Widget (Intelligence Cluster):**
     - AI-detected recurring issues: e.g. *"⚠️ Outage Warning: 4 Wi-Fi complaints in Block C within 45 mins"*.
  4. **Active Queue Status Bar:**
     - Quick widget showing live queue lengths at Accounts, ID Card Counter, and Registrar.
* **UX States:**
  - **Loading:** Shimmer table rows and metric skeletons.
  - **Empty State:** *"All queues clear. No critical alerts across campus."*
  - **Error State:** Top warning ribbon: *"Failed to stream realtime updates. Retrying..."*

---

### SCR-ADM-02: Admin CampusFix Issue Triage & Management

* **Purpose:** Centralized dispatch table to review student/staff reported issues, verify AI priority/category, and dispatch work orders to field technicians.
* **User:** Operations Manager, Dispatcher, Maintenance Leads.
* **Primary Action:** Click `[Assign]` or row to open Assignment & Status Dialog (`SCR-ADM-02A`).
* **Secondary Actions:**
  - Filter issues by Status (`Reported`, `Verified`, `Assigned`, `In Progress`, `Resolved`, `Closed`).
  - Filter by Department (IT, Electrical, Plumbing, Housekeeping, Civil).
  - Search by room number, reporter name, or keyword.
* **Information Displayed:**
  - Rich Data Table:
    - `ID`: e.g. `#1042`.
    - `Priority Badge`: Color-coded pill (`CRITICAL` in Red, `HIGH` in Orange, `MEDIUM` in Yellow).
    - `Category & Sub-Type`: e.g. `Equipment / Projector`.
    - `Location`: `Block B — Room 204`.
    - `Reporter`: Student Name + ID.
    - `Assigned Staff`: Avatar + Name or `Unassigned` warning badge.
    - `Status`: Current state pill.
    - `Actions`: `[Assign]` button, `[View Details]` button.
* **UX States:**
  - **Empty:** *"No issues match the selected filter criteria."*

---

### SCR-ADM-02A: Issue Assignment & Status Modal

* **Purpose:** Dispatch dialog for assigning responsible technician, adjusting priority, or updating status.
* **User:** Dispatcher.
* **Information Displayed:**
  - Issue summary: Full description, Before photo, Location, Student contact.
  - AI Suggestion Pill: *"Classified as Equipment by Intelligence Engine (98% confidence)"*.
* **Form Controls:**
  - *Department Selector:* Dropdown (IT Support, Electrical, Plumbing, Facilities).
  - *Assignee:* Dropdown of available technicians in that department (e.g. "Ramesh Kumar (3 active tasks)").
  - *Priority Override:* Toggle (LOW, MEDIUM, HIGH, CRITICAL).
  - *Admin Internal Note:* Text area.
* **Actions:** `[Save & Dispatch]` (Primary Blue), `[Cancel]`.

---

### SCR-ADM-03 & SCR-ADM-03A: Admin Lost & Found Management & Claim Review

* **Purpose:** Audit active lost/found items, review pending ownership claims, and verify physical handover.
* **User:** Security Supervisor, Campus Helpdesk Lead.
* **Information Displayed on SCR-ADM-03:**
  - Dual tabs: "Active Found Items in Custody" vs "Unmatched Lost Reports".
  - Alert banner: e.g. *"2 Pending Claims Requiring Verification"*.
  - Table of items: Photo thumbnail, Item name, Category, Stored Locker/Desk location, Reported Date, Status.
* **SCR-ADM-03A (Claim Verification Review Modal):**
  - Triggered when student taps "Claim Item" on a match.
  - Shows:
    - Found Item details & photo held at desk.
    - Claimant's Profile (Name, Roll Number).
    - Claimant's Verification Response: e.g. *"Blue sticker with initials RS on back"*.
    - Match Confidence Score: `94% Match`.
  - Administrator Actions:
    - Green Button: `[Approve Claim & Authorize Handover]` $\rightarrow$ issues recovery QR/token.
    - Red Button: `[Reject Claim]` $\rightarrow$ opens reason dropdown (Wrong details, Suspected fraudulent).

---

### SCR-ADM-04: Admin Queue Counter Control

* **Purpose:** Real-time physical desk tool for service staff to call next token, advance queue, or pause service.
* **User:** Counter Staff (Accounts, Registrar, ID Desk).
* **Information Displayed:**
  - Counter Title: "Accounts & Fee Desk — Window 2".
  - **Giant Token Display:**
    - Currently Serving: Large `Token #22`.
    - Elapsed time on current token: `4m 32s`.
  - Waiting Queue List: Ordered list of next tokens in line (`#23`, `#24`, `#25`, `#26`).
  - Active Queue Controls:
    - Primary Button: **`[Call Next Token]`** (calls #23, triggers alert push to student).
    - Secondary Button: **`[Recall Current Token]`** (resends alert if student did not approach).
    - Warning Button: **`[Mark No-Show / Skip]`**.
    - Toggle: **`[Pause / Close Queue]`**.
* **Realtime Feedback:** Instant visual transition upon button click; counter increments without full-page reload.

---

### SCR-ADM-05: Admin Notices Publisher

* **Purpose:** Authoring and broadcasting official campus announcements.
* **User:** Dean, Department Admin.
* **Form Inputs:**
  - *Title:* Text input (max 120 chars).
  - *Category:* Dropdown (Academic, Examination, Fees, Event, Placement, Hostel, Emergency, General).
  - *Priority:* Selector (`Normal` | `🔴 Urgent / Critical Banner`).
  - *Target Campus / Department:* Scope selector.
  - *Deadline / Event Date:* Optional date-time picker.
  - *Body / Content:* Formatted text area.
* **Actions:** `[Publish Notice]` (Primary Blue), `[Save Draft]`.

---

### SCR-ADM-06: Campus Intelligence & Analytics

* **Purpose:** Strategic executive view providing operational insights derived from closed-loop workflows.
* **User:** Dean of Operations, Vice-Chancellor, Department Heads.
* **Information Displayed:**
  1. **Campus Reliability Score:** Large metric gauge (e.g. `87 / 100` — Healthy campus operations).
  2. **Resolution Rate:** Visual donut chart (`84% Resolved within SLA`).
  3. **Average Resolution Time:** e.g. `3.8 hours` (Tracked over weekly trend line).
  4. **Category Breakdown:** Bar chart showing volume by department (Plumbing: 35%, IT: 28%, Electrical: 22%, Other: 15%).
  5. **Recurring Problem Clusters (Task-2 Intelligence integration):**
     - Table of detected problem clusters:
       - Cluster 1: *"Block B 2nd Floor — Wi-Fi Access Point Drops (6 incidents in 7 days)"*.
       - Cluster 2: *"Hostel 3 Mess — Water Cooler Filter (4 incidents this month)"*.
  6. **Lost & Found Efficiency:**
     - Recovery Rate: `76%`.
     - Average claim time: `1.4 days`.
