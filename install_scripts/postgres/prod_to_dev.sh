PGPASSWORD=ciMl0OqeyrXqv21RREnw psql -U master -w -d comics_dev -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
PGPASSWORD=ciMl0OqeyrXqv21RREnw psql -U master -w -d comics_dev -f ~/nix-configs/install_scripts/postgres/2_grant_privileges_on_schema.sql
PGPASSWORD=ciMl0OqeyrXqv21RREnw pg_dump -U master comics_prod | PGPASSWORD=ciMl0OqeyrXqv21RREnw psql -U master comics_dev
