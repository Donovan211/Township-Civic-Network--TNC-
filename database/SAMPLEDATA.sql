USE freelancing_network;

-- SAMPLE DATA: 
DROP PROCEDURE IF EXISTS sample_data;

CREATE TEMPORARY TABLE IF NOT EXISTS load_guard (
    ERROR_The_database_is_not_empty_run_schema_sql_first INT NOT NULL
);

INSERT INTO load_guard
SELECT NULL FROM DUAL
WHERE (SELECT COUNT(*) FROM administrator)
    + (SELECT COUNT(*) FROM customer)
    + (SELECT COUNT(*) FROM location)
    + (SELECT COUNT(*) FROM service_category)
    + (SELECT COUNT(*) FROM freelancer)
    + (SELECT COUNT(*) FROM service)
    + (SELECT COUNT(*) FROM booking) > 0;

DROP TEMPORARY TABLE IF EXISTS load_guard;

ALTER TABLE administrator AUTO_INCREMENT = 1;
ALTER TABLE customer AUTO_INCREMENT = 1;
ALTER TABLE location AUTO_INCREMENT = 1;
ALTER TABLE service_category AUTO_INCREMENT = 1;
ALTER TABLE freelancer AUTO_INCREMENT = 1;
ALTER TABLE service AUTO_INCREMENT = 1;
ALTER TABLE booking AUTO_INCREMENT = 1;

START TRANSACTION;

INSERT INTO administrator (admin_name)
VALUES ('Unathi Spele'),
       ('Siyambulela Williams'),
       ('Busisiwe Tyhokolo'),          
       ('Thandolwethu Mlaba'),
       ('Abongile Sima');

INSERT INTO customer (cus_first_name, cus_last_name, cus_phone_num, cus_email)
VALUES ('Alexandra', 'Van Heerden', '0814447392', 'alexandra221@gmail.com'),
       ('Kagiso', 'Sithole', '0786543545', 'kagiso@gmail.com'),
       ('Thato', 'Modau', '0734561110', 'thatohopemodau229@gmail.com'),
       ('Pieter', 'van Wyk', '0812678901', 'pieterwyk000@gmail.com'),   
       ('Langelihle', 'Nkosi', '0756789012', 'langelihle1234@gmail.com');   

INSERT INTO location (location_name, municipality_name)
VALUES ('Soweto', 'City of Johannesburg'),
       ('Alexandra', 'City of Johannesburg'),
       ('Khayelitsha', 'City of Cape Town'),
       ('Umlazi', 'eThekwini'),
       ('Mamelodi', 'City of Tshwane');

INSERT INTO service_category (service_category_name)
VALUES ('Plumbing & Water'),
       ('Electrical & Wiring'),
       ('Building & Renovations'),
       ('Cleaning & Laundry'),
       ('Gardening & Landscaping'),
       ('Beauty & Grooming'),
       ('Transport & Delivery'),
       ('Catering & Events'),
       ('Tutoring & Education'),
       ('Automotive & Mechanics'),
       ('Appliance & Electronics Repair'),
       ('Security & Handyman');

INSERT INTO freelancer (f_first_name, f_last_name, f_phone_num, f_email, verification_status, verification_date, admin_id)
VALUES ('Bongani', 'Mthembu', '0812345678', 'bonganimthembu@gmail.com', 'verified', '2025-01-15', 1),
       ('Ncedo', 'Ncabane', '0823456789', 'Ncedoncabane@gmail.com', 'verified', '2025-01-20', 1),
       ('Sibusiso', 'Radebe', '0834567890', 'sibusisoradebe293@gmail.com', 'verified', '2025-02-01', 5),
       ('Nomvula', 'Sangweni', '0845678901', 'nomvula@gmail.com', 'pending', NULL, NULL),   
       ('Jabu', 'Mahlaba', '0856789012', 'jabumahlaba@gmail.com', 'verified', '2025-02-10', 2);

INSERT INTO service (service_name, service_category_id)
VALUES ('Plumbing Repairs', 1),
       ('Electrical Work', 2),
       ('Maths Tutoring', 9),
       ('Electrical Wiring', 2),
       ('Computer Repair', 11);

INSERT INTO booking (booking_date, scheduled_date, scheduled_time, booking_status, customer_id, freelancer_id, location_id)
VALUES ('2025-03-01', '2025-03-05', '09:00:00', 'completed', 1, 1, 1),
       ('2025-03-02', '2025-03-07', '14:00:00', 'completed', 3, 2, 5),
       ('2025-03-04', '2025-03-09', '10:30:00', 'completed', 5, 2, 2), 
       ('2025-03-06', '2025-03-12', '08:00:00', 'confirmed', 2, 5, 4),
       ('2025-03-08', '2025-03-15', '13:00:00', 'pending', 4, 3, 3);   

INSERT INTO booking_service (booking_id, service_id, hours_booked, agreed_hourly_rate)
VALUES (1, 1, 3.0, 251.40),
       (2, 2, 2.5, 180.53),
       (3, 4, 4.0, 303.86),
       (4, 3, 2.0, 201.44),
       (5, 5, 1.5, 220.13);

INSERT INTO payment (booking_id, payment_method, payment_date, payment_amount, payment_status)
VALUES (1, 'eft', '2025-03-05', 754.20, 'paid'),
       (2, 'cash', '2025-03-06', 451.33, 'paid'),
       (3, 'card', '2025-03-07', 1215.44, 'paid'), 
       (4, 'eft', '2025-03-10', 402.88, 'pending'),
       (5, 'cash', '2025-03-11', 330.20, 'pending'); 

INSERT INTO review (booking_id, rating, review_comment, review_date)
VALUES (1, 5, 'Excellent plumbing work, very professional!', '2025-03-06'),
       (2, 1, 'The work done on the electrical grid was not done properly. Very disappointed.', '2025-03-08'),
       (3, 3, 'Electrical work was okay but arrived late.', '2025-03-10');

INSERT INTO safety_report (booking_id, report_type, report_reason, report_description, report_date, report_status)
VALUES (1, 'freelancer', 'Late arrival', 'Freelancer arrived 30 minutes late.', '2025-03-05', 'dismissed'),
       (2, 'customer', 'Unsafe environment', 'Customer location had aggressive dogs.', '2025-03-07', 'investigating'),
       (4, 'freelancer', 'Payment delay', 'Customer paid 2 days after service.', '2025-03-12', 'resolved'), 
       (4, 'customer', 'Rude behaviour', 'Freelancer was rude on arrival.', '2025-03-13', 'open'),
       (5, 'freelancer', 'No-show', 'Customer was not home at scheduled time.', '2025-03-15', 'open');

COMMIT;
