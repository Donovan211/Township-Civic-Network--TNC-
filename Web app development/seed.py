"""
Township Civic Network - Seed Script
Creates sample users (everyone: first name in lowercase + 123; admins listed in ADMIN_ACCOUNTS),
past bookings, payments, reviews, portfolio placeholders.

Run AFTER schema.sql and with the Flask app context available,
or simply: python seed.py  (it creates its own engine).

Usage:
  1. Run schema.sql in MySQL
  2. Update DB credentials below if needed
  3. python seed.py
"""

from werkzeug.security import generate_password_hash
from datetime import date, time
from sqlalchemy import create_engine, text

# ---- CHANGE THESE IF YOUR MYSQL CREDENTIALS DIFFER ----
DB_URI = "mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network"
# -------------------------------------------------------

def pw_for(first_name):
    """Password rule: first name in lowercase + 123  (Unathi -> unathi123)."""
    return generate_password_hash(first_name.strip().lower() + "123")

# Each administrator has their own email. Password = first name (lowercase) + 123.
# (Change these before any real deployment.)
ADMIN_ACCOUNTS = [
    # (name,                  email,             password)
    ("Unathi Spele",          "unathi@tcn.local", "unathi123"),
    ("Siyambulela Williams",  "siyambulela@tcn.local",  "siyambulela123"),
    ("Busisiwe Tyhokolo",     "busisiwe@tcn.local",  "busisiwe123"),
    ("Thandolwethu Mlaba",    "thandolwethu@tcn.local","thandolwethu123"),
    ("Abongile Sima",         "abongile@tcn.local",   "abongile123"),
]

engine = create_engine(DB_URI)

with engine.begin() as conn:
    # Clear existing data (children first)
    for table in [
        "safety_report", "review", "payment", "booking_service",
        "portfolio_image", "freelancer_service", "booking",
        "service", "freelancer", "service_category", "location",
        "administrator", "customer"
    ]:
        conn.execute(text(f"DELETE FROM {table}"))
        try:
            conn.execute(text(f"ALTER TABLE {table} AUTO_INCREMENT = 1"))
        except Exception:
            pass

    # Administrators (each has their own email and password - see ADMIN_ACCOUNTS)
    for name, email, password in ADMIN_ACCOUNTS:
        conn.execute(text("""
            INSERT INTO administrator (admin_name, admin_email, password_hash) VALUES (:n, :e, :pw)
        """), {"n": name, "e": email, "pw": generate_password_hash(password)})

    # Customers (password = first name + 123)
    customers = [
        ("Alexandra", "Van Heerden", "0814447392", "alexandra221@gmail.com", "customer1.jpg"),
        ("Kagiso", "Sithole", "0786543545", "kagiso@gmail.com", "customer2.jpg"),
        ("Thato", "Modau", "0734561110", "thatohopemodau229@gmail.com", "default.jpg"),
        ("Pieter", "van Wyk", "0812678901", "pieterwyk000@gmail.com", "default.jpg"),
        ("Langelihle", "Nkosi", "0756789012", "langelihle1234@gmail.com", "customer3.jpg"),
    ]
    for c in customers:
        conn.execute(text("""
            INSERT INTO customer (cus_first_name, cus_last_name, cus_phone_num, cus_email, password_hash, profile_pic)
            VALUES (:fn, :ln, :ph, :em, :pw, :pic)
        """), {"fn": c[0], "ln": c[1], "ph": c[2], "em": c[3], "pw": pw_for(c[0]), "pic": c[4]})

    # Locations
    conn.execute(text("""
        INSERT INTO location (location_name, municipality_name) VALUES
        ('Soweto', 'City of Johannesburg'),
        ('Alexandra', 'City of Johannesburg'),
        ('Khayelitsha', 'City of Cape Town'),
        ('Umlazi', 'eThekwini'),
        ('Mamelodi', 'City of Tshwane')
    """))

    # Service categories
    categories = [
        "Plumbing & Water", "Electrical & Wiring", "Building & Renovations",
        "Cleaning & Laundry", "Gardening & Landscaping", "Beauty & Grooming",
        "Transport & Delivery", "Catering & Events", "Tutoring & Education",
        "Automotive & Mechanics", "Appliance & Electronics Repair", "Security & Handyman"
    ]
    for cat in categories:
        conn.execute(text("INSERT INTO service_category (service_category_name) VALUES (:n)"), {"n": cat})

    # Freelancers (password = first name + 123)
    freelancers = [
        ("Bongani", "Mthembu", "0812345678", "bonganimthembu@gmail.com", "verified", "2025-01-15", 1, "freelancer1.jpg",
         "Experienced plumber serving Soweto for 8+ years. Geyser installs, leaks, drain clearing."),
        ("Ncedo", "Ncabane", "0823456789", "Ncedoncabane@gmail.com", "verified", "2025-01-20", 1, "freelancer2.jpg",
         "Qualified electrician. DB boards, wiring, solar-ready installs across Gauteng townships."),
        ("Sibusiso", "Radebe", "0834567890", "sibusisoradebe293@gmail.com", "verified", "2025-02-01", 5, "freelancer3.jpg",
         "PC & laptop repairs, software installs, tutoring in Maths & IT."),
        ("Nomvula", "Sangweni", "0845678901", "nomvula@gmail.com", "pending", None, None, "default.jpg",
         "Beauty & grooming services – awaiting verification."),
        ("Jabu", "Mahlaba", "0856789012", "jabumahlaba@gmail.com", "verified", "2025-02-10", 2, "freelancer4.jpg",
         "Maths tutor (Grade 8–12) and garden maintenance. Patient and reliable."),
    ]
    for f in freelancers:
        conn.execute(text("""
            INSERT INTO freelancer
            (f_first_name, f_last_name, f_phone_num, f_email, password_hash,
             verification_status, verification_date, admin_id, profile_pic, bio)
            VALUES (:fn, :ln, :ph, :em, :pw, :vs, :vd, :aid, :pic, :bio)
        """), {
            "fn": f[0], "ln": f[1], "ph": f[2], "em": f[3], "pw": pw_for(f[0]),
            "vs": f[4], "vd": f[5], "aid": f[6], "pic": f[7], "bio": f[8]
        })

    # Services
    services = [
        ("Plumbing Repairs", 1),
        ("Electrical Work", 2),
        ("Maths Tutoring", 9),
        ("Electrical Wiring", 2),
        ("Computer Repair", 11),
        ("House Cleaning", 4),
        ("Garden Maintenance", 5),
    ]
    for s in services:
        conn.execute(text("""
            INSERT INTO service (service_name, service_category_id) VALUES (:n, :c)
        """), {"n": s[0], "c": s[1]})

    # Freelancer ↔ Service links
    links = [
        (1, 1), (1, 6),          # Bongani: Plumbing, Cleaning
        (2, 2), (2, 4),          # Ncedo: Electrical Work, Wiring
        (3, 5), (3, 3),          # Sibusiso: Computer Repair, Maths Tutoring
        (5, 3), (5, 7),          # Jabu: Maths Tutoring, Garden
    ]
    for fid, sid in links:
        conn.execute(text("""
            INSERT INTO freelancer_service (freelancer_id, service_id) VALUES (:f, :s)
        """), {"f": fid, "s": sid})

    # Bookings (past + current)
    bookings = [
        ("2025-03-01", "2025-03-05", "09:00:00", "completed", 1, 1, 1),
        ("2025-03-02", "2025-03-07", "14:00:00", "completed", 3, 2, 5),
        ("2025-03-04", "2025-03-09", "10:30:00", "completed", 5, 2, 2),
        ("2025-03-06", "2025-03-12", "08:00:00", "confirmed", 2, 5, 4),
        ("2025-03-08", "2025-03-15", "13:00:00", "pending", 4, 3, 3),
        ("2025-04-01", "2025-04-10", "11:00:00", "completed", 1, 5, 1),
        ("2025-04-05", "2025-04-12", "15:00:00", "completed", 2, 1, 2),
    ]
    for b in bookings:
        conn.execute(text("""
            INSERT INTO booking
            (booking_date, scheduled_date, scheduled_time, booking_status,
             customer_id, freelancer_id, location_id)
            VALUES (:bd, :sd, :st, :bs, :cid, :fid, :lid)
        """), {
            "bd": b[0], "sd": b[1], "st": b[2], "bs": b[3],
            "cid": b[4], "fid": b[5], "lid": b[6]
        })

    # Booking services
    bservices = [
        (1, 1, 3.0, 250.00),
        (2, 2, 2.5, 180.00),
        (3, 4, 4.0, 300.00),
        (4, 3, 2.0, 200.00),
        (5, 5, 1.5, 220.00),
        (6, 3, 2.0, 180.00),
        (7, 1, 3.5, 260.00),
    ]
    for bs in bservices:
        conn.execute(text("""
            INSERT INTO booking_service (booking_id, service_id, hours_booked, agreed_hourly_rate)
            VALUES (:bid, :sid, :hrs, :rate)
        """), {"bid": bs[0], "sid": bs[1], "hrs": bs[2], "rate": bs[3]})

    # Payments
    payments = [
        (1, "eft", "2025-03-05", 750.00, "paid"),
        (2, "cash", "2025-03-07", 450.00, "paid"),
        (3, "card", "2025-03-09", 1200.00, "paid"),
        (4, "eft", "2025-03-12", 400.00, "pending"),
        (5, "cash", "2025-03-15", 330.00, "pending"),
        (6, "eft", "2025-04-10", 360.00, "paid"),
        (7, "card", "2025-04-12", 910.00, "paid"),
    ]
    for p in payments:
        conn.execute(text("""
            INSERT INTO payment (booking_id, payment_method, payment_date, payment_amount, payment_status)
            VALUES (:bid, :meth, :pd, :amt, :st)
        """), {"bid": p[0], "meth": p[1], "pd": p[2], "amt": p[3], "st": p[4]})

    # Reviews
    reviews = [
        (1, 5, "Excellent plumbing work, very professional!", "2025-03-06"),
        (2, 2, "Electrical work was not done properly. Disappointed.", "2025-03-08"),
        (3, 4, "Good work, arrived a bit late but fixed everything.", "2025-03-10"),
        (6, 5, "Jabu is a great tutor. My marks improved!", "2025-04-11"),
        (7, 5, "Bongani fixed the leak fast. Highly recommend.", "2025-04-13"),
    ]
    for r in reviews:
        conn.execute(text("""
            INSERT INTO review (booking_id, rating, review_comment, review_date)
            VALUES (:bid, :rt, :cmt, :rd)
        """), {"bid": r[0], "rt": r[1], "cmt": r[2], "rd": r[3]})

    # Safety reports
    reports = [
        (1, "freelancer", "Late arrival", "Freelancer arrived 30 minutes late.", "2025-03-05", "dismissed"),
        (2, "customer", "Unsafe environment", "Customer location had aggressive dogs.", "2025-03-07", "investigating"),
        (4, "freelancer", "Payment delay", "Customer paid 2 days after service.", "2025-03-12", "resolved"),
        (4, "customer", "Rude behaviour", "Freelancer was rude on arrival.", "2025-03-13", "open"),
        (5, "freelancer", "No-show", "Customer was not home at scheduled time.", "2025-03-15", "open"),
    ]
    for rp in reports:
        conn.execute(text("""
            INSERT INTO safety_report
            (booking_id, report_type, report_reason, report_description, report_date, report_status)
            VALUES (:bid, :tp, :rsn, :desc, :rd, :st)
        """), {
            "bid": rp[0], "tp": rp[1], "rsn": rp[2], "desc": rp[3], "rd": rp[4], "st": rp[5]
        })

    # Portfolio images (filenames – place matching images in static/uploads/)
    portfolio = [
        (1, "portfolio_plumb1.jpg", "Kitchen sink repair – Soweto"),
        (1, "portfolio_plumb2.jpg", "Geyser installation"),
        (2, "portfolio_elec1.jpg", "DB board upgrade – Alexandra"),
        (2, "portfolio_elec2.jpg", "House rewiring"),
        (3, "portfolio_pc1.jpg", "Laptop motherboard repair"),
        (5, "portfolio_tutor1.jpg", "Grade 12 Maths session"),
    ]
    for p in portfolio:
        conn.execute(text("""
            INSERT INTO portfolio_image (freelancer_id, filename, caption)
            VALUES (:fid, :fn, :cap)
        """), {"fid": p[0], "fn": p[1], "cap": p[2]})

print("=" * 50)
print("SEED COMPLETE")
print("Password for everyone = first name in lowercase + 123")
print()
print("Sample logins:")
for _n, _e, _p in ADMIN_ACCOUNTS:
    print(f"  Admin                : {_e} / {_p}")
print("  Customer             : alexandra221@gmail.com / alexandra123")
print("  Customer             : kagiso@gmail.com / kagiso123")
print("  Freelancer (verified): bonganimthembu@gmail.com / bongani123")
print("  Freelancer (verified): Ncedoncabane@gmail.com / ncedo123")
print("  Freelancer (pending) : nomvula@gmail.com / nomvula123")
print("=" * 50)
print("Place placeholder images in static/uploads/ if you want photos to show.")
print("Filenames used: default.jpg, customer1-3.jpg, freelancer1-4.jpg,")
print("                 portfolio_plumb1/2.jpg, portfolio_elec1/2.jpg, etc.")
