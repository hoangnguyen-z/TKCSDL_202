# Conceptual Database Design

## 1. Conceptual Design Goal

The conceptual model represents business meaning, provenance, contest workflow, human decision points, and archival outcomes without introducing SQL Server-specific concerns such as datatype, index, or implementation syntax.

The model covers the complete chain:

`User/Role -> Participant -> Registration -> Film Roll -> Film Frame -> Submission -> Verification -> Judging -> Result/Award -> Digital Archive -> Audit`

## 2. Business Entities and Meaning

| Entity | Meaning | Why it is needed at conceptual level |
| --- | --- | --- |
| UserAccount | A platform identity used to access the system. | Separates identity and access ownership from business activities. |
| Role | A named responsibility set such as Administrator, Organizer, Judge, or Participant. | Defines the responsibility vocabulary used by RBAC. |
| UserRole | The assignment of a role to a user account. | Represents the UserAccount-to-Role many-to-many business relationship. |
| ParticipantProfile | Participant-specific details attached to a user who can register and submit work. | Captures participant business data without duplicating the user identity. |
| Contest | A competition event with schedule, policy, and status. | Anchors contest configuration and the complete contest lifecycle. |
| ContestCategory | A competition class or section inside a contest. | Represents category-specific eligibility, judging and results. |
| Registration | A participant's enrollment into a contest and its eligibility outcome. | Records the participant-contest transaction before submissions exist. |
| FilmStock | A reference concept describing a stock of film. | Preserves technical provenance for film rolls. |
| Camera | A reference concept describing a camera body. | Identifies the capture equipment associated with a frame. |
| Lens | A reference concept describing a lens. | Identifies the optical equipment associated with a frame. |
| Lab | A reference concept describing a film processing lab. | Preserves developing and processing provenance for a roll. |
| FilmRoll | A participant-owned roll of film used to preserve provenance. | Groups physical frames and their film metadata. |
| FilmFrame | An individual frame on a film roll that may become a contest entry. | Provides the physical source and reusable unit for a submission. |
| Submission | A contest entry created from one film frame under one approved registration and one contest category. | Represents the work being verified, judged and ranked. |
| VerificationCase | The current verification review record for a submission. | Separates human eligibility decisions from the submission itself. |
| AIAnalysisResult | An advisory AI output linked to a submission, possibly with evidence or related submission reference. | Preserves AI evidence without making AI the final decision-maker. |
| JudgingRound | A round of evaluation scoped to a contest category. | Supports multi-round judging and round-specific policy. |
| JudgeAssignment | The assignment of a judge to a judging round. | Records judging workload and scope. |
| ScoringCriterion | A criterion with weight and score range used in a judging round. | Defines the evaluation dimensions for a specific round. |
| Evaluation | One judge's assessment of one submission in one judging round. | Captures the atomic judging event. |
| EvaluationScore | A criterion-level score inside an evaluation. | Resolves the evaluation-to-criterion many-to-many relationship. |
| Result | The finalized category ranking record for a submission. | Preserves the official ranking outcome. |
| AwardDefinition | A contest/category-specific award that can later be assigned. | Defines the available prize structure independently of winners. |
| AwardAssignment | The linking of an award definition to a finalized result. | Records which finalized result received which award. |
| ArchiveItem | An immutable archived snapshot of a selected finalized result. | Preserves historical meaning after live data changes. |
| AuditLog | A business event history record for traceability. | Provides accountability for important lifecycle changes. |

## 3. Core Relationships, Cardinality, and Optionality

### 3.1 Identity and Role

1. One `UserAccount` may have zero, one, or many `UserRole` assignments.
2. One `Role` may be assigned to zero, one, or many `UserAccount` records through `UserRole`.
3. One `ParticipantProfile` must belong to exactly one `UserAccount`.
4. One `UserAccount` may have zero or one `ParticipantProfile`.

### 3.2 Contest and Registration

1. One `Contest` must have one or many `ContestCategory` records before publication.
2. One `Contest` may have zero or many `Registration` records.
3. One `ParticipantProfile` may have zero or many `Registration` records across contests.
4. One `Registration` must belong to exactly one `ParticipantProfile`.
5. One `Registration` must belong to exactly one `Contest`.

### 3.3 Film Provenance

1. One `ParticipantProfile` may own zero or many `FilmRoll` records.
2. One `FilmRoll` must belong to exactly one `ParticipantProfile`.
3. One `FilmRoll` may reference zero or one `FilmStock`.
4. One `FilmRoll` may reference zero or one `Lab`.
5. One `FilmRoll` must contain one or many `FilmFrame` records.
6. One `FilmFrame` must belong to exactly one `FilmRoll`.
7. One `FilmFrame` may reference zero or one `Camera`.
8. One `FilmFrame` may reference zero or one `Lens`.

### 3.4 Submission and Verification

1. One `Submission` must belong to exactly one `Registration`.
2. One `Submission` must belong to exactly one `Contest`.
3. One `Submission` must belong to exactly one `ContestCategory`.
4. One `Submission` must use exactly one `FilmFrame`.
5. One `FilmFrame` may be used by zero or many `Submission` records across different contests.
6. One `Submission` may have zero or one active `VerificationCase`.
7. One `VerificationCase` must belong to exactly one `Submission`.
8. One `Submission` may have zero, one, or many `AIAnalysisResult` records.
9. One `AIAnalysisResult` must belong to exactly one `Submission`.

### 3.5 Judging

1. One `ContestCategory` may have one or many `JudgingRound` records.
2. One `JudgingRound` must belong to exactly one `ContestCategory`.
3. One `JudgingRound` may have one or many `ScoringCriterion` records.
4. One `JudgingRound` may have zero or many `JudgeAssignment` records.
5. One `JudgeAssignment` must link exactly one `UserAccount` in Judge role to exactly one `JudgingRound`.
6. One `JudgingRound` may have zero or many `Evaluation` records.
7. One `Evaluation` must belong to exactly one `JudgingRound`.
8. One `Evaluation` must belong to exactly one `Submission`.
9. One `Evaluation` must belong to exactly one `UserAccount` in Judge role.
10. One `Evaluation` may have one or many `EvaluationScore` records.
11. One `EvaluationScore` must belong to exactly one `Evaluation`.
12. One `EvaluationScore` must correspond to exactly one `ScoringCriterion`.

### 3.6 Results, Awards, and Archive

1. One `Submission` may produce zero or one finalized `Result` per contest category.
2. One `Result` must belong to exactly one `ContestCategory`.
3. One `Result` must belong to exactly one `Submission`.
4. One `ContestCategory` may define zero or many `AwardDefinition` records.
5. One `AwardAssignment` must bind exactly one `AwardDefinition` to exactly one `Result`.
6. One `Result` may have zero or many `AwardAssignment` records, subject to contest policy.
7. One `ArchiveItem` must be created from exactly one finalized `Result`.
8. One `ArchiveItem` may retain references to one `Submission`, but its business meaning is a snapshot, not a live dependency only.

### 3.7 Audit

1. One `AuditLog` record may reference any governed business entity by name and identifier.
2. One governed entity may have zero or many `AuditLog` records over time.

## 4. Conceptual Business Rules Embedded In The Model

| Rule Theme | Conceptual Position |
| --- | --- |
| Multi-role user | User identity is independent from role assignment. |
| Provenance chain | Film frame cannot exist without film roll, and submission cannot exist without frame and registration. |
| Submission uniqueness | Same frame can be reused across contests, but proposed policy limits reuse inside the same contest. |
| Human review ownership | Verification decision is separate from AI analysis result. |
| Multi-round judging | Judging round is its own entity rather than a simple flag. |
| Criterion versioning | Criterion belongs to a round, enabling round-level scoring differences. |
| Historical durability | Archive is modeled as a snapshot-oriented entity. |

## 5. Key Design Questions And Resolutions

### 5.1 Is Participant a separate business entity or only User + Role?

- Resolution: `ParticipantProfile` is a business entity with one-to-one relationship to `UserAccount`.
- Rationale: Participant-specific data and contest participation history require a participant business concept.

### 5.2 Can a user have multiple roles?

- Resolution: Yes, through `UserRole`.
- Status: Proposed business rule.
- Rationale: Academic and operational environments often reuse accounts for organizing, judging, and administration.

### 5.3 Can a FilmFrame be reused?

- Resolution: A `FilmFrame` may be reused across different contests, but at most once per contest.
- Status: Proposed business rule.
- Rationale: Supports reuse of a meaningful work over time without duplicate entries inside the same contest.

### 5.4 Where do scoring criteria belong?

- Resolution: Criteria belong to `JudgingRound`.
- Status: Proposed design decision.
- Rationale: Different rounds may use different criteria or weights.

### 5.5 Is archive a live reference or a historical snapshot?

- Resolution: Archive is conceptually a snapshot entity.
- Status: Proposed design decision.
- Rationale: Historical meaning must survive changes to live contest configuration and profiles.

## 6. Conceptual Lifecycle Summary

| Entity | Lifecycle |
| --- | --- |
| Contest | Draft -> Published -> Open -> Closed -> Finalized -> Archived |
| Registration | Pending -> Approved / Rejected / Withdrawn |
| FilmRoll | Draft -> Ready -> Archived |
| FilmFrame | Draft -> Ready -> Submitted -> Archived |
| Submission | Draft -> PendingVerification -> Verified / Rejected / NeedsClarification -> Judged -> Finalized -> Archived |
| VerificationCase | Pending -> UnderReview -> Verified / Rejected / NeedsClarification |
| JudgeAssignment | Assigned -> InProgress -> Submitted / Cancelled |
| Evaluation | Draft -> Submitted -> Locked |
| Result | Draft -> Finalized -> Published |
| ArchiveItem | PendingArchive -> Archived -> Retired |

## 7. Conceptual Validation Against Core Flows

| Flow | Covered By |
| --- | --- |
| Contest planning | Contest, Category, JudgingRound, ScoringCriterion, AwardDefinition |
| Registration | ParticipantProfile, Registration |
| Film roll and frame management | FilmRoll, FilmFrame, FilmStock, Camera, Lens, Lab |
| Submission | Registration, FilmFrame, Submission |
| Verification | Submission, VerificationCase, AIAnalysisResult |
| Judge assignment and evaluation | JudgingRound, JudgeAssignment, Evaluation, EvaluationScore |
| Result finalization | Evaluation, Result, AwardAssignment |
| Digital archive | Result, ArchiveItem |

## 8. Readiness For Logical Modeling

The conceptual model is ready to transition to logical design because:

- Every core flow has a complete entity chain.
- Human decision points are represented explicitly.
- Multi-round judging and archival durability are represented structurally.
- The model separates identity, configuration, transaction, and history concerns.
