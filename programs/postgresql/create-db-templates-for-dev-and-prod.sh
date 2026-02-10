#!/usr/bin/env bash
set -euo pipefail

# One-shot PostgreSQL setup:
# - Grant CREATEDB to roles master and rw (assumes roles exist)
# - Create template_app_dev and template_app_prod with the desired privileges
# - Mark both as template databases so future app DBs can be cloned from them
#
# Usage (run as a sudo-capable user):
#   sudo bash mkFiles/setup_postgres.sh
#
# After running this once, you can create new app DBs by cloning templates:
#   sudo -u master createdb -T template_app_prod "${APP_NAME}_prod"
#   sudo -u rw createdb -T template_app_dev   "${APP_NAME}_dev"

PSQL_SUPER=(sudo -u postgres psql -X -v ON_ERROR_STOP=1)
CREATEDB_SUPER=(sudo -u postgres createdb)

# Check if template1 exists, if not try to recreate it from template0
check_template1() {
	if ! "${PSQL_SUPER[@]}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='template1'" | grep -q 1; then
		echo "ERROR: template1 database does not exist!"
		echo "This usually means PostgreSQL cluster wasn't initialized properly."
		echo ""
		echo "To fix this, you need to:"
		echo "   sudo -u postgres createdb -T template0 template1"
		echo ""
		exit 1
	fi
}

# Verify template1 exists before proceeding
check_template1

# Grant CREATEDB to master and rw so they can create databases
"${PSQL_SUPER[@]}" -d postgres -c "ALTER ROLE master LOGIN CREATEDB;"
"${PSQL_SUPER[@]}" -d postgres -c "ALTER ROLE rw LOGIN CREATEDB;"

# Helper: create database if not exists
create_db_if_missing() {
	local dbname="$1"
	if ! "${PSQL_SUPER[@]}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${dbname}'" | grep -q 1; then
		"${CREATEDB_SUPER[@]}" "${dbname}"
	fi
}

# Create DEV template and set privileges: rw has DDL + DML
create_db_if_missing template_app_dev
"${PSQL_SUPER[@]}" -d template_app_dev <<'SQL'
REVOKE ALL ON DATABASE template_app_dev FROM PUBLIC;
GRANT CONNECT ON DATABASE template_app_dev TO rw;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO rw;
GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO rw;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO rw;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO rw;
SQL
"${PSQL_SUPER[@]}" -d postgres -c "UPDATE pg_database SET datistemplate=true WHERE datname='template_app_dev';"

# Create PROD template and set privileges: master has DDL; rw has DML
create_db_if_missing template_app_prod
"${PSQL_SUPER[@]}" -d template_app_prod <<'SQL'
REVOKE ALL ON DATABASE template_app_prod FROM PUBLIC;
GRANT CONNECT ON DATABASE template_app_prod TO master;
GRANT CONNECT ON DATABASE template_app_prod TO rw;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO master;
GRANT USAGE ON SCHEMA public TO rw;
GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO rw;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO rw;

ALTER DEFAULT PRIVILEGES FOR ROLE master IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO rw;
ALTER DEFAULT PRIVILEGES FOR ROLE master IN SCHEMA public
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO rw;
SQL
"${PSQL_SUPER[@]}" -d postgres -c "UPDATE pg_database SET datistemplate=true WHERE datname='template_app_prod';"

echo "PostgreSQL templates ready: template_app_dev, template_app_prod" 
