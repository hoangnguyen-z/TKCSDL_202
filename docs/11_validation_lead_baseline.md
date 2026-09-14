# Testing & Validation Lead Baseline

**Baseline date:** 2026-09-14  
**Scope:** `database/`, `tests/`, `docs/`, `README.md`, `docker/`

## Evidence and environment

| Area | Observed baseline | Status |
| --- | --- | --- |
| Database scripts | `00_create_database.sql` through `09_seed_demo_data.sql` | Inventory complete |
| Tables | 26 tables across `iam`, `participant`, `contest`, `reference`, `film`, `submission`, `verification`, `judging`, `result`, `archive`, and `audit` | Inventory complete |
| Tests | 15 executable test scripts plus `00_run_all_tests.sql` | Inventory complete |
| Requirements | FR-001 to FR-031, NFR-001 to NFR-012, BR-O-001 to BR-O-011 and BR-P-001 to BR-P-018 | Compared with RTM |
| Docker | Docker CLI available; no running compose service observed | Runtime blocked at baseline |
| SQL execution | Static review completed; SQL Server execution not claimed without a running database | Pending environment |

## Database object inventory

### Tables

`iam.UserAccount`, `iam.Role`, `iam.UserRole`, `participant.ParticipantProfile`, `participant.Registration`, `contest.Contest`, `contest.ContestCategory`, `contest.JudgingRound`, `contest.ScoringCriterion`, `contest.AwardDefinition`, `reference.FilmStock`, `reference.Camera`, `reference.Lens`, `reference.Lab`, `film.FilmRoll`, `film.FilmFrame`, `submission.Submission`, `verification.VerificationCase`, `verification.AIAnalysisResult`, `judging.JudgeAssignment`, `judging.Evaluation`, `judging.EvaluationScore`, `result.Result`, `result.AwardAssignment`, `archive.ArchiveItem`, and `audit.AuditLog`.

The physical scripts also define schemas, keys, foreign keys, unique/check constraints, indexes, reporting views, functions, procedures, triggers and seed data. Their exact runtime definition must be confirmed by SQL Server execution after Docker is available.

## Test inventory and current traceability

| Test | Current purpose | RTM status |
| --- | --- | --- |
| `TST-REG-001_duplicate_registration.sql` | Duplicate registration rejection | Linked to FR-007/FR-008 and BR-P-002; RTM filename needs correction |
| `TST-FRAME-001_duplicate_frame_number.sql` | Duplicate frame number rejection | Linked to FR-010/FR-011/FR-012 and BR-P-005; filename needs correction |
| `TST-SUB-001_normal_submission.sql` | Valid submission flow | Linked to FR-013/FR-014/FR-015; filename needs correction |
| `TST-SUB-002_invalid_late_submission.sql` | Late submission rejection | Linked to FR-014; filename needs correction |
| `TST-VER-001_ai_flag_human_review.sql` | AI flag requires human review | Linked to FR-017/FR-018/FR-019; filename needs correction |
| `TST-JDG-001_duplicate_judge_evaluation.sql` | Duplicate evaluation rejection | Linked to FR-020/FR-021/FR-022/FR-023; filename needs correction |
| `TST-JDG-002_multi_round_judging.sql` | Multi-round judging chain | Existing test; direct RTM link should be explicit |
| `TST-RES-001_result_finalization.sql` | Final result finalization | Linked to FR-025 and BR-O-010; filename needs correction |
| `TST-ARC-001_historical_archive.sql` | Archive snapshot stability | Linked to FR-028 and BR-O-011; filename needs correction |
| `TST-AUD-001_audit_status_change.sql` | Audit status change | Linked to FR-029; filename needs correction |
| `TST-INT-001_invalid_foreign_key.sql` | Invalid foreign key rejection | Linked to submission integrity; direct RTM link should be explicit |
| `TST-INT-002_invalid_status.sql` | Invalid status rejection | Linked to submission integrity; direct RTM link should be explicit |
| `TST-INT-003_invalid_criterion_weight.sql` | Invalid criterion weight rejection | Linked to scoring constraints; direct RTM link should be explicit |
| `TST-INT-004_invalid_date_window.sql` | Invalid date-window rejection | Linked to BR-O-003; direct RTM link should be explicit |
| `TST-RET-001_restricted_deletion.sql` | Archive deletion protection | Linked to BR-P-018; filename needs correction |

## Static checklist applied

- Every test file has a unique `TST-*` identifier in its filename and title.
- The runner references all 15 test scripts currently present.
- Most tests isolate writes with a transaction and rollback; `TST-JDG-002` is a read-only seeded-data check and is intentionally different.
- Negative tests use `TRY/CATCH` or an explicit failure flag; expected failure must be asserted.
- Tests use the fixed database name `FilmContestDB` and therefore require initialized SQL Server.
- No `.env` file was added to the validation artifacts.
- Runtime pass/fail remains unverified until Docker SQL Server is running.

## Coverage gaps for next commits

The current RTM has no direct executable test link for FR-001 to FR-006, FR-009, FR-016, FR-031 and NFR-004 to NFR-012. It also has no explicit test links for several IAM, contest configuration, award assignment, reporting-view and concurrency rules. These are gaps, not failures, and must be closed by separate tests rather than by relabeling existing tests.

## Ownership protection

This baseline is an additive Validation Lead artifact. Existing schema, seed, requirement and team-owned documents are not replaced. Before every commit, review `git diff`, stage only files belonging to the current prompt, and never use reset/checkout/force-push operations that could discard another member's work.

## Local execution evidence (2026-09-14)

| Check | Result | Evidence / blocker |
| --- | --- | --- |
| Database inventory | PASS | 10 database scripts and 26 table declarations found. |
| Runner completeness | PASS | 15 `:r` entries match 15 test scripts; no missing or unreferenced test file. |
| Static test checklist | PASS with exception noted | All 15 tests have an ID, `USE FilmContestDB` and assertion. Fourteen use transaction cleanup; `TST-JDG-002` is intentionally read-only. |
| RTM identifier audit | GAP | 19 requirement/rule IDs are not directly present in the RTM: `BR-P-003`, `BR-P-004`, `BR-P-007`, `BR-P-008`, `BR-P-010`, `BR-P-011`, `BR-P-012`, `BR-P-016`, `FR-002`, `FR-003`, `FR-004`, `FR-005`, `NFR-005`, `NFR-006`, `NFR-007`, `NFR-008`, `NFR-009`, `NFR-010`, `NFR-011`. |
| Compose configuration | PASS with warning | `docker compose config` renders the SQL Server service; `MSSQL_SA_PASSWORD` is blank because `.env` is absent. |
| Runtime initialization | BLOCKED | All 10 init scripts and `.env.example` exist, but Docker daemon is unavailable and no SQL Server container is running. |

These results are local validation evidence only. They are not staged, committed or uploaded as part of this execution.