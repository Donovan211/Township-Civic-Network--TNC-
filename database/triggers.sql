USE freelancing_network;

DROP TRIGGER IF EXISTS trg_booking_verified_insert;
DROP TRIGGER IF EXISTS trg_booking_verified_update;
DROP TRIGGER IF EXISTS trg_booking_freelancer_verified_insert;
DROP TRIGGER IF EXISTS trg_booking_freelancer_verified_update;
DROP TRIGGER IF EXISTS trg_review_booking_completed_insert;
DROP TRIGGER IF EXISTS trg_payment_date_after_booking_insert;

DELIMITER //

CREATE TRIGGER trg_booking_freelancer_verified_insert
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(15);

    SELECT verification_status 
    INTO v_status
    FROM freelancer
    WHERE freelancer_id = NEW.freelancer_id;

    IF v_status IS NULL OR v_status <> 'verified' THEN
        SIGNAL SQLSTATE '45000'
            SET MYSQL_ERRNO = 50001,
                MESSAGE_TEXT = 'Only verified freelancers can be booked';
    END IF;
END //


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
