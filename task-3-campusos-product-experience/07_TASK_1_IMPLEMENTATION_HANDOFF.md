# CampusOS — Implementation Handoff Guide for Task-1 (Jitin)

**Phase:** Phase 1 — Product Research & Experience Foundation  
**Owner:** Arko (Task-3: CampusOS Product Experience)  
**Consumer:** Jitin (Task-1: CampusOS Full-Stack Application)  
**Status:** Authoritative Handoff Specification  
**Source of Truth:** `task-3-campusos-product-experience/`

---

## 1. Overview for Jitin (Task-1 Full-Stack Lead)

This document provides direct, actionable instructions and mapping tables to translate the UX and screen specifications directly into Flutter widgets, routes, and state controllers.

All UX deliverables have been prepared strictly within the Phase-0 PRD/SRD boundaries:
- **No out-of-scope features** (no campus maps, no student payment wallets, no complex social chats).
- **Exact alignment with SOLID**: UI screens consume use-case / repository interfaces rather than raw database queries.
- **Graceful intelligence handling**: Intelligence outputs (matches, priorities) degrade cleanly into standard manual lists if service calls fail.

---

## 2. Flutter Widget & Feature Directory Mapping

To implement the architecture defined in `docs/03_ARCHITECTURE.md`, structure the `lib/` directory as follows:

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          <-- Implements color tokens from 03_DESIGN_SYSTEM.md
│   │   ├── app_typography.dart      <-- Implements Inter text styles
│   │   ├── app_spacing.dart         <-- Implements 4px/8px scale
│   │   └── app_theme.dart           <-- ThemeData configuration (light/dark)
│   ├── widgets/
│   │   ├── app_button.dart          <-- Primary, Outlined, Danger buttons
│   │   ├── app_card.dart            <-- Standardized border/elevation container
│   │   ├── status_badge.dart        <-- Semantic pills with icon + text
│   │   ├── priority_chip.dart       <-- CRITICAL, HIGH, MEDIUM, LOW
│   │   ├── state_stepper.dart       <-- Stepper for CampusFix & Claim verification
│   │   ├── loading_shimmer.dart     <-- Loading state skeleton
│   │   └── empty_state_view.dart    <-- Empty state illustration + action button
│   └── routing/
│       └── app_router.dart          <-- GoRouter config implementing 06_NAVIGATION_MAP_AND_ROUTING.md
│
├── features/
│   ├── auth/
│   │   └── presentation/login_screen.dart
│   ├── student/
│   │   ├── dashboard/
│   │   │   ├── presentation/student_home_screen.dart    <-- SCR-STU-01
│   │   │   └── widgets/action_grid.dart
│   │   ├── lost_found/
│   │   │   ├── presentation/lost_found_hub_screen.dart  <-- SCR-STU-02
│   │   │   ├── presentation/report_lost_screen.dart     <-- SCR-STU-02A
│   │   │   ├── presentation/report_found_screen.dart    <-- SCR-STU-02B
│   │   │   └── presentation/match_detail_screen.dart    <-- SCR-STU-02C
│   │   ├── campus_fix/
│   │   │   ├── presentation/campus_fix_hub_screen.dart  <-- SCR-STU-03
│   │   │   ├── presentation/report_issue_screen.dart    <-- SCR-STU-03A
│   │   │   └── presentation/issue_detail_screen.dart    <-- SCR-STU-03B
│   │   ├── queue/
│   │   │   ├── presentation/queue_directory_screen.dart <-- SCR-STU-04
│   │   │   └── presentation/live_token_screen.dart      <-- SCR-STU-04A
│   │   ├── notices/
│   │   │   ├── presentation/notices_screen.dart         <-- SCR-STU-05
│   │   │   └── presentation/notice_detail_screen.dart   <-- SCR-STU-05A
│   │   └── activity/
│   │       └── presentation/my_activity_screen.dart     <-- SCR-STU-06
│   │
│   └── admin/
│       ├── dashboard/
│       │   └── presentation/admin_dashboard_screen.dart <-- SCR-ADM-01
│       ├── issues/
│       │   ├── presentation/admin_issues_screen.dart    <-- SCR-ADM-02
│       │   └── widgets/issue_assign_dialog.dart         <-- SCR-ADM-02A
│       ├── lost_found/
│       │   ├── presentation/admin_lost_found_screen.dart<-- SCR-ADM-03
│       │   └── widgets/claim_review_dialog.dart         <-- SCR-ADM-03A
│       ├── queues/
│       │   └── presentation/admin_queues_screen.dart    <-- SCR-ADM-04
│       ├── notices/
│       │   └── presentation/admin_notices_screen.dart   <-- SCR-ADM-05
│       └── analytics/
│           └── presentation/admin_analytics_screen.dart <-- SCR-ADM-06
```

---

## 3. UI State Handling Contract

Every feature view MUST handle four mandatory states:

1. **Loading State:**
   - Never display a single centered infinite spinner on a blank white page.
   - Use `loading_shimmer.dart` to render placeholder card skeletons that match the exact shape of incoming content.
2. **Success / Content State:**
   - Display populated list/card hierarchy with clear typography.
3. **Empty State:**
   - Use `empty_state_view.dart` containing:
     - Clear vector icon / illustration.
     - Headline (e.g. *"No Active Tickets"*).
     - Subtitle (e.g. *"You have not reported any issues yet."*).
     - CTA button (e.g. `[Report Issue]`).
4. **Error State:**
   - Display user-friendly message (e.g. *"Could not load live queues. Please check your campus Wi-Fi connection."*).
   - Display `[Retry]` button invoking the controller refresh method.

---

## 4. Key UX Details to Implement Exactly

1. **Lost & Found Explainability Card (`SCR-STU-02C`):**
   - Must render the checklist showing *why* a match was identified:
     - Category check
     - Brand check
     - Color check
     - Location proximity
     - Temporal proximity
   - Do not display an ungrounded raw number without explaining the matched criteria.
2. **CampusFix Visual Stepper (`SCR-STU-03B`):**
   - The status stepper must visibly convey:
     `Reported` $\rightarrow$ `Verified` $\rightarrow$ `Assigned` $\rightarrow$ `In Progress` $\rightarrow$ `Resolved` $\rightarrow$ `Student Verified` $\rightarrow$ `Closed`.
   - When status reaches `Resolved`, display the side-by-side Before/After photo comparison widget with `[Confirm Resolution]` and `[Dispute]` action buttons.
3. **Queue Dynamic Tracker (`SCR-STU-04A`):**
   - Large display of `#Token`.
   - Realtime update of "People Ahead".
   - Color shifts to amber when $\le 2$ people are ahead, and pulsing green banner when token is called.
4. **Desktop Admin Adaptation:**
   - Ensure the admin dashboard does not display as a narrow stretched phone column on widescreen browsers ($>1200\text{px}$). Use `Row` with fixed `260px` left sidebar and flexible content body with responsive grid (`GridView.extent` or multi-column layout).
