# CampusOS — Product Positioning & Personas

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification  
**Source of Truth:** `docs/01_PRD.md`, `docs/04_UX_DESIGN.md`

---

## 1. Product Positioning

> **CampusOS is a Progressive Web App and cross-platform campus operating layer that converts fragmented student requests and campus problems into trackable, accountable workflows and converts operational activity into campus intelligence.**

### The Core Mechanism
CampusOS replaces unstructured, conversational communication channels (WhatsApp chats, verbal complaints, physical notice boards, paper tokens) with an integrated workflow engine:

$$\text{Discover / Report / Request} \longrightarrow \text{Classify} \longrightarrow \text{Prioritize} \longrightarrow \text{Route} \longrightarrow \text{Assign} \longrightarrow \text{Track} \longrightarrow \text{Resolve} \longrightarrow \text{Verify} \longrightarrow \text{Analyze}$$

### What CampusOS Is NOT
- **Not an academic ERP or LMS:** Does not handle grading, attendance, transcripts, or fee bursar ledger management.
- **Not a social network / notice bulletin:** Does not feature open comment threads, social chat, or unstructured feeds.
- **Not a fragmented utility toolbox:** All sub-modules share common data primitives (`campus_id`, actor IDs, timestamps, status transitions, activity logging).

---

## 2. Target User Personas & Journey Mapping

### Persona 1: Rohan Sharma — The Busy Undergraduate Student
* **Demographics:** 20 years old, 3rd-year Computer Science student. Mobile-first user (90% on phone, 10% on laptop in library).
* **Environment:** Constantly moving between lecture halls, labs, canteen, and library.
* **Pain Points:**
  - Loses personal belongings (calculators, chargers, ID cards) and has to ask in 5 different chaotic WhatsApp groups.
  - Notices broken infrastructure (e.g. faulty lab projector, AC leak) but has no idea who to contact, feeling that verbal complaints fall on deaf ears.
  - Wastes 40 minutes standing in line at the Academic Office just to collect a bona fide certificate.
* **Goals in CampusOS:**
  - File an issue or lost item report in under 60 seconds with minimal keystrokes.
  - Track real-time progress of his requests without asking anyone.
  - Join an administrative queue remotely while remaining in the library.
* **Key Experience Requirements:**
  - One-tap quick actions from home screen.
  - Clear visual stepper showing status (`Reported` $\rightarrow$ `Assigned` $\rightarrow$ `Resolved`).
  - Clear explanations for matching confidence (e.g., *94% match based on category, brand, color*).

---

### Persona 2: Dr. Sunita Mehra — Faculty Member
* **Demographics:** 46 years old, Associate Professor of Physics. Uses desktop workstation in office and smartphone on campus.
* **Environment:** Conducting lectures, grading, mentoring students, managing lab equipment.
* **Pain Points:**
  - Equipment malfunctions in lecture hall 302 interrupt teaching; physical maintenance logs are ignored.
  - Important administrative notices get buried in email inboxes.
* **Goals in CampusOS:**
  - Report projector or audio issues during class immediately.
  - View high-priority institutional announcements with deadlines.
* **Key Experience Requirements:**
  - Streamlined incident reporting with automatic departmental routing.
  - Instant acknowledgement of reports.

---

### Persona 3: Ramesh Kumar — Maintenance Supervisor / Field Technician
* **Demographics:** 38 years old, Campus Facility & Electrical Operations Supervisor.
* **Environment:** Moves around campus, smartphone-first, limited technical patience.
* **Pain Points:**
  - Receives vague verbal instructions (*"Go fix the projector in block B"* — which room? what problem?).
  - Accused of delays even when parts were pending or work was completed.
* **Goals in CampusOS:**
  - Clear queue of assigned work orders with photos and exact room numbers.
  - Ability to upload "After" resolution photos to verify completion.
* **Key Experience Requirements:**
  - High-contrast, clean mobile cards with room numbers prominently highlighted.
  - Simple 2-tap state transitions (`Mark In Progress` $\rightarrow$ `Resolve with Photo`).

---

### Persona 4: Vikram Singhania — Campus Administrator & Dean of Operations
* **Demographics:** 52 years old, Chief Administrative Officer. Uses desktop/laptop (wide-screen 1280px+).
* **Environment:** Administrative office, reviews campus health, vendor SLAs, and operations.
* **Pain Points:**
  - Lacks aggregate visibility: repeated plumbing issues in Hostel 3 look like random one-off events.
  - Zero data on mean time to resolution or lost item recovery rates.
* **Goals in CampusOS:**
  - Triage unassigned issues by priority (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`).
  - Spot systemic hotspots (e.g., 5 network tickets filed in Block C within 30 minutes).
  - Review queue flow and publish urgent campus notices.
* **Key Experience Requirements:**
  - Multi-column widescreen dashboard showing operational queues and KPI summary tiles.
  - Instant triage actions (one-click assignment to technicians/departments).

---

## 3. Product Principles Translated to UX Rules

1. **Action-First Principle:**
   - The student home page must never be a passive news feed. Top viewport real estate is dedicated to the **Action Grid**: [Report Issue], [Lost & Found], [Join Queue], [Notices].
2. **Status Visibility Principle:**
   - Every user request must have a single unambiguous active state, visualized via explicit step bars. No generic "Pending" without stating *who* owns the next action.
3. **Minimal Input Principle:**
   - Forms prioritize structured pickers (dropdowns, location tags, category chips, camera upload) over long free-text descriptions.
4. **Progressive Disclosure Principle:**
   - Operational complexities (triage algorithms, SLA timers, departmental IDs, routing keys) are hidden from students and surfaced cleanly to admins.
5. **Deterministic Explainability:**
   - Any intelligence suggestion (e.g. Lost & Found match score) must explicitly display the matched criteria (e.g., category, brand, color, location) so users trust the system.
