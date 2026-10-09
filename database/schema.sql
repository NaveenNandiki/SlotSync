-- =======================================================
-- SlotSync Database Schema
-- Resource Booking and Reservation Management System
-- Compatible with MySQL 8.0+ / MariaDB
-- =======================================================

CREATE DATABASE IF NOT EXISTS `slotsync` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `slotsync`;

-- Drop tables in reverse dependency order if recreating
DROP TABLE IF EXISTS `reservation_status_history`;
DROP TABLE IF EXISTS `reservations`;
DROP TABLE IF EXISTS `resources`;
DROP TABLE IF EXISTS `users`;

-- -------------------------------------------------------
-- 1. USERS TABLE
-- -------------------------------------------------------
CREATE TABLE `users` (
    `user_id` BIGINT NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
    `active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_users_email` (`email`),
    INDEX `idx_users_role` (`role`),
    INDEX `idx_users_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 2. RESOURCES TABLE
-- -------------------------------------------------------
CREATE TABLE `resources` (
    `resource_id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(120) NOT NULL,
    `resource_type` VARCHAR(50) NOT NULL,
    `location` VARCHAR(150) NOT NULL,
    `capacity` INT NOT NULL DEFAULT 1,
    `description` VARCHAR(500) DEFAULT NULL,
    `active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`resource_id`),
    INDEX `idx_resources_type` (`resource_type`),
    INDEX `idx_resources_location` (`location`),
    INDEX `idx_resources_active` (`active`),
    CONSTRAINT `chk_resource_capacity` CHECK (`capacity` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 3. RESERVATIONS TABLE
-- -------------------------------------------------------
CREATE TABLE `reservations` (
    `reservation_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `resource_id` BIGINT NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NOT NULL,
    `purpose` VARCHAR(300) NOT NULL,
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    `reviewed_by` BIGINT DEFAULT NULL,
    `review_reason` VARCHAR(500) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`reservation_id`),
    INDEX `idx_reservations_user` (`user_id`),
    INDEX `idx_reservations_resource` (`resource_id`),
    INDEX `idx_reservations_status` (`status`),
    INDEX `idx_reservations_time_range` (`start_time`, `end_time`),
    INDEX `idx_reservations_conflict_check` (`resource_id`, `status`, `start_time`, `end_time`),
    CONSTRAINT `fk_res_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_res_resource` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`resource_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_res_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_reservation_time` CHECK (`end_time` > `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 4. RESERVATION STATUS HISTORY TABLE
-- -------------------------------------------------------
CREATE TABLE `reservation_status_history` (
    `history_id` BIGINT NOT NULL AUTO_INCREMENT,
    `reservation_id` BIGINT NOT NULL,
    `changed_by` BIGINT NOT NULL,
    `old_status` VARCHAR(20) DEFAULT NULL,
    `new_status` VARCHAR(20) NOT NULL,
    `reason` VARCHAR(500) DEFAULT NULL,
    `changed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`history_id`),
    INDEX `idx_history_reservation` (`reservation_id`),
    INDEX `idx_history_changed_by` (`changed_by`),
    CONSTRAINT `fk_hist_reservation` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_hist_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
