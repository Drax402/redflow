SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

CREATE DATABASE IF NOT EXISTS `redflow_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `redflow_db`;

DROP TABLE IF EXISTS `blood_transfers`, `blood_bags`, `storage_units`, `edit_requests`, `export_guards`, `secure_files`, `password_reset_otps`, `user_logs`, `audit_log`, `app_notifications`, `staff_profiles`, `monitoring_transactions`, `monitoring_records`, `donors`, `users`, `sessions`, `cache`, `cache_locks`;

CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` CHAR(36) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `username` VARCHAR(40) DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `contact` TEXT DEFAULT NULL,
  `brgy` TEXT DEFAULT NULL,
  `gender` TEXT DEFAULT NULL,
  `ext_name` VARCHAR(255) DEFAULT NULL,
  `dob` TEXT DEFAULT NULL,
  `role` ENUM('Admin','Staff') NOT NULL DEFAULT 'Staff',
  `status` ENUM('Pending','Approved') NOT NULL DEFAULT 'Pending',
  `id_front_path` VARCHAR(255) DEFAULT NULL,
  `id_back_path` VARCHAR(255) DEFAULT NULL,
  `face_doc_path` VARCHAR(255) DEFAULT NULL,
  `action_taken` VARCHAR(255) NOT NULL DEFAULT 'Registered',
  `approved_by` BIGINT UNSIGNED DEFAULT NULL,
  `approved_at` TIMESTAMP NULL DEFAULT NULL,
  `is_disabled` TINYINT(1) NOT NULL DEFAULT 0,
  `disabled_at` TIMESTAMP NULL DEFAULT NULL,
  `disabled_by` BIGINT UNSIGNED DEFAULT NULL,
  `last_login_at` TIMESTAMP NULL DEFAULT NULL,
  `failed_login_attempts` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_uuid_unique` (`uuid`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`),
  KEY `users_approved_by_foreign` (`approved_by`),
  CONSTRAINT `users_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `staff_profiles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `avatar_path` VARCHAR(255) DEFAULT NULL,
  `extra` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_profiles_user_id_unique` (`user_id`),
  CONSTRAINT `staff_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `donors` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `donor_uid` VARCHAR(255) NOT NULL,
  `name` TEXT NOT NULL,
  `blood_type` TEXT DEFAULT NULL,
  `contact` TEXT DEFAULT NULL,
  `brgy` TEXT DEFAULT NULL,
  `gender` TEXT DEFAULT NULL,
  `dob` TEXT DEFAULT NULL,
  `extra` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donors_donor_uid_unique` (`donor_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `monitoring_records` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `record_uid` VARCHAR(255) NOT NULL,
  `donor_id` BIGINT UNSIGNED DEFAULT NULL,
  `donation_date` DATE NOT NULL,
  `blood_type` TEXT DEFAULT NULL,
  `times_donated` INT UNSIGNED NOT NULL DEFAULT 1,
  `extra` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `monitoring_records_record_uid_unique` (`record_uid`),
  KEY `monitoring_records_donor_id_foreign` (`donor_id`),
  CONSTRAINT `monitoring_records_donor_id_foreign` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `monitoring_transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transaction_uid` VARCHAR(255) NOT NULL,
  `donor_id` BIGINT UNSIGNED NOT NULL,
  `monitoring_record_id` BIGINT UNSIGNED DEFAULT NULL,
  `donation_date` DATE NOT NULL,
  `blood_type` TEXT DEFAULT NULL,
  `extra` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `monitoring_transactions_transaction_uid_unique` (`transaction_uid`),
  KEY `monitoring_transactions_donor_id_foreign` (`donor_id`),
  KEY `monitoring_transactions_monitoring_record_id_foreign` (`monitoring_record_id`),
  CONSTRAINT `monitoring_transactions_donor_id_foreign` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `monitoring_transactions_monitoring_record_id_foreign` FOREIGN KEY (`monitoring_record_id`) REFERENCES `monitoring_records` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `edit_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `requested_by` BIGINT UNSIGNED NOT NULL,
  `type` VARCHAR(30) NOT NULL,
  `donor_id` BIGINT UNSIGNED DEFAULT NULL,
  `donor_name` TEXT DEFAULT NULL,
  `payload` LONGTEXT DEFAULT NULL,
  `original` LONGTEXT DEFAULT NULL,
  `reason` TEXT DEFAULT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'Pending',
  `reviewed_by` BIGINT UNSIGNED DEFAULT NULL,
  `reviewed_at` TIMESTAMP NULL DEFAULT NULL,
  `hidden_by_requester` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `edit_requests_status_type_index` (`status`,`type`),
  CONSTRAINT `edit_requests_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `edit_requests_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `app_notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `message` TEXT NOT NULL,
  `category` VARCHAR(30) NOT NULL DEFAULT 'other',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `app_notifications_user_id_foreign` (`user_id`),
  CONSTRAINT `app_notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `audit_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED DEFAULT NULL,
  `user_name` VARCHAR(255) DEFAULT NULL,
  `user_role` VARCHAR(255) DEFAULT NULL,
  `action` VARCHAR(255) NOT NULL,
  `action_label` VARCHAR(255) DEFAULT NULL,
  `donor_id` BIGINT UNSIGNED DEFAULT NULL,
  `donor_name` VARCHAR(255) DEFAULT NULL,
  `details` TEXT DEFAULT NULL,
  `logged_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `audit_log_user_id_foreign` (`user_id`),
  CONSTRAINT `audit_log_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `user_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event` VARCHAR(255) NOT NULL,
  `occurred_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_logs_user_id_foreign` (`user_id`),
  CONSTRAINT `user_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_reset_otps` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `code_hash` VARCHAR(255) NOT NULL,
  `expires_at` TIMESTAMP NOT NULL,
  `consumed` TINYINT(1) NOT NULL DEFAULT 0,
  `attempts` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `password_reset_otps_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `export_guards` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `failed_attempts` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` TIMESTAMP NULL DEFAULT NULL,
  `exports` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `export_guards_user_id_unique` (`user_id`),
  CONSTRAINT `export_guards_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `secure_files` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `path` VARCHAR(255) NOT NULL,
  `content` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `secure_files_path_unique` (`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sessions` (
  `id` VARCHAR(255) NOT NULL,
  `user_id` BIGINT UNSIGNED DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `payload` LONGTEXT NOT NULL,
  `last_activity` INT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache` (
  `key` VARCHAR(255) NOT NULL,
  `value` MEDIUMTEXT NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache_locks` (
  `key` VARCHAR(255) NOT NULL,
  `owner` VARCHAR(255) NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;
