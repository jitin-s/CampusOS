# CampusOS — Student Screen Specifications

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification for Task-1  
**Source of Truth:** `docs/01_PRD.md`, `docs/04_UX_DESIGN.md`

---

## 1. Screen Inventory (Student Scope)

| Screen ID | Screen Name | Route | PRD Ref | Primary User |
| :--- | :--- | :--- | :--- | :--- |
| `SCR-STU-01` | Student Dashboard / Home | `/student/home` | PRD 5.1 | Student / Faculty |
| `SCR-STU-02` | Lost & Found Hub | `/student/lost-found` | PRD 5.2 | Student / Faculty |
| `SCR-STU-02A`| Report Lost Item Form | `/student/lost-found/report-lost` | PRD 5.2 | Student |
| `SCR-STU-02B`| Report Found Item Form | `/student/lost-found/report-found`| PRD 5.2 | Student / Staff |
| `SCR-STU-02C`| Match Details & Ownership Claim | `/student/lost-found/match/:id` | PRD 5.2, SRD 4 | Student |
| `SCR-STU-03` | CampusFix Hub & Feed | `/student/campus-fix` | PRD 5.3 | Student / Faculty |
| `SCR-STU-03A`| Report Campus Issue (Step Form) | `/student/campus-fix/report` | PRD 5.3 | Student / Faculty |
| `SCR-STU-03B`| Issue Detail & Resolution Verification | `/student/campus-fix/issue/:id` | PRD 5.3, UX 6 | Student / Reporter |
| `SCR-STU-04` | Digital Queue Service Directory | `/student/queue` | PRD 5.4 | Student |
| `SCR-STU-04A`| Active Queue Live Token Tracker | `/student/queue/token/:id` | PRD 5.4, UX 9 | Student |
| `SCR-STU-05` | Campus Notices Board | `/student/notices` | PRD 5.5, UX 10 | Student / Faculty |
| `SCR-STU-05A`| Notice Detail View | `/student/notices/:id` | PRD 5.5 | Student / Faculty |
| `SCR-STU-06` | My Activity Unified Timeline | `/student/activity` | PRD 5.6, UX 11 | Student |

---

## 2. Detailed Screen Specifications

---

### SCR-STU-01: Student Dashboard / Home

* **Purpose:** Command center enabling rapid action, immediate visibility of active student requests, campus operating status, and urgent notices.
* **User:** Student, Faculty.
* **Primary Action:** Tap an Action Grid button ([Report Issue], [Lost & Found], [Join Queue], [Notices]).
* **Secondary Actions:**
  - Tap active request card to view detail.
  - Pull down to refresh data.
  - Switch active campus context (if multi-campus enabled).
* **Information Displayed:**
  - Header: CampusOS Logo, Greeting ("Good morning, [User Name]"), Avatar / Profile icon.
  - **Action Grid (2x2 on mobile, 4 across on desktop):**
    1. *Report Issue* (Icon: `build_circle`, Subtext: "Classroom, Lab, Wi-Fi")
    2. *Lost & Found* (Icon: `inventory_2`, Subtext: "Report or find belongings")
    3. *Join Queue* (Icon: `confirmation_number`, Subtext: "Accounts, Admin desks")
    4. *Notices* (Icon: `campaign`, Subtext: "Announcements & Deadlines")
  - **Active Requests Section:**
    - Live cards for pending items (e.g., active queue token #27, reported projector issue in progress, calculator match found).
  - **Campus Status Bar:**
    - Operational summary badge (e.g., "All Systems Normal" or "⚠️ Wi-Fi Disruption reported in Block C").
  - **Important Notices Snippet:** Top 2 high-priority or urgent notices with deadline chips.
* **Navigation:** Bottom navigation bar on mobile (Home, CampusFix, Lost & Found, Queue, Activity). Left sidebar on desktop.
* **UX States:**
  - **Loading State:** Shimmer skeletons for Action Grid and Active Request cards.
  - **Empty State (No active requests):** Clean illustration with label *"No pending requests. Everything is running smoothly!"*
  - **Error State:** Banner at top: *"Unable to refresh campus status. Tap to retry."* with retry icon.
  - **Success State:** Instant toast on successful background synchronization.

---

### SCR-STU-02: Lost & Found Hub

* **Purpose:** Central portal to report lost/found items, view nearby active listings, and review potential match notifications.
* **User:** Student, Staff, Faculty.
* **Primary Action:** Tap **[I Lost Something]** (Primary Blue Button) or **[I Found Something]** (Secondary Outlined Button).
* **Secondary Actions:**
  - Search items by keyword (e.g., "Casio calculator", "Blue umbrella").
  - Filter by category chips: All, Electronics, Cards & IDs, Bags, Books, Other.
  - Tap an item card to inspect public details.
* **Information Displayed:**
  - Top CTA Banner with two prominent actions: `[I Lost Something]` and `[I Found Something]`.
  - "Potential Matches" banner if user has an active lost item that triggered a match.
  - Grid / List of recent campus listings (photo thumbnail, item title, location found/lost, relative timestamp, status badge: `Searching` | `Found/At Desk`).
  - Strict privacy rule: Sensitive identification details (e.g., hidden serial numbers, specific wallet cash amount) are never shown on public cards.
* **UX States:**
  - **Loading State:** 6 card skeletons pulsing.
  - **Empty State:** *"No lost or found items reported today. Tap above to report one."*
  - **Error State:** Full-page error card with *"Failed to load Lost & Found directory"* + `[Retry]` button.

---

### SCR-STU-02A: Report Lost Item Form

* **Purpose:** Minimal-input form to log a lost personal item.
* **User:** Student.
* **Primary Action:** `[Submit Lost Report]`.
* **Form Inputs (Minimal Input Principle):**
  1. *Category* (Dropdown / Chips: Electronics, ID Cards, Bags, Books, Keys, Apparel, Other).
  2. *Item Name* (Text: e.g. "Casio FX-991EX Calculator").
  3. *Brand / Model* (Text: e.g. "Casio").
  4. *Color* (Dropdown / Chips: Black, Blue, Silver, Red, etc.).
  5. *Last Seen Location* (Dropdown: Main Library 2nd Floor, Canteen, Block A Lab, etc.).
  6. *Approximate Date & Time* (Date/Time picker).
  7. *Description* (Text area: up to 250 characters).
  8. *Photo* (Optional camera capture / upload).
  9. *Ownership Verification Question & Secret Answer* (e.g., "What name sticker is on the back?" -> "Rohan S.").
* **Success State:**
  - Redirects immediately to potential matches or gives success modal: *"Report submitted! CampusOS is automatically checking for matches."*

---

### SCR-STU-02C: Match Details & Ownership Claim View

* **Purpose:** Explainable intelligence display showing why two items match, and initiating the ownership claim process.
* **User:** Student claiming a lost item.
* **Primary Action:** `[Claim Item]`.
* **Secondary Action:** `[Not My Item / Dismiss Match]`.
* **Information Displayed:**
  - **Match Strength Meter:** Large circular gauge or prominent bar: `94% Potential Match — Strong Candidate`.
  - **Explainability Checklist (Why this matches):**
    - `✓ Same Category: Electronics`
    - `✓ Same Brand: Casio`
    - `✓ Matching Color: Black / Silver`
    - `✓ Nearby Location: Library 2nd Floor`
    - `✓ Temporal Proximity: Found 30 mins after report`
  - Side-by-side preview of Lost Item report and Found Item public details.
* **Claim Workflow Trigger:**
  - Tapping `[Claim Item]` opens **Ownership Verification Modal**.
  - Student is prompted to provide verification proof/answer.
  - Upon submission: Displays status banner *"Claim submitted to Desk Administrator. You will be notified once verified."*

---

### SCR-STU-03: CampusFix Hub & Feed

* **Purpose:** View active campus maintenance issues, report new facility problems, and track community resolution progress.
* **User:** Student, Faculty.
* **Primary Action:** Floating or top `[Report Campus Issue]` button.
* **Secondary Actions:**
  - Filter issues by category (Electrical, Wi-Fi, Equipment, Cleanliness, Water, Hostel).
  - Filter by tab: "My Reported Issues" vs "Campus Open Issues".
* **Information Displayed:**
  - Issue list cards: Title, Category badge, Location chip (e.g. `Room 204`), Date filed, Current Status Stepper pill (`Reported`, `In Progress`, `Resolved`).

---

### SCR-STU-03A: Report Campus Issue (Step Form)

* **Purpose:** Multi-step wizard or progressive single-page form to submit an incident with minimal cognitive load.
* **Form Steps:**
  - **Step 1: Category** (8 visual icon tiles: Classroom, Electrical, Wi-Fi, Equipment, Cleanliness, Water, Hostel, Other).
  - **Step 2: Location** (Campus block selector, Floor, Room number picker).
  - **Step 3: Description & Severity** (Short description: e.g., *"Projector lamp is flickering and HDMI cable missing"*).
  - **Step 4: Photo Evidence** (Camera capture button / gallery upload).
* **Primary Action:** `[Submit Issue]`.
* **Success State:**
  - Navigates to issue receipt screen showing generated Issue ID (#1042), AI-assigned priority tag, and initial status stepper (`● Reported`).

---

### SCR-STU-03B: Issue Detail & Resolution Verification

* **Purpose:** Real-time tracking of issue lifecycle and mandatory student resolution verification.
* **User:** Reporting student, interested peers.
* **Information Displayed:**
  - Issue ID, Title, Category, Location, Timestamp.
  - **Visible Stepper Bar:**
    `● Reported` $\rightarrow$ `● Verified` $\rightarrow$ `● Assigned` $\rightarrow$ `○ In Progress` $\rightarrow$ `○ Resolved` $\rightarrow$ `○ Student Verified` $\rightarrow$ `○ Closed`.
  - Assigned Department / Technician badge (e.g. `IT Operations / Ramesh K.`).
  - Initial "Before" photo.
  - "After" resolution photo (once uploaded by technician).
* **Verification Action (When Status = 'Resolved'):**
  - Prompt: *"The technician has marked this issue as resolved. Please inspect and verify."*
  - Side-by-side comparison of "Before" vs "After" photos.
  - Action buttons:
    - Primary Green: `[Confirm Resolution]` (moves state to `student_verified` $\rightarrow$ `closed`).
    - Secondary Red: `[Issue Still Persists / Reopen]` (reopens ticket for admin inspection).

---

### SCR-STU-04 & SCR-STU-04A: Digital Queue & Live Token Tracker

* **SCR-STU-04 Purpose:** Browse live campus service counters and take a digital queue token.
* **Directory Displays:** List of service desks (e.g. "Fee Accounts Desk", "ID Card Counter", "Hostel Warden Office").
  - Current status: `Open` / `Closed`.
  - Serving token: `Now Serving #22`.
  - Waiting count: `5 people waiting`.
  - Estimated wait: `~12 mins`.
* **Primary Action on SCR-STU-04:** `[Join Queue / Take Token]`.
* **SCR-STU-04A (Live Token View):**
  - Full-screen clean card display:
    - Your Token: `#27` (Large 48pt bold type).
    - Now Serving: `#22`.
    - People Ahead: `4`.
    - Estimated Wait Time: `~12 mins`.
    - Dynamic Status Banner:
      * When 5+ ahead: *"You can relax or study nearby. We'll notify you."*
      * When 2 ahead: *"⚠️ Please proceed to the waiting area."* (Orange alert).
      * When token called: *"🔔 Now Calling #27! Proceed to Desk 2 immediately."* (Vibrating green alert).
  - Secondary Action: `[Cancel Token / Leave Queue]` (with confirmation dialog).

---

### SCR-STU-05: Campus Notices Board

* **Purpose:** Clean, prioritized feed of institutional notices with deadlines.
* **User:** Student, Faculty.
* **Primary Action:** Tap notice card to read details and view attachments/links.
* **Information Displayed:**
  - Category Filter Bar: All, Academic, Exams, Fees, Events, Placement, Hostel, Emergency.
  - Notice Card:
    - Priority Badge: `[🔴 URGENT]` or `[NORMAL]`.
    - Category chip.
    - Title (e.g., *"Mid-Semester Exam Schedule Published"*).
    - Deadline badge: `📅 Deadline: Oct 15, 2026` (Red if within 48 hours).
    - Summary snippet.
* **UX States:**
  - Empty state: *"No active notices in this category."*

---

### SCR-STU-06: My Activity Unified Timeline

* **Purpose:** Single unified chronological feed across all CampusOS modules (No separate silos).
* **User:** Student.
* **Information Displayed:**
  - Chronological grouped list: Today, Yesterday, Earlier This Week.
  - Event Cards with module icon:
    - 10:42 — CampusFix: *"Projector issue #1042 assigned to IT Operations"*
    - 09:30 — Lost & Found: *"Potential match (94%) found for Casio Calculator"*
    - Yesterday — Queue: *"Token #27 at Accounts Desk marked served"*
    - Oct 04 — Notices: *"Acknowledged Mid-Semester Exam Schedule"*
  - Tap card: Deep-links directly to the relevant detail screen (`SCR-STU-03B`, `SCR-STU-02C`, etc.).
