USE FilmContestDB;
GO

PRINT 'TST-VER-001 - Human review should resolve AI-flagged submission';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @submission_id INT = (
            SELECT s.submission_id
            FROM submission.Submission AS s
            INNER JOIN contest.Contest AS c
                ON c.contest_id = s.contest_id
            INNER JOIN contest.ContestCategory AS cc
                ON cc.category_id = s.category_id
            WHERE c.contest_code = N'FILM2026-FALL'
              AND cc.category_code = N'STREET'
              AND s.submission_title = N'Morning Market'
        ),
        @reviewer_user_id INT = (
            SELECT user_id
            FROM iam.UserAccount
            WHERE email = N'olivia.organizer@filmplatform.local'
        );

    EXEC verification.usp_record_verification_decision
        @submission_id = @submission_id,
        @reviewed_by_user_id = @reviewer_user_id,
        @completeness_status = N'PASS',
        @technical_status = N'PASS',
        @final_decision_code = N'VERIFIED',
        @review_notes = N'AI flag reviewed manually and accepted.';

    IF NOT EXISTS (
        SELECT 1
        FROM verification.VerificationCase
        WHERE submission_id = @submission_id
          AND verification_status = N'VERIFIED'
          AND final_decision_code = N'VERIFIED'
    )
        THROW 70006, 'Verification case was not updated correctly.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM submission.Submission
        WHERE submission_id = @submission_id
          AND submission_status = N'VERIFIED'
    )
        THROW 70007, 'Submission status was not updated correctly.', 1;

    PRINT 'PASS: AI-flagged submission was resolved by human review.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
