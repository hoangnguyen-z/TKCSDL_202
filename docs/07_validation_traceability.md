# Validation, Traceability, and Project Freeze

## 1. Requirement Traceability Matrix

| Requirement / BR | Flow / Use Case | Architecture Module | Conceptual Entity | Logical Relation | Physical Table / Object | Constraint / Index / Test |
| --- | --- | --- | --- | --- | --- | --- |
| FR-007, FR-008, BR-P-002 | F02 / UC-02 | Registration | Registration | Registration | `participant.Registration` | Unique registration key, `tests/TST-REG-001.sql` |
| FR-010, FR-011, FR-012, BR-P-005 | F03 / UC-03 | Film Asset Management | FilmRoll, FilmFrame | FilmRoll, FilmFrame | `film.FilmRoll`, `film.FilmFrame` | `UQ` on `(roll_id, frame_number)`, `tests/TST-FRAME-001.sql` |
| FR-013, FR-014, FR-015, BR-P-006, BR-P-009 | F04 / UC-04 | Submission Management | Submission | Submission | `submission.Submission`, `submission.usp_create_submission` | Submission uniqueness, deadline validation, `tests/TST-SUB-001.sql`, `tests/TST-SUB-002.sql` |
| FR-017, FR-018, FR-019, BR-O-006, BR-O-007 | F05 / UC-05 | Verification | VerificationCase, AIAnalysisResult | VerificationCase, AIAnalysisResult | `verification.VerificationCase`, `verification.AIAnalysisResult`, `verification.usp_record_verification_decision` | Status checks, `tests/TST-VER-001.sql` |
| FR-020, FR-021, FR-022, FR-023, BR-O-008, BR-O-009 | F06 / UC-06 | Judging | JudgeAssignment, Evaluation, EvaluationScore | JudgeAssignment, Evaluation, EvaluationScore | `judging.JudgeAssignment`, `judging.Evaluation`, `judging.EvaluationScore` | Duplicate evaluation unique key, score checks, `tests/TST-JDG-001.sql` |
| FR-024, FR-025, FR-026, FR-027, BR-O-010, BR-P-014, BR-P-015 | F07 / UC-07 | Result & Award | Result, AwardDefinition, AwardAssignment | Result, AwardDefinition, AwardAssignment | `result.Result`, `result.AwardAssignment`, `result.usp_finalize_results_for_round` | Rank uniqueness, finalization logic, `tests/TST-RES-001.sql` |
| FR-028, BR-O-011, BR-P-017 | F08 / UC-08 | Digital Archive | ArchiveItem | ArchiveItem | `archive.ArchiveItem`, `reporting.vw_archive_catalog` | `UQ` on result archive, `tests/TST-ARC-001.sql` |
| FR-029 | All flows | Audit & Reporting | AuditLog | AuditLog | `audit.AuditLog`, audit triggers | Audit indexes, `tests/TST-AUD-001.sql` |
| FR-030, BR-P-001 | All role-scoped flows | Identity & Access | UserAccount, Role, UserRole | UserAccount, Role, UserRole | `iam.UserAccount`, `iam.Role`, `iam.UserRole` | Unique account and role keys |
| NFR-001, NFR-002, NFR-003 | Environment setup | Deployment View | N/A | N/A | `docker-compose.yml`, `README.md` | Docker startup and SSMS connectivity check |

## 2. CRUD / Data Ownership Matrix

| Module | Create | Read | Update | Delete | System Owner |
| --- | --- | --- | --- | --- | --- |
| Identity & Access | UserAccount, UserRole | UserAccount, Role, UserRole | UserAccount, UserRole | No hard delete by default | Identity & Access |
| Contest Management | Contest, ContestCategory, JudgingRound, ScoringCriterion, AwardDefinition | Same | Same | Restricted | Contest Management |
| Registration | Registration | Registration, Contest, ParticipantProfile | Registration | Restricted | Registration |
| Film Asset Management | FilmRoll, FilmFrame | FilmRoll, FilmFrame, reference data | FilmRoll, FilmFrame | Restricted | Film Asset Management |
| Submission Management | Submission | Submission, Registration, FilmFrame, ContestCategory | Submission status before verification completion | Restricted | Submission Management |
| Verification | VerificationCase, AIAnalysisResult | Submission, VerificationCase, AIAnalysisResult | VerificationCase, AIAnalysisResult | Restricted | Verification |
| Judging | JudgeAssignment, Evaluation, EvaluationScore | Same plus rounds and criteria | Assignment state, Evaluation, EvaluationScore | Restricted | Judging |
| Result & Award | Result, AwardAssignment | Result, AwardDefinition, AwardAssignment | Result state, AwardAssignment | Restricted | Result & Award |
| Digital Archive | ArchiveItem | ArchiveItem, Result, Submission | Archive status only | Restricted | Digital Archive |
| Audit & Reporting | AuditLog | AuditLog and reporting views | Not normally updated | No delete in routine operations | Audit & Reporting |

## 3. Rule-to-Enforcement Matrix

| Business Rule | Enforcement Type | Enforcement Location |
| --- | --- | --- |
| BR-O-001 Contest completeness before publish | Application / workflow validation | Organizer workflow and publication process |
| BR-O-002 Criterion has range and weight | Database + SQL logic | Check constraints |
| BR-O-003 Deadline enforcement | SQL logic + application validation | Procedures and workflow checks |
| BR-O-004 Frame belongs to one roll | Database | Foreign key |
| BR-O-005 Submission binds registration, contest, category, frame | Database + SQL logic | Foreign keys and submission procedure |
| BR-O-006 AI cannot finalize verification alone | Human decision + application rule | Verification process |
| BR-O-007 Verification terminal states | Database + procedure logic | Check constraints and verification procedure |
| BR-O-008 Judge assignment scoped to round | Database | Foreign key and unique key |
| BR-O-009 One evaluation per judge-submission-round | Database | Unique key |
| BR-O-010 Results finalized only after judging complete | SQL logic + application validation | Result finalization procedure |
| BR-O-011 Archive only from finalized results | SQL logic + foreign key + workflow | Archive creation logic |
| BR-P-001 Multi-role user | Database + application authorization | UserRole model |
| BR-P-002 One active registration per contest | Database | Unique key |
| BR-P-005 Frame number unique within roll | Database | Unique key |
| BR-P-006 Frame reused across contests, not inside same contest | Database | Unique key on `(contest_id, frame_id)` |
| BR-P-009 Submission owner must match frame owner | SQL logic | Submission creation procedure |
| BR-P-013 Evaluation needs criterion scores | SQL logic + trigger support | Evaluation submission procedure |
| BR-P-018 Restricted deletion policy | Database + operational policy | `NO ACTION` foreign keys and admin policy |

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
| DD-008 | Delete strategy | Cascade delete vs restrict and status transitions | Restrict deletes | Contest history must survive | `NO ACTION` FKs, archive and result protection |
| DD-009 | DBMS | PostgreSQL vs SQL Server | SQL Server | Official current technology choice | All physical artifacts use SQL Server syntax |
| DD-010 | Local runtime | Native host install only vs Dockerized SQL Server | Dockerized SQL Server + SSMS | Repeatable environment and easy review | Compose file, init workflow, host connection docs |

## 5. Consistency Audit Checklist

- Requirement IDs are unique and stable.
- Business rule IDs are unique and marked official or proposed.
- Conceptual, logical, and physical layers stay at different abstraction levels.
- All core flows map to data structures.
- No module owns data without a requirement or flow reason.
- No historical table is left exposed to unsafe cascade delete.
- AI results remain advisory, not authoritative.
- Seed data and tests cover all core flows.

## 6. Project Freeze Criteria

Project Freeze is reached when:

1. Requirement artifacts are complete and internally consistent.
2. Architecture artifacts align with the requirement baseline.
3. Conceptual, logical, and physical database designs are complete.
4. SQL Server scripts execute successfully.
5. Dockerized SQL Server runs successfully and is reachable from SSMS 22.
6. Seed data loads without integrity errors.
7. Success and failure tests behave as expected.
8. Traceability and validation matrices are complete.
9. No unresolved critical or high-severity inconsistencies remain.
