PRINT 'T-SQL validation runner: 35 test suites.';
PRINT 'Run from the tests folder in SSMS 22 with SQLCMD Mode enabled.';
:on error exit
:r TST-REG-001_duplicate_registration.sql
:r TST-FRAME-001_duplicate_frame_number.sql
:r TST-UQ-001_business_keys.sql
:r TST-SEED-001_reference_data.sql
:r TST-SEED-002_demo_graph_consistency.sql
:r TST-SUB-001_normal_submission.sql
:r TST-SUB-002_invalid_late_submission.sql
:r TST-SUB-003_creation_procedure_matrix.sql
:r TST-VER-001_ai_flag_human_review.sql
:r TST-VER-002_human_gate_terminal_state.sql
:r TST-FN-001_round_max_score.sql
:r TST-TXN-001_procedure_rollback.sql
:r TST-JDG-001_duplicate_judge_evaluation.sql
:r TST-JDG-002_multi_round_judging.sql
:r TST-RES-001_result_finalization.sql
:r TST-RES-002_finalization_idempotency.sql
:r TST-ARC-001_historical_archive.sql
:r TST-AUD-001_audit_status_change.sql
:r TST-INT-001_invalid_foreign_key.sql
:r TST-FK-001_core_foreign_keys.sql
:r TST-INT-002_invalid_status.sql
:r TST-INT-003_invalid_criterion_weight.sql
:r TST-BOUNDARY-001_status_score_dates.sql
:r TST-INT-004_invalid_date_window.sql
:r TST-RET-001_restricted_deletion.sql
:r TST-TMPL-001_contest_template_cloning.sql
:r TST-ASSET-001_asset_metadata_qc.sql
:r TST-ARC-002_archive_from_non_finalized_rejected.sql
:r TST-IMMUT-001_result_archive_immutability.sql
:r TST-PUB-001_publication_completeness.sql
:r TST-AWD-001_award_category_mismatch_rejected.sql
:r TST-VIEW-001_reporting_views_integrity.sql
:r TST-CONC-001_concurrent_registration.sql
:r TST-CONC-002_concurrent_submission.sql
:r TST-CONC-003_concurrent_evaluation.sql
PRINT '==================================================';
PRINT 'ALL 35 TEST SUITES COMPLETED SUCCESSFULLY.';
PRINT '==================================================';
