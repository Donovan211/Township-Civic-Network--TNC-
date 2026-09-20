CREATE DATABASE IF NOT EXISTS freelancing_network;

USE freelancing_network;

-- CHILDREN FIRST, THEN PARENTS
DROP TABLE IF EXISTS safety_report;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS booking_service;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS freelancer;
DROP TABLE IF EXISTS service_category;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS administrator;
DROP TABLE IF EXISTS customer;

-- CREATING OUR ENTITIES, FROM PARENT TO CHILD
CREATE TABLE customer (
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
    cus_first_name VARCHAR(50) NOT NULL,
    cus_last_name VARCHAR(50) NOT NULL,
    cus_phone_num VARCHAR(15) NOT NULL,
    cus_email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE administrator (
	admin_id INT PRIMARY KEY AUTO_INCREMENT,
    admin_name VARCHAR(100) NOT NULL
);

CREATE TABLE location (
	location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    municipality_name VARCHAR(100) NOT NULL,
    CONSTRAINT unique_location UNIQUE (location_name, municipality_name)
);

CREATE TABLE service_category (
	service_category_id INT PRIMARY KEY AUTO_INCREMENT,
    service_category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE freelancer (
	freelancer_id INT PRIMARY KEY AUTO_INCREMENT,
    f_first_name VARCHAR(50) NOT NULL,
    f_last_name VARCHAR(50) NOT NULL,
    f_phone_num VARCHAR(15) NOT NULL,
    f_email VARCHAR(100) NOT NULL UNIQUE,
    verification_status VARCHAR(15) NOT NULL DEFAULT 'pending',
    verification_date DATE NULL,
    admin_id INT NULL,
    FOREIGN KEY (admin_id) REFERENCES administrator(admin_id)
);

CREATE TABLE service (
	service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    service_category_id INT NOT NULL,
    FOREIGN KEY (service_category_id) REFERENCES service_category(service_category_id)
);

CREATE TABLE booking (
	booking_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    booking_status VARCHAR(15) NOT NULL DEFAULT 'pending',
    customer_id INT NOT NULL,
    freelancer_id INT NOT NULL,
    location_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id)
);

CREATE TABLE booking_service (
	booking_id INT NOT NULL,
    service_id INT NOT NULL,
    hours_booked DECIMAL(4,1) NOT NULL,
    agreed_hourly_rate DECIMAL(7,2) NOT NULL,
    PRIMARY KEY (booking_id, service_id),
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES service(service_id)
);

CREATE TABLE payment (
	payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(10) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(9,2) NOT NULL,
    payment_status VARCHAR(10) NOT NULL DEFAULT 'pending',
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

CREATE TABLE review (
	review_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL UNIQUE,
    rating TINYINT UNSIGNED NOT NULL, -- SAVES DATA USAGE AND STARTS FROM THE VALUE 0
	review_comment VARCHAR(300),
    review_date DATE NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

CREATE TABLE safety_report (
	report_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    report_type VARCHAR(10) NOT NULL,
    report_reason VARCHAR(100) NOT NULL,
    report_description VARCHAR(300),
    report_date DATE NOT NULL,
	report_status VARCHAR(15) NOT NULL DEFAULT 'open',
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

 SHOW TABLES;
 