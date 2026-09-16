USE FilmContestDB;
GO

PRINT 'TST-VER-002 - Human verification gate preserves AI evidence and protects terminal state';
BEGIN TRANSACTION;

DECLARE
    @submission_id INT,
    @reviewer_user_id INT,
    @ai_result_id INT,
    @expected_failure BIT = 0,
    @terminal_protection_gap BIT = 0;

SELECT TOP (1) @submission_id = s.submission_id
FROM submission.Submission AS s
INNER JOIN contest.Contest AS c ON c.contest_id = s.contest_id
WHERE c.contest_code = N'FILM2026-FALL'
ORDER BY s.submission_id;

SELECT @reviewer_user_id = user_id
FROM iam.UserAccount
WHERE email = N'olivia.organizer@filmplatform.local';

IF @submission_id IS NULL OR @reviewer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70311, 'TST-VER-002 blocked: seeded submission or reviewer is missing.', 1;
END;

BEGIN TRY
    EXEC verification.usp_record_verification_decision
        @submission_id = -903111,
        @reviewed_by_user_id = @reviewer_user_id,
        @completeness_status = N'PASS',
        @technical_status = N'PASS',
        @final_decision_code = N'VERIFIED',
        @review_notes = N'Nonexistent submission should fail.';
END TRY
BEGIN CATCH
    SET @expected_failure = 1;
    PRINT 'PASS: nonexistent submission cannot receive a verification decision.';
END CATCH;

IF @expected_failure = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70312, 'TST-VER-002 failed: nonexistent submission was accepted.', 1;
END;

INSERT INTO verification.AIAnalysisResult
(
    submission_id,
    analysis_type_code,
    analysis_outcome_code,
    confidence_score,
    model_name,
    model_version,
    review_decision_code,
    analysis_summary
)
VALUES
(
    @submission_id,
    N'AI_GENERATED',
    N'FLAGGED',
    0.9900,
    N'TestModel',
    N'1.0',
    N'PENDING_REVIEW',
    N'AI flag must remain advisory.'
);

SET @ai_result_id = SCOPE_IDENTITY();

EXEC verification.usp_record_verification_decision
    @submission_id = @submission_id,
    @reviewed_by_user_id = @reviewer_user_id,
    @completeness_status = N'PASS',
    @technical_status = N'PASS',
    @final_decision_code = N'VERIFIED',
    @review_notes = N'Human reviewer made the final decision.';

IF NOT EXISTS
(
    SELECT 1
    FROM verification.AIAnalysisResult
    WHERE ai_result_id = @ai_result_id
      AND review_decision_code = N'PENDING_REVIEW'
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70313, 'TST-VER-002 failed: AI advisory evidence was changed by human decision procedure.', 1;
END;

BEGIN TRY
    EXEC verification.usp_record_verification_decision
        @submission_id = @submission_id,
        @reviewed_by_user_id = @reviewer_user_id,
        @completeness_status = N'FAIL',
        @technical_status = N'FAIL',
        @final_decision_code = N'REJECTED',
        @review_notes = N'Terminal verification state should not be overwritten.';
END TRY
BEGIN CATCH
    PRINT 'PASS: terminal verification state rejected a second decision.';
END CATCH;

IF EXISTS
(
    SELECT 1
    FROM verification.VerificationCase
    WHERE submission_id = @submission_id
      AND final_decision_code = N'REJECTED'
)
BEGIN
    SET @terminal_protection_gap = 1;
    PRINT 'GAP: terminal verification state was overwritten by a second decision.';
END;

IF @terminal_protection_gap = 1
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70314, 'TST-VER-002 failed: terminal verification state is mutable.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: AI result remained advisory and human verification terminal state was protected.';
GO
