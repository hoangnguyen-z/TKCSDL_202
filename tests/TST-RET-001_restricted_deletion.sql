USE FilmContestDB;
GO

PRINT 'TST-RET-001 - Deletion of an archived result must fail';
BEGIN TRANSACTION;

DECLARE
    @expected_failure_observed BIT = 0,
    @result_id INT = (SELECT TOP (1) result_id FROM archive.ArchiveItem ORDER BY archive_item_id);

IF @result_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70105, 'TST-RET-001 cannot run: seeded archive item is missing.', 1;
END;

BEGIN TRY
    DELETE FROM result.Result
    WHERE result_id = @result_id;
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: archived result deletion was blocked by retention foreign key as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70106, 'TST-RET-001 failed: archived result was deleted.', 1;
END;

ROLLBACK TRANSACTION;
GO
