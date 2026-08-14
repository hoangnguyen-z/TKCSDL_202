# Logical Database Design

## 1. Logical Design Goal

The logical model converts the conceptual business model into normalized relations, resolves many-to-many relationships, establishes keys and nullability logic, and separates configuration, transaction, and history records without using SQL Server-specific physical details.

## 2. Logical Relations

### 2.1 Identity and Access

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| UserAccount | user_id | email, username, display_name, account_status | Platform identity |
| Role | role_id | role_code, role_name, role_description | Master role catalog |
| UserRole | user_role_id | user_id, role_id, assigned_at, assigned_by_user_id, assignment_status | Resolves UserAccount N:M Role |
| ParticipantProfile | participant_id | user_id, display_name, portfolio_url, country_code, participant_status | Participant subtype |

### 2.2 Contest Configuration

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| Contest | contest_id | contest_code, contest_title, contest_theme, registration_open_at, registration_close_at, submission_open_at, submission_close_at, result_publish_at, contest_status | Contest header |
| ContestCategory | category_id | contest_id, category_code, category_name, category_status, sort_order | Category unique within contest |
| JudgingRound | round_id | category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round | Round scoped to category |
| ScoringCriterion | criterion_id | round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, sort_order, criterion_status | Criteria scoped to round |
| AwardDefinition | award_definition_id | category_id, award_code, award_name, rank_order, award_type, prize_description, award_status | Award templates per category |

### 2.3 Registration and Participant Activity

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| Registration | registration_id | contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id | One participant per contest |

### 2.4 Reference Data

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| FilmStock | film_stock_id | brand_name, stock_name, iso_native, film_format_code, stock_status | Reference data |
| Camera | camera_id | brand_name, model_name, camera_type, camera_status | Reference data |
| Lens | lens_id | brand_name, model_name, focal_description, lens_status | Reference data |
| Lab | lab_id | lab_name, city_name, country_code, lab_status | Reference data |

### 2.5 Film Provenance

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| FilmRoll | roll_id | participant_id, film_stock_id, lab_id, roll_code, film_format_code, iso_setting, developed_at, scanned_at, roll_status | Participant-owned roll |
| FilmFrame | frame_id | roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_status, negative_image_uri, contact_sheet_uri | Unique frame number per roll |

### 2.6 Submission and Verification

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| Submission | submission_id | registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, submitted_at, submission_status | One frame per contest maximum |
| VerificationCase | verification_id | submission_id, verification_status, completeness_status, technical_status, final_decision_code, reviewed_by_user_id, reviewed_at, review_notes | Current verification record |
| AIAnalysisResult | ai_result_id | submission_id, analysis_type_code, analysis_outcome_code, confidence_score, model_name, model_version, related_submission_id, review_decision_code, reviewed_by_user_id, reviewed_at | Advisory AI output |

### 2.7 Judging

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| JudgeAssignment | judge_assignment_id | round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id | One judge per round once |
| Evaluation | evaluation_id | round_id, submission_id, judge_user_id, evaluation_status, total_score, submitted_at, locked_at, overall_comment | One judge-submission-round combination |
| EvaluationScore | evaluation_score_id | evaluation_id, criterion_id, score_value, score_comment | One row per criterion inside evaluation |

### 2.8 Results and Archive

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| Result | result_id | category_id, submission_id, final_score, final_rank, result_status, tie_break_note, finalized_at, finalized_by_user_id, published_at | Finalized category ranking |
| AwardAssignment | award_assignment_id | award_definition_id, result_id, assigned_at, assigned_by_user_id, assignment_note | Award to finalized result |
| ArchiveItem | archive_item_id | result_id, submission_id, archive_status, archived_at, archived_by_user_id, contest_snapshot, category_snapshot, participant_snapshot, technical_snapshot, judging_snapshot, image_uri_snapshot | Immutable archive snapshot |

### 2.9 Audit

| Relation | Primary Key | Key Attributes | Notes |
| --- | --- | --- | --- |
| AuditLog | audit_log_id | entity_name, entity_id, action_code, actor_user_id, action_at, action_summary, detail_payload | Generic traceability log |

## 3. N:M Resolution Summary

| Conceptual N:M | Resolved Relation |
| --- | --- |
| UserAccount <-> Role | UserRole |
| JudgingRound <-> Judge | JudgeAssignment |
| Evaluation <-> ScoringCriterion | EvaluationScore |
| AwardDefinition <-> Result | AwardAssignment |

## 4. Candidate Keys and Alternate Keys

| Relation | Alternate / Candidate Key |
| --- | --- |
| UserAccount | email, username |
| Role | role_code |
| UserRole | (user_id, role_id) |
| ParticipantProfile | user_id |
| Contest | contest_code |
| ContestCategory | (contest_id, category_code) |
| JudgingRound | (category_id, round_number), (category_id, round_sequence) |
| ScoringCriterion | (round_id, criterion_code) |
| AwardDefinition | (category_id, award_code), (category_id, rank_order) |
| Registration | (contest_id, participant_id) |
| FilmRoll | (participant_id, roll_code) |
| FilmFrame | (roll_id, frame_number) |
| Submission | (contest_id, frame_id) |
| VerificationCase | submission_id |
| JudgeAssignment | (round_id, judge_user_id) |
| Evaluation | (round_id, submission_id, judge_user_id) |
| EvaluationScore | (evaluation_id, criterion_id) |
| Result | (category_id, submission_id), (category_id, final_rank) |
| AwardAssignment | (award_definition_id, result_id) |
| ArchiveItem | result_id |

## 5. Nullability Logic

| Relation.Attribute | Nullability Logic |
| --- | --- |
| ParticipantProfile.portfolio_url | Optional because not all participants expose public work |
| Contest.result_publish_at | Optional until results are published |
| Registration.reviewed_at / reviewed_by_user_id | Null until reviewed |
| FilmRoll.film_stock_id / lab_id | Optional if reference data not selected yet, but roll may remain draft |
| FilmFrame.camera_id / lens_id | Optional because reference catalogs may be incomplete |
| Submission.submission_statement | Optional if contest does not require narrative |
| VerificationCase.reviewed_at / reviewed_by_user_id | Null until decision taken |
| AIAnalysisResult.related_submission_id | Used only for similarity evidence |
| Evaluation.locked_at | Null until evaluation is locked |
| Result.tie_break_note | Optional, only populated when tie resolution needs explanation |

## 6. Status Lifecycle Separation

### 6.1 Configuration Relations

- Contest
- ContestCategory
- JudgingRound
- ScoringCriterion
- AwardDefinition
- Reference data

These change less frequently and define operational policy.

### 6.2 Transaction Relations

- Registration
- FilmRoll
- FilmFrame
- Submission
- VerificationCase
- JudgeAssignment
- Evaluation
- EvaluationScore
- Result
- AwardAssignment

These record contest operations and business activity.

### 6.3 History / Retention Relations

- ArchiveItem
- AuditLog

These preserve long-term or event-oriented history.

## 7. Functional Dependency and 3NF Analysis

### 7.1 Registration

Relation:

`Registration(registration_id, contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note)`

Functional Dependencies:

- `registration_id -> contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note`
- `(contest_id, participant_id) -> registration_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note`

Normalization:

- 1NF: Atomic attributes only.
- 2NF: PK is single-attribute surrogate key; no partial dependency.
- 3NF: Non-key attributes depend on the key, not on each other. Reviewer metadata depends on the registration event, not directly on participant or contest.

### 7.2 FilmFrame

Relation:

`FilmFrame(frame_id, roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_status, negative_image_uri, contact_sheet_uri)`

Functional Dependencies:

- `frame_id -> roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_status, negative_image_uri, contact_sheet_uri`
- `(roll_id, frame_number) -> frame_id, camera_id, lens_id, frame_title, captured_on, capture_location, frame_status, negative_image_uri, contact_sheet_uri`

Normalization:

- 1NF: No repeating groups; one frame per row.
- 2NF: Single-attribute surrogate key eliminates partial dependency.
- 3NF: Camera and lens details are separated to reference relations; frame row contains only foreign keys and frame-specific attributes.

### 7.3 Submission

Relation:

`Submission(submission_id, registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, submitted_at, submission_status)`

Functional Dependencies:

- `submission_id -> registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, submitted_at, submission_status`
- `(contest_id, frame_id) -> submission_id, registration_id, category_id, submission_title, submission_statement, scanned_image_uri, submitted_at, submission_status`

Normalization:

- 1NF: Atomic data.
- 2NF: Single-attribute surrogate key.
- 3NF: Contest and category descriptors are not stored redundantly here; only foreign keys are stored. Participant identity is reached through registration and frame provenance rather than repeated text fields.

### 7.4 EvaluationScore

Relation:

`EvaluationScore(evaluation_score_id, evaluation_id, criterion_id, score_value, score_comment)`

Functional Dependencies:

- `evaluation_score_id -> evaluation_id, criterion_id, score_value, score_comment`
- `(evaluation_id, criterion_id) -> evaluation_score_id, score_value, score_comment`

Normalization:

- 1NF: One score per criterion row.
- 2NF: No partial dependency because surrogate key is single attribute.
- 3NF: Criterion metadata is held in `ScoringCriterion`, not repeated here.

### 7.5 Result

Relation:

`Result(result_id, category_id, submission_id, final_score, final_rank, result_status, tie_break_note, finalized_at, finalized_by_user_id, published_at)`

Functional Dependencies:

- `result_id -> category_id, submission_id, final_score, final_rank, result_status, tie_break_note, finalized_at, finalized_by_user_id, published_at`
- `(category_id, submission_id) -> result_id, final_score, final_rank, result_status, tie_break_note, finalized_at, finalized_by_user_id, published_at`

Normalization:

- 1NF: Atomic attributes only.
- 2NF: Single surrogate key.
- 3NF: No contestant or contest details are repeated directly. Result meaning depends on the submission-category combination.

## 8. Controlled Denormalization / Snapshot Rationale

`ArchiveItem` intentionally stores snapshot attributes or JSON snapshots for:

- contest identity at archive time
- category identity at archive time
- participant display identity at archive time
- technical film metadata at archive time
- judging summary at archive time

Rationale:

- Archive items are history-preservation artifacts.
- Future edits to participant profiles, contest labels, or scoring configuration must not mutate historical archive meaning.
- This is an intentional exception to strict live-reference-only modeling.

## 9. Logical Data Dictionary

### 9.1 Identity and Access

| Relation.Attribute | Meaning |
| --- | --- |
| UserAccount.email | Unique login/contact email for the user account |
| UserAccount.account_status | Current state of the account |
| Role.role_code | Stable code such as ADMINISTRATOR, ORGANIZER, JUDGE, PARTICIPANT |
| UserRole.assignment_status | Whether the role grant is active or revoked |
| ParticipantProfile.participant_status | Active or inactive participant profile state |

### 9.2 Contest Configuration

| Relation.Attribute | Meaning |
| --- | --- |
| Contest.contest_code | Stable business identifier for a contest |
| Contest.registration_open_at / close_at | Registration window |
| Contest.submission_open_at / close_at | Submission window |
| Contest.contest_status | Contest lifecycle state |
| ContestCategory.category_code | Category identifier unique within contest |
| JudgingRound.round_sequence | Execution order of the round within a category |
| JudgingRound.is_final_round | Marks the round used for final result determination |
| ScoringCriterion.weight_percent | Relative contribution of the criterion to total score |
| AwardDefinition.rank_order | Intended ranking order or display priority |

### 9.3 Submission and Verification

| Relation.Attribute | Meaning |
| --- | --- |
| Submission.submission_status | Current entry state through verification and judging lifecycle |
| VerificationCase.completeness_status | Whether mandatory metadata and assets are complete |
| VerificationCase.technical_status | Whether file and technical checks pass |
| VerificationCase.final_decision_code | Final human verification outcome |
| AIAnalysisResult.analysis_type_code | Similarity, AI_GENERATED, AUTO_TAG, or other advisory type |
| AIAnalysisResult.analysis_outcome_code | Outcome from the AI process |
| AIAnalysisResult.confidence_score | Confidence returned by the model |

### 9.4 Judging and Results

| Relation.Attribute | Meaning |
| --- | --- |
| JudgeAssignment.assignment_status | Current assignment state |
| Evaluation.total_score | Total achieved by the judge for the submission in the round |
| EvaluationScore.score_value | Score for one criterion |
| Result.final_rank | Final category rank after organizer finalization |
| Result.result_status | Draft, Finalized, or Published |
| AwardAssignment.assignment_note | Optional note for special award explanation |

### 9.5 Archive and Audit

| Relation.Attribute | Meaning |
| --- | --- |
| ArchiveItem.contest_snapshot | Archived contest identity snapshot |
| ArchiveItem.technical_snapshot | Archived film and submission technical metadata |
| AuditLog.action_code | Event type such as INSERT, STATUS_CHANGE, FINALIZE_RESULT |
| AuditLog.detail_payload | Optional structured detail for later review |

## 10. Logical Readiness Review

The logical model is ready for physical SQL Server design because:

- Every conceptual relationship is resolved into relations or foreign keys.
- Candidate keys and uniqueness rules are explicit.
- Status lifecycles are represented.
- Important relations are normalized to 3NF.
- Archive denormalization is clearly intentional and justified.
