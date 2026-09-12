# Gap Analysis

## Current Repository State

The source baseline for the project consists of two requirement artifacts:

- `Đề tài.pdf`
- `Nhiệm vụ và phân công TKCSDL.docx`

The repository has since been expanded by the Requirement Lead and the wider team. The source documents remain the authority for the business scope; repository artifacts translate that scope into implementation-ready analysis, design, and validation inputs.

The initial repository state contained no project structure, SQL Server scripts, Docker assets, validation artifacts, or implementation-ready documentation. This historical baseline is retained to show the gap that the project addressed.

## Required Scope Versus Current State

| Area | Required Outcome | Current State | Gap |
| --- | --- | --- | --- |
| Requirement Analysis | Glossary, stakeholders, roles, AS-IS/TO-BE, flows, FR, NFR, BR, use cases | Documented in `docs/02_requirement_analysis.md` and LaTeX Chapters 1-2 | Closed for the current database phase |
| System Architecture Design | Boundary, principles, modules, dependencies, data ownership, AI/RBAC/audit design | Not documented in repository | Full gap |
| Conceptual Database Design | Business entities, relationships, cardinality, optionality, rationale | Not documented in repository | Full gap |
| Logical Database Design | Relational model, keys, status lifecycle, 3NF, logical dictionary | Not documented in repository | Full gap |
| Physical Database Design | SQL Server mapping, constraints, indexes, naming convention | Not documented in repository | Full gap |
| SQL Server Implementation | Executable DDL, DML, views, procedures, triggers, tests | Not present | Full gap |
| Docker Setup | SQL Server container, environment file template, initialization workflow | Not present | Full gap |
| Seed Data | Reference and demo data aligned to core flows | Not present | Full gap |
| Database Testing | Success and failure tests with expected results | Not present | Full gap |
| Validation & Traceability | RTM, CRUD/Data Ownership, Rule-to-Enforcement, decision log | Not present | Full gap |
| Repository Readiness | README, folders, conventions, repeatable setup steps | Not present | Full gap |

## Key Risks Identified Before Build-Out

1. The repository does not yet contain any baseline artifacts, so inconsistency can spread quickly unless requirements, architecture, and database design are frozen in order.
2. Older notes reference PostgreSQL, but the official target DBMS is now Microsoft SQL Server. All physical design and implementation assets must align with SQL Server only.
3. Business rules such as frame reuse, category uniqueness, tie-breaking, deletion policy, and AI decision boundary are not all explicitly mandated by the prompt. These must be recorded as `Proposed Business Rule` or `Design Decision` where applicable.
4. SQL Server and Docker setup must remain compatible with host-based SSMS 22 workflows because SSMS is the primary administration and testing tool.

## Requirement Ownership and Scope Boundary

The Requirement Lead maintains the traceability chain:

`Source requirements -> Business flows -> FR/NFR/BR -> Use cases -> Architecture inputs -> Database artifacts -> Tests`

Requirements explicitly stated in the source documents are treated as official. Rules introduced to make the database design executable are labeled as proposed business rules or design decisions. Web, mobile, backend runtime, production AI inference, and real cloud storage remain proposed or out of scope for this database-focused phase unless a later project decision changes the baseline.

## Delivery Strategy

The project will be completed in this sequence:

1. Requirement Baseline
2. Architecture Baseline
3. Conceptual Database Design
4. Logical Database Design
5. Physical SQL Server Design
6. SQL Server Implementation
7. Docker and SSMS workflow
8. Seed Data and Testing
9. Validation and Traceability
10. Consistency Audit and Project Freeze

## Exit Criteria For Gap Closure

The gap is considered closed only when:

- All required repository folders and core files exist.
- Every major artifact is internally consistent and traceable.
- SQL Server scripts execute successfully against the Dockerized environment.
- SSMS 22 can connect to the containerized SQL Server instance.
- Seed and test scripts run successfully.
- Validation matrices and design decisions are complete.
