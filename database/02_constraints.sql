USE FilmContestDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_iam_UserAccount_email')
    ALTER TABLE iam.UserAccount ADD CONSTRAINT UQ_iam_UserAccount_email UNIQUE (email);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_iam_UserAccount_username')
    ALTER TABLE iam.UserAccount ADD CONSTRAINT UQ_iam_UserAccount_username UNIQUE (username);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_iam_UserAccount_account_status')
    ALTER TABLE iam.UserAccount ADD CONSTRAINT CK_iam_UserAccount_account_status CHECK (account_status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_iam_Role_role_code')
    ALTER TABLE iam.Role ADD CONSTRAINT UQ_iam_Role_role_code UNIQUE (role_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_iam_Role_role_status')
    ALTER TABLE iam.Role ADD CONSTRAINT CK_iam_Role_role_status CHECK (role_status IN (N'ACTIVE', N'INACTIVE'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_iam_UserRole_user_id_role_id')
    ALTER TABLE iam.UserRole ADD CONSTRAINT UQ_iam_UserRole_user_id_role_id UNIQUE (user_id, role_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_iam_UserRole_assignment_status')
    ALTER TABLE iam.UserRole ADD CONSTRAINT CK_iam_UserRole_assignment_status CHECK (assignment_status IN (N'ACTIVE', N'REVOKED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_iam_UserRole_UserAccount')
    ALTER TABLE iam.UserRole ADD CONSTRAINT FK_iam_UserRole_UserAccount FOREIGN KEY (user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_iam_UserRole_Role')
    ALTER TABLE iam.UserRole ADD CONSTRAINT FK_iam_UserRole_Role FOREIGN KEY (role_id) REFERENCES iam.Role (role_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_iam_UserRole_AssignedByUser')
    ALTER TABLE iam.UserRole ADD CONSTRAINT FK_iam_UserRole_AssignedByUser FOREIGN KEY (assigned_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_participant_ParticipantProfile_user_id')
    ALTER TABLE participant.ParticipantProfile ADD CONSTRAINT UQ_participant_ParticipantProfile_user_id UNIQUE (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_participant_ParticipantProfile_participant_status')
    ALTER TABLE participant.ParticipantProfile ADD CONSTRAINT CK_participant_ParticipantProfile_participant_status CHECK (participant_status IN (N'ACTIVE', N'INACTIVE'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_participant_ParticipantProfile_UserAccount')
    ALTER TABLE participant.ParticipantProfile ADD CONSTRAINT FK_participant_ParticipantProfile_UserAccount FOREIGN KEY (user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_Contest_contest_code')
    ALTER TABLE contest.Contest ADD CONSTRAINT UQ_contest_Contest_contest_code UNIQUE (contest_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_Contest_contest_status')
    ALTER TABLE contest.Contest ADD CONSTRAINT CK_contest_Contest_contest_status CHECK (contest_status IN (N'DRAFT', N'PUBLISHED', N'OPEN', N'CLOSED', N'FINALIZED', N'ARCHIVED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_Contest_registration_window')
    ALTER TABLE contest.Contest ADD CONSTRAINT CK_contest_Contest_registration_window CHECK (registration_open_at <= registration_close_at);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_Contest_submission_window')
    ALTER TABLE contest.Contest ADD CONSTRAINT CK_contest_Contest_submission_window CHECK (submission_open_at <= submission_close_at);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_Contest_CreatedByUser')
    ALTER TABLE contest.Contest ADD CONSTRAINT FK_contest_Contest_CreatedByUser FOREIGN KEY (created_by_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_Contest_UpdatedByUser')
    ALTER TABLE contest.Contest ADD CONSTRAINT FK_contest_Contest_UpdatedByUser FOREIGN KEY (updated_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_ContestCategory_contest_id_category_code')
    ALTER TABLE contest.ContestCategory ADD CONSTRAINT UQ_contest_ContestCategory_contest_id_category_code UNIQUE (contest_id, category_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_ContestCategory_category_status')
    ALTER TABLE contest.ContestCategory ADD CONSTRAINT CK_contest_ContestCategory_category_status CHECK (category_status IN (N'DRAFT', N'ACTIVE', N'INACTIVE', N'ARCHIVED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ContestCategory_Contest')
    ALTER TABLE contest.ContestCategory ADD CONSTRAINT FK_contest_ContestCategory_Contest FOREIGN KEY (contest_id) REFERENCES contest.Contest (contest_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ContestCategory_CreatedByUser')
    ALTER TABLE contest.ContestCategory ADD CONSTRAINT FK_contest_ContestCategory_CreatedByUser FOREIGN KEY (created_by_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ContestCategory_UpdatedByUser')
    ALTER TABLE contest.ContestCategory ADD CONSTRAINT FK_contest_ContestCategory_UpdatedByUser FOREIGN KEY (updated_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_JudgingRound_category_id_round_number')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT UQ_contest_JudgingRound_category_id_round_number UNIQUE (category_id, round_number);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_JudgingRound_category_id_round_sequence')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT UQ_contest_JudgingRound_category_id_round_sequence UNIQUE (category_id, round_sequence);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_JudgingRound_round_number')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT CK_contest_JudgingRound_round_number CHECK (round_number > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_JudgingRound_round_sequence')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT CK_contest_JudgingRound_round_sequence CHECK (round_sequence > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_JudgingRound_round_status')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT CK_contest_JudgingRound_round_status CHECK (round_status IN (N'DRAFT', N'OPEN', N'CLOSED', N'FINALIZED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_JudgingRound_evaluation_window')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT CK_contest_JudgingRound_evaluation_window CHECK (evaluation_open_at <= evaluation_close_at);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_JudgingRound_ContestCategory')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT FK_contest_JudgingRound_ContestCategory FOREIGN KEY (category_id) REFERENCES contest.ContestCategory (category_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_JudgingRound_CreatedByUser')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT FK_contest_JudgingRound_CreatedByUser FOREIGN KEY (created_by_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_JudgingRound_UpdatedByUser')
    ALTER TABLE contest.JudgingRound ADD CONSTRAINT FK_contest_JudgingRound_UpdatedByUser FOREIGN KEY (updated_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_ScoringCriterion_round_id_criterion_code')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT UQ_contest_ScoringCriterion_round_id_criterion_code UNIQUE (round_id, criterion_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_ScoringCriterion_weight_percent')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT CK_contest_ScoringCriterion_weight_percent CHECK (weight_percent > 0 AND weight_percent <= 100);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_ScoringCriterion_score_range')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT CK_contest_ScoringCriterion_score_range CHECK (score_min_value >= 0 AND score_min_value <= score_max_value);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_ScoringCriterion_criterion_status')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT CK_contest_ScoringCriterion_criterion_status CHECK (criterion_status IN (N'ACTIVE', N'INACTIVE'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ScoringCriterion_JudgingRound')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT FK_contest_ScoringCriterion_JudgingRound FOREIGN KEY (round_id) REFERENCES contest.JudgingRound (round_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ScoringCriterion_CreatedByUser')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT FK_contest_ScoringCriterion_CreatedByUser FOREIGN KEY (created_by_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_ScoringCriterion_UpdatedByUser')
    ALTER TABLE contest.ScoringCriterion ADD CONSTRAINT FK_contest_ScoringCriterion_UpdatedByUser FOREIGN KEY (updated_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_AwardDefinition_category_id_award_code')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT UQ_contest_AwardDefinition_category_id_award_code UNIQUE (category_id, award_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_contest_AwardDefinition_category_id_rank_order')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT UQ_contest_AwardDefinition_category_id_rank_order UNIQUE (category_id, rank_order);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_AwardDefinition_rank_order')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT CK_contest_AwardDefinition_rank_order CHECK (rank_order > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_contest_AwardDefinition_award_status')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT CK_contest_AwardDefinition_award_status CHECK (award_status IN (N'ACTIVE', N'INACTIVE'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_AwardDefinition_ContestCategory')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT FK_contest_AwardDefinition_ContestCategory FOREIGN KEY (category_id) REFERENCES contest.ContestCategory (category_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_AwardDefinition_CreatedByUser')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT FK_contest_AwardDefinition_CreatedByUser FOREIGN KEY (created_by_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_contest_AwardDefinition_UpdatedByUser')
    ALTER TABLE contest.AwardDefinition ADD CONSTRAINT FK_contest_AwardDefinition_UpdatedByUser FOREIGN KEY (updated_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_participant_Registration_contest_id_participant_id')
    ALTER TABLE participant.Registration ADD CONSTRAINT UQ_participant_Registration_contest_id_participant_id UNIQUE (contest_id, participant_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_participant_Registration_registration_status')
    ALTER TABLE participant.Registration ADD CONSTRAINT CK_participant_Registration_registration_status CHECK (registration_status IN (N'PENDING', N'APPROVED', N'REJECTED', N'WITHDRAWN'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_participant_Registration_eligibility_status')
    ALTER TABLE participant.Registration ADD CONSTRAINT CK_participant_Registration_eligibility_status CHECK (eligibility_status IN (N'PENDING', N'ELIGIBLE', N'INELIGIBLE'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_participant_Registration_Contest')
    ALTER TABLE participant.Registration ADD CONSTRAINT FK_participant_Registration_Contest FOREIGN KEY (contest_id) REFERENCES contest.Contest (contest_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_participant_Registration_ParticipantProfile')
    ALTER TABLE participant.Registration ADD CONSTRAINT FK_participant_Registration_ParticipantProfile FOREIGN KEY (participant_id) REFERENCES participant.ParticipantProfile (participant_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_participant_Registration_ReviewedByUser')
    ALTER TABLE participant.Registration ADD CONSTRAINT FK_participant_Registration_ReviewedByUser FOREIGN KEY (reviewed_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_reference_FilmStock_brand_name_stock_name_film_format_code')
    ALTER TABLE reference.FilmStock ADD CONSTRAINT UQ_reference_FilmStock_brand_name_stock_name_film_format_code UNIQUE (brand_name, stock_name, film_format_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_reference_FilmStock_stock_status')
    ALTER TABLE reference.FilmStock ADD CONSTRAINT CK_reference_FilmStock_stock_status CHECK (stock_status IN (N'ACTIVE', N'INACTIVE'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_reference_FilmStock_iso_native')
    ALTER TABLE reference.FilmStock ADD CONSTRAINT CK_reference_FilmStock_iso_native CHECK (iso_native > 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_reference_Camera_brand_name_model_name')
    ALTER TABLE reference.Camera ADD CONSTRAINT UQ_reference_Camera_brand_name_model_name UNIQUE (brand_name, model_name);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_reference_Camera_camera_status')
    ALTER TABLE reference.Camera ADD CONSTRAINT CK_reference_Camera_camera_status CHECK (camera_status IN (N'ACTIVE', N'INACTIVE'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_reference_Lens_brand_name_model_name_focal_description')
    ALTER TABLE reference.Lens ADD CONSTRAINT UQ_reference_Lens_brand_name_model_name_focal_description UNIQUE (brand_name, model_name, focal_description);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_reference_Lens_lens_status')
    ALTER TABLE reference.Lens ADD CONSTRAINT CK_reference_Lens_lens_status CHECK (lens_status IN (N'ACTIVE', N'INACTIVE'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_reference_Lab_lab_name_city_name_country_code')
    ALTER TABLE reference.Lab ADD CONSTRAINT UQ_reference_Lab_lab_name_city_name_country_code UNIQUE (lab_name, city_name, country_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_reference_Lab_lab_status')
    ALTER TABLE reference.Lab ADD CONSTRAINT CK_reference_Lab_lab_status CHECK (lab_status IN (N'ACTIVE', N'INACTIVE'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_film_FilmRoll_participant_id_roll_code')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT UQ_film_FilmRoll_participant_id_roll_code UNIQUE (participant_id, roll_code);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_film_FilmRoll_roll_status')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT CK_film_FilmRoll_roll_status CHECK (roll_status IN (N'DRAFT', N'READY', N'ARCHIVED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_film_FilmRoll_iso_setting')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT CK_film_FilmRoll_iso_setting CHECK (iso_setting IS NULL OR iso_setting > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmRoll_ParticipantProfile')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT FK_film_FilmRoll_ParticipantProfile FOREIGN KEY (participant_id) REFERENCES participant.ParticipantProfile (participant_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmRoll_FilmStock')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT FK_film_FilmRoll_FilmStock FOREIGN KEY (film_stock_id) REFERENCES reference.FilmStock (film_stock_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmRoll_Lab')
    ALTER TABLE film.FilmRoll ADD CONSTRAINT FK_film_FilmRoll_Lab FOREIGN KEY (lab_id) REFERENCES reference.Lab (lab_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_film_FilmFrame_roll_id_frame_number')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT UQ_film_FilmFrame_roll_id_frame_number UNIQUE (roll_id, frame_number);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_film_FilmFrame_frame_number')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT CK_film_FilmFrame_frame_number CHECK (frame_number > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_film_FilmFrame_frame_status')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT CK_film_FilmFrame_frame_status CHECK (frame_status IN (N'DRAFT', N'READY', N'SUBMITTED', N'ARCHIVED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmFrame_FilmRoll')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT FK_film_FilmFrame_FilmRoll FOREIGN KEY (roll_id) REFERENCES film.FilmRoll (roll_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmFrame_Camera')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT FK_film_FilmFrame_Camera FOREIGN KEY (camera_id) REFERENCES reference.Camera (camera_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_film_FilmFrame_Lens')
    ALTER TABLE film.FilmFrame ADD CONSTRAINT FK_film_FilmFrame_Lens FOREIGN KEY (lens_id) REFERENCES reference.Lens (lens_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_submission_Submission_contest_id_frame_id')
    ALTER TABLE submission.Submission ADD CONSTRAINT UQ_submission_Submission_contest_id_frame_id UNIQUE (contest_id, frame_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_submission_Submission_submission_status')
    ALTER TABLE submission.Submission ADD CONSTRAINT CK_submission_Submission_submission_status CHECK (submission_status IN (N'DRAFT', N'PENDING_VERIFICATION', N'VERIFIED', N'REJECTED', N'NEEDS_CLARIFICATION', N'JUDGED', N'FINALIZED', N'ARCHIVED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_submission_Submission_Registration')
    ALTER TABLE submission.Submission ADD CONSTRAINT FK_submission_Submission_Registration FOREIGN KEY (registration_id) REFERENCES participant.Registration (registration_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_submission_Submission_Contest')
    ALTER TABLE submission.Submission ADD CONSTRAINT FK_submission_Submission_Contest FOREIGN KEY (contest_id) REFERENCES contest.Contest (contest_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_submission_Submission_ContestCategory')
    ALTER TABLE submission.Submission ADD CONSTRAINT FK_submission_Submission_ContestCategory FOREIGN KEY (category_id) REFERENCES contest.ContestCategory (category_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_submission_Submission_FilmFrame')
    ALTER TABLE submission.Submission ADD CONSTRAINT FK_submission_Submission_FilmFrame FOREIGN KEY (frame_id) REFERENCES film.FilmFrame (frame_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_verification_VerificationCase_submission_id')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT UQ_verification_VerificationCase_submission_id UNIQUE (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_VerificationCase_verification_status')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT CK_verification_VerificationCase_verification_status CHECK (verification_status IN (N'PENDING', N'UNDER_REVIEW', N'VERIFIED', N'REJECTED', N'NEEDS_CLARIFICATION'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_VerificationCase_completeness_status')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT CK_verification_VerificationCase_completeness_status CHECK (completeness_status IN (N'PENDING', N'PASS', N'FAIL'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_VerificationCase_technical_status')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT CK_verification_VerificationCase_technical_status CHECK (technical_status IN (N'PENDING', N'PASS', N'FAIL'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_VerificationCase_final_decision_code')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT CK_verification_VerificationCase_final_decision_code CHECK (final_decision_code IS NULL OR final_decision_code IN (N'VERIFIED', N'REJECTED', N'NEEDS_CLARIFICATION'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_verification_VerificationCase_Submission')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT FK_verification_VerificationCase_Submission FOREIGN KEY (submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_verification_VerificationCase_ReviewedByUser')
    ALTER TABLE verification.VerificationCase ADD CONSTRAINT FK_verification_VerificationCase_ReviewedByUser FOREIGN KEY (reviewed_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_AIAnalysisResult_analysis_type_code')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT CK_verification_AIAnalysisResult_analysis_type_code CHECK (analysis_type_code IN (N'SIMILARITY', N'AI_GENERATED', N'AUTO_TAG'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_AIAnalysisResult_confidence_score')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT CK_verification_AIAnalysisResult_confidence_score CHECK (confidence_score >= 0 AND confidence_score <= 1);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_verification_AIAnalysisResult_review_decision_code')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT CK_verification_AIAnalysisResult_review_decision_code CHECK (review_decision_code IS NULL OR review_decision_code IN (N'ACCEPT_FLAG', N'DISMISS_FLAG', N'PENDING_REVIEW'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_verification_AIAnalysisResult_Submission')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT FK_verification_AIAnalysisResult_Submission FOREIGN KEY (submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_verification_AIAnalysisResult_RelatedSubmission')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT FK_verification_AIAnalysisResult_RelatedSubmission FOREIGN KEY (related_submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_verification_AIAnalysisResult_ReviewedByUser')
    ALTER TABLE verification.AIAnalysisResult ADD CONSTRAINT FK_verification_AIAnalysisResult_ReviewedByUser FOREIGN KEY (reviewed_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_judging_JudgeAssignment_round_id_judge_user_id')
    ALTER TABLE judging.JudgeAssignment ADD CONSTRAINT UQ_judging_JudgeAssignment_round_id_judge_user_id UNIQUE (round_id, judge_user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_judging_JudgeAssignment_assignment_status')
    ALTER TABLE judging.JudgeAssignment ADD CONSTRAINT CK_judging_JudgeAssignment_assignment_status CHECK (assignment_status IN (N'ASSIGNED', N'IN_PROGRESS', N'SUBMITTED', N'CANCELLED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_JudgeAssignment_JudgingRound')
    ALTER TABLE judging.JudgeAssignment ADD CONSTRAINT FK_judging_JudgeAssignment_JudgingRound FOREIGN KEY (round_id) REFERENCES contest.JudgingRound (round_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_JudgeAssignment_JudgeUser')
    ALTER TABLE judging.JudgeAssignment ADD CONSTRAINT FK_judging_JudgeAssignment_JudgeUser FOREIGN KEY (judge_user_id) REFERENCES iam.UserAccount (user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_JudgeAssignment_AssignedByUser')
    ALTER TABLE judging.JudgeAssignment ADD CONSTRAINT FK_judging_JudgeAssignment_AssignedByUser FOREIGN KEY (assigned_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_judging_Evaluation_round_id_submission_id_judge_user_id')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT UQ_judging_Evaluation_round_id_submission_id_judge_user_id UNIQUE (round_id, submission_id, judge_user_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_judging_Evaluation_evaluation_status')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT CK_judging_Evaluation_evaluation_status CHECK (evaluation_status IN (N'DRAFT', N'SUBMITTED', N'LOCKED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_judging_Evaluation_total_score')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT CK_judging_Evaluation_total_score CHECK (total_score >= 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_Evaluation_JudgingRound')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT FK_judging_Evaluation_JudgingRound FOREIGN KEY (round_id) REFERENCES contest.JudgingRound (round_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_Evaluation_Submission')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT FK_judging_Evaluation_Submission FOREIGN KEY (submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_Evaluation_JudgeUser')
    ALTER TABLE judging.Evaluation ADD CONSTRAINT FK_judging_Evaluation_JudgeUser FOREIGN KEY (judge_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_judging_EvaluationScore_evaluation_id_criterion_id')
    ALTER TABLE judging.EvaluationScore ADD CONSTRAINT UQ_judging_EvaluationScore_evaluation_id_criterion_id UNIQUE (evaluation_id, criterion_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_EvaluationScore_Evaluation')
    ALTER TABLE judging.EvaluationScore ADD CONSTRAINT FK_judging_EvaluationScore_Evaluation FOREIGN KEY (evaluation_id) REFERENCES judging.Evaluation (evaluation_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_judging_EvaluationScore_ScoringCriterion')
    ALTER TABLE judging.EvaluationScore ADD CONSTRAINT FK_judging_EvaluationScore_ScoringCriterion FOREIGN KEY (criterion_id) REFERENCES contest.ScoringCriterion (criterion_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_result_Result_category_id_submission_id')
    ALTER TABLE result.Result ADD CONSTRAINT UQ_result_Result_category_id_submission_id UNIQUE (category_id, submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_result_Result_category_id_final_rank')
    ALTER TABLE result.Result ADD CONSTRAINT UQ_result_Result_category_id_final_rank UNIQUE (category_id, final_rank);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_result_Result_final_rank')
    ALTER TABLE result.Result ADD CONSTRAINT CK_result_Result_final_rank CHECK (final_rank > 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_result_Result_result_status')
    ALTER TABLE result.Result ADD CONSTRAINT CK_result_Result_result_status CHECK (result_status IN (N'DRAFT', N'FINALIZED', N'PUBLISHED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_Result_ContestCategory')
    ALTER TABLE result.Result ADD CONSTRAINT FK_result_Result_ContestCategory FOREIGN KEY (category_id) REFERENCES contest.ContestCategory (category_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_Result_Submission')
    ALTER TABLE result.Result ADD CONSTRAINT FK_result_Result_Submission FOREIGN KEY (submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_Result_FinalizedByUser')
    ALTER TABLE result.Result ADD CONSTRAINT FK_result_Result_FinalizedByUser FOREIGN KEY (finalized_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_result_AwardAssignment_award_definition_id_result_id')
    ALTER TABLE result.AwardAssignment ADD CONSTRAINT UQ_result_AwardAssignment_award_definition_id_result_id UNIQUE (award_definition_id, result_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_AwardAssignment_AwardDefinition')
    ALTER TABLE result.AwardAssignment ADD CONSTRAINT FK_result_AwardAssignment_AwardDefinition FOREIGN KEY (award_definition_id) REFERENCES contest.AwardDefinition (award_definition_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_AwardAssignment_Result')
    ALTER TABLE result.AwardAssignment ADD CONSTRAINT FK_result_AwardAssignment_Result FOREIGN KEY (result_id) REFERENCES result.Result (result_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_result_AwardAssignment_AssignedByUser')
    ALTER TABLE result.AwardAssignment ADD CONSTRAINT FK_result_AwardAssignment_AssignedByUser FOREIGN KEY (assigned_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_archive_ArchiveItem_result_id')
    ALTER TABLE archive.ArchiveItem ADD CONSTRAINT UQ_archive_ArchiveItem_result_id UNIQUE (result_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_archive_ArchiveItem_archive_status')
    ALTER TABLE archive.ArchiveItem ADD CONSTRAINT CK_archive_ArchiveItem_archive_status CHECK (archive_status IN (N'ARCHIVED', N'RETIRED'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_archive_ArchiveItem_Result')
    ALTER TABLE archive.ArchiveItem ADD CONSTRAINT FK_archive_ArchiveItem_Result FOREIGN KEY (result_id) REFERENCES result.Result (result_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_archive_ArchiveItem_Submission')
    ALTER TABLE archive.ArchiveItem ADD CONSTRAINT FK_archive_ArchiveItem_Submission FOREIGN KEY (submission_id) REFERENCES submission.Submission (submission_id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_archive_ArchiveItem_ArchivedByUser')
    ALTER TABLE archive.ArchiveItem ADD CONSTRAINT FK_archive_ArchiveItem_ArchivedByUser FOREIGN KEY (archived_by_user_id) REFERENCES iam.UserAccount (user_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_audit_AuditLog_ActorUser')
    ALTER TABLE audit.AuditLog ADD CONSTRAINT FK_audit_AuditLog_ActorUser FOREIGN KEY (actor_user_id) REFERENCES iam.UserAccount (user_id);
GO
