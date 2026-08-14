USE FilmContestDB;
GO

IF OBJECT_ID(N'iam.UserAccount', N'U') IS NULL
BEGIN
    CREATE TABLE iam.UserAccount
    (
        user_id INT IDENTITY(1,1) NOT NULL,
        email NVARCHAR(320) NOT NULL,
        username NVARCHAR(50) NOT NULL,
        display_name NVARCHAR(150) NOT NULL,
        account_status NVARCHAR(20) NOT NULL CONSTRAINT DF_iam_UserAccount_account_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_iam_UserAccount_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_iam_UserAccount_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_iam_UserAccount PRIMARY KEY CLUSTERED (user_id)
    );
END;
GO

IF OBJECT_ID(N'iam.Role', N'U') IS NULL
BEGIN
    CREATE TABLE iam.Role
    (
        role_id INT IDENTITY(1,1) NOT NULL,
        role_code NVARCHAR(30) NOT NULL,
        role_name NVARCHAR(100) NOT NULL,
        role_description NVARCHAR(500) NULL,
        role_status NVARCHAR(20) NOT NULL CONSTRAINT DF_iam_Role_role_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_iam_Role_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_iam_Role_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_iam_Role PRIMARY KEY CLUSTERED (role_id)
    );
END;
GO

IF OBJECT_ID(N'iam.UserRole', N'U') IS NULL
BEGIN
    CREATE TABLE iam.UserRole
    (
        user_role_id INT IDENTITY(1,1) NOT NULL,
        user_id INT NOT NULL,
        role_id INT NOT NULL,
        assignment_status NVARCHAR(20) NOT NULL CONSTRAINT DF_iam_UserRole_assignment_status DEFAULT (N'ACTIVE'),
        assigned_at DATETIME2(0) NOT NULL CONSTRAINT DF_iam_UserRole_assigned_at DEFAULT (SYSUTCDATETIME()),
        assigned_by_user_id INT NULL,
        revoked_at DATETIME2(0) NULL,
        notes NVARCHAR(500) NULL,
        CONSTRAINT PK_iam_UserRole PRIMARY KEY CLUSTERED (user_role_id)
    );
END;
GO

IF OBJECT_ID(N'participant.ParticipantProfile', N'U') IS NULL
BEGIN
    CREATE TABLE participant.ParticipantProfile
    (
        participant_id INT IDENTITY(1,1) NOT NULL,
        user_id INT NOT NULL,
        display_name NVARCHAR(150) NOT NULL,
        biography NVARCHAR(1000) NULL,
        portfolio_url NVARCHAR(500) NULL,
        country_code NCHAR(2) NULL,
        participant_status NVARCHAR(20) NOT NULL CONSTRAINT DF_participant_ParticipantProfile_participant_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_participant_ParticipantProfile_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_participant_ParticipantProfile_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_participant_ParticipantProfile PRIMARY KEY CLUSTERED (participant_id)
    );
END;
GO

IF OBJECT_ID(N'contest.Contest', N'U') IS NULL
BEGIN
    CREATE TABLE contest.Contest
    (
        contest_id INT IDENTITY(1,1) NOT NULL,
        contest_code NVARCHAR(30) NOT NULL,
        contest_title NVARCHAR(200) NOT NULL,
        contest_theme NVARCHAR(200) NULL,
        contest_summary NVARCHAR(1000) NULL,
        registration_open_at DATETIME2(0) NOT NULL,
        registration_close_at DATETIME2(0) NOT NULL,
        submission_open_at DATETIME2(0) NOT NULL,
        submission_close_at DATETIME2(0) NOT NULL,
        result_publish_at DATETIME2(0) NULL,
        contest_status NVARCHAR(20) NOT NULL CONSTRAINT DF_contest_Contest_contest_status DEFAULT (N'DRAFT'),
        created_by_user_id INT NOT NULL,
        updated_by_user_id INT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_Contest_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_Contest_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_contest_Contest PRIMARY KEY CLUSTERED (contest_id)
    );
END;
GO

IF OBJECT_ID(N'contest.ContestCategory', N'U') IS NULL
BEGIN
    CREATE TABLE contest.ContestCategory
    (
        category_id INT IDENTITY(1,1) NOT NULL,
        contest_id INT NOT NULL,
        category_code NVARCHAR(20) NOT NULL,
        category_name NVARCHAR(150) NOT NULL,
        category_description NVARCHAR(500) NULL,
        category_status NVARCHAR(20) NOT NULL CONSTRAINT DF_contest_ContestCategory_category_status DEFAULT (N'DRAFT'),
        sort_order INT NOT NULL CONSTRAINT DF_contest_ContestCategory_sort_order DEFAULT ((1)),
        created_by_user_id INT NOT NULL,
        updated_by_user_id INT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_ContestCategory_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_ContestCategory_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_contest_ContestCategory PRIMARY KEY CLUSTERED (category_id)
    );
END;
GO

IF OBJECT_ID(N'contest.JudgingRound', N'U') IS NULL
BEGIN
    CREATE TABLE contest.JudgingRound
    (
        round_id INT IDENTITY(1,1) NOT NULL,
        category_id INT NOT NULL,
        round_number INT NOT NULL,
        round_name NVARCHAR(100) NOT NULL,
        round_sequence INT NOT NULL,
        round_status NVARCHAR(20) NOT NULL CONSTRAINT DF_contest_JudgingRound_round_status DEFAULT (N'DRAFT'),
        evaluation_open_at DATETIME2(0) NOT NULL,
        evaluation_close_at DATETIME2(0) NOT NULL,
        is_final_round BIT NOT NULL CONSTRAINT DF_contest_JudgingRound_is_final_round DEFAULT ((0)),
        created_by_user_id INT NOT NULL,
        updated_by_user_id INT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_JudgingRound_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_JudgingRound_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_contest_JudgingRound PRIMARY KEY CLUSTERED (round_id)
    );
END;
GO

IF OBJECT_ID(N'contest.ScoringCriterion', N'U') IS NULL
BEGIN
    CREATE TABLE contest.ScoringCriterion
    (
        criterion_id INT IDENTITY(1,1) NOT NULL,
        round_id INT NOT NULL,
        criterion_code NVARCHAR(30) NOT NULL,
        criterion_name NVARCHAR(150) NOT NULL,
        criterion_description NVARCHAR(500) NULL,
        weight_percent DECIMAL(5,2) NOT NULL,
        score_min_value DECIMAL(5,2) NOT NULL,
        score_max_value DECIMAL(5,2) NOT NULL,
        sort_order INT NOT NULL CONSTRAINT DF_contest_ScoringCriterion_sort_order DEFAULT ((1)),
        criterion_status NVARCHAR(20) NOT NULL CONSTRAINT DF_contest_ScoringCriterion_criterion_status DEFAULT (N'ACTIVE'),
        created_by_user_id INT NOT NULL,
        updated_by_user_id INT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_ScoringCriterion_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_ScoringCriterion_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_contest_ScoringCriterion PRIMARY KEY CLUSTERED (criterion_id)
    );
END;
GO

IF OBJECT_ID(N'contest.AwardDefinition', N'U') IS NULL
BEGIN
    CREATE TABLE contest.AwardDefinition
    (
        award_definition_id INT IDENTITY(1,1) NOT NULL,
        category_id INT NOT NULL,
        award_code NVARCHAR(30) NOT NULL,
        award_name NVARCHAR(150) NOT NULL,
        rank_order INT NOT NULL,
        award_type NVARCHAR(30) NOT NULL,
        prize_description NVARCHAR(500) NULL,
        award_status NVARCHAR(20) NOT NULL CONSTRAINT DF_contest_AwardDefinition_award_status DEFAULT (N'ACTIVE'),
        created_by_user_id INT NOT NULL,
        updated_by_user_id INT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_AwardDefinition_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_contest_AwardDefinition_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_contest_AwardDefinition PRIMARY KEY CLUSTERED (award_definition_id)
    );
END;
GO

IF OBJECT_ID(N'participant.Registration', N'U') IS NULL
BEGIN
    CREATE TABLE participant.Registration
    (
        registration_id INT IDENTITY(1,1) NOT NULL,
        contest_id INT NOT NULL,
        participant_id INT NOT NULL,
        registration_status NVARCHAR(20) NOT NULL CONSTRAINT DF_participant_Registration_registration_status DEFAULT (N'PENDING'),
        eligibility_status NVARCHAR(20) NOT NULL CONSTRAINT DF_participant_Registration_eligibility_status DEFAULT (N'PENDING'),
        applied_at DATETIME2(0) NOT NULL CONSTRAINT DF_participant_Registration_applied_at DEFAULT (SYSUTCDATETIME()),
        reviewed_at DATETIME2(0) NULL,
        reviewed_by_user_id INT NULL,
        review_note NVARCHAR(500) NULL,
        withdrawn_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_participant_Registration_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_participant_Registration_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_participant_Registration PRIMARY KEY CLUSTERED (registration_id)
    );
END;
GO

IF OBJECT_ID(N'reference.FilmStock', N'U') IS NULL
BEGIN
    CREATE TABLE reference.FilmStock
    (
        film_stock_id INT IDENTITY(1,1) NOT NULL,
        brand_name NVARCHAR(100) NOT NULL,
        stock_name NVARCHAR(100) NOT NULL,
        iso_native SMALLINT NOT NULL,
        film_format_code NVARCHAR(20) NOT NULL,
        stock_status NVARCHAR(20) NOT NULL CONSTRAINT DF_reference_FilmStock_stock_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_FilmStock_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_FilmStock_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_reference_FilmStock PRIMARY KEY CLUSTERED (film_stock_id)
    );
END;
GO

IF OBJECT_ID(N'reference.Camera', N'U') IS NULL
BEGIN
    CREATE TABLE reference.Camera
    (
        camera_id INT IDENTITY(1,1) NOT NULL,
        brand_name NVARCHAR(100) NOT NULL,
        model_name NVARCHAR(100) NOT NULL,
        camera_type NVARCHAR(50) NOT NULL,
        camera_status NVARCHAR(20) NOT NULL CONSTRAINT DF_reference_Camera_camera_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Camera_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Camera_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_reference_Camera PRIMARY KEY CLUSTERED (camera_id)
    );
END;
GO

IF OBJECT_ID(N'reference.Lens', N'U') IS NULL
BEGIN
    CREATE TABLE reference.Lens
    (
        lens_id INT IDENTITY(1,1) NOT NULL,
        brand_name NVARCHAR(100) NOT NULL,
        model_name NVARCHAR(100) NOT NULL,
        focal_description NVARCHAR(80) NOT NULL,
        lens_status NVARCHAR(20) NOT NULL CONSTRAINT DF_reference_Lens_lens_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Lens_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Lens_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_reference_Lens PRIMARY KEY CLUSTERED (lens_id)
    );
END;
GO

IF OBJECT_ID(N'reference.Lab', N'U') IS NULL
BEGIN
    CREATE TABLE reference.Lab
    (
        lab_id INT IDENTITY(1,1) NOT NULL,
        lab_name NVARCHAR(150) NOT NULL,
        city_name NVARCHAR(100) NULL,
        country_code NCHAR(2) NULL,
        lab_status NVARCHAR(20) NOT NULL CONSTRAINT DF_reference_Lab_lab_status DEFAULT (N'ACTIVE'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Lab_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_reference_Lab_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_reference_Lab PRIMARY KEY CLUSTERED (lab_id)
    );
END;
GO

IF OBJECT_ID(N'film.FilmRoll', N'U') IS NULL
BEGIN
    CREATE TABLE film.FilmRoll
    (
        roll_id INT IDENTITY(1,1) NOT NULL,
        participant_id INT NOT NULL,
        film_stock_id INT NULL,
        lab_id INT NULL,
        roll_code NVARCHAR(50) NOT NULL,
        film_format_code NVARCHAR(20) NOT NULL,
        iso_setting SMALLINT NULL,
        developed_at DATE NULL,
        scanned_at DATE NULL,
        scan_notes NVARCHAR(500) NULL,
        roll_status NVARCHAR(20) NOT NULL CONSTRAINT DF_film_FilmRoll_roll_status DEFAULT (N'DRAFT'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_film_FilmRoll_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_film_FilmRoll_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_film_FilmRoll PRIMARY KEY CLUSTERED (roll_id)
    );
END;
GO

IF OBJECT_ID(N'film.FilmFrame', N'U') IS NULL
BEGIN
    CREATE TABLE film.FilmFrame
    (
        frame_id INT IDENTITY(1,1) NOT NULL,
        roll_id INT NOT NULL,
        camera_id INT NULL,
        lens_id INT NULL,
        frame_number INT NOT NULL,
        frame_title NVARCHAR(150) NULL,
        captured_on DATE NULL,
        capture_location NVARCHAR(200) NULL,
        frame_notes NVARCHAR(500) NULL,
        frame_status NVARCHAR(20) NOT NULL CONSTRAINT DF_film_FilmFrame_frame_status DEFAULT (N'DRAFT'),
        negative_image_uri NVARCHAR(500) NULL,
        contact_sheet_uri NVARCHAR(500) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_film_FilmFrame_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_film_FilmFrame_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_film_FilmFrame PRIMARY KEY CLUSTERED (frame_id)
    );
END;
GO

IF OBJECT_ID(N'submission.Submission', N'U') IS NULL
BEGIN
    CREATE TABLE submission.Submission
    (
        submission_id INT IDENTITY(1,1) NOT NULL,
        registration_id INT NOT NULL,
        contest_id INT NOT NULL,
        category_id INT NOT NULL,
        frame_id INT NOT NULL,
        submission_title NVARCHAR(200) NOT NULL,
        submission_statement NVARCHAR(1000) NULL,
        scanned_image_uri NVARCHAR(500) NOT NULL,
        thumbnail_image_uri NVARCHAR(500) NULL,
        submitted_at DATETIME2(0) NOT NULL CONSTRAINT DF_submission_Submission_submitted_at DEFAULT (SYSUTCDATETIME()),
        submission_status NVARCHAR(30) NOT NULL CONSTRAINT DF_submission_Submission_submission_status DEFAULT (N'PENDING_VERIFICATION'),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_submission_Submission_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_submission_Submission_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_submission_Submission PRIMARY KEY CLUSTERED (submission_id)
    );
END;
GO

IF OBJECT_ID(N'verification.VerificationCase', N'U') IS NULL
BEGIN
    CREATE TABLE verification.VerificationCase
    (
        verification_id INT IDENTITY(1,1) NOT NULL,
        submission_id INT NOT NULL,
        verification_status NVARCHAR(30) NOT NULL CONSTRAINT DF_verification_VerificationCase_verification_status DEFAULT (N'PENDING'),
        completeness_status NVARCHAR(20) NOT NULL CONSTRAINT DF_verification_VerificationCase_completeness_status DEFAULT (N'PENDING'),
        technical_status NVARCHAR(20) NOT NULL CONSTRAINT DF_verification_VerificationCase_technical_status DEFAULT (N'PENDING'),
        final_decision_code NVARCHAR(30) NULL,
        reviewed_by_user_id INT NULL,
        reviewed_at DATETIME2(0) NULL,
        review_notes NVARCHAR(1000) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_verification_VerificationCase_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_verification_VerificationCase_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_verification_VerificationCase PRIMARY KEY CLUSTERED (verification_id)
    );
END;
GO

IF OBJECT_ID(N'verification.AIAnalysisResult', N'U') IS NULL
BEGIN
    CREATE TABLE verification.AIAnalysisResult
    (
        ai_result_id INT IDENTITY(1,1) NOT NULL,
        submission_id INT NOT NULL,
        analysis_type_code NVARCHAR(30) NOT NULL,
        analysis_outcome_code NVARCHAR(30) NOT NULL,
        confidence_score DECIMAL(5,4) NOT NULL,
        model_name NVARCHAR(100) NOT NULL,
        model_version NVARCHAR(50) NULL,
        related_submission_id INT NULL,
        review_decision_code NVARCHAR(30) NULL,
        reviewed_by_user_id INT NULL,
        reviewed_at DATETIME2(0) NULL,
        analysis_summary NVARCHAR(1000) NULL,
        analysis_payload NVARCHAR(MAX) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_verification_AIAnalysisResult_created_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_verification_AIAnalysisResult PRIMARY KEY CLUSTERED (ai_result_id)
    );
END;
GO

IF OBJECT_ID(N'judging.JudgeAssignment', N'U') IS NULL
BEGIN
    CREATE TABLE judging.JudgeAssignment
    (
        judge_assignment_id INT IDENTITY(1,1) NOT NULL,
        round_id INT NOT NULL,
        judge_user_id INT NOT NULL,
        assignment_status NVARCHAR(20) NOT NULL CONSTRAINT DF_judging_JudgeAssignment_assignment_status DEFAULT (N'ASSIGNED'),
        assigned_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_JudgeAssignment_assigned_at DEFAULT (SYSUTCDATETIME()),
        assigned_by_user_id INT NOT NULL,
        assignment_note NVARCHAR(500) NULL,
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_JudgeAssignment_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_judging_JudgeAssignment PRIMARY KEY CLUSTERED (judge_assignment_id)
    );
END;
GO

IF OBJECT_ID(N'judging.Evaluation', N'U') IS NULL
BEGIN
    CREATE TABLE judging.Evaluation
    (
        evaluation_id INT IDENTITY(1,1) NOT NULL,
        round_id INT NOT NULL,
        submission_id INT NOT NULL,
        judge_user_id INT NOT NULL,
        evaluation_status NVARCHAR(20) NOT NULL CONSTRAINT DF_judging_Evaluation_evaluation_status DEFAULT (N'DRAFT'),
        total_score DECIMAL(6,2) NOT NULL CONSTRAINT DF_judging_Evaluation_total_score DEFAULT ((0)),
        overall_comment NVARCHAR(1000) NULL,
        submitted_at DATETIME2(0) NULL,
        locked_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_Evaluation_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_Evaluation_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_judging_Evaluation PRIMARY KEY CLUSTERED (evaluation_id)
    );
END;
GO

IF OBJECT_ID(N'judging.EvaluationScore', N'U') IS NULL
BEGIN
    CREATE TABLE judging.EvaluationScore
    (
        evaluation_score_id INT IDENTITY(1,1) NOT NULL,
        evaluation_id INT NOT NULL,
        criterion_id INT NOT NULL,
        score_value DECIMAL(5,2) NOT NULL,
        score_comment NVARCHAR(500) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_EvaluationScore_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_judging_EvaluationScore_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_judging_EvaluationScore PRIMARY KEY CLUSTERED (evaluation_score_id)
    );
END;
GO

IF OBJECT_ID(N'result.Result', N'U') IS NULL
BEGIN
    CREATE TABLE result.Result
    (
        result_id INT IDENTITY(1,1) NOT NULL,
        category_id INT NOT NULL,
        submission_id INT NOT NULL,
        final_score DECIMAL(6,2) NOT NULL,
        final_rank INT NOT NULL,
        result_status NVARCHAR(20) NOT NULL CONSTRAINT DF_result_Result_result_status DEFAULT (N'DRAFT'),
        tie_break_note NVARCHAR(500) NULL,
        finalized_at DATETIME2(0) NULL,
        finalized_by_user_id INT NULL,
        published_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_result_Result_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_result_Result_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_result_Result PRIMARY KEY CLUSTERED (result_id)
    );
END;
GO

IF OBJECT_ID(N'result.AwardAssignment', N'U') IS NULL
BEGIN
    CREATE TABLE result.AwardAssignment
    (
        award_assignment_id INT IDENTITY(1,1) NOT NULL,
        award_definition_id INT NOT NULL,
        result_id INT NOT NULL,
        assigned_at DATETIME2(0) NOT NULL CONSTRAINT DF_result_AwardAssignment_assigned_at DEFAULT (SYSUTCDATETIME()),
        assigned_by_user_id INT NOT NULL,
        assignment_note NVARCHAR(500) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_result_AwardAssignment_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_result_AwardAssignment_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_result_AwardAssignment PRIMARY KEY CLUSTERED (award_assignment_id)
    );
END;
GO

IF OBJECT_ID(N'archive.ArchiveItem', N'U') IS NULL
BEGIN
    CREATE TABLE archive.ArchiveItem
    (
        archive_item_id INT IDENTITY(1,1) NOT NULL,
        result_id INT NOT NULL,
        submission_id INT NOT NULL,
        archive_status NVARCHAR(20) NOT NULL CONSTRAINT DF_archive_ArchiveItem_archive_status DEFAULT (N'ARCHIVED'),
        archived_at DATETIME2(0) NOT NULL CONSTRAINT DF_archive_ArchiveItem_archived_at DEFAULT (SYSUTCDATETIME()),
        archived_by_user_id INT NOT NULL,
        contest_snapshot NVARCHAR(MAX) NOT NULL,
        category_snapshot NVARCHAR(MAX) NOT NULL,
        participant_snapshot NVARCHAR(MAX) NOT NULL,
        technical_snapshot NVARCHAR(MAX) NOT NULL,
        judging_snapshot NVARCHAR(MAX) NOT NULL,
        image_uri_snapshot NVARCHAR(500) NOT NULL,
        retention_note NVARCHAR(500) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_archive_ArchiveItem_created_at DEFAULT (SYSUTCDATETIME()),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_archive_ArchiveItem_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_archive_ArchiveItem PRIMARY KEY CLUSTERED (archive_item_id)
    );
END;
GO

IF OBJECT_ID(N'audit.AuditLog', N'U') IS NULL
BEGIN
    CREATE TABLE audit.AuditLog
    (
        audit_log_id BIGINT IDENTITY(1,1) NOT NULL,
        entity_name NVARCHAR(128) NOT NULL,
        entity_id INT NOT NULL,
        action_code NVARCHAR(40) NOT NULL,
        actor_user_id INT NULL,
        action_at DATETIME2(0) NOT NULL CONSTRAINT DF_audit_AuditLog_action_at DEFAULT (SYSUTCDATETIME()),
        action_summary NVARCHAR(500) NOT NULL,
        detail_payload NVARCHAR(MAX) NULL,
        CONSTRAINT PK_audit_AuditLog PRIMARY KEY CLUSTERED (audit_log_id)
    );
END;
GO
