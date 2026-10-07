# CampusOS --- Demo Data Specification

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative References:**  
- [01_PRD.md Section 5, 6, 7](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/01_PRD.md)
- [02_SRD.md Section 11](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/02_SRD.md#L334-L364)
- [03_ARCHITECTURE.md Section 8](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/03_ARCHITECTURE.md#L270-L321)

---

## 1. Campus & Multi-Tenant Boundary

All demo records belong to a primary test institution:
- **Campus ID**: `c0000001-0000-0000-0000-000000000001`
- **Name**: `Apex Institute of Technology (Main Campus)`
- **Code**: `AIT-MAIN`

---

## 2. User Personas & Accounts

| Persona / Name | Email | Role | Department / Affiliation | Password | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Arjun Mehta** | `student@campusos.internal` | `student` | Computer Science (3rd Year) | `StudentPass123!` | Primary student demo: reports lost item, joins queue, tracks issues |
| **Priya Sharma** | `student2@campusos.internal` | `student` | Electronics Eng (2nd Year) | `StudentPass123!` | Secondary student demo: reports broken projector in Room 204 |
| **Dr. Rajesh Rao** | `faculty@campusos.internal` | `faculty` | CS Department Head | `FacultyPass123!` | Faculty reporting lab equipment & viewing notices |
| **Suresh Kumar** | `staff_tech@campusos.internal`| `staff` | IT & Facilities Support | `StaffPass123!` | Technician resolving tickets with before/after photos |
| **Anita Deshmukh**| `admin@campusos.internal` | `admin` | Campus Operations Director | `AdminPass123!` | Administrator triaging tickets, advancing queues, viewing analytics |

---

## 3. Departments & Campus Locations

### Departments
1. `dept-it`: IT & Audio-Visual Support
2. `dept-facilities`: Facilities & Maintenance
3. `dept-accounts`: Finance & Accounts Office
4. `dept-registrar`: Student Registrar & Academic Affairs
5. `dept-library`: Central Library Services

### Locations
1. `loc-lib-201`: Central Library - 2nd Floor (Reading Hall)
2. `loc-acad-204`: Academic Block B - Lecture Hall 204
3. `loc-acad-101`: Academic Block A - Computer Lab 1
4. `loc-host-c3`: Hostel Block C - 3rd Floor Washroom
5. `loc-admin-10`: Administrative Building - Room 10 (Accounts Desk)

---

## 4. Lost & Found Scenario Dataset

### Lost Item
- **ID**: `lost-item-001`
- **User**: Arjun Mehta (`student@campusos.internal`)
- **Category**: `Electronics`
- **Item Name**: `Casio fx-991CW Scientific Calculator`
- **Brand**: `Casio`
- **Color**: `Black`
- **Location**: `Central Library - 2nd Floor (Reading Hall)`
- **Occurred At**: `2026-10-07T10:00:00Z`
- **Status**: `lost`
- **Description**: `Black scientific calculator with solar panel and silver keys.`

### Found Item (The Perfect Match)
- **ID**: `found-item-001`
- **Finder/Staff**: Anita Deshmukh (`admin@campusos.internal`)
- **Category**: `Electronics`
- **Item Name**: `Casio Scientific Calculator`
- **Brand**: `Casio`
- **Color**: `Black`
- **Location**: `Central Library - 2nd Floor`
- **Occurred At**: `2026-10-07T11:15:00Z`
- **Status**: `found`
- **Description**: `Found on desk 14 near the window. Has a small sticker residue on back.`

### Match Record
- **Lost Item ID**: `lost-item-001`
- **Found Item ID**: `found-item-001`
- **Calculated Match Score**: `94%`
- **Match Strength**: `STRONG`
- **Matched Attributes**: `["Category: Electronics", "Brand: Casio", "Color: Black", "Location: Central Library", "Time Window: < 2 hours"]`

### Claim Record
- **Claimant**: Arjun Mehta
- **Verification Question**: *"Does this item have any distinguishing private markings or serial numbers?"*
- **Verification Answer**: *"There is a sticker residue on the bottom back cover."*
- **Status**: `approved` -> leads to `recovered`

---

## 5. CampusFix Issue Dataset

### Issue 1: High Priority Class Disruption (Scenario B)
- **ID**: `issue-001`
- **Reporter**: Priya Sharma (`student2@campusos.internal`)
- **Location**: `Academic Block B - Lecture Hall 204`
- **Category**: `equipment`
- **Type**: `projector`
- **Description**: `The ceiling projector in room 204 keeps turning off automatically after 2 minutes of class.`
- **Severity**: `HIGH`
- **Priority**: `HIGH`
- **Department**: `IT & Audio-Visual Support`
- **Assigned To**: Suresh Kumar
- **Status**: `resolved` (ready for student verification)
- **Before Image**: `https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600`
- **After Image**: `https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600`

### Issue 2: Critical Facility Hazard
- **ID**: `issue-002`
- **Reporter**: Arjun Mehta
- **Location**: `Hostel Block C - 3rd Floor Washroom`
- **Category**: `water`
- **Type**: `pipe_burst`
- **Description**: `Major water pipe leaking on 3rd floor hallway, pooling near power socket.`
- **Severity**: `CRITICAL`
- **Priority**: `CRITICAL`
- **Department**: `Facilities & Maintenance`
- **Status**: `in_progress`

### Issue 3: Recurring Wi-Fi Outage (Hotspot Cluster)
- **ID**: `issue-003` & `issue-004`
- **Location**: `Academic Block A - Computer Lab 1`
- **Category**: `wi-fi`
- **Description**: `No internet access, students cannot submit lab assignments.`
- **Cluster Tag**: `Cluster #7: Academic Block A Network Outage (3 reports in 1hr)`

---

## 6. Digital Queue Dataset

### Queue 1: Accounts Office
- **ID**: `queue-acc-01`
- **Service Name**: `Accounts Office - Fee Clearance Desk`
- **Location**: `Administrative Building - Room 10`
- **Active**: `true`
- **Current Token Number**: `22`
- **Waiting Count**: `5`

### Queue Tokens
- Token `#22`: Status `called` (Current serving)
- Token `#23` through `#26`: Status `waiting`
- Token `#27`: User `student@campusos.internal` (Arjun Mehta), Status `waiting`, Position `#5` (~12 mins)

---

## 7. Campus Notices Bulletin Dataset

### Notice 1: Critical Examination Announcement
- **ID**: `notice-001`
- **Title**: `End-Semester Examination Schedule - Winter 2026`
- **Category**: `examination`
- **Priority**: `CRITICAL`
- **Deadline**: `2026-10-15T17:00:00Z`
- **Body**: `The official exam timetable for Winter 2026 has been published. Verify your examination hall ticket by October 15th.`
- **Active**: `true`

### Notice 2: Fee Clearance Notice
- **ID**: `notice-002`
- **Title**: `Semester Tuition Fee Installment Deadline`
- **Category**: `fees`
- **Priority**: `HIGH`
- **Deadline**: `2026-10-20T23:59:59Z`
- **Body**: `Students paying fees in installments must submit receipts to the Accounts Office before the due date.`

---

## 8. Admin Intelligence & Analytics Baselines

- **Total Active Issues**: `14`
- **Resolved Issues Today**: `9`
- **Average Resolution Time**: `3.4 hours`
- **Lost & Found Recovery Rate**: `68.2%` (15 recovered / 22 reported)
- **Campus Reliability Score**: `87 / 100` (computed from downtime & resolution SLAs)
- **Primary Operational Hotspots**:
  1. `Academic Block B` (8 equipment/electrical issues)
  2. `Hostel Block C` (5 plumbing/water issues)
