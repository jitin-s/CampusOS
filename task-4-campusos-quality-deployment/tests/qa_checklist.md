# CampusOS --- Comprehensive Quality Assurance (QA) Checklist

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Reference Documents:**  
- [01_PRD.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/01_PRD.md)
- [02_SRD.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md)
- [03_ARCHITECTURE.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/03_ARCHITECTURE.md)
- [04_UX_DESIGN.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/04_UX_DESIGN.md)

---

## 1. Core State & UX Integrity Checks (Mandatory for ALL Screens)

Per SRD Section 15 and UX Design Section 2, no screen may present an infinite loading spinner or unhandled error.

- [ ] **Loading State**: A visible, non-blocking loading indicator appears during asynchronous data fetch.
- [ ] **Success State**: Clean visual rendering of data without clipped text, overflow badges, or unstyled strings.
- [ ] **Empty State**: Meaningful graphic/icon, explanation, and clear Call to Action (e.g., "No active issues found. Tap to report a problem.") when arrays are empty.
- [ ] **Error State**: Informative, user-friendly error message displayed if network/backend fails (no raw exception dumps or stack traces exposed to students).
- [ ] **Retry Action**: Every error state includes an actionable "Retry" / "Refresh" button that re-triggers the data fetch.
- [ ] **No Infinite Loading**: Network timeout (maximum 10 seconds) fails gracefully to an error state.

---

## 2. Responsive & Platform Layout Checks

Per SRD Section 14 and UX Design Section 15:

### 2.1 Mobile Viewport (360px – 430px)
- [ ] Bottom navigation bar visible and functional.
- [ ] Touch targets are at least 48x48 dp.
- [ ] No horizontal scrolling or viewport clipping on small mobile viewports (360px width).
- [ ] Modals and bottom sheets dismiss cleanly with swipe/backdrop tap.

### 2.2 Tablet Viewport (768px – 1024px)
- [ ] Two-column adaptive layout renders cleanly where appropriate.
- [ ] Grid cards scale without disproportionate whitespace.

### 2.3 Desktop Viewport (1280px+)
- [ ] Admin dashboard utilizes wide layout with persistent sidebar navigation.
- [ ] Student views remain visually balanced (centered max-width container, not stretched full-screen phone UI).
- [ ] Charts and analytics cards align to a clean multi-column dashboard grid.

### 2.4 PWA & Web Standards
- [ ] Web application loads over HTTPS.
- [ ] `manifest.json` provides application title, start URL, theme colors, and standard icon set.
- [ ] Browser back/forward buttons function correctly without breaking navigation stack.
- [ ] Direct URL deep links (e.g., `/student/issues`, `/admin/dashboard`) resolve correctly.

---

## 3. Role-Based Access Control (RBAC) Verification

Per SRD FR-001 and Architecture Section 10:

- [ ] **Student Role**:
  - Accessible: `/student/home`, `/student/lost-found`, `/student/issues`, `/student/queue`, `/student/notices`, `/student/activity`.
  - Blocked: Direct URL access to `/admin/**` redirects immediately to `/student/home` or unauthorized error.
- [ ] **Admin Role**:
  - Accessible: `/admin/dashboard`, `/admin/issues`, `/admin/lost-found`, `/admin/queues`, `/admin/notices`, `/admin/analytics`.
  - Can assign issues, close queues, advance tokens, and publish notices.
- [ ] **Unauthenticated User**:
  - Cannot access student or admin routes.
  - Redirected directly to `/login`.

---

## 4. Feature QA Checklists

### 4.1 Lost & Found Feature
- [ ] **Report Lost Form**:
  - Inputs: Item Category, Name, Brand, Color, Location, Occurred At/Time, Description, Image Upload.
  - Validation: Category, Name, and Location are mandatory.
- [ ] **Report Found Form**:
  - Inputs match lost item specification.
- [ ] **Potential Matches Screen**:
  - Displays explainable match percentage (0–100%).
  - Lists matched attributes clearly (e.g., "✓ Same category", "✓ Same brand").
  - Falls back gracefully to manual search if match scoring is pending or unavailable.
- [ ] **Ownership Claim**:
  - Claimant submits verification answer without exposing confidential hidden details.
  - Claim status transitions: `Claim Submitted -> Ownership Verification -> Approved/Rejected -> Recovered`.

### 4.2 CampusFix (Issue Reporting) Feature
- [ ] **Report Issue Form**:
  - Steps: Category Selection -> Location Selection -> Description -> Image Upload -> Submit.
  - Validation: Prevents empty description submission.
- [ ] **Lifecycle Stepper**:
  - Visually updates along status chain:
    `Reported -> Verified -> Assigned -> In Progress -> Resolved -> Student Verified -> Closed`
  - Current state clearly highlighted with both color and text label.
- [ ] **Proof of Resolution**:
  - Admin/Technician can attach `after_image_url`.
  - Student can verify resolution with a single tap.

### 4.3 Digital Queue System
- [ ] **Service Listing**: Shows available campus counters/services with active status.
- [ ] **Join Queue**:
  - Generates token (e.g., `#27`).
  - Displays "Now Serving" token number (e.g., `#22`).
  - Displays "People Ahead" count (e.g., `4`).
  - Displays estimated wait time.
- [ ] **Status Transitions**: Token states transition accurately: `waiting -> called -> served -> cancelled`.
- [ ] **Admin Operations**: Admin can call next token, mark served, or close queue.

### 4.4 Notices Bulletin
- [ ] **Student View**:
  - Filter notices by category: `Academic`, `Examination`, `Fees`, `Event`, `Placement`, `Hostel`, `Emergency`, `General`.
  - Critical/Emergency notices visually distinguished with high-priority banner.
  - Deadlines prominently formatted.
- [ ] **Admin Creation**: Admin can publish title, category, description, deadline date, and priority flag.

### 4.5 My Activity Timeline
- [ ] Aggregates student actions in reverse chronological order.
- [ ] Unified cards for issues reported, lost/found claims, queue tokens, and acknowledged notices.
- [ ] Tapping an activity card opens the relevant detail view.

### 4.6 Admin Dashboard & Analytics
- [ ] Metric cards show real calculated numbers:
  - Critical Issues Count
  - Active Issues Count
  - Resolved Today Count
  - Lost & Found Recovery Rate (%)
- [ ] Priority queue displays highest urgency issues first.
- [ ] Problem clusters / hotspots highlight recurring problem locations.

---

## 5. Non-Functional & Reliability Checks

- [ ] Form submit buttons disable during in-flight network requests (prevents duplicate submission).
- [ ] No private API keys or service-role secrets printed in client console logs.
- [ ] Network disconnect during form submission shows offline notification with retry capability.
- [ ] All inputs strip leading/trailing whitespace and sanitize HTML tags.
