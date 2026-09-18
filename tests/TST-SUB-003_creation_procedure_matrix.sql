USE FilmContestDB;
GO

PRINT 'TST-SUB-003 - Submission creation procedure accepts valid input and rejects invalid cases';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @lan_participant_id INT,
    @bao_participant_id INT,
    @lan_frame_id INT,
    @bao_frame_id INT,
    @contest_id INT,
    @expired_contest_id INT,
    @category_id INT,
    @expired_category_id INT,
    @lan_registration_id INT,
    @pending_registration_id INT,
    @expired_registration_id INT,
    @created_submission_id INT,
    @rejected_count INT = 0,
    @contest_code NVARCHAR(30) = N'TST-SUB-' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID()))),
    @expired_contest_code NVARCHAR(30) = N'TST-EXP-' + CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID())));

SELECT @lan_participant_id = participant_id
FROM participant.ParticipantProfile AS p
INNER JOIN iam.UserAccount AS u ON u.user_id = p.user_id
WHERE u.email = N'lan.participant@filmplatform.local';

SELECT @bao_participant_id = participant_id
FROM participant.ParticipantProfile AS p
INNER JOIN iam.UserAccount AS u ON u.user_id = p.user_id
WHERE u.email = N'bao.participant@filmplatform.local';

SELECT TOP (1) @lan_frame_id = ff.frame_id
FROM film.FilmFrame AS ff
INNER JOIN film.FilmRoll AS fr ON fr.roll_id = ff.roll_id
WHERE fr.participant_id = @lan_participant_id
ORDER BY ff.frame_id;

SELECT TOP (1) @bao_frame_id = ff.frame_id
FROM film.FilmFrame AS ff
INNER JOIN film.FilmRoll AS fr ON fr.roll_id = ff.roll_id
WHERE fr.participant_id = @bao_participant_id
ORDER BY ff.frame_id;

IF @organizer_user_id IS NULL OR @lan_participant_id IS NULL OR @bao_participant_id IS NULL OR @lan_frame_id IS NULL OR @bao_frame_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70301, 'TST-SUB-003 blocked: required participant and frame fixtures are missing.', 1;
END;

INSERT INTO contest.Contest
(
    contest_code, contest_title, contest_theme, contest_summary,
    registration_open_at, registration_close_at,
    submission_open_at, submission_close_at,
    contest_status, created_by_user_id
)
VALUES
(
    @contest_code, N'Submission Procedure Test', N'Test', N'Rollback-only fixture',
    DATEADD(DAY, -2, SYSUTCDATETIME()), DATEADD(DAY, 2, SYSUTCDATETIME()),
    DATEADD(DAY, -1, SYSUTCDATETIME()), DATEADD(DAY, 1, SYSUTCDATETIME()),
    N'OPEN', @organizer_user_id
);
SET @contest_id = SCOPE_IDENTITY();

INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_status, created_by_user_id)
VALUES (@contest_id, N'TEST', N'Submission Test', N'ACTIVE', @organizer_user_id);
SET @category_id = SCOPE_IDENTITY();

INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
VALUES (@contest_id, @lan_participant_id, N'APPROVED', N'ELIGIBLE');
SET @lan_registration_id = SCOPE_IDENTITY();

INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
VALUES (@contest_id, @bao_participant_id, N'PENDING', N'PENDING');
SET @pending_registration_id = SCOPE_IDENTITY();

INSERT INTO contest.Contest
(
    contest_code, contest_title, contest_theme, contest_summary,
    registration_open_at, registration_close_at,
    submission_open_at, submission_close_at,
    contest_status, created_by_user_id
)
VALUES
(
    @expired_contest_code, N'Expired Submission Test', N'Test', N'Rollback-only fixture',
    DATEADD(DAY, -10, SYSUTCDATETIME()), DATEADD(DAY, -5, SYSUTCDATETIME()),
    DATEADD(DAY, -4, SYSUTCDATETIME()), DATEADD(DAY, -1, SYSUTCDATETIME()),
    N'CLOSED', @organizer_user_id
);
SET @expired_contest_id = SCOPE_IDENTITY();

INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_status, created_by_user_id)
VALUES (@expired_contest_id, N'EXPIRED', N'Expired Test', N'ACTIVE', @organizer_user_id);
SET @expired_category_id = SCOPE_IDENTITY();

INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
VALUES (@expired_contest_id, @lan_participant_id, N'APPROVED', N'ELIGIBLE');
SET @expired_registration_id = SCOPE_IDENTITY();

DECLARE @created TABLE (submission_id INT);
INSERT INTO @created
EXEC submission.usp_create_submission
    @registration_id = @lan_registration_id,
    @category_id = @category_id,
    @frame_id = @lan_frame_id,
    @submission_title = N'Valid procedure fixture',
    @submission_statement = N'Valid submission path.',
    @scanned_image_uri = N'https://test.local/valid-procedure.jpg';

SELECT @created_submission_id = submission_id FROM @created;

IF @created_submission_id IS NULL OR NOT EXISTS
(
    SELECT 1 FROM verification.VerificationCase
    WHERE submission_id = @created_submission_id AND verification_status = N'PENDING'
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70302, 'TST-SUB-003 failed: valid submission did not create verification case.', 1;
END;

BEGIN TRY
    EXEC submission.usp_create_submission
        @registration_id = @lan_registration_id,
        @category_id = @category_id,
        @frame_id = @bao_frame_id,
        @submission_title = N'Wrong owner fixture',
        @scanned_image_uri = N'https://test.local/wrong-owner.jpg';
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: frame owner mismatch was rejected.';
END CATCH;

BEGIN TRY
    EXEC submission.usp_create_submission
        @registration_id = @pending_registration_id,
        @category_id = @category_id,
        @frame_id = @bao_frame_id,
        @submission_title = N'Invalid status fixture',
        @scanned_image_uri = N'https://test.local/invalid-status.jpg';
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: non-approved registration was rejected.';
END CATCH;

BEGIN TRY
    EXEC submission.usp_create_submission
        @registration_id = @lan_registration_id,
        @category_id = @category_id,
        @frame_id = @lan_frame_id,
        @submission_title = N'Duplicate contest frame fixture',
        @scanned_image_uri = N'https://test.local/duplicate-frame.jpg';
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: duplicate frame in the same contest was rejected.';
END CATCH;

BEGIN TRY
    EXEC submission.usp_create_submission
        @registration_id = @expired_registration_id,
        @category_id = @expired_category_id,
        @frame_id = @lan_frame_id,
        @submission_title = N'Late procedure fixture',
        @scanned_image_uri = N'https://test.local/late.jpg';
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: expired submission window was rejected.';
END CATCH;

IF @rejected_count <> 4
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70303, 'TST-SUB-003 failed: one or more invalid submission cases were accepted.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: valid, owner, duplicate, status and deadline submission paths were verified.';
GO
