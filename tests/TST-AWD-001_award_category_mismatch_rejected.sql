USE FilmContestDB;
GO

PRINT 'TST-AWD-001 - Award-Category mapping integrity and mismatch rejection';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @spring_result_id INT = (
        SELECT TOP (1) r.result_id
        FROM result.Result AS r
        INNER JOIN contest.ContestCategory AS cc ON cc.category_id = r.category_id
        WHERE cc.category_code = N'LANDSCAPE'
          AND r.result_status = N'PUBLISHED'
    ),
    @portrait_award_id INT = (
        SELECT TOP (1) ad.award_definition_id
        FROM contest.AwardDefinition AS ad
        INNER JOIN contest.ContestCategory AS cc ON cc.category_id = ad.category_id
        WHERE cc.category_code = N'PORTRAIT'
    ),
    @expected_failure_observed BIT = 0;

IF @spring_result_id IS NULL OR @portrait_award_id IS NULL OR @organizer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70451, 'TST-AWD-001 blocked: result or award fixtures are missing.', 1;
END;

-- 1. Negative test via procedure: Assign PORTRAIT award to LANDSCAPE result
SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC result.usp_assign_award
        @award_definition_id = @portrait_award_id,
        @result_id = @spring_result_id,
        @assigned_by_user_id = @organizer_user_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 54103
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: cross-category award assignment via procedure was blocked with code 54103.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70452, 'TST-AWD-001 failed: cross-category award assignment procedure succeeded.', 1;
END;

-- 2. Negative test via direct INSERT: Trigger TR_AwardAssignment_BIU_CheckCategoryMatch must block
SET @expected_failure_observed = 0;
BEGIN TRY
    INSERT INTO result.AwardAssignment
    (
        award_definition_id,
        result_id,
        assigned_by_user_id
    )
    VALUES
    (
        @portrait_award_id,
        @spring_result_id,
        @organizer_user_id
    );
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 54105
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: cross-category award direct insert was blocked by trigger with code 54105.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70453, 'TST-AWD-001 failed: cross-category award direct insert bypassed trigger.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: award-category mapping is strictly enforced at procedure and trigger levels.';
GO
