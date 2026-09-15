USE FilmContestDB;
GO

PRINT 'TST-UQ-001 - Business unique keys reject duplicates and allow a different contest scope';
BEGIN TRANSACTION;

DECLARE
    @rejected_count INT = 0,
    @registration_id INT,
    @contest_id INT,
    @participant_id INT,
    @roll_id INT,
    @frame_id INT,
    @frame_number INT,
    @submission_id INT,
    @submission_contest_id INT,
    @submission_category_id INT,
    @submission_registration_id INT,
    @evaluation_id INT,
    @evaluation_round_id INT,
    @evaluation_submission_id INT,
    @evaluation_judge_id INT,
    @organizer_user_id INT,
    @unique_contest_id INT,
    @unique_category_id INT,
    @unique_registration_id INT,
    @unique_code NVARCHAR(30);

SELECT TOP (1)
    @registration_id = registration_id,
    @contest_id = contest_id,
    @participant_id = participant_id
FROM participant.Registration
ORDER BY registration_id;

SELECT TOP (1)
    @roll_id = roll_id,
    @frame_id = frame_id,
    @frame_number = frame_number
FROM film.FilmFrame
ORDER BY frame_id;

SELECT TOP (1)
    @submission_id = submission_id,
    @submission_contest_id = contest_id,
    @submission_category_id = category_id,
    @submission_registration_id = registration_id
FROM submission.Submission
ORDER BY submission_id;

SELECT TOP (1)
    @evaluation_id = evaluation_id,
    @evaluation_round_id = round_id,
    @evaluation_submission_id = submission_id,
    @evaluation_judge_id = judge_user_id
FROM judging.Evaluation
ORDER BY evaluation_id;

SELECT TOP (1) @organizer_user_id = created_by_user_id
FROM contest.Contest
ORDER BY contest_id;

IF @registration_id IS NULL OR @roll_id IS NULL OR @submission_id IS NULL OR @evaluation_id IS NULL OR @organizer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70211, 'TST-UQ-001 blocked: required demo fixtures are missing.', 1;
END;

BEGIN TRY
    INSERT INTO participant.Registration (contest_id, participant_id)
    VALUES (@contest_id, @participant_id);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: duplicate registration was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO film.FilmFrame (roll_id, frame_number, frame_status)
    VALUES (@roll_id, @frame_number, N'DRAFT');
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: duplicate frame number within a roll was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO submission.Submission
    (
        registration_id, contest_id, category_id, frame_id,
        submission_title, scanned_image_uri
    )
    SELECT
        registration_id, contest_id, category_id, frame_id,
        submission_title, scanned_image_uri
    FROM submission.Submission
    WHERE submission_id = @submission_id;
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: duplicate submission scope was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id)
    VALUES (@evaluation_round_id, @evaluation_submission_id, @evaluation_judge_id);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: duplicate evaluation scope was rejected.';
END CATCH;

SET @unique_code = N'TST-UQ-' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID())));

INSERT INTO contest.Contest
(
    contest_code, contest_title, contest_theme, contest_summary,
    registration_open_at, registration_close_at,
    submission_open_at, submission_close_at,
    contest_status, created_by_user_id
)
VALUES
(
    @unique_code, N'Unique Scope Test Contest', N'Test', N'Rollback-only uniqueness fixture',
    '2026-01-01T00:00:00', '2026-12-01T23:59:59',
    '2026-01-01T00:00:00', '2026-12-15T23:59:59',
    N'OPEN', @organizer_user_id
);

SET @unique_contest_id = SCOPE_IDENTITY();

INSERT INTO contest.ContestCategory
(
    contest_id, category_code, category_name, category_status, created_by_user_id
)
VALUES
(
    @unique_contest_id, N'TEST', N'Uniqueness Test', N'ACTIVE', @organizer_user_id
);

SET @unique_category_id = SCOPE_IDENTITY();

INSERT INTO participant.Registration
(
    contest_id, participant_id, registration_status, eligibility_status
)
VALUES
(
    @unique_contest_id, @participant_id, N'APPROVED', N'ELIGIBLE'
);

SET @unique_registration_id = SCOPE_IDENTITY();

INSERT INTO submission.Submission
(
    registration_id, contest_id, category_id, frame_id,
    submission_title, scanned_image_uri
)
VALUES
(
    @unique_registration_id, @unique_contest_id, @unique_category_id, @frame_id,
    N'Same frame in a different contest', N'https://test.local/cross-contest.jpg'
);

IF NOT EXISTS
(
    SELECT 1
    FROM submission.Submission
    WHERE contest_id = @unique_contest_id AND frame_id = @frame_id
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70212, 'TST-UQ-001 failed: valid cross-contest frame reuse was not accepted.', 1;
END;

IF @rejected_count <> 4
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70213, 'TST-UQ-001 failed: one or more duplicate business keys were accepted.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: duplicate business keys were rejected and cross-contest frame reuse was accepted.';
GO
