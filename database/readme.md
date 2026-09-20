# Database setup

1. Copy .env.example to .env and put in your own MySQL password.
2. In MySQL Workbench, run these files IN THIS ORDER:
   1. database/schema.sql       (WARNING: drops all tables and deletes all data)
   2. database/constraints.sql
   3. database/triggers.sql     (Workbench only, uses DELIMITER)
   4. database/SAMPLEDATA.sql   (loads the demo data into an empty database)
3. Never run schema.sql again unless you want to wipe your local data.

Each person has their own local database. The data is not shared through Git.