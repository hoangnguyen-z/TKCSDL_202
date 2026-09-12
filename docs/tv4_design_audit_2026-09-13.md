# TV4 Conceptual and Logical Design Audit

**Audit date:** 2026-09-13  
**Scope:** C01-C07, A09 and A11  
**Reviewed artifacts:** `docs/02_requirement_analysis.md`, `docs/04_conceptual_database_design.md`, `docs/05_logical_database_design.md`, `docs/07_validation_traceability.md`, `latex-book-main/chapter4.tex`, and `latex-book-main/chapter5.tex`

## 1. Coverage Summary

| ID | Expected result | Current evidence | Status | Gap or follow-up |
| --- | --- | --- | --- | --- |
| C01 | Complete conceptual entity inventory | `docs/04_conceptual_database_design.md` section 2; `chapter4.tex` entity table | Partial | The Markdown inventory needs explicit business necessity and the LaTeX table groups reference entities (`FilmStock / Lab`, `Camera / Lens`). |
| C02 | Conceptual ERD with relationships, cardinality and optionality | `docs/04_conceptual_database_design.md` sections 3-3.7; conceptual ERD figure assets | Partial | Relationship prose exists; the rendered ERD and its source need a final entity/name consistency check. |
| C03 | Flow-to-entity conceptual validation | `docs/04_conceptual_database_design.md` section 7; `docs/07_validation_traceability.md` | Partial | Core flows are mapped, but a dedicated gap/status table should make missing coverage explicit. |
| C04 | Logical relational model with attributes and keys | `docs/05_logical_database_design.md` sections 2-5 | Covered | Verify every relation uses the same entity vocabulary as the conceptual model. |
| C05 | Logical ERD with PK/FK and bridge relations | Logical ERD figure assets and report references | Partial | Confirm the diagram contains all bridge relations and uses logical, not physical, notation. |
| C06 | 1NF-3NF and functional dependency analysis | `docs/05_logical_database_design.md` section 7; `chapter4.tex` normalization section | Partial | Analysis exists for selected relations; final review must ensure archive snapshot is explicitly controlled denormalization. |
| C07 | Logical data dictionary | `docs/05_logical_database_design.md` section 8 | Covered | Confirm attribute names, nullability and key roles match the logical relations. |
| A09 | Functional requirement to database review | `docs/02_requirement_analysis.md` FR-001 to FR-031; existing traceability matrix | Partial | A dedicated FR-to-conceptual/logical coverage review is still required. |
| A11 | Business rule to model/enforcement review | `docs/02_requirement_analysis.md` BR-O/BR-P catalog; `docs/07_validation_traceability.md` rule matrix | Partial | The rule matrix focuses on enforcement; TV4 still needs explicit model support and application-boundary notes. |

## 2. Entity Consistency Findings

| Finding | Evidence | Decision |
| --- | --- | --- |
| Reference concepts are separate business concepts | Markdown lists `FilmStock`, `Camera`, `Lens`, and `Lab`; LaTeX groups them in two rows | Keep four separate entities in every conceptual inventory. |
| Participant is a subtype/profile, not a second user identity | Requirements define `ParticipantProfile`; conceptual and logical documents use that name | Use `ParticipantProfile` consistently. Use “Participant” only as a stakeholder or role description. |
| Verification is a process and `VerificationCase` is the data entity | Requirements and conceptual model distinguish human decision from AI output | Use `VerificationCase` for the entity; reserve “verification” for the workflow. |
| Award has two different meanings | `AwardDefinition` defines a prize; `AwardAssignment` links it to a result | Keep both entities separate. Use “award” as a generic business term only. |
| Archive is both a business capability and an entity | `ArchiveItem` stores the historical record | Use `ArchiveItem` for the entity and “digital archive” for the capability. |
| Judge is a role held by a user | Requirements model Judge as a role; assignments reference `UserAccount` | Use `UserAccount` with Judge role in relationships; do not create a duplicate `Judge` entity. |

## 3. Required Follow-up Sequence

1. Expand the conceptual Entity Inventory with explicit business necessity and separate reference entities.
2. Align entity terminology across Markdown and LaTeX report sections.
3. Recheck conceptual and logical ERD labels against the inventory and relation model.
4. Complete dedicated A09 and A11 review tables after the inventory vocabulary is frozen.

This audit intentionally excludes physical implementation work such as SQL Server datatypes, indexes, triggers, stored procedures, seed data and tests.
