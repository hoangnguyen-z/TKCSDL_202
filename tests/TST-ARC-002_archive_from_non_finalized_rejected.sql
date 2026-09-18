USE FilmContestDB;
GO

PRINT 'TST-ARC-002 - Archival creation rejected for non-finalized results and duplicates';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @archived_result_id INT = (SELECT TOP (1) result_id FROM archive.ArchiveItem),
    @category_id INT = (SELECT TOP (1) category_id FROM contest.ContestCategory WHERE category_status = N'ACTIVE'),
    @submission_id INT = (SELECT TOP (1) submission_id FROM submission.Submission WHERE submission_status = N'VERIFIED'),
    @draft_result_id INT,
    @expected_failure_observed BIT = 0;

IF @organizer_user_id IS NULL OR @archived_result_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70421, 'TST-ARC-002 blocked: fixtures missing.', 1;
END;

-- 1. Negative test: Attempt archiving an already-archived result
SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC archive.usp_create_archive_item
        @result_id = @archived_result_id,
        @archived_by_user_id = @organizer_user_id,
        @retention_note = N'Duplicate attempt';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 55002
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: duplicate archive creation was rejected with code 55002.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70422, 'TST-ARC-002 failed: duplicate archive creation was accepted or wrong error.', 1;
END;

-- 2. Negative test: Attempt archiving a DRAFT result
IF @category_id IS NOT NULL AND @submission_id IS NOT NULL
BEGIN
    -- Create a temporary DRAFT result
    INSERT INTO result.Result
    (
        category_id, submission_id, final_score, final_rank, result_status
    )
    VALUES
    (
        @category_id, @submission_id, 20.00, 99, N'DRAFT'
    );
    SET @draft_result_id = SCOPE_IDENTITY();

    SET @expected_failure_observed = 0;
    BEGIN TRY
        EXEC archive.usp_create_archive_item
            @result_id = @draft_result_id,
            @archived_by_user_id = @organizer_user_id,
            @retention_note = N'Should fail from draft';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 55001
        BEGIN
            SET @expected_failure_observed = 1;
            PRINT 'PASS: archive creation from DRAFT result was rejected with code 55001.';
        END;
    END CATCH;

    IF @expected_failure_observed = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 70423, 'TST-ARC-002 failed: archive creation from DRAFT result was accepted.', 1;
    END;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: archival creation properly rejects non-finalized results and duplicate entries.';
GO
