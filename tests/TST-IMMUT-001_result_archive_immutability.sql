USE FilmContestDB;
GO

PRINT 'TST-IMMUT-001 - Enforcement of Result and Archive immutability';

DECLARE
    @published_result_id INT = (SELECT TOP (1) result_id FROM result.Result WHERE result_status = N'PUBLISHED'),
    @archive_item_id INT = (SELECT TOP (1) archive_item_id FROM archive.ArchiveItem),
    @expected_failure_observed BIT = 0;

IF @published_result_id IS NULL OR @archive_item_id IS NULL
BEGIN
    THROW 70431, 'TST-IMMUT-001 blocked: published result or archive item fixture is missing.', 1;
END;

-- 1. Negative test: Attempt to DELETE a published/finalized result
SET @expected_failure_observed = 0;
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM result.Result
    WHERE result_id = @published_result_id;
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: deleting a published result was blocked by trigger/FK as expected.';
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

IF @expected_failure_observed = 0
BEGIN
    THROW 70432, 'TST-IMMUT-001 failed: published result deletion was permitted.', 1;
END;

-- 2. Negative test: Attempt to modify score/rank of a published result
SET @expected_failure_observed = 0;
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE result.Result
    SET final_score = 99.99
    WHERE result_id = @published_result_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 54011
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: score alteration on published result was blocked with code 54011.';
    END;
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

IF @expected_failure_observed = 0
BEGIN
    THROW 70433, 'TST-IMMUT-001 failed: published result score was modified.', 1;
END;

-- 3. Negative test: Attempt to UPDATE archive.ArchiveItem
SET @expected_failure_observed = 0;
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE archive.ArchiveItem
    SET retention_note = N'Illegitimate update attempt'
    WHERE archive_item_id = @archive_item_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 55010
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: updating ArchiveItem was blocked by trigger with code 55010.';
    END;
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

IF @expected_failure_observed = 0
BEGIN
    THROW 70434, 'TST-IMMUT-001 failed: ArchiveItem was modified.', 1;
END;

-- 4. Negative test: Attempt to DELETE archive.ArchiveItem
SET @expected_failure_observed = 0;
BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM archive.ArchiveItem
    WHERE archive_item_id = @archive_item_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 55010
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: deleting ArchiveItem was blocked by trigger with code 55010.';
    END;
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

IF @expected_failure_observed = 0
BEGIN
    THROW 70435, 'TST-IMMUT-001 failed: ArchiveItem was deleted.', 1;
END;

PRINT 'PASS: result and archive immutability rules are fully enforced.';
GO
