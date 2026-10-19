-- REDFLOW: cleanup for an existing XAMPP database (phpMyAdmin > redflow_db > SQL).
-- Keeps all donors/records/users. Safe to run more than once.
USE `redflow_db`;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `blood_transfers`;
DROP TABLE IF EXISTS `blood_bags`;
DROP TABLE IF EXISTS `storage_units`;
SET FOREIGN_KEY_CHECKS=1;

DELETE FROM `app_notifications` WHERE `category` = 'blood_expiry';

UPDATE `users` SET `role` = 'Staff' WHERE `role` = 'Blood Bank MedTech';
ALTER TABLE `users` MODIFY `role` ENUM('Admin','Staff') NOT NULL DEFAULT 'Staff';

-- Mark the cleanup migration as done so "php artisan migrate" will not run it again.
INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2024_01_13_000001_remove_blood_bank_features', x.`b`
FROM (SELECT COALESCE(MAX(`batch`), 0) + 1 AS `b` FROM `migrations`) x
WHERE NOT EXISTS (SELECT 1 FROM (SELECT `migration` FROM `migrations`) m WHERE m.`migration` = '2024_01_13_000001_remove_blood_bank_features');
