USE FilmContestDB;
GO

PRINT 'TST-INT-001 - Invalid foreign key must fail';
BEGIN TRANSACTION;

DECLARE @expected_failure_observed BIT = 0;

BEGIN TRY
    INSERT INTO film.FilmFrame (roll_id, frame_number, frame_status)
    VALUES (-999999, 9901, N'DRAFT');
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: invalid FilmRoll foreign key was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70101, 'TST-INT-001 failed: invalid foreign key was accepted.', 1;
END;

ROLLBACK TRANSACTION;
GO
