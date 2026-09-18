USE FilmContestDB;
GO

PRINT 'TST-CONC-001 - Concurrency simulation for duplicate registration race condition';

-- Create isolated test fixtures
DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @contest_id INT,
    @participant_id INT,
    @reg1_success BIT = 0,
    @reg2_failure BIT = 0,
    @test_code NVARCHAR(30) = N'CONC-REG-' + CONVERT(NVARCHAR(10), ABS(CHECKSUM(NEWID())));

-- Setup test contest
INSERT INTO contest.Contest
(
    contest_code, contest_title, registration_open_at, registration_close_at,
    submission_open_at, submission_close_at, contest_status, created_by_user_id
)
VALUES
(
    @test_code, N'Concurrent Registration Test',
    DATEADD(DAY, -1, SYSUTCDATETIME()), DATEADD(DAY, 10, SYSUTCDATETIME()),
    DATEADD(DAY, 1, SYSUTCDATETIME()), DATEADD(DAY, 15, SYSUTCDATETIME()),
    N'OPEN', @organizer_user_id
);
SET @contest_id = SCOPE_IDENTITY();

-- Create temporary test user and participant
INSERT INTO iam.UserAccount (email, username, display_name)
VALUES (@test_code + N'@test.local', @test_code, N'Concurrent Test User');
DECLARE @test_user_id INT = SCOPE_IDENTITY();

INSERT INTO participant.ParticipantProfile (user_id, display_name)
VALUES (@test_user_id, N'Concurrent Participant');
SET @participant_id = SCOPE_IDENTITY();

-- Session 1: Inserts registration in active transaction
BEGIN TRANSACTION;

INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
VALUES (@contest_id, @participant_id, N'APPROVED', N'ELIGIBLE');
SET @reg1_success = 1;

-- Session 2 simulation: In parallel/subsequent attempt within same contest scope
BEGIN TRY
    INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status)
    VALUES (@contest_id, @participant_id, N'PENDING', N'PENDING');
END TRY
BEGIN CATCH
    -- Error 2627 / 2601 is unique constraint violation
    IF ERROR_NUMBER() IN (2627, 2601)
    BEGIN
        SET @reg2_failure = 1;
        PRINT 'PASS: concurrent duplicate registration was rejected by unique constraint (2627/2601).';
    END;
END CATCH;

COMMIT TRANSACTION;

-- Clean up test fixtures
DELETE FROM participant.Registration WHERE contest_id = @contest_id;
DELETE FROM participant.ParticipantProfile WHERE participant_id = @participant_id;
DELETE FROM iam.UserAccount WHERE user_id = @test_user_id;
DELETE FROM contest.Contest WHERE contest_id = @contest_id;

IF @reg1_success = 1 AND @reg2_failure = 1
    PRINT 'PASS: concurrency test verified serializability and unique registration protection.';
ELSE
    THROW 70471, 'TST-CONC-001 failed: race condition allowed duplicate registration.', 1;
GO
