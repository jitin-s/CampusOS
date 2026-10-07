-- =============================================================================
-- CampusOS PostgreSQL / Supabase Seed Dataset
-- Author: Ansh (QA & Deployment Lead)
-- Phase: Task 4 / Phase 1 — Development Infrastructure
-- =============================================================================

-- Clean up existing demo records safely
TRUNCATE TABLE queue_tokens, queues, claims, matches, found_items, lost_items, 
               issue_updates, issues, notices, users, locations, departments, campuses CASCADE;

-- 1. Campuses
INSERT INTO campuses (id, name, code, active, created_at)
VALUES 
  ('c0000001-0000-0000-0000-000000000001', 'Apex Institute of Technology (Main Campus)', 'AIT-MAIN', true, NOW());

-- 2. Departments
INSERT INTO departments (id, campus_id, name, code)
VALUES 
  ('dept-it', 'c0000001-0000-0000-0000-000000000001', 'IT & Audio-Visual Support', 'IT-AV'),
  ('dept-facilities', 'c0000001-0000-0000-0000-000000000001', 'Facilities & Maintenance', 'FAC-MAINT'),
  ('dept-accounts', 'c0000001-0000-0000-0000-000000000001', 'Finance & Accounts Office', 'FIN-ACC'),
  ('dept-registrar', 'c0000001-0000-0000-0000-000000000001', 'Student Registrar & Academic Affairs', 'REG-ACAD'),
  ('dept-library', 'c0000001-0000-0000-0000-000000000001', 'Central Library Services', 'LIB-SRV');

-- 3. Locations
INSERT INTO locations (id, campus_id, name, building, floor, room_number)
VALUES
  ('loc-lib-201', 'c0000001-0000-0000-0000-000000000001', 'Central Library - 2nd Floor (Reading Hall)', 'Central Library', '2', '201'),
  ('loc-acad-204', 'c0000001-0000-0000-0000-000000000001', 'Academic Block B - Lecture Hall 204', 'Academic Block B', '2', '204'),
  ('loc-acad-101', 'c0000001-0000-0000-0000-000000000001', 'Academic Block A - Computer Lab 1', 'Academic Block A', '1', '101'),
  ('loc-host-c3', 'c0000001-0000-0000-0000-000000000001', 'Hostel Block C - 3rd Floor Washroom', 'Hostel Block C', '3', '300'),
  ('loc-admin-10', 'c0000001-0000-0000-0000-000000000001', 'Administrative Building - Room 10 (Accounts Desk)', 'Admin Building', '1', '10');

-- 4. Users
INSERT INTO users (id, campus_id, role, full_name, email, department_id, created_at)
VALUES
  ('usr-student-001', 'c0000001-0000-0000-0000-000000000001', 'student', 'Arjun Mehta', 'student@campusos.internal', 'dept-registrar', NOW()),
  ('usr-student-002', 'c0000001-0000-0000-0000-000000000001', 'student', 'Priya Sharma', 'student2@campusos.internal', 'dept-registrar', NOW()),
  ('usr-faculty-001', 'c0000001-0000-0000-0000-000000000001', 'faculty', 'Dr. Rajesh Rao', 'faculty@campusos.internal', 'dept-it', NOW()),
  ('usr-staff-001', 'c0000001-0000-0000-0000-000000000001', 'staff', 'Suresh Kumar', 'staff_tech@campusos.internal', 'dept-it', NOW()),
  ('usr-admin-001', 'c0000001-0000-0000-0000-000000000001', 'admin', 'Anita Deshmukh', 'admin@campusos.internal', 'dept-facilities', NOW());

-- 5. Issues (CampusFix)
INSERT INTO issues (id, campus_id, reporter_id, category, type, description, location_id, severity, priority, department_id, assigned_to, status, before_image_url, after_image_url, created_at, resolved_at)
VALUES
  ('iss-001', 'c0000001-0000-0000-0000-000000000001', 'usr-student-002', 'equipment', 'projector', 
   'The ceiling projector in room 204 keeps turning off automatically after 2 minutes of class.', 
   'loc-acad-204', 'HIGH', 'HIGH', 'dept-it', 'usr-staff-001', 'resolved', 
   'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600', 
   'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600', 
   NOW() - INTERVAL '3 hours', NOW() - INTERVAL '30 minutes'),
  ('iss-002', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'water', 'pipe_burst', 
   'Major water pipe leaking on 3rd floor hallway, pooling near power socket.', 
   'loc-host-c3', 'CRITICAL', 'CRITICAL', 'dept-facilities', 'usr-staff-001', 'in_progress', 
   'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600', NULL, 
   NOW() - INTERVAL '2 hours', NULL),
  ('iss-003', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'wi-fi', 'network_down', 
   'Wi-Fi access point in Lab 1 is unreachable, no internet connection.', 
   'loc-acad-101', 'HIGH', 'HIGH', 'dept-it', NULL, 'reported', 
   NULL, NULL, 
   NOW() - INTERVAL '1 hour', NULL);

-- 6. Lost & Found Items
INSERT INTO lost_items (id, campus_id, user_id, category, item_name, brand, color, location, occurred_at, description, image_url, status, created_at)
VALUES
  ('lost-001', 'c0000001-0000-0000-0000-000000000001', 'usr-student-001', 'Electronics', 'Casio fx-991CW Scientific Calculator', 'Casio', 'Black', 'Central Library - 2nd Floor (Reading Hall)', NOW() - INTERVAL '4 hours', 'Black scientific calculator with solar panel and silver keys.', 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=600', 'lost', NOW() - INTERVAL '3 hours 45 minutes');

INSERT INTO found_items (id, campus_id, finder_id, category, item_name, brand, color, location, occurred_at, description, image_url, status, created_at)
VALUES
  ('found-001', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'Electronics', 'Casio Scientific Calculator', 'Casio', 'Black', 'Central Library - 2nd Floor', NOW() - INTERVAL '2 hours', 'Found on desk 14 near the window. Has a small sticker residue on back.', 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=600', 'found', NOW() - INTERVAL '1 hour 50 minutes');

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
  ('queue-002', 'c0000001-0000-0000-0000-000000000001', 'Student Registrar - ID Card Printing', 'loc-admin-10', true, 15, 2, NOW() - INTERVAL '5 hours');

INSERT INTO queue_tokens (id, queue_id, user_id, token_number, status, joined_at, called_at, served_at)
VALUES
  ('tok-022', 'queue-001', 'usr-student-002', 22, 'called', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '10 minutes', NULL),
  ('tok-027', 'queue-001', 'usr-student-001', 27, 'waiting', NOW() - INTERVAL '25 minutes', NULL, NULL);

-- 9. Notices
INSERT INTO notices (id, campus_id, author_id, title, category, priority, body, deadline, published_at, is_active)
VALUES
  ('not-001', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'End-Semester Examination Schedule - Winter 2026', 'examination', 'CRITICAL', 'The official exam timetable for Winter 2026 has been published. Verify your examination hall ticket details before the deadline.', NOW() + INTERVAL '7 days', NOW() - INTERVAL '1 day', true),
  ('not-002', 'c0000001-0000-0000-0000-000000000001', 'usr-admin-001', 'Annual Inter-College Hackathon Registrations Open', 'event', 'HIGH', 'Registrations are now open for HackCampus 2026. Submit team details before Friday 6:00 PM.', NOW() + INTERVAL '10 days', NOW() - INTERVAL '4 hours', true);
