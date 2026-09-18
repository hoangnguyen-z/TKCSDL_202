USE FilmContestDB;
GO

PRINT 'TST-PUB-001 - Publication completeness enforcement for contest lifecycle';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @contest_id INT,
    @cat_id INT,
    @round_id INT,
    @crit_id INT,
    @award_id INT,
    @expected_failure_observed BIT = 0,
    @test_code NVARCHAR(30) = N'TST-PUB-' + CONVERT(NVARCHAR(10), ABS(CHECKSUM(NEWID())));

IF @organizer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70441, 'TST-PUB-001 blocked: organizer fixture missing.', 1;
END;

-- Step 1: Contest with no categories
INSERT INTO contest.Contest
(
    contest_code, contest_title, registration_open_at, registration_close_at,
    submission_open_at, submission_close_at, contest_status, created_by_user_id
)
VALUES
(
    @test_code, N'Publication Test Contest',
    '2026-11-01T00:00:00', '2026-11-15T23:59:59',
    '2026-11-05T00:00:00', '2026-11-20T23:59:59',
    N'DRAFT', @organizer_user_id
);
SET @contest_id = SCOPE_IDENTITY();

-- Expect failure: No categories
SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC contest.usp_publish_contest @contest_id = @contest_id, @published_by_user_id = @organizer_user_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51202
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: publishing contest without category was rejected with code 51202.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70442, 'TST-PUB-001 failed: contest published without categories.', 1;
END;

-- Step 2: Add category, but no rounds
INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_status, created_by_user_id)
VALUES (@contest_id, N'CAT1', N'Category 1', N'ACTIVE', @organizer_user_id);
SET @cat_id = SCOPE_IDENTITY();

SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC contest.usp_publish_contest @contest_id = @contest_id, @published_by_user_id = @organizer_user_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51203
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: publishing contest without judging round was rejected with code 51203.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70443, 'TST-PUB-001 failed: contest published without judging round.', 1;
END;

-- Step 3: Add round, but no criteria
INSERT INTO contest.JudgingRound
(
    category_id, round_number, round_name, round_sequence, round_status,
    evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
)
VALUES
(
    @cat_id, 1, N'Round 1', 1, N'DRAFT',
    '2026-11-21T00:00:00', '2026-11-25T23:59:59', 1, @organizer_user_id
);
SET @round_id = SCOPE_IDENTITY();

SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC contest.usp_publish_contest @contest_id = @contest_id, @published_by_user_id = @organizer_user_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51204
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: publishing contest without scoring criteria was rejected with code 51204.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70444, 'TST-PUB-001 failed: contest published without scoring criteria.', 1;
END;

-- Step 4: Add criteria, but no awards
INSERT INTO contest.ScoringCriterion
(
    round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, created_by_user_id
)
VALUES
(
    @round_id, N'CRIT1', N'Criterion 1', 100.00, 0.00, 10.00, @organizer_user_id
);
SET @crit_id = SCOPE_IDENTITY();

SET @expected_failure_observed = 0;
BEGIN TRY
    EXEC contest.usp_publish_contest @contest_id = @contest_id, @published_by_user_id = @organizer_user_id;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51205
    BEGIN
        SET @expected_failure_observed = 1;
        PRINT 'PASS: publishing contest without award definition was rejected with code 51205.';
    END;
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70445, 'TST-PUB-001 failed: contest published without award definitions.', 1;
END;

-- Step 5: Add award -> publishing must SUCCEED
INSERT INTO contest.AwardDefinition
(
    category_id, award_code, award_name, rank_order, award_type, created_by_user_id
)
VALUES
(
    @cat_id, N'FIRST', N'First Place', 1, N'MAJOR', @organizer_user_id
);
SET @award_id = SCOPE_IDENTITY();

EXEC contest.usp_publish_contest @contest_id = @contest_id, @published_by_user_id = @organizer_user_id;

IF NOT EXISTS (SELECT 1 FROM contest.Contest WHERE contest_id = @contest_id AND contest_status = N'PUBLISHED')
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70446, 'TST-PUB-001 failed: contest status was not set to PUBLISHED.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: publication completeness checks verified all mandatory configuration prerequisites.';
GO
