"""Diagnose admin login problems. Run with DATABASE_URL set, same as app.py."""
import os
from sqlalchemy import create_engine, text
from werkzeug.security import check_password_hash

DB_URI = os.environ.get("DATABASE_URL", "mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network")
EXPECTED = {
    "unathi@tcn.local": "unathi123",
    "siyambulela@tcn.local": "siyambulela123",
    "busisiwe@tcn.local": "busisiwe123",
    "thandolwethu@tcn.local": "thandolwethu123",
    "abongile@tcn.local": "abongile123",
}

engine = create_engine(DB_URI)
with engine.connect() as conn:
    print("Connected to:", conn.execute(text("SELECT DATABASE()")).scalar())
    rows = conn.execute(text("SELECT admin_id, admin_name, admin_email, password_hash FROM administrator")).fetchall()
    if not rows:
        print("PROBLEM: administrator table is EMPTY -> load SAMPLEDATA.sql (or run seed.py), then set_passwords.py")
    for i, name, email, h in rows:
        if not email:
            status = "NO EMAIL -> run set_passwords.py"
        elif not h:
            status = "NO PASSWORD -> run set_passwords.py"
        elif email.lower() in EXPECTED:
            status = "login OK" if check_password_hash(h, EXPECTED[email.lower()]) else "PASSWORD MISMATCH -> run set_passwords.py"
        else:
            status = "unexpected email (old data?) -> run set_passwords.py"
        print(f"{i}  {name:<22} {str(email):<28} {status}")
