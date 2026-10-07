-- =============================================================================
-- CampusOS Phase 2 Expanded Seed Dataset
-- Multi-Campus, Multi-Status, Edge Cases & Verification Scenarios
-- Author: Ansh (QA & Deployment Lead)
-- =============================================================================

-- Clean existing demo records
TRUNCATE TABLE queue_tokens, queues, claims, matches, found_items, lost_items, 
               issue_updates, issues, notices, users, locations, departments, campuses CASCADE;

-- 1. Campuses (Multi-Tenant Isolation Test)
INSERT INTO campuses (id, name, code, active, created_at)
VALUES 
  ('c0000001-0000-0000-0000-000000000001', 'Apex Institute of Technology (Main Campus)', 'AIT-MAIN', true, NOW()),
  ('c0000002-0000-0000-0000-000000000002', 'Apex Institute of Technology (North Campus)', 'AIT-NORTH', true, NOW());

-- 2. Departments
INSERT INTO departments (id, campus_id, name, code)
VALUES 
  ('dept-it-main', 'c0000001-0000-0000-0000-000000000001', 'IT & Audio-Visual Support', 'IT-AV'),
  ('dept-fac-main', 'c0000001-0000-0000-0000-000000000001', 'Facilities & Maintenance', 'FAC-MAINT'),
  ('dept-acc-main', 'c0000001-0000-0000-0000-000000000001', 'Finance & Accounts Office', 'FIN-ACC'),
  ('dept-reg-main', 'c0000001-0000-0000-0000-000000000001', 'Student Registrar & Academic Affairs', 'REG-ACAD'),
  ('dept-lib-main', 'c0000001-0000-0000-0000-000000000001', 'Central Library Services', 'LIB-SRV'),
  ('dept-fac-north', 'c0000002-0000-0000-0000-000000000002', 'North Campus Facilities', 'FAC-NORTH');

-- 3. Locations
INSERT INTO locations (id, campus_id, name, building, floor, room_number)
VALUES
  ('loc-lib-201', 'c0000001-0000-0000-0000-000000000001', 'Central Library - 2nd Floor (Reading Hall)', 'Central Library', '2', '201'),
  ('loc-acad-204', 'c0000001-0000-0000-0000-000000000001', 'Academic Block B - Lecture Hall 204', 'Academic Block B', '2', '204'),
  ('loc-acad-101', 'c0000001-0000-0000-0000-000000000001', 'Academic Block A - Computer Lab 1', 'Academic Block A', '1', '101'),
  ('loc-host-c3', 'c0000001-0000-0000-0000-000000000001', 'Hostel Block C - 3rd Floor Washroom', 'Hostel Block C', '3', '300'),
  ('loc-admin-10', 'c0000001-0000-0000-0000-000000000001', 'Administrative Building - Room 10 (Accounts Desk)', 'Admin Building', '1', '10'),
  ('loc-north-101', 'c0000002-0000-0000-0000-000000000002', 'North Campus Engineering Lab 1', 'North Block 1', '1', '101');

-- 4. Users (Role Based: Student, Faculty, Staff, Admin)
INSERT INTO users (id, campus_id, role, full_name, email, department_id, created_at)
VALUES
  ('usr-student-001', 'c0000001-0000-0000-0000-000000000001', 'student', 'Arjun Mehta', 'student@campusos.internal', 'dept-reg-main', NOW()),
  ('usr-student-002', 'c0000001-0000-0000-0000-000000000001', 'student', 'Priya Sharma', 'student2@campusos.internal', 'dept-reg-main', NOW()),
  ('usr-student-003', 'c0000001-0000-0000-0000-000000000001', 'student', 'Vikram Patel', 'student3@campusos.internal', 'dept-reg-main', NOW()),
  ('usr-faculty-001', 'c0000001-0000-0000-0000-000000000001', 'faculty', 'Dr. Rajesh Rao', 'faculty@campusos.internal', 'dept-it-main', NOW()),
  ('usr-staff-001', 'c0000001-0000-0000-0000-000000000001', 'staff', 'Suresh Kumar', 'staff_tech@campusos.internal', 'dept-it-main', NOW()),
  ('usr-admin-001', 'c0000001-0000-0000-0000-000000000001', 'admin', 'Anita Deshmukh', 'admin@campusos.internal', 'dept-fac-main', NOW()),
  ('usr-student-north', 'c0000002-0000-0000-0000-000000000002', 'student', 'Rohan Das', 'rohan@north.campusos.internal', 'dept-fac-north', NOW());

-- 5. Issues (Covering Full Stepper: reported -> verified -> assigned -> in_progress -> resolved -> student_verified -> closed)
INSERT INTO issues (id, campus_id, reporter_id, category, type, description, location_id, severity, priority, department_id, assigned_to, status, before_image_url, after_image_url, created_at, resolved_at, verified_at)
VALUES
  ('iss-001', 'c0000001-0000-0000-0000-000000000001', 'usr-student-002', 'equipment', 'projector', 
   'The ceiling projector in room 204 keeps turning off automatically after 2 minutes of class.', 
   'loc-acad-204', 'HIGH', 'HIGH', 'dept-it-main', 'usr-staff-001', 'resolved', 
   'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 
   'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600', 
   NOW() - INTERVAL '3 hours', NOW() - INTERVAL '30 minutes', NULL),
  ('iss-002', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'water', 'pipe_burst', 
   'Major water pipe leaking on 3rd floor hallway, pooling near power socket.', 
   'loc-host-c3', 'CRITICAL', 'CRITICAL', 'dept-fac-main', 'usr-staff-001', 'in_progress', 
   'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600', NULL, 
   NOW() - INTERVAL '2 hours', NULL, NULL),
  ('iss-003', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'wi-fi', 'network_down', 
   'Wi-Fi access point in Lab 1 is unreachable, no internet connection.', 
   'loc-acad-101', 'HIGH', 'HIGH', 'dept-it-main', NULL, 'reported', 
   NULL, NULL, 
   NOW() - INTERVAL '1 hour', NULL, NULL),
  ('iss-004', 'c0000001-0000-0000-0000-000000000001', 'usr-student-003', 'wi-fi', 'network_down', 
   'Cannot connect to campus wifi in computer lab 1 for programming practical.', 
   'loc-acad-101', 'HIGH', 'HIGH', 'dept-it-main', NULL, 'verified', 
   NULL, NULL, 
   NOW() - INTERVAL '40 minutes', NULL, NULL),
  ('iss-005', 'c0000001-0000-0000-0000-000000000001', 'usr-faculty-001', 'cleanliness', 'trash_overflow', 
   'Recycling bin overflowing in library reading hall.', 
   'loc-lib-201', 'LOW', 'LOW', 'dept-fac-main', 'usr-staff-001', 'closed', 
   NULL, NULL, 
   NOW() - INTERVAL '1 day', NOW() - INTERVAL '20 hours', NOW() - INTERVAL '19 hours'),
  ('iss-north-001', 'c0000002-0000-0000-0000-000000000002', 'usr-student-north', 'electrical', 'light_flicker', 
   'Fluorescent lights flickering in North Engineering Lab 1.', 
   'loc-north-101', 'MEDIUM', 'MEDIUM', 'dept-fac-north', NULL, 'reported', 
   NULL, NULL, 
   NOW() - INTERVAL '30 minutes', NULL, NULL);

-- 6. Lost & Found Items
INSERT INTO lost_items (id, campus_id, user_id, category, item_name, brand, color, location, occurred_at, description, image_url, status, created_at)
VALUES
  ('lost-001', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'Electronics', 'Casio fx-991CW Scientific Calculator', 'Casio', 'Black', 'Central Library - 2nd Floor (Reading Hall)', NOW() - INTERVAL '4 hours', 'Black scientific calculator with solar panel and silver keys.', 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=600', 'lost', NOW() - INTERVAL '3 hours 45 minutes'),
  ('lost-002', 'c0000001-0000-0000-0000-000000000001', 'usr-student-003', 'Accessories', 'Blue Nike Backpack', 'Nike', 'Blue', 'Academic Block A - Ground Floor', NOW() - INTERVAL '5 hours', 'Blue backpack with white Nike swoosh containing notebook.', NULL, 'lost', NOW() - INTERVAL '4 hours 30 minutes');

INSERT INTO found_items (id, campus_id, finder_id, category, item_name, brand, color, location, occurred_at, description, image_url, status, created_at)
VALUES
  ('found-001', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'Electronics', 'Casio Scientific Calculator', 'Casio', 'Black', 'Central Library - 2nd Floor', NOW() - INTERVAL '2 hours', 'Found on desk 14 near the window. Has a small sticker residue on back.', 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=600', 'found', NOW() - INTERVAL '1 hour 50 minutes'),
  ('found-002', 'c0000001-0000-0000-0000-000000000001', 'usr-staff-001', 'Keys', 'Brass Bike Key on Honda Keychain', 'Honda', 'Silver', 'Central Library - Ground Floor Parking', NOW() - INTERVAL '6 hours', 'Single key with black rubber fob.', NULL, 'found', NOW() - INTERVAL '5 hours 30 minutes');

-- 7. Matches & Claims
INSERT INTO matches (id, lost_item_id, found_item_id, score, matched_attributes, created_at)
VALUES
  ('match-001', 'lost-001', 'found-001', 94, '{"category": true, "brand": true, "color": true, "location": true, "time": true}', NOW() - INTERVAL '1 hour 45 minutes');

INSERT INTO claims (id, match_id, claimant_id, verification_answer, status, created_at, verified_at)
VALUES
  ('claim-001', 'match-001', 'usr-student-001', 'There is a sticker residue on the bottom back cover.', 'approved', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '40 minutes');

-- 8. Queues & Queue Tokens
INSERT INTO queues (id, campus_id, service_name, location_id, is_active, current_token_number, waiting_count, created_at)
VALUES
  ('queue-001', 'c0000001-0000-0000-0000-000000000001', 'Accounts Office - Fee Clearance Desk', 'loc-admin-10', true, 22, 5, NOW() - INTERVAL '5 hours'),
  ('queue-002', 'c0000001-0000-0000-0000-000000000001', 'Student Registrar - ID Card Printing', 'loc-admin-10', true, 15, 2, NOW() - INTERVAL '5 hours'),
  ('queue-003', 'c0000001-0000-0000-0000-000000000001', 'Hostel Affairs - Room Allotment Desk', 'loc-admin-10', false, 0, 0, NOW() - INTERVAL '5 hours');

INSERT INTO queue_tokens (id, queue_id, user_id, token_number, status, joined_at, called_at, served_at)
VALUES
  ('tok-022', 'queue-001', 'usr-student-002', 22, 'called', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '10 minutes', NULL),
  ('tok-026', 'queue-001', 'usr-student-003', 26, 'waiting', NOW() - INTERVAL '30 minutes', NULL, NULL),
  ('tok-027', 'queue-001', 'usr-student-001', 27, 'waiting', NOW() - INTERVAL '25 minutes', NULL, NULL);

-- 9. Notices
INSERT INTO notices (id, campus_id, author_id, title, category, priority, body, deadline, published_at, is_active)
VALUES
  ('not-001', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'End-Semester Examination Schedule - Winter 2026', 'examination', 'CRITICAL', 'The official exam timetable for Winter 2026 has been published. Verify your examination hall ticket details before the deadline.', NOW() + INTERVAL '7 days', NOW() - INTERVAL '1 day', true),
  ('not-002', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'Annual Inter-College Hackathon Registrations Open', 'event', 'HIGH', 'Registrations are now open for HackCampus 2026. Submit team details before Friday 6:00 PM.', NOW() + INTERVAL '10 days', NOW() - INTERVAL '4 hours', true),
  ('not-003', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'Hostel Water Tank Maintenance Shutdown Notice', 'hostel', 'MEDIUM', 'Water supply in Hostel Block C will be suspended from 2:00 PM to 4:00 PM today for maintenance.', NOW() + INTERVAL '4 hours', NOW() - INTERVAL '2 hours', true);
