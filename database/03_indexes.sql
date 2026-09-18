USE FilmContestDB;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_submission_Submission_contest_id_submission_status' AND object_id = OBJECT_ID(N'submission.Submission'))
    CREATE NONCLUSTERED INDEX IX_submission_Submission_contest_id_submission_status
        ON submission.Submission (contest_id, submission_status)
        INCLUDE (category_id, registration_id, submitted_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_submission_Submission_registration_id_submitted_at' AND object_id = OBJECT_ID(N'submission.Submission'))
    CREATE NONCLUSTERED INDEX IX_submission_Submission_registration_id_submitted_at
        ON submission.Submission (registration_id, submitted_at)
        INCLUDE (submission_status, contest_id, category_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_verification_VerificationCase_verification_status_reviewed_at' AND object_id = OBJECT_ID(N'verification.VerificationCase'))
    CREATE NONCLUSTERED INDEX IX_verification_VerificationCase_verification_status_reviewed_at
        ON verification.VerificationCase (verification_status, reviewed_at)
        INCLUDE (submission_id, reviewed_by_user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_verification_AIAnalysisResult_submission_id_analysis_type_code' AND object_id = OBJECT_ID(N'verification.AIAnalysisResult'))
    CREATE NONCLUSTERED INDEX IX_verification_AIAnalysisResult_submission_id_analysis_type_code
        ON verification.AIAnalysisResult (submission_id, analysis_type_code)
        INCLUDE (confidence_score, analysis_outcome_code, related_submission_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_judging_JudgeAssignment_judge_user_id_assignment_status' AND object_id = OBJECT_ID(N'judging.JudgeAssignment'))
    CREATE NONCLUSTERED INDEX IX_judging_JudgeAssignment_judge_user_id_assignment_status
        ON judging.JudgeAssignment (judge_user_id, assignment_status)
        INCLUDE (round_id, assigned_at);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_judging_Evaluation_round_id_submission_id' AND object_id = OBJECT_ID(N'judging.Evaluation'))
    CREATE NONCLUSTERED INDEX IX_judging_Evaluation_round_id_submission_id
        ON judging.Evaluation (round_id, submission_id)
        INCLUDE (judge_user_id, evaluation_status, total_score);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_result_Result_category_id_final_rank' AND object_id = OBJECT_ID(N'result.Result'))
    CREATE UNIQUE NONCLUSTERED INDEX IX_result_Result_category_id_final_rank
        ON result.Result (category_id, final_rank)
        INCLUDE (submission_id, final_score, result_status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_archive_ArchiveItem_archive_status_archived_at' AND object_id = OBJECT_ID(N'archive.ArchiveItem'))
    CREATE NONCLUSTERED INDEX IX_archive_ArchiveItem_archive_status_archived_at
        ON archive.ArchiveItem (archive_status, archived_at)
        INCLUDE (result_id, submission_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_audit_AuditLog_entity_name_entity_id_action_at' AND object_id = OBJECT_ID(N'audit.AuditLog'))
    CREATE NONCLUSTERED INDEX IX_audit_AuditLog_entity_name_entity_id_action_at
        ON audit.AuditLog (entity_name, entity_id, action_at)
        INCLUDE (action_code, actor_user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_contest_ContestTemplate_template_status' AND object_id = OBJECT_ID(N'contest.ContestTemplate'))
    CREATE NONCLUSTERED INDEX IX_contest_ContestTemplate_template_status
        ON contest.ContestTemplate (template_status)
        INCLUDE (template_code, template_name);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_contest_Contest_source_template_id' AND object_id = OBJECT_ID(N'contest.Contest'))
    CREATE NONCLUSTERED INDEX IX_contest_Contest_source_template_id
        ON contest.Contest (source_template_id)
        WHERE source_template_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_film_AssetMetadata_frame_id_asset_type_code' AND object_id = OBJECT_ID(N'film.AssetMetadata'))
    CREATE NONCLUSTERED INDEX IX_film_AssetMetadata_frame_id_asset_type_code
        ON film.AssetMetadata (frame_id, asset_type_code)
        INCLUDE (file_size_bytes, qc_status, checksum_sha256);
GO
