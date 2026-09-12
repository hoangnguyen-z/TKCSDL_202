PRINT 'Run this script in SSMS 22 with SQLCMD Mode enabled.';
:r .\TST-REG-001_duplicate_registration.sql
:r .\TST-FRAME-001_duplicate_frame_number.sql
:r .\TST-SUB-001_normal_submission.sql
:r .\TST-SUB-002_invalid_late_submission.sql
:r .\TST-VER-001_ai_flag_human_review.sql
:r .\TST-JDG-001_duplicate_judge_evaluation.sql
:r .\TST-JDG-002_multi_round_judging.sql
:r .\TST-RES-001_result_finalization.sql
:r .\TST-ARC-001_historical_archive.sql
:r .\TST-AUD-001_audit_status_change.sql
:r .\TST-INT-001_invalid_foreign_key.sql
:r .\TST-INT-002_invalid_status.sql
:r .\TST-INT-003_invalid_criterion_weight.sql
:r .\TST-INT-004_invalid_date_window.sql
:r .\TST-RET-001_restricted_deletion.sql
