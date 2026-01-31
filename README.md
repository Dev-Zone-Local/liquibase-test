# Liquibase Dev Setup

This repo contains Liquibase changelogs under `app1/` and examples to run Liquibase via Docker against local databases.

## Prerequisites
- Docker Desktop (Windows)
- Recommended: Git, Java (optional if you only use Docker)

## Project Layout
- `app1/changelog.master.xml` — master changelog including versioned files
- `app1/v1.0/changelog-app1.xml` — v1.0 changesets (executes `v1.0/sql/app1.sql`)
- `app1/v2.0/changelog-app1.xml` — v2.0 skeleton
- `app1/liquibase.properties` — defaults for local runs
- `app1/lib/` — optional JDBC drivers (e.g., MySQL)

## Start PostgreSQL (Docker)
```powershell
# Start Postgres (default user/password: postgres/postgres)
docker run -d --name pg \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_DB=app1 \
  -p 5432:5432 postgres:16

# Start pgAdmin4 at http://localhost:8080 (admin/admin)
docker run -d --name pgadmin \
  -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
  -e PGADMIN_DEFAULT_PASSWORD=admin \
  -p 8080:80 dpage/pgadmin4
```

In pgAdmin4, add a server connection pointing to `host.docker.internal:5432`, database `app1`, user `postgres`, password `postgres`.

## Run Liquibase with Postgres (Docker)
Use the mounted repo path and set the search path to the changelog directory.
```powershell
# Validate
docker run --rm \
  -v "D:/Projects/Personal/liquibase/app1:/liquibase/changelog" \
  liquibase/liquibase:4.33.0 \
  --defaultsFile=/liquibase/changelog/liquibase.properties \
  --searchPath=/liquibase/changelog \
  --changelog-file=changelog.master.xml \
  --url="jdbc:postgresql://host.docker.internal:5432/app1" \
  --username=postgres --password=postgres \
  validate

# Status (pending changes)
docker run --rm \
  -v "D:/Projects/Personal/liquibase/app1:/liquibase/changelog" \
  liquibase/liquibase:4.33.0 \
  --defaultsFile=/liquibase/changelog/liquibase.properties \
  --searchPath=/liquibase/changelog \
  --changelog-file=changelog.master.xml \
  --url="jdbc:postgresql://host.docker.internal:5432/app1" \
  --username=postgres --password=postgres \
  status

# Apply changes
docker run --rm \
  -v "D:/Projects/Personal/liquibase/app1:/liquibase/changelog" \
  liquibase/liquibase:4.33.0 \
  --defaultsFile=/liquibase/changelog/liquibase.properties \
  --searchPath=/liquibase/changelog \
  --changelog-file=changelog.master.xml \
  --url="jdbc:postgresql://host.docker.internal:5432/app1" \
  --username=postgres --password=postgres \
  update
```

Note: The official Liquibase image includes the PostgreSQL JDBC driver; no extra classpath is required.

## Run Liquibase with MySQL (Docker)
The Liquibase image may not include the MySQL Connector/J. Mount the driver and set `--classpath`.
```powershell
# Download MySQL Connector/J JAR (once)
$uri = "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.1.0/mysql-connector-j-9.1.0.jar"
$dest = "D:\\Projects\\Personal\\liquibase\\app1\\lib\\mysql-connector-j-9.1.0.jar"
Invoke-WebRequest -Uri $uri -OutFile $dest

# Validate (MySQL) using host.docker.internal
docker run --rm \
  -v "D:/Projects/Personal/liquibase/app1:/liquibase/changelog" \
  -v "D:/Projects/Personal/liquibase/app1/lib:/liquibase/lib" \
  liquibase/liquibase:4.33.0 \
  --defaultsFile=/liquibase/changelog/liquibase.properties \
  --searchPath=/liquibase/changelog \
  --changelog-file=changelog.master.xml \
  --url="jdbc:mysql://host.docker.internal:3306/app1?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
  --username=root --password= \
  --classpath=/liquibase/lib/mysql-connector-j-9.1.0.jar \
  validate
```

## Tips
- On Windows, use `host.docker.internal` from inside containers to reach services on the host.
- Prefer `--defaultsFile` and `--searchPath` to keep commands short; override `--url`, `--username`, `--password` per target DB.
- Use `status` before `update` and consider `updateSQL` to preview SQL.

## Troubleshooting
- "Cannot find database driver": provide/mount the proper JDBC driver and/or set `--classpath`.
- "Changelog not found": ensure `--searchPath` matches the mounted directory and use a relative `--changelog-file`.
- "Unknown database": create the DB (e.g., `POSTGRES_DB` env or `?createDatabaseIfNotExist=true` for MySQL).
