USE FilmContestDB;
GO

PRINT 'TST-INT-003 - Invalid scoring criterion weight must fail';
BEGIN TRANSACTION;

DECLARE
    @expected_failure_observed BIT = 0,
    @criterion_id INT = (SELECT TOP (1) criterion_id FROM contest.ScoringCriterion ORDER BY criterion_id);

BEGIN TRY
    UPDATE contest.ScoringCriterion
    SET weight_percent = 101.00
    WHERE criterion_id = @criterion_id;
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: criterion weight above 100 percent was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70103, 'TST-INT-003 failed: invalid criterion weight was accepted.', 1;
END;

ROLLBACK TRANSACTION;
GO
