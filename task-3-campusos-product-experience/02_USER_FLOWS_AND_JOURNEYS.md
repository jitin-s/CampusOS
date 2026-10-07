# CampusOS — User Flows & Interaction Journeys

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification  
**Source of Truth:** `docs/01_PRD.md`, `docs/02_SRD.md`, `docs/04_UX_DESIGN.md`

---

## 1. Core End-to-End User Journeys

The PRD mandates four primary closed-loop workflows for MVP:
1. **Lost & Found:** Report $\rightarrow$ Match $\rightarrow$ Verify $\rightarrow$ Recover
2. **CampusFix:** Report $\rightarrow$ Classify $\rightarrow$ Assign $\rightarrow$ Resolve $\rightarrow$ Verify
3. **Digital Queue:** Join $\rightarrow$ Token $\rightarrow$ Wait $\rightarrow$ Notification $\rightarrow$ Service
4. **Campus Notices:** Publish $\rightarrow$ Prioritize $\rightarrow$ Consume $\rightarrow$ Acknowledge
5. **Admin Operations:** Detect $\rightarrow$ Prioritize $\rightarrow$ Assign $\rightarrow$ Resolve $\rightarrow$ Analyze

---

## 2. Detailed Workflow 1: Lost & Found

### Flowchart: Report $\rightarrow$ Match $\rightarrow$ Verify $\rightarrow$ Recover

```text
[Student A: Loses Item]
       │
       ▼
 [Tap "I Lost Something"]
       │
       ▼
[Fill Lost Item Form] (Category, Item Name, Brand, Color, Location, Date/Time, Photo, Hidden Question)
       │
       ▼
[System: Compute Deterministic Match Scores against active Found Items]
       ├── Score >= 70%: [Immediate Match Candidate Modal/Card]
       └── Score < 70%:  [Submitted to Active Lost Registry]
                                │
[Student B: Finds Item in Library]
       │
       ▼
[Fill Found Item Form] (Category, Item Name, Brand, Color, Location, Held at Desk/Self, Photo)
       │
       ▼
[System Match Engine: Evaluates Lost vs Found pairs]
       │
       ▼ (Match detected, e.g. 94%)
[Student A receives Match Notification & Activity Item]
       │
       ▼
[Student A opens "Match Details View"]
       ├── Displays Match Strength (94%) & Breakdown (✓ Category, ✓ Brand, ✓ Color, ✓ Location)
       └── Action: [Claim Item]
              │
              ▼
       [Ownership Verification Modal]
       - System displays claimant question: e.g. "What sticker or engraving is on the back?"
       - Student A inputs security answer
              │
              ▼
       [Claim Submitted to Administrator / Found Item Holder]
              ├── If Approved: Token / Recovery QR / Handover Code Generated
              └── If Rejected: Reason recorded, item returned to search pool
              │
              ▼
       [Physical Handover Verification at Campus Desk]
              │
              ▼
       [Status updated to 'recovered' / Closed]
```

### State Transitions (`LostItem` & `FoundItem`)
- `reported` (Active search)
- `matched` (Potential match associated)
- `claimed` (Claim filed, verification pending)
- `verified` (Ownership proven)
- `recovered` (Physical handover confirmed)
- `closed` (Archived)

---

## 3. Detailed Workflow 2: CampusFix

### Flowchart: Report $\rightarrow$ Classify $\rightarrow$ Assign $\rightarrow$ Resolve $\rightarrow$ Verify

```text
[Student / Faculty: Encounters Facility Failure]
       │
       ▼
 [Tap "Report Issue"]
       │
       ▼
[CampusFix Step-Form]
       - Step 1: Category (Electrical, Wi-Fi, Equipment, Cleanliness, Water, Classroom, Hostel, Other)
       - Step 2: Location (Campus Block, Floor, Room Number)
       - Step 3: Description (Text explanation of failure)
       - Step 4: Before Photo (Camera capture / file upload)
       │
       ▼
 [Submit Issue]
       │
       ▼
[Task-2 Intelligence Engine Pipeline]
       ├── Classifies Category & Sub-type (e.g. equipment -> projector)
       ├── Determines Responsible Department (e.g. IT Operations)
       └── Calculates Priority Level (LOW | MEDIUM | HIGH | CRITICAL)
              │
              ▼
 [Status: 'reported' / Priority: 'HIGH']
       │
       ▼
[Admin Issue Triage Queue]
       - Administrator inspects issue card with AI tags
       - Action: [Assign Technician / Department]
              │
              ▼
 [Status: 'assigned'] ──> Technician receives notification & task
       │
       ▼
[Technician begins work]
       - Action: [Start Work] ──> Status: 'in_progress'
       - Action: [Mark Resolved] ──> Uploads required "After" photo
              │
              ▼
 [Status: 'resolved'] ──> Student reporter notified
       │
       ▼
[Student Resolution Verification Screen]
       - Displays "Before" vs "After" photo side-by-side
       - Question: "Has this issue been resolved to your satisfaction?"
       ├── [Confirm Resolved] ──> Status: 'student_verified' ──> 'closed'
       └── [Dispute / Re-open] ──> Status: 'in_progress' (Re-queued to admin)
```

### State Stepper Visual Sequence
`Reported` $\longrightarrow$ `Verified` $\longrightarrow$ `Assigned` $\longrightarrow$ `In Progress` $\longrightarrow$ `Resolved` $\longrightarrow$ `Student Verified` $\longrightarrow$ `Closed`

---

## 4. Detailed Workflow 3: Digital Queue

### Flowchart: Join $\rightarrow$ Token $\rightarrow$ Wait $\rightarrow$ Notification $\rightarrow$ Service

```text
[Student: Needs On-Campus Administrative Service]
 (e.g., Accounts Office, Registrar, ID Card Desk, Hostel Warden)
       │
       ▼
 [Tap "Join Queue"]
       │
       ▼
[Select Active Queue Service]
       - Displays: Service Name, Office Location, Active Status, Current Serving Token, Estimated Wait
       │
       ▼
 [Tap "Take Token"]
       │
       ▼
[Token Issued: e.g. #27]
       - Generates `QueueToken` with timestamp
       - App displays live tracker:
              * Your Token: #27
              * Currently Serving: #22
              * People Ahead: 5
              * Estimated Time: ~15 mins
       │
       ▼ (Student leaves to library/cafeteria)
[Realtime Position Updates]
       ├── When 3 people ahead: Status banner "Your turn is approaching" (Subtle alert)
       ├── When next in line (#26 served): Status banner turns High Alert (Vibration / Banner)
       └── When #27 is called: Full screen alert "Now Calling Token #27! Please proceed to Desk 2"
              │
              ▼
[Desk Staff: Completes service and clicks "Mark Served"]
       │
       ▼
 [Status: 'served']
       - Token archived in Student's "My Activity" timeline
```

### State Transitions (`QueueToken`)
- `waiting` (In queue, waiting for number)
- `called` (Desk has signaled for user to approach)
- `served` (Service completed)
- `cancelled` (User voluntarily dropped token or missed call)

---

## 5. Detailed Workflow 4: Campus Notices

### Flowchart: Publish $\rightarrow$ Prioritize $\rightarrow$ Consume $\rightarrow$ Acknowledge

```text
[Admin: Creates Announcement]
       │
       ▼
[Notice Form: Title, Category, Priority (Normal | Critical), Body, Deadline Date, Campus Scope]
       │
       ▼
[Publish Notice]
       │
       ▼
[Student Dashboard & Notices Screen]
       ├── If 'Critical': Highlighted banner at top of Student Home + Urgent status badge
       └── If 'Normal': Displayed in categorized notice list with deadline chip
       │
       ▼
[Student taps Notice Card]
       ├── Displays structured notice view: Category chip, Published time, Deadline badge, Full body text
       └── Action: [Acknowledge / Save to Activity]
```

---

## 6. Detailed Workflow 5: Admin Operations & Triage

### Flowchart: Detect $\rightarrow$ Prioritize $\rightarrow$ Assign $\rightarrow$ Resolve $\rightarrow$ Analyze

```text
[Admin logs in to /admin/dashboard]
       │
       ▼
[Top KPI Summary Cards: Active Issues, Critical Count, Resolution Rate, Recovery Rate]
       │
       ▼
[Priority Triage Table: Issues sorted by Priority (CRITICAL first) & Recency]
       │
       ▼
[Admin selects Critical Issue: e.g. "Main Lab 204 Projector Failure"]
       - Inspects: Location, AI Classification (Equipment), Suggested Dept (IT)
       - Action: Select Staff Member -> Click "Assign"
       │
       ▼
[System updates status, routes notification to Staff]
       │
       ▼
[Resolved Issues automatically feed into Campus Intelligence KPI metrics]
       - Average Resolution Time recalculated
       - Recurring Problem Clusters updated
```
