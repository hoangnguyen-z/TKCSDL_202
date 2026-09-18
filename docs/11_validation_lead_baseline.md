# Testing & Validation Lead Baseline

**Baseline date:** 2026-09-18  
**Scope:** `database/`, `tests/`, `docs/`, `README.md`, `docker/`  
**Target Environment:** Docker Container `tkcsdl-sqlserver` (`mcr.microsoft.com/mssql/server:2022-CU24-ubuntu-22.04`), Port `14333`, SSMS 22 Compatible.

## Evidence and environment

| Area | Observed baseline | Status |
| --- | --- | --- |
| Database scripts | `00_create_database.sql` through `09_seed_demo_data.sql` | 10 scripts, 100% executable and idempotent |
| Schemas | 13 custom schemas (`iam`, `participant`, `contest`, `reference`, `film`, `submission`, `verification`, `judging`, `result`, `archive`, `audit`, `reporting`, `dbo`) | Complete |
| Tables | 32 tables (including 5 Contest Template tables and `film.AssetMetadata`) | Complete and validated |
| Procedures & Triggers | 8 stored procedures, 6 triggers, 5 reporting views, 1 scalar function | Recompiled with zero errors |
| Constraints & Indexes | 62 Foreign Keys, 53 Check Constraints, 199 Unique/Indexes | 100% validated |
| Tests | 35 executable test suites orchestrated by `00_run_all_tests.sql` | **35 / 35 PASS (100%)** |
| Docker Status | Container `tkcsdl-sqlserver` running healthy on port 14333 | Healthy, Verified via Docker API |
| SQL Execution Log | `tests/latest_test_run.log` UTF-8 without BOM | 332 lines, exit code 0 |

## Database object inventory (32 Tables)

1. **`iam`**: `UserAccount`, `Role`, `UserRole`
2. **`participant`**: `ParticipantProfile`, `Registration`
3. **`contest`**: `Contest`, `ContestCategory`, `JudgingRound`, `ScoringCriterion`, `AwardDefinition`, `ContestTemplate`, `TemplateCategory`, `TemplateJudgingRound`, `TemplateScoringCriterion`, `TemplateAwardDefinition`
4. **`reference`**: `FilmStock`, `Camera`, `Lens`, `Lab`
5. **`film`**: `FilmRoll`, `FilmFrame`, `AssetMetadata`
6. **`submission`**: `Submission`
7. **`verification`**: `VerificationCase`, `AIAnalysisResult`
8. **`judging`**: `JudgeAssignment`, `Evaluation`, `EvaluationScore`
9. **`result`**: `Result`, `AwardAssignment`
10. **`archive`**: `ArchiveItem`
11. **`audit`**: `AuditLog`

## Test inventory and current traceability (35 Executable Test Suites)

| Test Suite | Purpose | Target Feature / Constraint | Runtime Result |
| --- | --- | --- | --- |
| `TST-REG-001_duplicate_registration.sql` | Duplicate registration rejection | UQ constraint `(contest_id, participant_id)` | **PASS** |
| `TST-FRAME-001_duplicate_frame_number.sql` | Duplicate frame number within roll rejection | UQ constraint `(roll_id, frame_number)` | **PASS** |
| `TST-UQ-001_business_keys.sql` | Business unique keys reject duplicates & allow cross-contest frame reuse | Multi-entity UQ validation | **PASS** |
| `TST-SEED-001_reference_data.sql` | Reference seed completeness, uniqueness, referential consistency | Reference tables audit | **PASS** |
| `TST-SEED-002_demo_graph_consistency.sql` | Demo data graph, ownership, and key consistency | Integrity graph audit | **PASS** |
| `TST-SUB-001_normal_submission.sql` | Normal valid submission creates verification case | `submission.usp_create_submission` | **PASS** |
| `TST-SUB-002_invalid_late_submission.sql` | Late submission outside window rejection | Contest window check | **PASS** |
| `TST-SUB-003_creation_procedure_matrix.sql` | Submission creation procedure matrix (owner mismatch, status, duplicate) | Procedure edge cases | **PASS** |
| `TST-VER-001_ai_flag_human_review.sql` | AI-flagged submission resolved by human review | Advisory AI gate | **PASS** |
| `TST-VER-002_human_gate_terminal_state.sql` | Human verification gate preserves AI evidence & protects terminal state | Terminal state immutability | **PASS** |
| `TST-FN-001_round_max_score.sql` | Round maximum score function calculation accuracy | `contest.fn_get_round_max_score` | **PASS** |
| `TST-TXN-001_procedure_rollback.sql` | Procedure failure rolls back partial verification changes | Transaction rollback | **PASS** |
| `TST-JDG-001_duplicate_judge_evaluation.sql` | Duplicate judge evaluation in same round rejection | UQ constraint on evaluation | **PASS** |
| `TST-JDG-002_multi_round_judging.sql` | Multi-round judging chain exists end-to-end | Multi-round consistency | **PASS** |
| `TST-RES-001_result_finalization.sql` | Final round result finalization and ranking | `result.usp_finalize_results_for_round` | **PASS** |
| `TST-RES-002_finalization_idempotency.sql` | Finalization idempotency & incomplete judging block | Idempotent finalization | **PASS** |
| `TST-ARC-001_historical_archive.sql` | Archive snapshot stability upon live profile change | Denormalized snapshot stability | **PASS** |
| `TST-AUD-001_audit_status_change.sql` | Submission status change creates audit log entry | Trigger `TR_Submission_AU_AuditStatus` | **PASS** |
| `TST-INT-001_invalid_foreign_key.sql` | Invalid foreign key rejection | Foreign key enforcement | **PASS** |
| `TST-FK-001_core_foreign_keys.sql` | Core foreign keys reject invalid parent references | Multi-table FK audit | **PASS** |
| `TST-INT-002_invalid_status.sql` | Invalid submission status rejection | CHECK constraint on status | **PASS** |
| `TST-INT-003_invalid_criterion_weight.sql` | Scoring criterion weight above 100% rejection | CHECK constraint on weight | **PASS** |
| `TST-BOUNDARY-001_status_score_dates.sql` | Status, score, weight, rank and date boundary checks | Multi-domain CHECK bounds | **PASS** |
| `TST-INT-004_invalid_date_window.sql` | Reversed contest submission window rejection | CHECK constraint on dates | **PASS** |
| `TST-RET-001_restricted_deletion.sql` | Deletion of archived result blocked by FK | Retention FK protection | **PASS** |
| `TST-TMPL-001_contest_template_cloning.sql` | Contest template hierarchy replication | `contest.usp_create_contest_from_template` | **PASS** |
| `TST-ASSET-001_asset_metadata_qc.sql` | Asset metadata structure, SHA-256 hex & bit depth validation | `film.AssetMetadata` constraints | **PASS** |
| `TST-ARC-002_archive_from_non_finalized_rejected.sql` | Archival rejected for non-finalized results and duplicates | `archive.usp_create_archive_item` | **PASS** |
| `TST-IMMUT-001_result_archive_immutability.sql` | Result & Archive immutability against modification/delete | Triggers `TR_Result_BUD_ProtectFinalized` & `TR_ArchiveItem_BUD_Immutable` | **PASS** |
| `TST-PUB-001_publication_completeness.sql` | Publication completeness (category, round, criteria, award) | `contest.usp_publish_contest` | **PASS** |
| `TST-AWD-001_award_category_mismatch_rejected.sql` | Award-category mismatch rejected by procedure & trigger | Trigger `TR_AwardAssignment_BIU_CheckCategoryMatch` | **PASS** |
| `TST-VIEW-001_reporting_views_integrity.sql` | Reporting views runtime execution & JSON snapshot validation | Views schema & JSON check | **PASS** |
| `TST-CONC-001_concurrent_registration.sql` | Two-session duplicate registration race condition simulation | Concurrency serialization | **PASS** |
| `TST-CONC-002_concurrent_submission.sql` | Two-session duplicate submission race condition simulation | Concurrency serialization | **PASS** |
| `TST-CONC-003_concurrent_evaluation.sql` | Two-session duplicate evaluation race condition simulation | Concurrency serialization | **PASS** |

## Runtime execution evidence (2026-09-18)

```
T-SQL validation runner: 35 test suites.
Run from the tests folder in SSMS 22 with SQLCMD Mode enabled.
Changed database context to 'FilmContestDB'.
TST-REG-001 - Duplicate registration must fail
PASS: duplicate registration was rejected as expected.
TST-FRAME-001 - Duplicate frame number in same roll must fail
PASS: duplicate frame number was rejected as expected.
TST-UQ-001 - Business unique keys reject duplicates and allow a different contest scope
PASS: duplicate business keys were rejected and cross-contest frame reuse was accepted.
TST-SEED-001 - Reference seed completeness, uniqueness and referential consistency
PASS: reference seed has required coverage, unique business keys and no orphan film-roll references.
TST-SEED-002 - Demo data graph, ownership and business-key consistency
PASS: demo data graph, ownership links and key consistency checks returned zero violations.
TST-SUB-001 - Normal submission should succeed
PASS: normal submission was created successfully.
TST-SUB-002 - Late submission should fail
PASS: late submission was rejected as expected.
TST-SUB-003 - Submission creation procedure accepts valid input and rejects invalid cases
PASS: valid, owner, duplicate, status and deadline submission paths were verified.
TST-VER-001 - Human review should resolve AI-flagged submission
PASS: AI-flagged submission was resolved by human review.
TST-VER-002 - Human verification gate preserves AI evidence and protects terminal state
PASS: AI result remained advisory and human verification terminal state was protected.
TST-FN-001 - Round maximum score function matches expected aggregate values
PASS: round maximum score function matched expected values for all seeded rounds, NULL and unknown input.
TST-TXN-001 - Procedure failure rolls back partial verification changes
PASS: failed procedure left verification, submission and audit state unchanged.
TST-JDG-001 - Duplicate judge evaluation in same round must fail
PASS: duplicate judge evaluation was rejected as expected.
TST-JDG-002 - Multi-round judging data should exist end-to-end
PASS: multi-round judging chain exists for the seeded submission.
TST-RES-001 - Final round result finalization should succeed
PASS: result finalization succeeded for the final round.
TST-RES-002 - Result finalization blocks incomplete judging and remains idempotent
PASS: result finalization idempotency and incomplete-judging behavior were checked.
TST-ARC-001 - Archive snapshot should remain stable if live profile changes
PASS: archive snapshot remained stable.
TST-AUD-001 - Submission status change should create audit entry
PASS: submission status change generated an audit log entry.
TST-INT-001 - Invalid foreign key must fail
PASS: invalid FilmRoll foreign key was rejected as expected.
TST-FK-001 - Core foreign keys must reject invalid parent references
PASS: all six core foreign-key checks rejected invalid references and left no rows.
TST-INT-002 - Invalid submission status must fail
PASS: invalid submission status was rejected as expected.
TST-INT-003 - Invalid scoring criterion weight must fail
PASS: criterion weight above 100 percent was rejected as expected.
TST-BOUNDARY-001 - Status, score, weight, rank and date boundaries
PASS: declared status, weight, rank and date boundary checks completed.
TST-INT-004 - Invalid contest submission date window must fail
PASS: reversed submission date window was rejected as expected.
TST-RET-001 - Deletion of an archived result must fail
PASS: archived result deletion was blocked by retention foreign key as expected.
TST-TMPL-001 - Contest template cloning and structure replication
PASS: contest template cloning replicated categories, rounds, criteria, and awards successfully.
TST-ASSET-001 - Asset metadata structure, QC validation, and integrity checks
PASS: asset metadata integrity, SHA-256 validation, bit depth check, and uniqueness verified.
TST-ARC-002 - Archival creation rejected for non-finalized results and duplicates
PASS: archival creation properly rejects non-finalized results and duplicate entries.
TST-IMMUT-001 - Enforcement of Result and Archive immutability
PASS: result and archive immutability rules are fully enforced.
TST-PUB-001 - Publication completeness enforcement for contest lifecycle
PASS: publication completeness checks verified all mandatory configuration prerequisites.
TST-AWD-001 - Award-Category mapping integrity and mismatch rejection
PASS: award-category mapping is strictly enforced at procedure and trigger levels.
TST-VIEW-001 - Reporting views runtime integrity and query execution
PASS: all reporting views executed with valid counts and valid JSON schema structure.
TST-CONC-001 - Concurrency simulation for duplicate registration race condition
PASS: concurrency test verified serializability and unique registration protection.
TST-CONC-002 - Concurrency simulation for duplicate submission race condition
PASS: concurrent submission race condition prevented double-submission of identical film frame.
TST-CONC-003 - Concurrency simulation for duplicate judge evaluation race condition
PASS: concurrency test verified unique judge evaluation protection against double-evaluation.
==================================================
ALL 35 TEST SUITES COMPLETED SUCCESSFULLY.
==================================================
```

## Validation sign-off

- All 35 executable test suites pass with 0 errors.
- No false positives remain; negative tests strictly check expected error codes (`51000`-`55010`).
- Two-session concurrency race conditions tested and verified.
- Docker environment healthy; reproducible from cold-start via `docker/init-database.ps1`.
- SSMS 22 connectivity verified on port `14333`.