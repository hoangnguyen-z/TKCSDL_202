# System Architecture Design

## 1. System Boundary

### 1.1 Inside the System

- User identity and role governance
- Contest configuration
- Participant registration
- Film roll and frame metadata management
- Submission management
- Submission verification and human review workflow
- Judging rounds, criteria, assignments, evaluations, and aggregation support
- Result publication and award assignment
- Digital archive snapshot management
- Audit logging and reporting views

### 1.2 Outside the System

- Actual cloud object storage service implementation
- Real AI inference service implementation
- Email/SMS delivery channels
- Public website or mobile app implementation
- Payment systems or sponsor contract systems

### 1.3 External Interfaces Assumed

- Object storage endpoint or URI provider for images and references
- AI analysis service returning advisory outputs
- SSMS 22 as administrative and testing client against SQL Server

## 2. Architecture Principles

| Principle | Description | Design Impact |
| --- | --- | --- |
| AP-01 Modularity | Each business capability must live in a bounded module with clear ownership. | Drives schema grouping, service boundaries, and data ownership mapping. |
| AP-02 Traceability | Every table and technical object must map back to a requirement, rule, or flow. | Prevents orphan objects and supports defense readiness. |
| AP-03 Human-Governed Decisions | AI can advise, but humans own verification and result finalization. | AI results are separated from verification decisions and final results. |
| AP-04 Data Integrity First | Contest, provenance, judging, and archive data must be protected with keys and constraints. | Strong PK/FK/UNIQUE/CHECK design and limited deletes. |
| AP-05 Lifecycle Explicitness | Business states must be visible and controlled. | Status columns and audit events are modeled across core transactions. |
| AP-06 Historical Preservation | Result and archive data must remain reliable even when upstream records evolve later. | Snapshot archive design and restricted deletion policy. |
| AP-07 Operability | The environment must be easy to run and inspect in academic demos. | Dockerized SQL Server and SSMS-compatible workflow. |
| AP-08 Security By Design | Access must be role-governed and data operations attributable. | RBAC model, actor references, and audit log support. |

## 3. Module Decomposition

| Module | Responsibility | Owned Data | Read Data | Inputs | Outputs | Dependencies | Related FR |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Identity & Access | User accounts, roles, activation, role assignment | UserAccount, Role, UserRole | AuditLog | User creation, role changes | Authorized identity context | None | FR-029, FR-030 |
| Contest Management | Contest setup, categories, rounds, criteria, awards | Contest, ContestCategory, JudgingRound, ScoringCriterion, AwardDefinition | UserAccount | Contest configuration inputs | Contest publication state and scoring model | Identity & Access | FR-001 to FR-005 |
| Registration | Participant contest enrollment and eligibility review | Registration | Contest, ParticipantProfile, UserAccount | Participant registration request | Eligibility and registration status | Identity & Access, Contest Management | FR-007 to FR-009 |
| Film Asset Management | Film rolls, frames, technical metadata | FilmRoll, FilmFrame | FilmStock, Camera, Lens, Lab, ParticipantProfile | Film asset creation and update | Reusable frame provenance | Identity & Access | FR-010 to FR-012 |
| Submission Management | Submission creation and submission status lifecycle | Submission | Registration, FilmFrame, ContestCategory | Submission request | Verification queue entries | Registration, Film Asset Management, Contest Management | FR-013 to FR-016 |
| Verification | Submission checks, AI flag intake, manual review decision | VerificationCase, AIAnalysisResult | Submission, Contest, Registration | Submission awaiting verification, AI outputs | Verification outcome | Submission Management, Contest Management | FR-017 to FR-019 |
| Judging | Judge assignment, scoring, evaluations, score totals | JudgeAssignment, Evaluation, EvaluationScore | Submission, JudgingRound, ScoringCriterion, UserAccount | Assignment actions, scoring inputs | Evaluation records and totals | Contest Management, Verification, Identity & Access | FR-020 to FR-024 |
| Result & Award | Aggregation, ranking, finalization, award assignment, publication | Result, AwardAssignment | Evaluation, AwardDefinition, Submission | Finalization request | Published results and awards | Judging, Contest Management, Verification | FR-025 to FR-027 |
| Digital Archive | Immutable long-term archive snapshot | ArchiveItem | Result, Submission, FilmFrame, ContestCategory | Archival command | Searchable archive record | Result & Award | FR-028 |
| AI & Analytics | Advisory analysis result storage and analytical summaries | AIAnalysisResult | Submission, Result | Similarity/AI-generated/tagging outputs | Advisory flags and evidence | Submission Management | FR-018, FR-031 |
| Audit & Reporting | Operational history and read-optimized reporting | AuditLog, reporting views | All modules | Entity changes and reporting queries | Traceability and operational insight | Cross-cutting | FR-029, FR-031 |

## 4. Logical Architecture

### 4.1 Architecture Style

The target system follows a modular layered architecture:

1. Client Layer
   - Web or mobile clients for participants, judges, organizers, and administrators
2. Application Layer
   - Role-aware business services by module
3. Data Access Layer
   - Repository/query logic, transaction orchestration
4. Data Layer
   - Microsoft SQL Server as system-of-record database
5. External Services Layer
   - Object storage and AI analysis provider

### 4.2 Dependency Direction

- Client Layer -> Application Layer
- Application Layer -> Data Access Layer
- Data Access Layer -> SQL Server
- Submission and Verification modules may call external AI services through integration components
- No module should directly bypass ownership boundaries for writes

## 5. Component Responsibilities

| Component | Responsibility |
| --- | --- |
| Identity Service | Authenticate user context, manage user-role assignments, expose authorization claims |
| Contest Service | Manage contests, categories, rounds, criteria, and awards |
| Registration Service | Manage registrations and eligibility review |
| Film Asset Service | Manage film rolls, frames, and technical metadata |
| Submission Service | Validate and create submissions |
| Verification Service | Run completeness checks, ingest AI outputs, support organizer review |
| Judging Service | Manage judge assignments and evaluation capture |
| Result Service | Aggregate final scores, manage result finalization and publication |
| Archive Service | Build immutable snapshots for archival reuse |
| Reporting Service | Provide queue, summary, archive, and audit queries |
| Audit Service | Record key status transitions and business events |

## 6. Module Dependencies

| Source Module | Depends On | Reason |
| --- | --- | --- |
| Contest Management | Identity & Access | Organizer identity and authorization |
| Registration | Contest Management, Identity & Access | Contest windows and participant identity |
| Film Asset Management | Identity & Access | Ownership and role context |
| Submission Management | Registration, Film Asset Management, Contest Management | Requires approved registration, owned frame, active contest/category |
| Verification | Submission Management, Contest Management | Submission payload and contest policy |
| Judging | Verification, Contest Management, Identity & Access | Verified entries, round configuration, judge identity |
| Result & Award | Judging, Contest Management | Final scores and award definitions |
| Digital Archive | Result & Award, Submission Management | Snapshot source data |
| Audit & Reporting | All modules | Observability and traceability |

## 7. Data Ownership

| Data Set | System Owner |
| --- | --- |
| User accounts and role membership | Identity & Access |
| Contest configuration | Contest Management |
| Participant registration | Registration |
| Film roll and frame provenance | Film Asset Management |
| Submission transaction | Submission Management |
| Verification decision | Verification |
| Evaluation transaction | Judging |
| Result finalization and awards | Result & Award |
| Archive snapshot | Digital Archive |
| Audit trail | Audit & Reporting |

## 8. Security and RBAC

### 8.1 Access Control Model

- Authentication and user identity are outside current implementation scope, but the data model assumes authenticated user context.
- Authorization is role-based.
- Multi-role users are supported.
- Sensitive actions require role-specific authorization:
  - Organizer: contest operation and finalization
  - Judge: scoped evaluation only
  - Participant: owned profile/assets/submissions only
  - Administrator: governance and oversight

### 8.2 Data Protection Notes

- Images are stored as URI or path references, not in-row binaries.
- Hard deletes are restricted for high-value historical records.
- Audit logs record actor, action, entity, and summary payload.

## 9. Audit and Logging

### 9.1 What Must Be Audited

- Registration decisions
- Submission status changes
- Verification decisions
- Judge assignment changes
- Evaluation submissions and score recalculations
- Result finalization and publication
- Archive creation
- User-role changes when applicable

### 9.2 Logging Model

- Audit logging stores entity name, entity id, action code, actor user id, timestamp, and summary payload.
- Status transitions are also visible in transactional rows themselves for current state.

## 10. Concurrency Considerations

| Concern | Strategy |
| --- | --- |
| Multiple participants submitting near the deadline | Enforce uniqueness and deadline logic transactionally |
| Multiple judges scoring in parallel | One evaluation row per judge-submission-round combination avoids collision |
| Organizer finalizing results while evaluations still change | Finalization procedure checks required submitted states first |
| Archive creation after result publication | Archive only from finalized results with immutable snapshot |

## 11. Data Integrity Strategy

1. Primary keys and foreign keys for structural integrity
2. Unique constraints for business uniqueness
3. Check constraints for bounded status and score domains
4. Triggers only where derived or audited behavior adds real value
5. Procedures for high-risk workflows such as submission creation and result finalization
6. Restricted delete policies for historical records

## 12. AI Integration Design

### 12.1 AI Use Cases

- Duplicate or similarity detection
- AI-generated image detection
- Optional auto-tag suggestion

### 12.2 AI Input

- Submission identifier
- Scanned image reference
- Optional contest and category context

### 12.3 AI Output

- Analysis type
- Outcome code
- Confidence score
- Model name and version
- Evidence or payload summary
- Optional related submission reference for similarity results

### 12.4 Decision Boundary

- AI may flag or recommend only.
- Organizer owns the final verification decision.
- AI results are stored separately from verification decisions.

### 12.5 Governance Notes

- Confidence values are informational, not authoritative.
- Low-confidence or high-risk cases require manual review.
- Final contest outcomes cannot be directly written by AI analysis outputs.

## 13. Deployment View Specification

The deployment view should contain at least:

- Host machine
  - Docker Engine
  - SSMS 22 client
- SQL Server container
  - Microsoft SQL Server instance
  - Persistent volume
- Optional init workflow
  - SQL script execution from SSMS or scripted host-side initialization
- External conceptual services
  - Object storage
  - AI analysis provider

## 14. Architecture Readiness Review

The architecture is ready for database design because:

- Module boundaries are stable.
- Data ownership is explicit.
- AI and human decision boundaries are clear.
- Access control and audit concerns are defined.
- The database can now be modeled to support each module without ambiguity.
