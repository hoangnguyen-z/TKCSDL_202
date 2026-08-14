# Physical Database Design for Microsoft SQL Server

## 1. DBMS Decision

### Selected DBMS

- Microsoft SQL Server

### Rationale

1. Strong relational integrity and mature constraint support
2. Good compatibility with structured transactional design
3. Native fit with SSMS 22 for inspection, testing, and academic demonstration
4. Strong support for views, procedures, triggers, and operational tooling
5. Straightforward Dockerized local environment setup

## 2. Physical Naming Convention

| Object Type | Convention | Example |
| --- | --- | --- |
| Schema | lowercase singular module name | `iam`, `contest`, `judging` |
| Table | PascalCase noun | `UserAccount`, `Submission`, `ArchiveItem` |
| Column | snake_case | `user_id`, `contest_code`, `submitted_at` |
| Primary Key Constraint | `PK_<Schema>_<Table>` | `PK_submission_Submission` |
| Foreign Key Constraint | `FK_<Schema>_<Table>_<RefTable>` | `FK_submission_Submission_Contest` |
| Unique Constraint | `UQ_<Schema>_<Table>_<BusinessKey>` | `UQ_submission_Submission_contest_id_frame_id` |
| Check Constraint | `CK_<Schema>_<Table>_<Rule>` | `CK_judging_Evaluation_total_score` |
| Default Constraint | `DF_<Schema>_<Table>_<Column>` | `DF_iam_UserAccount_created_at` |
| Index | `IX_<Schema>_<Table>_<Columns>` | `IX_submission_Submission_contest_id_submission_status` |
| View | schema `reporting`, prefix `vw_` | `reporting.vw_submission_overview` |
| Stored Procedure | owning schema, prefix `usp_` | `submission.usp_create_submission` |
| Function | owning schema, prefix `fn_` | `judging.fn_round_max_total_score` |
| Trigger | `TR_<Schema>_<Table>_<Event>` | `TR_judging_EvaluationScore_AIU_RecalcEvaluation` |

## 3. Schema Layout

| Schema | Purpose |
| --- | --- |
| `iam` | Identity and access data |
| `participant` | Participant profiles and registrations |
| `reference` | Reference/master data |
| `contest` | Contest configuration |
| `film` | Film rolls and frames |
| `submission` | Submission transaction data |
| `verification` | Verification and AI analysis |
| `judging` | Judge assignments and evaluations |
| `result` | Results and award assignments |
| `archive` | Long-term archive snapshot |
| `audit` | Audit logging |
| `reporting` | Views for operational queries |

## 4. Datatype Strategy

| Logical Attribute Type | SQL Server Physical Choice | Rationale |
| --- | --- | --- |
| Surrogate identifier | `INT IDENTITY(1,1)` | Simple, readable, efficient for academic demo |
| Short code | `NVARCHAR(30)` to `NVARCHAR(50)` | Controlled business identifier length |
| Name / title | `NVARCHAR(100)` to `NVARCHAR(200)` | Adequate for multilingual labels |
| Long description / note | `NVARCHAR(1000)` or `NVARCHAR(MAX)` when justified | Avoid arbitrary 255 defaults |
| Status code | `NVARCHAR(30)` | Human-readable and check-constrained |
| URI / path | `NVARCHAR(500)` | Supports longer storage references |
| Weight / score | `DECIMAL(5,2)` or `DECIMAL(6,2)` | Supports controlled scoring precision |
| Flag | `BIT` | Clear boolean semantics |
| Date only | `DATE` | Non-time-bound dates |
| Timestamp | `DATETIME2(0)` | Consistent and precise without overkill |
| Snapshot payload | `NVARCHAR(MAX)` | Human-readable JSON-compatible snapshot storage |

## 5. Table Mapping Summary

| Logical Relation | Physical Table |
| --- | --- |
| UserAccount | `iam.UserAccount` |
| Role | `iam.Role` |
| UserRole | `iam.UserRole` |
| ParticipantProfile | `participant.ParticipantProfile` |
| Contest | `contest.Contest` |
| ContestCategory | `contest.ContestCategory` |
| JudgingRound | `contest.JudgingRound` |
| ScoringCriterion | `contest.ScoringCriterion` |
| AwardDefinition | `contest.AwardDefinition` |
| Registration | `participant.Registration` |
| FilmStock | `reference.FilmStock` |
| Camera | `reference.Camera` |
| Lens | `reference.Lens` |
| Lab | `reference.Lab` |
| FilmRoll | `film.FilmRoll` |
| FilmFrame | `film.FilmFrame` |
| Submission | `submission.Submission` |
| VerificationCase | `verification.VerificationCase` |
| AIAnalysisResult | `verification.AIAnalysisResult` |
| JudgeAssignment | `judging.JudgeAssignment` |
| Evaluation | `judging.Evaluation` |
| EvaluationScore | `judging.EvaluationScore` |
| Result | `result.Result` |
| AwardAssignment | `result.AwardAssignment` |
| ArchiveItem | `archive.ArchiveItem` |
| AuditLog | `audit.AuditLog` |

## 6. Constraint Strategy

### 6.1 Core Key Constraints

- Unique email and username in `iam.UserAccount`
- Unique role code in `iam.Role`
- Unique `(user_id, role_id)` in `iam.UserRole`
- Unique participant profile per user
- Unique contest code
- Unique category code within contest
- Unique round number and sequence within category
- Unique criterion code within round
- Unique award code and rank within category
- Unique registration per `(contest_id, participant_id)`
- Unique roll code per participant
- Unique frame number per roll
- Unique submission per `(contest_id, frame_id)`
- Unique verification case per submission
- Unique judge assignment per `(round_id, judge_user_id)`
- Unique evaluation per `(round_id, submission_id, judge_user_id)`
- Unique evaluation score per `(evaluation_id, criterion_id)`
- Unique result per submission within category and unique final rank within category
- Unique archive item per result

### 6.2 Check Constraints

- Status domains for every lifecycle-controlled table
- `registration_open_at <= registration_close_at`
- `submission_open_at <= submission_close_at`
- `score_min_value <= score_max_value`
- `weight_percent > 0 and weight_percent <= 100`
- `confidence_score between 0 and 1`
- `frame_number > 0`
- `round_number > 0` and `round_sequence > 0`
- `final_rank > 0`
- `total_score >= 0`

### 6.3 Referential Actions

| Relationship | Action |
| --- | --- |
| Most parent-child configuration relations | `ON DELETE NO ACTION` |
| Submission to verification / judging / result / archive | `ON DELETE NO ACTION` |
| UserAccount referenced as actor/reviewer/finalizer | `ON DELETE NO ACTION` |
| Optional reference data from film assets | `ON DELETE NO ACTION` |

Design policy:

- No cascade delete for business history.
- Retention uses status transitions rather than hard deletion.

## 7. Audit Field Strategy

Most business tables use these core fields:

- `created_at`
- `created_by_user_id` where actor context exists
- `updated_at`
- `updated_by_user_id` where actor context exists

Rationale:

- Supports traceability without a full event-sourcing model
- Helps correlate row state with audit logs

## 8. Views, Procedures, Functions, and Triggers

### 8.1 Views

| Object | Purpose |
| --- | --- |
| `reporting.vw_submission_overview` | Operational submission overview for organizers |
| `reporting.vw_verification_queue` | Pending verification workload |
| `reporting.vw_judge_work_queue` | Judge-scoped assignment and evaluation workload |
| `reporting.vw_result_summary` | Contest result and award summary |
| `reporting.vw_archive_catalog` | Searchable archive view |

### 8.2 Functions

| Object | Purpose |
| --- | --- |
| `judging.fn_round_max_total_score` | Returns the sum of maximum criterion scores for a round |

### 8.3 Procedures

| Object | Purpose |
| --- | --- |
| `submission.usp_create_submission` | Validates and creates a submission |
| `verification.usp_record_verification_decision` | Records human verification decision and syncs submission status |
| `judging.usp_submit_evaluation` | Validates and submits a judge evaluation |
| `result.usp_finalize_results_for_round` | Aggregates and finalizes results for a final round |

### 8.4 Triggers

| Object | Purpose |
| --- | --- |
| `TR_judging_EvaluationScore_AIU_RecalcEvaluation` | Recalculates evaluation total after insert or update of criterion scores |
| `TR_submission_Submission_AU_AuditStatus` | Writes audit entries when submission status changes |
| `TR_result_Result_AU_AuditStatus` | Writes audit entries when result status changes |

## 9. Index Strategy

| Index | Type | Key Columns | Include | Rationale |
| --- | --- | --- | --- | --- |
| `IX_submission_Submission_contest_id_submission_status` | Non-unique | `contest_id`, `submission_status` | `category_id`, `registration_id`, `submitted_at` | Organizer submission queue by contest and status |
| `IX_submission_Submission_registration_id_submitted_at` | Non-unique | `registration_id`, `submitted_at` | `submission_status`, `contest_id`, `category_id` | Participant submission history |
| `IX_film_FilmFrame_roll_id_frame_number` | Unique | `roll_id`, `frame_number` | None | Provenance lookup and uniqueness |
| `IX_verification_VerificationCase_verification_status` | Non-unique | `verification_status`, `reviewed_at` | `submission_id`, `reviewed_by_user_id` | Verification queue |
| `IX_verification_AIAnalysisResult_submission_id_analysis_type_code` | Non-unique | `submission_id`, `analysis_type_code` | `confidence_score`, `analysis_outcome_code`, `related_submission_id` | Advisory analysis lookup |
| `IX_judging_JudgeAssignment_judge_user_id_assignment_status` | Non-unique | `judge_user_id`, `assignment_status` | `round_id`, `assigned_at` | Judge work queue |
| `IX_judging_Evaluation_round_id_submission_id` | Non-unique | `round_id`, `submission_id` | `judge_user_id`, `evaluation_status`, `total_score` | Aggregation and review |
| `IX_result_Result_category_id_final_rank` | Unique | `category_id`, `final_rank` | `submission_id`, `final_score`, `result_status` | Published ranking order |
| `IX_archive_ArchiveItem_archive_status_archived_at` | Non-unique | `archive_status`, `archived_at` | `result_id`, `submission_id` | Archive operations |
| `IX_audit_AuditLog_entity_name_entity_id_action_at` | Non-unique | `entity_name`, `entity_id`, `action_at` | `action_code`, `actor_user_id` | Entity history lookup |

## 10. Physical Readiness Review

The physical design is ready for implementation because:

- SQL Server datatypes are fixed.
- Naming conventions are stable.
- Referential actions reflect retention policy.
- Indexes are tied to realistic access patterns.
- Procedural objects are limited to high-value workflows.
