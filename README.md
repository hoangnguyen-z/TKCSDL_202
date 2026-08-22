# AI-powered Film Photography Contest Management Platform

This repository contains the full analysis, architecture, database design, SQL Server implementation, Docker runtime setup, seed data, and SQL-based validation artifacts for the project scope:

- Requirement Analysis
- System Architecture Design
- Conceptual Database Design
- Logical Database Design
- Physical Database Design
- SQL Server Implementation
- Docker Setup
- Seed Data
- Database Testing
- Validation & Traceability
- Project Freeze

## Team Ownership

| Thành viên | Vai trò | Phạm vi phụ trách |
| --- | --- | --- |
| Trung Châu | Requirement Lead | Requirement baseline, gap analysis, business glossary, stakeholders, AS-IS/TO-BE flows, FR, NFR, BR và use cases |

Chi tiết phân công và liên kết các artifact được ghi tại [docs/09_team_assignment.md](docs/09_team_assignment.md).

## Official Technology Stack

- DBMS: Microsoft SQL Server
- Runtime: Docker and Docker Compose
- Management Client: SQL Server Management Studio 22 (SSMS 22)
- Documentation: Markdown
- SQL Testing: T-SQL scripts executed through SSMS 22 or `sqlcmd`
- Container image: `mcr.microsoft.com/mssql/server:2022-CU24-ubuntu-22.04`

## Repository Structure

```text
.
|-- README.md
|-- .env.example
|-- .gitignore
|-- docker-compose.yml
|-- docs/
|   |-- 01_gap_analysis.md
|   |-- 02_requirement_analysis.md
|   |-- 03_system_architecture.md
|   |-- 04_conceptual_database_design.md
|   |-- 05_logical_database_design.md
|   |-- 06_physical_database_design_sql_server.md
|   |-- 07_validation_traceability.md
|   `-- 08_project_freeze.md
|-- docker/
|   `-- init-database.ps1
|-- database/
|   |-- 00_create_database.sql
|   |-- 01_tables.sql
|   |-- 02_constraints.sql
|   |-- 03_indexes.sql
|   |-- 04_views.sql
|   |-- 05_functions.sql
|   |-- 06_procedures.sql
|   |-- 07_triggers.sql
|   |-- 08_seed_reference_data.sql
|   `-- 09_seed_demo_data.sql
`-- tests/
    |-- 00_run_all_tests.sql
    |-- TST-REG-001_duplicate_registration.sql
    |-- TST-FRAME-001_duplicate_frame_number.sql
    |-- TST-SUB-001_normal_submission.sql
    |-- TST-SUB-002_invalid_late_submission.sql
    |-- TST-VER-001_ai_flag_human_review.sql
    |-- TST-JDG-001_duplicate_judge_evaluation.sql
    |-- TST-JDG-002_multi_round_judging.sql
    |-- TST-RES-001_result_finalization.sql
    |-- TST-ARC-001_historical_archive.sql
    `-- TST-AUD-001_audit_status_change.sql
```

## Key Artifacts

- Gap analysis: [01_gap_analysis.md](D:/dự án TKCSDL/docs/01_gap_analysis.md)
- Requirement baseline: [02_requirement_analysis.md](D:/dự án TKCSDL/docs/02_requirement_analysis.md)
- Architecture baseline: [03_system_architecture.md](D:/dự án TKCSDL/docs/03_system_architecture.md)
- Conceptual design: [04_conceptual_database_design.md](D:/dự án TKCSDL/docs/04_conceptual_database_design.md)
- Logical design: [05_logical_database_design.md](D:/dự án TKCSDL/docs/05_logical_database_design.md)
- Physical SQL Server design: [06_physical_database_design_sql_server.md](D:/dự án TKCSDL/docs/06_physical_database_design_sql_server.md)
- Validation and traceability: [07_validation_traceability.md](D:/dự án TKCSDL/docs/07_validation_traceability.md)
- Project freeze: [08_project_freeze.md](D:/dự án TKCSDL/docs/08_project_freeze.md)

## Quick Start

### 1. Prepare Environment Variables

Copy `.env.example` to `.env` and set a strong SA password:

```powershell
Copy-Item .env.example .env
```

Minimum required variables:

- `MSSQL_SA_PASSWORD`
- `MSSQL_PORT`
- `MSSQL_PID`
- `MSSQL_DATABASE`

### 2. Start SQL Server in Docker

```powershell
docker compose up -d
```

Expected container:

- Service: `sqlserver`
- Container name: `tkcsdl-sqlserver`

### 3. Initialize Database

Option A - Recommended for repeatable setup:

```powershell
.\docker\init-database.ps1
```

Option B - Manual through SSMS 22:

Run the scripts in this exact order:

1. `database/00_create_database.sql`
2. `database/01_tables.sql`
3. `database/02_constraints.sql`
4. `database/03_indexes.sql`
5. `database/04_views.sql`
6. `database/05_functions.sql`
7. `database/06_procedures.sql`
8. `database/07_triggers.sql`
9. `database/08_seed_reference_data.sql`
10. `database/09_seed_demo_data.sql`

## SSMS 22 Connection Guide

Use SSMS 22 on the host machine with:

- Server type: `Database Engine`
- Server name: `localhost,14333`
- Authentication: `SQL Server Authentication`
- Login: `sa`
- Password: value from `.env`
- Encrypt: `Optional / according to local SSMS policy`

After connecting:

1. Verify the database `FilmContestDB` exists.
2. Expand schemas such as `iam`, `contest`, `film`, `submission`, `judging`, `result`, `archive`, and `audit`.
3. Review keys, indexes, views, procedures, and triggers in Object Explorer.

## Validation Queries In SSMS

Quick checks after initialization:

```sql
SELECT COUNT(*) AS user_count FROM iam.UserAccount;
SELECT COUNT(*) AS contest_count FROM contest.Contest;
SELECT COUNT(*) AS submission_count FROM submission.Submission;
SELECT COUNT(*) AS archive_count FROM archive.ArchiveItem;
SELECT TOP (10) * FROM reporting.vw_submission_overview;
SELECT TOP (10) * FROM reporting.vw_result_summary;
```

## Running Tests

### Option A - Run Individual Tests In SSMS

Open and execute each file under `tests/`.

### Option B - Run All Tests In SSMS SQLCMD Mode

1. Open `tests/00_run_all_tests.sql`
2. Turn on `SQLCMD Mode` in SSMS
3. Execute the file

## What The Demo Data Covers

The seed data covers:

- User and role setup, including multi-role support
- Two contests with different lifecycle stages
- Registration and eligibility decisions
- Film roll and frame provenance
- Pending and verified submissions
- AI advisory results
- Multi-round judging
- Finalized result and award assignment
- Historical digital archive snapshot

## Reset Strategy

If you need a clean rebuild:

1. Stop containers: `docker compose down`
2. Remove the named volume if a full reset is needed:
   `docker volume rm <project>_sqlserver_data`
3. Start the environment again
4. Re-run initialization

## Notes

- AI analysis results are advisory only.
- Historical records use restrictive delete behavior by design.
- The archive stores snapshots intentionally for long-term integrity.
- Older PostgreSQL references from source material are obsolete for this project phase; all physical implementation artifacts in this repository target SQL Server only.
