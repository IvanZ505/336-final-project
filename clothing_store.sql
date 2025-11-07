CREATE DATABASE IF NOT EXISTS `clothing_store`;
USE `clothing_store`;

CREATE TABLE `USER` (
    `user_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `address` VARCHAR(60),
    `is_active` TINYINT(1) DEFAULT 1,
    `email` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(20) NOT NULL,
    `username` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `ADMIN` (
    `admin_id` INT PRIMARY KEY,
    CONSTRAINT `fk_admin_user` FOREIGN KEY (`admin_id`) REFERENCES `USER`(`user_id`) ON DELETE CASCADE
);

CREATE TABLE `CUSTOMER_REP` (
    `rep_id` INT PRIMARY KEY,
    `admin_id` INT,
    CONSTRAINT `fk_rep_user` FOREIGN KEY (`rep_id`) REFERENCES `USER`(`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rep_admin` FOREIGN KEY (`admin_id`) REFERENCES `ADMIN`(`admin_id`)
);

CREATE TABLE `END_USER` (
    `user_id` INT PRIMARY KEY,
    CONSTRAINT `fk_enduser_user` FOREIGN KEY (`user_id`) REFERENCES `USER`(`user_id`) ON DELETE CASCADE
);

CREATE TABLE `ITEM` (
    `item_id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(50) NOT NULL,
    `starting_price` DECIMAL(10, 2) NOT NULL,
    `bid_increment` DECIMAL(10, 2) NOT NULL,
    `secret_min_price` DECIMAL(10, 2),
    `auction_start` DATETIME NOT NULL,
    `auction_end` DATETIME NOT NULL,
    `status` VARCHAR(10) DEFAULT 'pending',
    `current_bid` DECIMAL(10, 2),
    `description` TEXT,
    `seller_id` INT,
    CONSTRAINT `fk_item_seller` FOREIGN KEY (`seller_id`) REFERENCES `END_USER`(`user_id`)
);

CREATE TABLE `SHIRT` (
    `item_id` INT PRIMARY KEY,
    `condition` VARCHAR(10),
    `color` VARCHAR(15),
    `size` VARCHAR(5),
    `brand` VARCHAR(20),
    CONSTRAINT `fk_shirt_item` FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`) ON DELETE CASCADE
);

CREATE TABLE `BAG` (
    `item_id` INT PRIMARY KEY,
    `condition` VARCHAR(10),
    `material` VARCHAR(20),
    `brand` VARCHAR(20),
    `color` VARCHAR(15),
    CONSTRAINT `fk_bag_item` FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`) ON DELETE CASCADE
);

CREATE TABLE `SHOE` (
    `item_id` INT PRIMARY KEY,
    `condition` VARCHAR(10),
    `brand` VARCHAR(20),
    `size` DECIMAL(3,1),
    CONSTRAINT `fk_shoe_item` FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`) ON DELETE CASCADE
);

CREATE TABLE `SUPPORTS` (
    `log_id` INT PRIMARY KEY AUTO_INCREMENT,
    `reason` TEXT,
    `action_type` VARCHAR(10),
    `action_time` DATETIME,
    `user_id` INT,
    `rep_id` INT,
    CONSTRAINT `fk_supports_user` FOREIGN KEY (`user_id`) REFERENCES `END_USER`(`user_id`),
    CONSTRAINT `fk_supports_rep` FOREIGN KEY (`rep_id`) REFERENCES `CUSTOMER_REP`(`rep_id`)
);

CREATE TABLE `SETS_ALERT` (
    `user_id` INT,
    `item_id` INT,
    `size` VARCHAR(5),
    `brand` VARCHAR(20),
    `keywords` VARCHAR(30),
    `is_active` TINYINT(1) DEFAULT 1,
    `condition` VARCHAR(20),
    `color` VARCHAR(15),
    `min_price` DECIMAL(10, 2),
    `max_price` DECIMAL(10, 2),
    PRIMARY KEY (`user_id`, `item_id`),
    CONSTRAINT `fk_alert_user` FOREIGN KEY (`user_id`) REFERENCES `USER`(`user_id`),
    CONSTRAINT `fk_alert_item` FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`)
);

CREATE TABLE `BID` (
    `bid_id` INT PRIMARY KEY AUTO_INCREMENT,
    `bid_amount` DECIMAL(10, 2) NOT NULL,
    `bid_status` VARCHAR(10),
    `is_automatic` TINYINT(1) DEFAULT 0
);

CREATE TABLE `AUTOMATIC_BID` (
    `bid_id` INT PRIMARY KEY,
    `upper_limit` DECIMAL(10, 2),
    `is_active` TINYINT(1) DEFAULT 1,
    `current_proxy_bid` DECIMAL(10, 2),
    CONSTRAINT `fk_autobid_bid` FOREIGN KEY (`bid_id`) REFERENCES `BID`(`bid_id`) ON DELETE CASCADE
);

CREATE TABLE `RECEIVES` (
    `item_id` INT,
    `bid_id` INT,
    PRIMARY KEY (`item_id`, `bid_id`),
    CONSTRAINT `fk_receives_item` FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`),
    CONSTRAINT `fk_receives_bid` FOREIGN KEY (`bid_id`) REFERENCES `BID`(`bid_id`)
);


CREATE TABLE `PLACES` (
    `user_id` INT,
    `bid_id` INT,
    PRIMARY KEY (`user_id`, `bid_id`),
    CONSTRAINT `fk_places_user` FOREIGN KEY (`user_id`) REFERENCES `USER`(`user_id`),
    CONSTRAINT `fk_places_bid` FOREIGN KEY (`bid_id`) REFERENCES `BID`(`bid_id`)
);

-- Add a sample user for testing the login functionality
INSERT INTO `USER` (`name`, `address`, `email`, `password`, `username`) 
VALUES ('Test User', '123 Main St', 'test@example.com', 'password123', 'testuser');
