USE FilmContestDB;
GO

PRINT 'TST-CONC-002 - Concurrency simulation for duplicate submission race condition';

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @contest_id INT,
    @category_id INT,
    @participant_id INT,
    @roll_id INT,
    @frame_id INT,
    @reg_id INT,
    @sub1_success BIT = 0,
    @sub2_failure BIT = 0,
    @test_code NVARCHAR(30) = N'CONC-SUB-' + CONVERT(NVARCHAR(10), ABS(CHECKSUM(NEWID())));

-- Setup test contest
INSERT INTO contest.Contest
(
    contest_code, contest_title, registration_open_at, registration_close_at,
    submission_open_at, submission_close_at, contest_status, created_by_user_id
)
VALUES
(
    @test_code, N'Concurrent Submission Test',
    DATEADD(DAY, -5, SYSUTCDATETIME()), DATEADD(DAY, 5, SYSUTCDATETIME()),
    DATEADD(DAY, -2, SYSUTCDATETIME()), DATEADD(DAY, 10, SYSUTCDATETIME()),
    N'OPEN', @organizer_user_id
);
SET @contest_id = SCOPE_IDENTITY();

INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_status, created_by_user_id)
VALUES (@contest_id, N'STREET', N'Street', N'ACTIVE', @organizer_user_id);
SET @category_id = SCOPE_IDENTITY();

-- Create test user, profile, film roll, and frame
INSERT INTO iam.UserAccount (email, username, display_name)
VALUES (@test_code + N'@test.local', @test_code, N'Concurrent Submitter');
DECLARE @test_user_id INT = SCOPE_IDENTITY();

INSERT INTO participant.ParticipantProfile (user_id, display_name)
VALUES (@test_user_id, N'Concurrent Submitter');
SET @participant_id = SCOPE_IDENTITY();

INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
VALUES (@contest_id, @participant_id, N'APPROVED', N'ELIGIBLE');
SET @reg_id = SCOPE_IDENTITY();

INSERT INTO film.FilmRoll (participant_id, roll_code, film_format_code, roll_status)
VALUES (@participant_id, @test_code, N'35MM', N'READY');
SET @roll_id = SCOPE_IDENTITY();

INSERT INTO film.FilmFrame (roll_id, frame_number, frame_title, frame_status)
VALUES (@roll_id, 1, N'Concurrent Frame', N'READY');
SET @frame_id = SCOPE_IDENTITY();

-- Session 1: Submits frame via stored procedure inside transaction
BEGIN TRANSACTION;

EXEC submission.usp_create_submission
    @registration_id = @reg_id,
    @category_id = @category_id,
    @frame_id = @frame_id,
    @submission_title = N'Submission 1',
    @scanned_image_uri = N'https://storage.test/sub1.jpg';
SET @sub1_success = 1;

-- Session 2 simulation: Attempting to submit the exact same frame concurrently
BEGIN TRY
    EXEC submission.usp_create_submission
        @registration_id = @reg_id,
        @category_id = @category_id,
        @frame_id = @frame_id,
        @submission_title = N'Submission 2 Concurrent',
        @scanned_image_uri = N'https://storage.test/sub2.jpg';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 51007 OR ERROR_NUMBER() IN (2627, 2601)
    BEGIN
        SET @sub2_failure = 1;
        PRINT 'PASS: concurrent duplicate submission was rejected by frame uniqueness check.';
    END;
END CATCH;

COMMIT TRANSACTION;

-- Cleanup test fixtures
DELETE FROM audit.AuditLog WHERE entity_name IN (N'submission.Submission', N'verification.VerificationCase');
DELETE FROM verification.VerificationCase WHERE submission_id IN (SELECT submission_id FROM submission.Submission WHERE contest_id = @contest_id);
DELETE FROM submission.Submission WHERE contest_id = @contest_id;
DELETE FROM film.FilmFrame WHERE roll_id = @roll_id;
DELETE FROM film.FilmRoll WHERE roll_id = @roll_id;
DELETE FROM participant.Registration WHERE contest_id = @contest_id;
DELETE FROM participant.ParticipantProfile WHERE participant_id = @participant_id;
DELETE FROM iam.UserAccount WHERE user_id = @test_user_id;
DELETE FROM contest.ContestCategory WHERE contest_id = @contest_id;
DELETE FROM contest.Contest WHERE contest_id = @contest_id;

IF @sub1_success = 1 AND @sub2_failure = 1
    PRINT 'PASS: concurrent submission race condition prevented double-submission of identical film frame.';
ELSE
    THROW 70472, 'TST-CONC-002 failed: duplicate submission was accepted during concurrency simulation.', 1;
GO
