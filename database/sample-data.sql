-- =======================================================
-- SlotSync Sample Seed Data
-- Resource Booking and Reservation Management System
-- =======================================================

USE `slotsync`;

-- -------------------------------------------------------
-- 1. SEED USERS
-- Passwords:
-- Admin: admin@slotsync.com / Admin@12345 (Role: ADMIN)
-- User:  john.doe@slotsync.com / User@12345 (Role: USER)
-- User:  jane.smith@slotsync.com / User@12345 (Role: USER)
-- User:  alex.turner@slotsync.com / User@12345 (Role: USER)
-- -------------------------------------------------------
INSERT INTO `users` (`user_id`, `full_name`, `email`, `password_hash`, `role`, `active`, `created_at`) VALUES
(1, 'System Administrator', 'admin@slotsync.com', '$ss$65536$3addce11a808cea5251db5137f503718$cf79c2c395a359185f97cdd1bb429f5d9f942d82aea78f320e2dc809fb323e2055881c04cf29f830b8640f5a5e592e0255ac5d142efeb616b75bcf72dae10abe', 'ADMIN', TRUE, NOW()),
(2, 'Dr. John Doe', 'john.doe@slotsync.com', '$ss$65536$f8f7f4f7ede35a11ad2faf081951bb2e$30f32b227dae3d3b4cff91d23db53f7b442be62ddcee6b473aa40e6e1d0967447a6d5d1ddf072cb8b0a2cb8f14acefecda14a73365d07b5dc2fa32ca6cba6ed9', 'USER', TRUE, NOW()),
(3, 'Prof. Jane Smith', 'jane.smith@slotsync.com', '$ss$65536$f8f7f4f7ede35a11ad2faf081951bb2e$30f32b227dae3d3b4cff91d23db53f7b442be62ddcee6b473aa40e6e1d0967447a6d5d1ddf072cb8b0a2cb8f14acefecda14a73365d07b5dc2fa32ca6cba6ed9', 'USER', TRUE, NOW()),
(4, 'Alex Turner', 'alex.turner@slotsync.com', '$ss$65536$f8f7f4f7ede35a11ad2faf081951bb2e$30f32b227dae3d3b4cff91d23db53f7b442be62ddcee6b473aa40e6e1d0967447a6d5d1ddf072cb8b0a2cb8f14acefecda14a73365d07b5dc2fa32ca6cba6ed9', 'USER', TRUE, NOW())
ON DUPLICATE KEY UPDATE `full_name` = VALUES(`full_name`), `password_hash` = VALUES(`password_hash`);

-- -------------------------------------------------------
-- 2. SEED RESOURCES
-- Categories: Computer Laboratory, Meeting Room, Projector, Computer System, Conference Hall
-- -------------------------------------------------------
INSERT INTO `resources` (`resource_id`, `name`, `resource_type`, `location`, `capacity`, `description`, `active`, `created_at`) VALUES
(1, 'Advanced Computing Laboratory (Lab 101)', 'Computer Laboratory', 'Science & Tech Block, 1st Floor, Room 101', 45, 'Equipped with 45 high-spec Dell Core i9 workstations, dual monitors, high-speed Gigabit LAN, and projector setup for programming and data analytics sessions.', TRUE, NOW()),
(2, 'AI & Robotics Research Lab', 'Computer Laboratory', 'Innovation Hub, Ground Floor, Room G-04', 30, 'Specialized lab equipped with Nvidia RTX GPU workstations, IoT hardware development kits, ROS simulation tools, and collaborative workbenches.', TRUE, NOW()),
(3, 'Executive Boardroom (Room 302)', 'Meeting Room', 'Administrative Wing, 3rd Floor, Room 302', 16, 'Modern boardroom featuring a 75-inch interactive 4K smart display, omnidirectional conferencing microphones, executive leather seating, and glass whiteboard.', TRUE, NOW()),
(4, 'Faculty Conference Hall', 'Conference Hall', 'Main Academic Building, 2nd Floor, Hall B', 80, 'Spacious tiered conference hall with dual projection screens, wireless podium mics, surround sound acoustics, and recording equipment for seminars.', TRUE, NOW()),
(5, '4K Laser Projector - Unit Alpha', 'Projector', 'Media Equipment Center, IT Helpdesk Depot', 1, 'Epson Pro 4K 6000-Lumen Laser Projector with wireless casting (HDMI, AirPlay, Miracast) and carrying case. Ideal for indoor & outdoor presentations.', TRUE, NOW()),
(6, 'Ultra-Short Throw Smart Projector - Unit Beta', 'Projector', 'Media Equipment Center, IT Helpdesk Depot', 1, 'Optoma Ultra Short Throw Laser Projector with interactive touch pen sensor and magnetic screen mount.', TRUE, NOW()),
(7, 'High-Performance Workstation - Rig #01', 'Computer System', 'Virtual Reality Lab, Room 205', 1, 'Workstation equipped with AMD Ryzen 9 7950X, 64GB DDR5 RAM, Nvidia RTX 4090 24GB, and dual 32-inch 4K color-accurate displays for rendering and modeling.', TRUE, NOW()),
(8, 'High-Performance Workstation - Rig #02', 'Computer System', 'Virtual Reality Lab, Room 205', 1, 'Workstation equipped with Intel Core i9-14900K, 64GB DDR5 RAM, Nvidia RTX 4080 16GB, and dual 32-inch displays.', TRUE, NOW()),
(9, 'Collaborative Study Pod A', 'Meeting Room', 'Central Library, 2nd Floor, Pod A', 6, 'Acoustically isolated soundproof pod with whiteboard table, HDMI plug-and-play screen, and comfortable seating for group discussions.', TRUE, NOW()),
(10, 'Collaborative Study Pod B', 'Meeting Room', 'Central Library, 2nd Floor, Pod B', 6, 'Acoustically isolated soundproof pod with whiteboard table, HDMI plug-and-play screen, and ergonomic seating.', TRUE, NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- -------------------------------------------------------
-- 3. SEED RESERVATIONS
-- Sample reservations with realistic past, present, and future dates
-- -------------------------------------------------------
INSERT INTO `reservations` (`reservation_id`, `user_id`, `resource_id`, `start_time`, `end_time`, `purpose`, `status`, `reviewed_by`, `review_reason`, `created_at`, `updated_at`) VALUES
(1, 2, 1, DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 9 HOUR), DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 12 HOUR), 'Advanced Java Web Programming Practical Session for Batch 2026', 'APPROVED', 1, 'Approved for academic lab curriculum.', NOW(), NOW()),
(2, 3, 3, DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 2 DAY), INTERVAL 14 HOUR), DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 2 DAY), INTERVAL 16 HOUR), 'Departmental Curriculum Review & Faculty Planning Meeting', 'APPROVED', 1, 'Boardroom allocated for faculty meeting.', NOW(), NOW()),
(3, 4, 2, DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 3 DAY), INTERVAL 10 HOUR), DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 3 DAY), INTERVAL 13 HOUR), 'Robotics Club autonomous rover sensor calibration workshop', 'PENDING', NULL, NULL, NOW(), NOW()),
(4, 2, 5, DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 4 DAY), INTERVAL 15 HOUR), DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 4 DAY), INTERVAL 17 HOUR), 'Guest Lecture on Cloud Native Systems by Industry Expert', 'PENDING', NULL, NULL, NOW(), NOW()),
(5, 3, 1, DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 0 DAY), INTERVAL 2 DAY), DATE_SUB(DATE_ADD(CURDATE(), INTERVAL 0 DAY), INTERVAL 2 DAY) + INTERVAL 3 HOUR, 'Database Systems Lab Midterm Practical Exam', 'COMPLETED', 1, 'Completed successfully.', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 4, 3, DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 10 HOUR), DATE_ADD(DATE_ADD(CURDATE(), INTERVAL 1 DAY), INTERVAL 12 HOUR), 'Student Council Weekly Sync', 'REJECTED', 1, 'Executive Boardroom is reserved exclusively for faculty and administrative staff. Please book Collaborative Pod A or B.', NOW(), NOW())
ON DUPLICATE KEY UPDATE `purpose` = VALUES(`purpose`);

-- -------------------------------------------------------
-- 4. SEED RESERVATION STATUS HISTORY
-- -------------------------------------------------------
INSERT INTO `reservation_status_history` (`reservation_id`, `changed_by`, `old_status`, `new_status`, `reason`, `changed_at`) VALUES
(1, 2, NULL, 'PENDING', 'Initial reservation request submitted.', NOW()),
(1, 1, 'PENDING', 'APPROVED', 'Approved for academic lab curriculum.', NOW()),
(2, 3, NULL, 'PENDING', 'Initial reservation request submitted.', NOW()),
(2, 1, 'PENDING', 'APPROVED', 'Boardroom allocated for faculty meeting.', NOW()),
(3, 4, NULL, 'PENDING', 'Initial reservation request submitted.', NOW()),
(4, 2, NULL, 'PENDING', 'Initial reservation request submitted.', NOW()),
(5, 3, NULL, 'PENDING', 'Initial reservation request submitted.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 1, 'PENDING', 'APPROVED', 'Approved for practical exam.', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 1, 'APPROVED', 'COMPLETED', 'Session ended.', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 4, NULL, 'PENDING', 'Initial reservation request submitted.', NOW()),
(6, 1, 'PENDING', 'REJECTED', 'Executive Boardroom is reserved exclusively for faculty and administrative staff. Please book Collaborative Pod A or B.', NOW());
