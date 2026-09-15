# TCN Development Setup

## Requirements

- Python 3.11 or newer
- MySQL 8 or MariaDB 10.6+
- Git

## First-time setup

From the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Edit `.env` with local database credentials. Never commit `.env`.

## Database setup

Create the database and starter tables by running these files in MySQL Workbench or the MySQL client:

```text
database/schema.sql
database/seed.sql
```

## Run the application

```powershell
$env:FLASK_APP = "backend.app"
flask run --debug
```

Open `http://127.0.0.1:5000/` and check `http://127.0.0.1:5000/health`.

## Run tests

```powershell
pytest
```

## Team rules

- Work on a feature branch, not directly on `main`.
- Do not commit `.venv/`, `.env`, passwords, API keys, or real personal data.
- Use prepared statements for database queries.
- Add authorization checks on the server for every protected action.
- Update the schema documentation when database tables change.
