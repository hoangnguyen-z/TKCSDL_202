USE FilmContestDB;
GO

PRINT 'TST-INT-004 - Invalid contest submission date window must fail';
BEGIN TRANSACTION;

DECLARE
    @expected_failure_observed BIT = 0,
    @contest_id INT = (SELECT TOP (1) contest_id FROM contest.Contest ORDER BY contest_id);

BEGIN TRY
    UPDATE contest.Contest
    SET submission_open_at = DATEADD(DAY, 1, submission_close_at)
    WHERE contest_id = @contest_id;
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: reversed submission date window was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70104, 'TST-INT-004 failed: invalid submission date window was accepted.', 1;
END;

ROLLBACK TRANSACTION;
GO
