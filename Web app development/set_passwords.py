import os

from sqlalchemy import create_engine, text
from werkzeug.security import generate_password_hash

DB_URI = os.environ.get(
    "DATABASE_URL",
    "mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network",
)

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

TABLES = [
    ("customer", "customer_id", "cus_first_name"),
    ("freelancer", "freelancer_id", "f_first_name"),
]

engine = create_engine(DB_URI)
with engine.begin() as conn:
    # Admins: individual email + password, matched by name
    for name, email, password in ADMIN_ACCOUNTS:
        res = conn.execute(
            text("UPDATE administrator SET admin_email = :e, password_hash = :h WHERE admin_name = :n"),
            {"e": email, "h": generate_password_hash(password), "n": name},
        )
        if res.rowcount == 0:
            conn.execute(
                text("INSERT INTO administrator (admin_name, admin_email, password_hash) VALUES (:n, :e, :h)"),
                {"n": name, "e": email, "h": generate_password_hash(password)},
            )
    print(f"administrator: {len(ADMIN_ACCOUNTS)} account(s) updated")

    for table, id_col, name_col in TABLES:
        rows = conn.execute(text(f"SELECT {id_col}, {name_col} FROM {table}")).fetchall()
        for row_id, name in rows:
            password = name.split()[0].lower() + "123"
            conn.execute(
                text(f"UPDATE {table} SET password_hash = :h WHERE {id_col} = :i"),
                {"h": generate_password_hash(password), "i": row_id},
            )
        print(f"{table}: {len(rows)} account(s) updated")
print("Done. Password = first name (lowercase) + 123. Admin logins:")
for name, email, password in ADMIN_ACCOUNTS:
    print(f"  {email:<18} {password}")
