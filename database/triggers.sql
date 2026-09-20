USE freelancing_network;
-- TRIGGERS: rules that a CHECK constraint cannot enforce, because they need to look at ANOTHER table.

-- Remove the triggers first so this file can be re-run safely
DROP TRIGGER IF EXISTS trg_booking_verified_insert;
DROP TRIGGER IF EXISTS trg_booking_verified_update;
DROP TRIGGER IF EXISTS trg_booking_freelancer_verified_insert;
DROP TRIGGER IF EXISTS trg_booking_freelancer_verified_update;
DROP TRIGGER IF EXISTS trg_review_booking_completed_insert;
DROP TRIGGER IF EXISTS trg_payment_date_after_booking_insert;

DELIMITER //

-- RULE 1 (error 50001): only a verified freelancer can be booked
CREATE TRIGGER trg_booking_freelancer_verified_insert
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(15);

    -- look up the status of the freelancer being booked
    SELECT verification_status 
    INTO v_status
    FROM freelancer
    WHERE freelancer_id = NEW.freelancer_id;

    -- v_status is empty (NULL) if the freelancer does not exist
    IF v_status IS NULL OR v_status <> 'verified' THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50001,
                MESSAGE_TEXT = 'Only verified freelancers can be booked';
    END IF;
END //

-- Rule when an existing booking is switched to a different freelancer.
-- Bookings whose freelancer does not change can still be edited freely,
-- A freelancer who is suspended later does not block old bookings.
CREATE TRIGGER trg_booking_freelancer_verified_update
BEFORE UPDATE ON booking
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(15);

    IF NEW.freelancer_id <> OLD.freelancer_id THEN
        SELECT verification_status 
        INTO v_status
        FROM freelancer
        WHERE freelancer_id = NEW.freelancer_id;

        IF v_status IS NULL OR v_status <> 'verified' THEN
            SIGNAL SQLSTATE '45000'
                SET MYSQL_ERRNO = 50001,
                    MESSAGE_TEXT = 'Only verified freelancers can be booked';
        END IF;
    END IF;
END //

-- RULE 2 (error 50002): a review can only be added for a completed booking
CREATE TRIGGER trg_review_booking_completed_insert
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
    DECLARE v_booking_status VARCHAR(15);

    SELECT booking_status INTO v_booking_status
    FROM booking
    WHERE booking_id = NEW.booking_id;

    IF v_booking_status IS NULL OR v_booking_status <> 'completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50002,
                MESSAGE_TEXT = 'A review can only be added for a completed booking';
    END IF;
END //

-- RULE 3 (error 50003): a payment cannot be dated before its booking
CREATE TRIGGER trg_payment_date_after_booking_insert
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE v_booking_date DATE;

    SELECT booking_date INTO v_booking_date
    FROM booking
    WHERE booking_id = NEW.booking_id;

    IF v_booking_date IS NOT NULL AND NEW.payment_date < v_booking_date THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50003,
                MESSAGE_TEXT = 'The payment date cannot be before the booking date';
    END IF;
END //

DELIMITER ;

-- Confirm all four triggers exist (run this line on its own):
-- SHOW TRIGGERS FROM freelancing_network;

-- TESTS: run these one at a time AFTER the sample data is loaded.
-- Each one should fail with the error number shown:
--
-- 50001: freelancer 4 is still pending
-- INSERT INTO booking (scheduled_date, scheduled_time, customer_id, freelancer_id, location_id)
-- VALUES (CURRENT_DATE, '09:00:00', 1, 4, 1);
--
-- 50002: booking 5 is still pending, not completed
-- INSERT INTO review (booking_id, rating, review_comment, review_date)
-- VALUES (5, 4, 'Test review', CURRENT_DATE);
--
-- 50003: booking 1 was made on 2025-03-01
-- INSERT INTO payment (booking_id, payment_method, payment_date, payment_amount, payment_status)
-- VALUES (5, 'cash', '2025-01-01', 100.00, 'pending');