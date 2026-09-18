# Validation, Traceability, and Project Freeze

## 1. Requirement Traceability Matrix (35 Executable Test Suites Baseline)

| Requirement / BR | Flow / Use Case | Architecture Module | Conceptual Entity | Logical Relation | Physical Table / Object | Constraint / Index / Test |
| --- | --- | --- | --- | --- | --- | --- |
| FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, BR-O-001, BR-P-023 | F01 / UC-01 | Contest Lifecycle | Contest, ContestCategory, JudgingRound, ScoringCriterion, AwardDefinition | Contest, ContestCategory, JudgingRound, ScoringCriterion, AwardDefinition | `contest.Contest`, `contest.usp_publish_contest` | Lifecycle check, completeness validation: [TST-PUB-001](file:///d:/dự%20án%20TKCSDL/tests/TST-PUB-001_publication_completeness.sql) |
| FR-031, BR-P-019 | F01 / UC-01 | Contest Templates | ContestTemplate, TemplateCategory, TemplateJudgingRound, TemplateScoringCriterion, TemplateAwardDefinition | ContestTemplate, TemplateCategory, TemplateJudgingRound, TemplateScoringCriterion, TemplateAwardDefinition | `contest.ContestTemplate`, `contest.usp_create_contest_from_template` | Template cloning validation: [TST-TMPL-001](file:///d:/dự%20án%20TKCSDL/tests/TST-TMPL-001_contest_template_cloning.sql) |
| FR-007, FR-008, BR-P-002 | F02 / UC-02 | Registration | Registration | Registration | `participant.Registration` | Unique registration key, [TST-REG-001](file:///d:/dự%20án%20TKCSDL/tests/TST-REG-001_duplicate_registration.sql), [TST-CONC-001](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-001_concurrent_registration.sql) |
| FR-010, FR-011, FR-012, BR-P-005 | F03 / UC-03 | Film Asset Management | FilmRoll, FilmFrame | FilmRoll, FilmFrame | `film.FilmRoll`, `film.FilmFrame` | `UQ` on `(roll_id, frame_number)`, [TST-FRAME-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FRAME-001_duplicate_frame_number.sql) |
| FR-032, BR-P-020 | F03 / UC-03 | Digital Asset Metadata | AssetMetadata | AssetMetadata | `film.AssetMetadata` | SHA-256 validation, bit depth check, [TST-ASSET-001](file:///d:/dự%20án%20TKCSDL/tests/TST-ASSET-001_asset_metadata_qc.sql) |
| FR-013, FR-014, FR-015, BR-P-006, BR-P-009 | F04 / UC-04 | Submission Management | Submission | Submission | `submission.Submission`, `submission.usp_create_submission` | Submission uniqueness, deadline validation, owner matching: [TST-SUB-001](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-001_normal_submission.sql), [TST-SUB-002](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-002_invalid_late_submission.sql), [TST-SUB-003](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-003_creation_procedure_matrix.sql), [TST-CONC-002](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-002_concurrent_submission.sql) |
| FR-017, FR-018, FR-019, BR-O-006, BR-O-007 | F05 / UC-05 | Verification | VerificationCase, AIAnalysisResult | VerificationCase, AIAnalysisResult | `verification.VerificationCase`, `verification.AIAnalysisResult`, `verification.usp_record_verification_decision` | Status checks, advisory AI gate, terminal state protection: [TST-VER-001](file:///d:/dự%20án%20TKCSDL/tests/TST-VER-001_ai_flag_human_review.sql), [TST-VER-002](file:///d:/dự%20án%20TKCSDL/tests/TST-VER-002_human_gate_terminal_state.sql), [TST-TXN-001](file:///d:/dự%20án%20TKCSDL/tests/TST-TXN-001_procedure_rollback.sql) |
| FR-020, FR-021, FR-022, FR-023, BR-O-008, BR-O-009 | F06 / UC-06 | Judging | JudgeAssignment, Evaluation, EvaluationScore | JudgeAssignment, Evaluation, EvaluationScore | `judging.JudgeAssignment`, `judging.Evaluation`, `judging.EvaluationScore` | Duplicate evaluation unique key, score range, max score function: [TST-JDG-001](file:///d:/dự%20án%20TKCSDL/tests/TST-JDG-001_duplicate_judge_evaluation.sql), [TST-JDG-002](file:///d:/dự%20án%20TKCSDL/tests/TST-JDG-002_multi_round_judging.sql), [TST-FN-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FN-001_round_max_score.sql), [TST-CONC-003](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-003_concurrent_evaluation.sql) |
| FR-024, FR-025, FR-026, FR-027, BR-O-010, BR-P-014, BR-P-015, BR-P-022, BR-P-024 | F07 / UC-07 | Result & Award | Result, AwardDefinition, AwardAssignment | Result, AwardDefinition, AwardAssignment | `result.Result`, `result.AwardAssignment`, `result.usp_finalize_results_for_round`, `result.usp_assign_award`, `result.TR_Result_BUD_ProtectFinalized`, `result.TR_AwardAssignment_BIU_CheckCategoryMatch` | Finalization idempotency, award-category matching, immutability: [TST-RES-001](file:///d:/dự%20án%20TKCSDL/tests/TST-RES-001_result_finalization.sql), [TST-RES-002](file:///d:/dự%20án%20TKCSDL/tests/TST-RES-002_finalization_idempotency.sql), [TST-AWD-001](file:///d:/dự%20án%20TKCSDL/tests/TST-AWD-001_award_category_mismatch_rejected.sql), [TST-IMMUT-001](file:///d:/dự%20án%20TKCSDL/tests/TST-IMMUT-001_result_archive_immutability.sql) |
| FR-028, BR-O-011, BR-P-017, BR-P-021, BR-P-022 | F08 / UC-08 | Digital Archive | ArchiveItem | ArchiveItem | `archive.ArchiveItem`, `archive.usp_create_archive_item`, `archive.TR_ArchiveItem_BUD_Immutable`, `reporting.vw_archive_catalog` | `UQ` on result archive, non-finalized rejection, snapshot stability, restricted-delete: [TST-ARC-001](file:///d:/dự%20án%20TKCSDL/tests/TST-ARC-001_historical_archive.sql), [TST-ARC-002](file:///d:/dự%20án%20TKCSDL/tests/TST-ARC-002_archive_from_non_finalized_rejected.sql), [TST-IMMUT-001](file:///d:/dự%20án%20TKCSDL/tests/TST-IMMUT-001_result_archive_immutability.sql), [TST-RET-001](file:///d:/dự%20án%20TKCSDL/tests/TST-RET-001_restricted_deletion.sql) |
| FR-029 | All flows | Audit & Reporting | AuditLog | AuditLog | `audit.AuditLog`, `reporting.vw_*` | Audit triggers, reporting views integrity: [TST-AUD-001](file:///d:/dự%20án%20TKCSDL/tests/TST-AUD-001_audit_status_change.sql), [TST-VIEW-001](file:///d:/dự%20án%20TKCSDL/tests/TST-VIEW-001_reporting_views_integrity.sql) |
| FR-030, BR-P-001 | All role-scoped flows | Identity & Access | UserAccount, Role, UserRole | UserAccount, Role, UserRole | `iam.UserAccount`, `iam.Role`, `iam.UserRole` | Unique account and role keys, referential integrity: [TST-SEED-001](file:///d:/dự%20án%20TKCSDL/tests/TST-SEED-001_reference_data.sql), [TST-SEED-002](file:///d:/dự%20án%20TKCSDL/tests/TST-SEED-002_demo_graph_consistency.sql) |
| NFR-001, NFR-002, NFR-003 | Environment setup | Deployment View | N/A | N/A | `docker/docker-compose.yml`, `docker/init-database.ps1` | Dockerized SQL Server 2022 container healthy, SSMS 22 port 14333 reachable |
| NFR-004 | High concurrency flows | Core Transactions | Registration, Submission, Evaluation | Registration, Submission, Evaluation | Constraints, Isolated Transactions | Concurrency race condition protection: [TST-CONC-001](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-001_concurrent_registration.sql), [TST-CONC-002](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-002_concurrent_submission.sql), [TST-CONC-003](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-003_concurrent_evaluation.sql) |
| NFR-005 - NFR-012 | Integrity & Reliability | Database Core | All Schemas | All Tables | Schema Constraints & Triggers | Generic Integrity Tests: [TST-UQ-001](file:///d:/dự%20án%20TKCSDL/tests/TST-UQ-001_business_keys.sql), [TST-FK-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FK-001_core_foreign_keys.sql), [TST-INT-001](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-001_invalid_foreign_key.sql), [TST-INT-002](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-002_invalid_status.sql), [TST-INT-003](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-003_invalid_criterion_weight.sql), [TST-INT-004](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-004_invalid_date_window.sql), [TST-BOUNDARY-001](file:///d:/dự%20án%20TKCSDL/tests/TST-BOUNDARY-001_status_score_dates.sql) |

## 2. CRUD / Data Ownership Matrix

| Module | Create | Read | Update | Delete | System Owner |
| --- | --- | --- | --- | --- | --- |
| Identity & Access | UserAccount, UserRole | UserAccount, Role, UserRole | UserAccount, UserRole | No hard delete by default | Identity & Access |
| Contest Management | Contest, ContestCategory, JudgingRound, ScoringCriterion, AwardDefinition, ContestTemplate | Same | Same | Restricted | Contest Management |
| Registration | Registration | Registration, Contest, ParticipantProfile | Registration | Restricted | Registration |
| Film Asset Management | FilmRoll, FilmFrame, AssetMetadata | FilmRoll, FilmFrame, AssetMetadata, reference data | FilmRoll, FilmFrame, AssetMetadata | Restricted | Film Asset Management |
| Submission Management | Submission | Submission, Registration, FilmFrame, ContestCategory | Submission status before verification completion | Restricted | Submission Management |
| Verification | VerificationCase, AIAnalysisResult | Submission, VerificationCase, AIAnalysisResult | VerificationCase, AIAnalysisResult | Restricted | Verification |
| Judging | JudgeAssignment, Evaluation, EvaluationScore | Same plus rounds and criteria | Assignment state, Evaluation, EvaluationScore | Restricted | Judging |
| Result & Award | Result, AwardAssignment | Result, AwardDefinition, AwardAssignment | Result state, AwardAssignment | Restricted (Trigger protected) | Result & Award |
| Digital Archive | ArchiveItem | ArchiveItem, Result, Submission | Archive status only | Prohibited (Trigger protected) | Digital Archive |
| Audit & Reporting | AuditLog | AuditLog and reporting views | Not normally updated | Prohibited (Immutable log) | Audit & Reporting |

## 3. Rule-to-Enforcement Matrix

| Business Rule | Rule Label | Enforcement Layer | Enforcement Implementation |
| --- | --- | --- | --- |
| Contest completeness before publish | BR-O-001 | Database & Stored Procedure | `contest.usp_publish_contest` verifies presence of categories, judging rounds, scoring criteria, and award definitions. |
| Criterion has range and weight | BR-O-002 | Database Layer | CHECK constraints `CK_contest_ScoringCriterion_weight_percent`, `CK_contest_ScoringCriterion_score_min_max`. |
| Deadline enforcement | BR-O-003 | Database & Stored Procedure | `submission.usp_create_submission` verifies `@now` against `submission_open_at` and `submission_close_at`. |
| Frame belongs to one roll | BR-O-004 | Database Layer | Foreign key `FK_film_FilmFrame_roll_id` with `NO ACTION`. |
| Submission binds registration, contest, category, frame | BR-O-005 | Database & Stored Procedure | Foreign keys + `submission.usp_create_submission` verifies matching contest/category IDs. |
| AI cannot finalize verification alone | BR-O-006 | Application & Human Decision | AIAnalysisResult is purely advisory (`FLAGGED`/`CLEAN`); decision requires human review (`VERIFIED`/`REJECTED`). |
| Verification terminal states | BR-O-007 | Database & Stored Procedure | CHECK constraint `CK_verification_VerificationCase_status` + `verification.usp_record_verification_decision` blocks modifying terminal state. |
| Judge assignment scoped to round | BR-O-008 | Database Layer | Foreign key `FK_judging_JudgeAssignment_round_id` and UNIQUE key `UQ_judging_JudgeAssignment_round_judge`. |
| One evaluation per judge-submission-round | BR-O-009 | Database Layer | UNIQUE constraint `UQ_judging_Evaluation_round_judge_submission`. |
| Results finalized only after judging complete | BR-O-010 | Stored Procedure | `result.usp_finalize_results_for_round` checks all assignments and evaluations before calculating final rank and score. |
| Archive only from finalized results | BR-O-011 | Stored Procedure | `archive.usp_create_archive_item` rejects any result not in `FINALIZED` or `PUBLISHED` state. |
| Multi-role user | BR-P-001 | Proposed | Database Layer | `iam.UserRole` many-to-many relationship with unique `(user_id, role_id)`. |
| One active registration per contest | BR-P-002 | Proposed | Database Layer | UNIQUE constraint `UQ_participant_Registration_contest_participant`. |
| Frame number unique within roll | BR-P-005 | Proposed | Database Layer | UNIQUE constraint `UQ_film_FilmFrame_roll_frame_number`. |
| Frame reused across contests, not inside same contest | BR-P-006 | Proposed | Database Layer | UNIQUE constraint `UQ_submission_Submission_contest_frame`. |
| Submission owner must match frame owner | BR-P-009 | Proposed | Stored Procedure | `submission.usp_create_submission` validates participant ownership of the film frame. |
| Evaluation needs criterion scores | BR-P-013 | Proposed | Stored Procedure | `judging.usp_submit_evaluation` ensures score rows exist for all round criteria. |
| Restricted deletion policy | BR-P-018 | Proposed | Database Layer | Referential integrity `ON DELETE NO ACTION` across all historical and audit entities. |
| Reusable contest configuration template | BR-P-019 | Proposed | Database & Stored Procedure | `contest.ContestTemplate` tables + `contest.usp_create_contest_from_template` replicates contest hierarchy. |
| Structured digital asset metadata and QC evidence | BR-P-020 | Proposed | Database Layer | `film.AssetMetadata` table with CHECK constraints on SHA-256 (64 hex characters), bit depth (8, 12, 14, 16), and QC status. |
| Archive creation from finalized results only | BR-P-021 | Proposed | Stored Procedure | `archive.usp_create_archive_item` verifies result status is `FINALIZED` or `PUBLISHED` (Throws error 55001). |
| Result and Archive immutability | BR-P-022 | Proposed | Database Triggers | `result.TR_Result_BUD_ProtectFinalized` blocks score/rank modifications; `archive.TR_ArchiveItem_BUD_Immutable` blocks all UPDATE/DELETE. |
| Publication completeness enforcement | BR-P-023 | Proposed | Stored Procedure | `contest.usp_publish_contest` validates categories, rounds, criteria, and awards before publishing. |
| Award-to-Category scope matching | BR-P-024 | Proposed | Database Trigger & Procedure | `result.TR_AwardAssignment_BIU_CheckCategoryMatch` and `result.usp_assign_award` enforce category consistency. |

## 4. Design Decision Log

| DD ID | Context | Options Considered | Selected Option | Rationale | Impact |
| --- | --- | --- | --- | --- | --- |
| DD-001 | User and role modeling | Single role per user vs multi-role model | Multi-role via `UserRole` | Matches realistic governance and prompt questions | Requires role assignment table and scoped authorization |
| DD-002 | Participant representation | Role only vs separate participant profile | Separate `ParticipantProfile` + role membership | Participant needs profile-specific data and history | Adds one-to-one subtype table |
| DD-003 | Frame reuse policy | No reuse, unrestricted reuse, reuse across contests only | Reuse across contests but not twice in same contest | Balances fairness and historical reuse | Unique submission rule on `(contest_id, frame_id)` |
| DD-004 | Criteria placement | Contest-level, category-level, round-level | Round-level criteria | Supports multi-round changes and weighting | Round becomes strong configuration anchor |
| DD-005 | Archive modeling | Live references only vs snapshot | Snapshot-oriented archive | Historical integrity is more important than perfect normalization | Archive stores denormalized snapshot fields |
| DD-006 | Result finalization | Dynamic ranking only vs persisted result | Persisted result rows | Needed for publication, audit, and archival | Adds controlled finalization procedure |
| DD-007 | Image storage | Store binary in DB vs URI/path reference | URI/path reference | Better for DB size, portability, and alignment with architecture | URI fields across frame/submission/archive |
| DD-008 | Delete strategy | Cascade delete vs restrict and status transitions | Restrict deletes | Contest history must survive | `NO ACTION` FKs, archive and result protection triggers |
| DD-009 | DBMS | PostgreSQL vs SQL Server | SQL Server 2022 | Official current technology choice | All physical artifacts use SQL Server 2022 T-SQL syntax |
| DD-010 | Local runtime | Native host install only vs Dockerized SQL Server | Dockerized SQL Server + SSMS 22 | Repeatable containerized environment and verified review | Container `tkcsdl-sqlserver`, port 14333, automated init scripts |
| DD-011 | Contest Templating | Manual re-entry vs Reusable Template Hierarchy | Hierarchical Template Model (`ContestTemplate` -> categories, rounds, criteria, awards) | Eliminates repetitive contest setup; supports standard analog workflows | Adds 5 template tables + automated cloning procedure |
| DD-012 | Asset Metadata & QC | Generic frame columns vs Structured Asset Entity | Dedicated `film.AssetMetadata` entity | Stores technical provenance (MIME, SHA-256 hash, scan hardware/settings, resolution, QC approval) | Enforces forensic auditability and high-res scan provenance |

## 5. Consistency Audit Checklist

- [x] Requirement IDs are unique, complete, and stable.
- [x] Business rule IDs are unique and explicitly partitioned into Official (`BR-O-*`) and Proposed (`BR-P-*`).
- [x] Conceptual, logical, and physical layers stay at strictly aligned abstraction levels across 32 tables.
- [x] All core flows map to data structures and stored procedures.
- [x] No historical or finalized table is left exposed to unsafe direct modification or delete.
- [x] AI results remain advisory, not authoritative; human verification gate is strictly protected.
- [x] Seed data and tests cover all core flows with 100% reproducibility.
- [x] 35/35 executable test suites run clean with zero errors on Dockerized SQL Server 2022.

## 6. Project Freeze Criteria

Project Freeze is reached when:

1. Requirement artifacts are complete and internally consistent.
2. Architecture artifacts align with the requirement baseline.
3. Conceptual, logical, and physical database designs are complete (32 tables, 13 schemas).
4. SQL Server scripts execute successfully from clean state (`00_create_database.sql` through `09_seed_demo_data.sql`).
5. Dockerized SQL Server runs healthy and is reachable from SSMS 22 on port 14333.
6. Seed data loads without integrity errors.
7. All 35 automated success and failure test suites pass cleanly.
8. Traceability and validation matrices are 100% synchronized with actual file paths.
9. No unresolved critical or high-severity inconsistencies remain.

## 7. Testing & Validation Lead Addendum (2026-09-18)

Full runtime validation executed against Docker container `tkcsdl-sqlserver` (`mcr.microsoft.com/mssql/server:2022-CU24-ubuntu-22.04`).

| Test Suite File | Test Objective | Test Type | Result |
| --- | --- | --- | --- |
| [TST-REG-001](file:///d:/dự%20án%20TKCSDL/tests/TST-REG-001_duplicate_registration.sql) | Duplicate registration rejected by unique key | Negative | **PASS** |
| [TST-FRAME-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FRAME-001_duplicate_frame_number.sql) | Duplicate frame number in roll rejected | Negative | **PASS** |
| [TST-UQ-001](file:///d:/dự%20án%20TKCSDL/tests/TST-UQ-001_business_keys.sql) | Core business keys uniqueness & cross-contest frame reuse | Boundary / Positive / Negative | **PASS** |
| [TST-SEED-001](file:///d:/dự%20án%20TKCSDL/tests/TST-SEED-001_reference_data.sql) | Reference seed completeness & referential integrity | Integrity | **PASS** |
| [TST-SEED-002](file:///d:/dự%20án%20TKCSDL/tests/TST-SEED-002_demo_graph_consistency.sql) | Demo data graph consistency & key linkages | Integrity | **PASS** |
| [TST-SUB-001](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-001_normal_submission.sql) | Normal submission created with verification case | Positive | **PASS** |
| [TST-SUB-002](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-002_invalid_late_submission.sql) | Submission outside contest window rejected | Negative | **PASS** |
| [TST-SUB-003](file:///d:/dự%20án%20TKCSDL/tests/TST-SUB-003_creation_procedure_matrix.sql) | Creation procedure matrix (owner mismatch, status, duplicate) | Matrix | **PASS** |
| [TST-VER-001](file:///d:/dự%20án%20TKCSDL/tests/TST-VER-001_ai_flag_human_review.sql) | AI-flagged submission resolved by human review | Workflow | **PASS** |
| [TST-VER-002](file:///d:/dự%20án%20TKCSDL/tests/TST-VER-002_human_gate_terminal_state.sql) | Human gate preserves AI evidence & protects terminal state | Negative / Integrity | **PASS** |
| [TST-FN-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FN-001_round_max_score.sql) | Round maximum score function calculation accuracy | Unit Function | **PASS** |
| [TST-TXN-001](file:///d:/dự%20án%20TKCSDL/tests/TST-TXN-001_procedure_rollback.sql) | Procedure failure rolls back partial verification changes | Transaction Rollback | **PASS** |
| [TST-JDG-001](file:///d:/dự%20án%20TKCSDL/tests/TST-JDG-001_duplicate_judge_evaluation.sql) | Duplicate judge evaluation in same round rejected | Negative | **PASS** |
| [TST-JDG-002](file:///d:/dự%20án%20TKCSDL/tests/TST-JDG-002_multi_round_judging.sql) | Multi-round judging chain exists end-to-end | Positive / Integration | **PASS** |
| [TST-RES-001](file:///d:/dự%20án%20TKCSDL/tests/TST-RES-001_result_finalization.sql) | Final round result finalization and ranking | Positive | **PASS** |
| [TST-RES-002](file:///d:/dự%20án%20TKCSDL/tests/TST-RES-002_finalization_idempotency.sql) | Finalization idempotency & incomplete judging block | Idempotency / Negative | **PASS** |
| [TST-ARC-001](file:///d:/dự%20án%20TKCSDL/tests/TST-ARC-001_historical_archive.sql) | Archive snapshot immutability upon live profile change | Snapshot Stability | **PASS** |
| [TST-AUD-001](file:///d:/dự%20án%20TKCSDL/tests/TST-AUD-001_audit_status_change.sql) | Submission status change creates audit log entry | Trigger Audit | **PASS** |
| [TST-INT-001](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-001_invalid_foreign_key.sql) | Invalid foreign key rejected | Negative | **PASS** |
| [TST-FK-001](file:///d:/dự%20án%20TKCSDL/tests/TST-FK-001_core_foreign_keys.sql) | Core foreign keys reject invalid parent references | Negative Integrity | **PASS** |
| [TST-INT-002](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-002_invalid_status.sql) | Invalid submission status rejected | Constraint | **PASS** |
| [TST-INT-003](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-003_invalid_criterion_weight.sql) | Criterion weight above 100% rejected | Constraint | **PASS** |
| [TST-BOUNDARY-001](file:///d:/dự%20án%20TKCSDL/tests/TST-BOUNDARY-001_status_score_dates.sql) | Status, score, weight, rank and date boundary checks | Boundary | **PASS** |
| [TST-INT-004](file:///d:/dự%20án%20TKCSDL/tests/TST-INT-004_invalid_date_window.sql) | Reversed contest submission window rejected | Constraint | **PASS** |
| [TST-RET-001](file:///d:/dự%20án%20TKCSDL/tests/TST-RET-001_restricted_deletion.sql) | Deletion of archived result blocked by FK | Retention Policy | **PASS** |
| [TST-TMPL-001](file:///d:/dự%20án%20TKCSDL/tests/TST-TMPL-001_contest_template_cloning.sql) | Contest template cloning & hierarchy replication | Procedure / Feature | **PASS** |
| [TST-ASSET-001](file:///d:/dự%20án%20TKCSDL/tests/TST-ASSET-001_asset_metadata_qc.sql) | Asset metadata structure, SHA-256 & bit depth checks | Constraint / Feature | **PASS** |
| [TST-ARC-002](file:///d:/dự%20án%20TKCSDL/tests/TST-ARC-002_archive_from_non_finalized_rejected.sql) | Archival rejected for non-finalized results and duplicates | Negative / Procedure | **PASS** |
| [TST-IMMUT-001](file:///d:/dự%20án%20TKCSDL/tests/TST-IMMUT-001_result_archive_immutability.sql) | Immutability of Result & ArchiveItem via triggers | Negative / Triggers | **PASS** |
| [TST-PUB-001](file:///d:/dự%20án%20TKCSDL/tests/TST-PUB-001_publication_completeness.sql) | Publication completeness (category, round, criteria, award) | Procedure / Lifecycle | **PASS** |
| [TST-AWD-001](file:///d:/dự%20án%20TKCSDL/tests/TST-AWD-001_award_category_mismatch_rejected.sql) | Award-category mismatch rejected by procedure & trigger | Integrity / Trigger | **PASS** |
| [TST-VIEW-001](file:///d:/dự%20án%20TKCSDL/tests/TST-VIEW-001_reporting_views_integrity.sql) | Reporting views runtime execution & JSON snapshots | Query / Reporting | **PASS** |
| [TST-CONC-001](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-001_concurrent_registration.sql) | Two-session duplicate registration race condition | Concurrency | **PASS** |
| [TST-CONC-002](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-002_concurrent_submission.sql) | Two-session duplicate submission race condition | Concurrency | **PASS** |
| [TST-CONC-003](file:///d:/dự%20án%20TKCSDL/tests/TST-CONC-003_concurrent_evaluation.sql) | Two-session duplicate judge evaluation race condition | Concurrency | **PASS** |

**Summary: 35 / 35 Passed (100%). Zero Gaps Remaining.**
