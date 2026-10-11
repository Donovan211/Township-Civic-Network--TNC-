USE freelancing_network;

-- CHECK CONSTRAINTS 
ALTER TABLE freelancer
ADD CONSTRAINT ck_freelancer_status
CHECK (verification_status IN ('pending', 'verified', 'rejected', 'suspended')),
ADD CONSTRAINT ck_freelancer_verified
CHECK (verification_status <> 'verified' OR (admin_id IS NOT NULL AND verification_date IS NOT NULL));

ALTER TABLE booking
ADD CONSTRAINT ck_booking_status
CHECK  (booking_status IN ('pending', 'confirmed', 'completed', 'cancelled')),
ADD CONSTRAINT ck_booking_dates
CHECK (scheduled_date >= booking_date);

ALTER TABLE booking_service
ADD CONSTRAINT ck_booking_hours
CHECK (hours_booked >0),
ADD CONSTRAINT ck_booking_rate 
CHECK (agreed_hourly_rate >0);

ALTER TABLE payment
ADD CONSTRAINT ck_payment_method
CHECK (payment_method IN ('cash', 'card', 'eft')),
ADD CONSTRAINT ck_payment_amount
CHECK (payment_amount >0),
ADD CONSTRAINT ck_payment_status
-- 'cancelled' added: the app marks an unpaid payment as cancelled when a booking is cancelled
CHECK (payment_status IN ('pending', 'paid', 'refunded', 'cancelled'));

ALTER TABLE review
ADD CONSTRAINT ck_review_rating
CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE safety_report 
ADD CONSTRAINT ck_report_type 
CHECK (report_type IN ('customer', 'freelancer')),
ADD CONSTRAINT ck_report_status
CHECK (report_status IN ('open', 'investigating', 'resolved', 'dismissed'));
