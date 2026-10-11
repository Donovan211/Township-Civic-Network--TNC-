# Township Civic Network (TCN)

A full-stack Flask marketplace connecting township customers with **verified** local freelancers.

Built for academic demonstration (Database Systems group project). It includes customer, freelancer **and admin** roles, past transactions, portfolio images, safety reports, search/filter, receipts, forgot-password, and **printable per-category reports**.

---

## Features

| Area | What you get |
|------|----------------|
| **Roles** | Customer, Freelancer, **Administrator** |
| **Auth** | Register, login, logout, **forgot/reset password** (signed tokens) |
| **Browse** | Search by name, filter by category, sort by rating/reviews |
| **Profiles** | Bio, portfolio gallery, average rating, completed jobs count |
| **Skills** | Freelancers pick from about 65 services grouped under 12 categories |
| **Booking** | Creates booking + service line + pending payment; date validation |
| **Lifecycle** | pending → confirmed → completed / cancelled |
| **Payments** | Shown on orders/bookings; marked paid on complete |
| **Reviews** | 1–5 stars + comment after completed jobs |
| **Safety** | Both parties can report; admin updates status |
| **Admin panel** | Verify/reject freelancers, manage reports, view all bookings/customers, live stats |
| **Analytics** | Top-rated freelancers, bookings by status, revenue by category, busiest locations |
| **Category reports** | **Report for one service category** (e.g. Electrical & Wiring) on the website (printable) and in the database (stored procedures) |
| **Receipts** | Printable booking receipt |
| **UX** | Flash messages, status badges, filters, empty states, 404/403/500 pages |
| **Sample data** | Past bookings, payments, reviews, portfolio, images |

---

## Quick start (Windows PowerShell)

You need Python 3, MySQL Server 8 and the project folder. Choose **ONE** of the two database options.

> If `mysql` or `mysqldump` is "not recognized", use the full path, for example
> `& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"`,
> or add it to PATH for the current window:
> `$env:Path += ";C:\Program Files\MySQL\MySQL Server 8.0\bin"`
>
> PowerShell does not support the `<` redirect, so every import below goes through `cmd /c "..."`.

### Option A: Full demo data (recommended for group members)

`Database/full_backup.sql` is a complete copy of our database: all tables, demo users, bookings, services, triggers, and the report view and procedures. Use this to see exactly what the team sees.

Do **NOT** run `schema.sql`, `SAMPLEDATA.sql`, `seed.py` or `set_passwords.py` with this option. The backup replaces all of them.

```powershell
# 1. Load the database (this REPLACES any existing freelancing_network database)
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\full_backup.sql"

# 2. Install and run the app
cd "Web app development"
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
$env:DATABASE_URL="mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network"
python app.py
```

### Option B: Fresh database with the original sample data

```powershell
# 1. Database (run in this order)
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\schema.sql"        # tables (drops old ones!)
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\constraints.sql"   # CHECK constraints
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\triggers.sql"      # business-rule triggers
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\SAMPLEDATA.sql"    # sample data
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\reports.sql"       # category report view + procedures
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD < Database\services.sql"      # extra skills (65 in total)

# 2. Install
cd "Web app development"
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt

# 3. Tell the app your MySQL password (repeat in every new terminal)
$env:DATABASE_URL="mysql+pymysql://root:YOUR_MYSQL_PASSWORD@localhost/freelancing_network"

# 4. Give every sample account its password (first name + 123)
python set_passwords.py

# 5. Run
python app.py
```

Alternative to `SAMPLEDATA.sql` + `set_passwords.py`: run `python seed.py` (it loads the data and sets passwords itself). Use one or the other, not both.

Open **http://127.0.0.1:5000**

> `YOUR_MYSQL_PASSWORD` is your own MySQL root password. If it contains `@`, `#` or `/`, write it URL-encoded in `DATABASE_URL` (`@` becomes `%40`).
> macOS/Linux: use `source .venv/bin/activate`, `export DATABASE_URL=...` and `mysql -u root -p < Database/file.sql`.

### Adding to a database you already have (without losing data)

`reports.sql` and `services.sql` are safe to run on a live database. They only add a view, procedures and missing services, and never touch existing rows.

```powershell
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD freelancing_network < Database\reports.sql"
cmd /c "mysql -u root -pYOUR_MYSQL_PASSWORD freelancing_network < Database\services.sql"
```

### Refreshing the backup after adding new demo data

```powershell
mysqldump -u root -pYOUR_MYSQL_PASSWORD --routines --default-character-set=utf8mb4 --databases freelancing_network --result-file="Database\full_backup.sql"
```

Use `--result-file` rather than `>`, because PowerShell's `>` saves the file in a format MySQL cannot read back. Re-zip the project afterwards, including `Web app development\static\uploads` so profile and portfolio pictures match the data.

---

## Demo logins (password = first name in lowercase + `123`)

| Role | Email | Password |
|------|-------|----------|
| **Admin** (Unathi) | `unathi@tcn.local` | `unathi123` |
| **Admin** (Siyambulela) | `siyambulela@tcn.local` | `siyambulela123` |
| **Admin** (Busisiwe) | `busisiwe@tcn.local` | `busisiwe123` |
| **Admin** (Thandolwethu) | `thandolwethu@tcn.local` | `thandolwethu123` |
| **Admin** (Abongile) | `abongile@tcn.local` | `abongile123` |
| Customer | `alexandra221@gmail.com` | `alexandra123` |
| Customer | `kagiso@gmail.com` | `kagiso123` |
| Freelancer (verified) | `bonganimthembu@gmail.com` | `bongani123` |
| Freelancer (verified) | `Ncedoncabane@gmail.com` | `ncedo123` |
| Freelancer (pending) | `nomvula@gmail.com` | `nomvula123` |

Accounts registered through the website use the password chosen at sign-up. With Option A they are included in `full_backup.sql`.

---

## Category reports

### On the website (admin only)

1. Log in as an admin and click **Category Report** in the navigation bar (or the button on the Analytics page).
2. Choose a service category, for example **Electrical & Wiring**.
3. The page shows the totals (bookings, completed, cancelled, freelancers involved, hours, total value excluding cancelled bookings) and every booking in that category.
4. Click **Print this report**. The navigation bar and buttons are hidden in the print version. Choose **landscape** in the print dialog so all columns fit.

Route: `/admin/category-report?category=<id>`

### In the database

`Database/reports.sql` creates one view and two stored procedures:

```sql
CALL category_report('Electrical & Wiring');    -- every booking in that category
CALL category_summary('Electrical & Wiring');   -- one row of totals
SELECT * FROM v_category_report;                -- all categories (filter by service_category_name)
```

An unknown category name raises the error `Unknown service category name`.

---

## Suggested demo flow for the lecturer (8 minutes)

1. **Home** – live stats, featured freelancers, categories, recent reviews
2. **Login as Admin** (`unathi@tcn.local`) – dashboard with revenue, pending verifications, open reports
3. **Verify** Nomvula (pending) → she can then appear in browse
4. **Login as Customer** – search/filter freelancers, open profile (portfolio + ratings)
5. **Book** a service → see order with pending payment
6. **Login as Freelancer** – confirm → complete job (payment flips to paid); open **Services** to show the full skills list grouped by category
7. **Customer** – leave review, open printable **receipt**
8. **Forgot password** – show token link generation
9. **Admin** – update a safety report status
10. **Admin → Category Report** – choose a single category (e.g. Electrical & Wiring) and print it; then show `CALL category_report('Electrical & Wiring');` in MySQL

---

## Project structure

```
Township Civic Network(TCN)/
├── Database/
│   ├── schema.sql          # Tables (drops existing ones first)
│   ├── constraints.sql     # CHECK constraints
│   ├── triggers.sql        # Rules 50001-50003
│   ├── SAMPLEDATA.sql      # Sample data (placeholder passwords)
│   ├── reports.sql         # v_category_report view + category_report / category_summary procedures
│   ├── services.sql        # 60 extra skills across the 12 categories (safe on live data)
│   └── full_backup.sql     # Complete database export incl. demo users (Option A)
└── Web app development/
    ├── app.py              # Flask application
    ├── seed.py             # Sample data loader (with passwords)
    ├── set_passwords.py    # Sets passwords after SAMPLEDATA.sql
    ├── check_admin.py
    ├── requirements.txt
    ├── static/             # css + uploads (profile and portfolio images)
    └── templates/          # pages, admin/ (incl. category_report.html), errors/
```

---

## Technical notes (for Q&A)

- **Stack**: Flask, Flask-SQLAlchemy, PyMySQL, Werkzeug (password hashing), itsdangerous (reset tokens)
- **Schema** aligned with models: `booking_date`, `profile_pic`, `bio`, `portfolio_image`, `freelancer_service`, admin `email`/`password_hash`
- **Skills**: the My Services page lists every row of the `service` table, grouped by category. Adding skills means adding rows to `service` (see `services.sql`). `service_name` is UNIQUE, so the script uses `INSERT IGNORE` and is safe to re-run.
- **Category report**: a booking can contain several services, so the report lists one row per booked service in that category. Totals exclude cancelled bookings.
- **Security (prototype)**: password hashing, login_required / admin_required decorators, secure_filename, file type whitelist, signed time-limited reset tokens
- **Not production-ready**: secret key and default database password in source, no CSRF tokens, no real email, no HTTPS. Fine for a coursework demo.

---

## Database rules (merged from the original TCN database)

| Rule | Where | Enforced by |
|------|-------|-------------|
| Allowed statuses, rating 1-5, hours/rate/amount > 0, payment method cash/card/eft, scheduled date >= booking date, verified freelancer must have admin + date | `constraints.sql` | CHECK constraints |
| **50001** Only a verified freelancer can be booked | `triggers.sql` | trigger on `booking` (insert + freelancer change) |
| **50002** A review needs a completed booking | `triggers.sql` | trigger on `review` |
| **50003** Payment date cannot be before the booking date | `triggers.sql` | trigger on `payment` |

Notes:
- `app.py` turns trigger errors (50001-50003) and CHECK failures into flash messages instead of a crash.
- One change to the original constraints: `payment_status` also allows `'cancelled'`, because the app marks an unpaid payment as cancelled when a booking is cancelled.
- `seed.py` / `SAMPLEDATA.sql` insert data in an order that satisfies the triggers (freelancers verified before bookings, reviews only on completed bookings). Test queries are at the bottom of `triggers.sql`.
- `reports.sql` and `services.sql` only add a view, procedures and missing services. They never delete or change existing rows.