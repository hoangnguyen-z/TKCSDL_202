USE FilmContestDB;
GO

PRINT 'TST-INT-002 - Invalid submission status must fail';
BEGIN TRANSACTION;

DECLARE
    @expected_failure_observed BIT = 0,
    @submission_id INT = (SELECT TOP (1) submission_id FROM submission.Submission ORDER BY submission_id);

BEGIN TRY
    UPDATE submission.Submission
    SET submission_status = N'NOT_A_VALID_STATUS'
    WHERE submission_id = @submission_id;
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: invalid submission status was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70102, 'TST-INT-002 failed: invalid submission status was accepted.', 1;
END;

ROLLBACK TRANSACTION;
GO
