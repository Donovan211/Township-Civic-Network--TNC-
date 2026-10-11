USE freelancing_network;

-- One row per booked service, with the category attached.
CREATE OR REPLACE VIEW v_category_report AS
SELECT sc.service_category_id,
       sc.service_category_name,
       b.booking_id,
       b.booking_date,
       b.scheduled_date,
       s.service_name,
       CONCAT(c.cus_first_name, ' ', c.cus_last_name)  AS customer,
       CONCAT(f.f_first_name, ' ', f.f_last_name)      AS freelancer,
       l.location_name,
       l.municipality_name,
       bs.hours_booked,
       bs.agreed_hourly_rate,
       ROUND(bs.hours_booked * bs.agreed_hourly_rate, 2) AS line_total,
       b.booking_status,
       p.payment_status
FROM booking_service bs
JOIN booking b           ON b.booking_id = bs.booking_id
JOIN service s           ON s.service_id = bs.service_id
JOIN service_category sc ON sc.service_category_id = s.service_category_id
JOIN customer c          ON c.customer_id = b.customer_id
JOIN freelancer f        ON f.freelancer_id = b.freelancer_id
JOIN location l          ON l.location_id = b.location_id
LEFT JOIN payment p      ON p.booking_id = b.booking_id;

DROP PROCEDURE IF EXISTS category_report;
DROP PROCEDURE IF EXISTS category_summary;

DELIMITER //

-- Detailed report for ONE category
CREATE PROCEDURE category_report(IN p_category VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM service_category WHERE service_category_name = p_category) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown service category name';
    END IF;

    SELECT booking_id, scheduled_date, service_name, customer, freelancer, location_name,
           hours_booked, agreed_hourly_rate, line_total, booking_status, payment_status
    FROM v_category_report
    WHERE service_category_name = p_category
    ORDER BY scheduled_date DESC, booking_id DESC;
END //

-- Totals for ONE category (cancelled bookings excluded from hours/value)
CREATE PROCEDURE category_summary(IN p_category VARCHAR(50))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM service_category WHERE service_category_name = p_category) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unknown service category name';
    END IF;

    SELECT p_category AS category,
           COUNT(DISTINCT booking_id)                                                  AS bookings,
           COUNT(DISTINCT CASE WHEN booking_status = 'completed' THEN booking_id END)  AS completed,
           COUNT(DISTINCT CASE WHEN booking_status = 'cancelled' THEN booking_id END)  AS cancelled,
           COUNT(DISTINCT CASE WHEN booking_status <> 'cancelled' THEN freelancer END) AS freelancers,
           COALESCE(SUM(CASE WHEN booking_status <> 'cancelled' THEN hours_booked END), 0) AS hours_booked,
           COALESCE(SUM(CASE WHEN booking_status <> 'cancelled' THEN line_total END), 0)   AS total_value
    FROM v_category_report
    WHERE service_category_name = p_category;
END //

DELIMITER ;