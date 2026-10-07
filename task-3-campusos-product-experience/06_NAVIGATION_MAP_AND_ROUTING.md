# CampusOS — Navigation Map & Routing Architecture

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Status:** Implementation-Ready Specification for Task-1  
**Source of Truth:** `docs/03_ARCHITECTURE.md`, `docs/04_UX_DESIGN.md`

---

## 1. Information Architecture (IA) Overview

The application is structured into two main role-guarded route branches:
1. **Student / Campus Member Experience** (`/student/*`) — Mobile-first, action-oriented, bottom navigation on mobile.
2. **Campus Administrator Experience** (`/admin/*`) — Widescreen-first, multi-column triage, persistent left sidebar on desktop.

Shared authentication screens (`/login`, `/unauthorized`) anchor the route hierarchy.

---

## 2. Complete Application Route Tree

```text
/                                           --> Redirects to /login (or /student/home if authenticated)
├── /login                                  --> Shared Authentication screen (Google/Email/Campus SSO)
│
├── /student                                --> Student Route Shell (Bottom Nav on Mobile)
│   ├── /student/home                       --> [SCR-STU-01] Student Dashboard & Action Grid
│   │
│   ├── /student/lost-found                 --> [SCR-STU-02] Lost & Found Directory Hub
│   │   ├── /student/lost-found/report-lost --> [SCR-STU-02A] Report Lost Item Form
│   │   ├── /student/lost-found/report-found--> [SCR-STU-02B] Report Found Item Form
│   │   ├── /student/lost-found/item/:id    --> View Lost or Found Item Detail
│   │   └── /student/lost-found/match/:id   --> [SCR-STU-02C] Match Explainability & Claim Modal
│   │
│   ├── /student/campus-fix                 --> [SCR-STU-03] CampusFix Issue Hub & Feed
│   │   ├── /student/campus-fix/report      --> [SCR-STU-03A] Report Campus Issue (Step Form)
│   │   └── /student/campus-fix/issue/:id   --> [SCR-STU-03B] Issue Lifecycle & Verification
│   │
│   ├── /student/queue                      --> [SCR-STU-04] Digital Queue Counters Directory
│   │   └── /student/queue/token/:id        --> [SCR-STU-04A] Live Active Token Tracker
│   │
│   ├── /student/notices                    --> [SCR-STU-05] Campus Notice Board
│   │   └── /student/notices/:id            --> [SCR-STU-05A] Detailed Notice View
│   │
│   ├── /student/activity                   --> [SCR-STU-06] My Activity Unified Timeline
│   └── /student/profile                    --> User Profile, Campus Context, Logout
│
└── /admin                                  --> Admin Route Shell (Sidebar Nav on Desktop, Protected Guard)
    ├── /admin/dashboard                    --> [SCR-ADM-01] Admin Command Overview
    ├── /admin/issues                       --> [SCR-ADM-02] Issue Triage & Dispatch Table
    │   └── /admin/issues/:id/action        --> [SCR-ADM-02A] Issue Assignment Dialog
    ├── /admin/lost-found                   --> [SCR-ADM-03] Lost & Found Custody & Claim Audit
    │   └── /admin/lost-found/claim/:id     --> [SCR-ADM-03A] Claim Verification Review Dialog
    ├── /admin/queues                       --> [SCR-ADM-04] Live Queue Counter Controller
    ├── /admin/notices                      --> [SCR-ADM-05] Notices Broadcast Manager
    └── /admin/analytics                    --> [SCR-ADM-06] Campus Intelligence & Analytics Dashboard
```

---

## 3. Navigation Controls & Layout Adaptation

### 3.1 Mobile Viewports (`< 600px`)
- **Bottom Navigation Bar (5 Primary Tabs):**
  1. `Home` (Icon: `dashboard_rounded`) $\rightarrow$ `/student/home`
  2. `Issues` (Icon: `build_circle_rounded`) $\rightarrow$ `/student/campus-fix`
  3. `Lost & Found` (Icon: `inventory_2_rounded`) $\rightarrow$ `/student/lost-found`
  4. `Queue` (Icon: `confirmation_number_rounded`) $\rightarrow$ `/student/queue`
  5. `Activity` (Icon: `timeline_rounded`) $\rightarrow$ `/student/activity`
- **Top App Bar:**
  - CampusOS Logo / Name, Campus Selector Chip (e.g. `Main Campus`), User Avatar leading to `/student/profile`.

### 3.2 Desktop Viewports (`> 1024px`)
- **Student Desktop Shell:**
  - Standard top navigation header with clean links: Home | Issues | Lost & Found | Queues | Notices | My Activity.
  - Max page width constraint: `1200px` centered to avoid awkward stretched mobile layouts.
- **Admin Desktop Shell (`/admin/*`):**
  - **Persistent Left Navigation Sidebar (260px fixed width):**
    - Brand Banner: CampusOS Admin
    - Navigation items:
      * Overview (`/admin/dashboard`)
      * CampusFix Triage (`/admin/issues`)
      * Lost & Found Custody (`/admin/lost-found`)
      * Queue Counters (`/admin/queues`)
      * Broadcast Notices (`/admin/notices`)
      * Campus Analytics (`/admin/analytics`)
    - Bottom Sidebar: Current Admin User profile card + Logout.

---

## 4. Role-Based Route Guards

1. **Unauthenticated Access:**
   - Attempting to visit `/student/*` or `/admin/*` without an active session automatically redirects to `/login` with a `redirect_to` query parameter.
2. **Student Role Guard:**
   - Users with role `student` or `faculty` attempting to navigate to `/admin/*` are blocked and redirected to `/student/home` with an alert toast: *"Access restricted to campus administrators"*.
3. **Admin Role Guard:**
   - Admins can freely access both `/admin/*` and test `/student/*` views.

---

## 5. Deep-Linking & Future QR Routes

Per PRD Section 10 and Architecture Section 15, the route structure supports pre-filling contexts via URL query parameters:

| Deep-Link Pattern | Destination Screen | Pre-Filled Context |
| :--- | :--- | :--- |
| `/student/campus-fix/report?location=room_204&category=equipment` | Issue Report Wizard | Sets Location to "Room 204" and Category to "Equipment" |
| `/student/queue?join_service=accounts` | Queue Directory | Automatically highlights or triggers token dialog for Accounts Desk |
| `/student/lost-found/report-found?location=library_desk` | Found Item Form | Sets Location to "Library Helpdesk" |
