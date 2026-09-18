USE FilmContestDB;
GO

PRINT 'TST-CONC-003 - Concurrency simulation for duplicate judge evaluation race condition';

DECLARE
    @round_id INT = (SELECT TOP (1) round_id FROM contest.JudgingRound WHERE round_status IN (N'OPEN', N'DRAFT')),
    @submission_id INT = (SELECT TOP (1) submission_id FROM submission.Submission WHERE submission_status = N'VERIFIED'),
    @judge_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'quang.judge@filmplatform.local'),
    @eval1_id INT,
    @eval1_success BIT = 0,
    @eval2_failure BIT = 0;

IF @round_id IS NULL OR @submission_id IS NULL OR @judge_user_id IS NULL
BEGIN
    THROW 70475, 'TST-CONC-003 blocked: required round, submission, or judge fixture is missing.', 1;
END;

-- Clean up any existing evaluation for this fixture
DELETE FROM judging.EvaluationScore WHERE evaluation_id IN (
    SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @round_id AND submission_id = @submission_id AND judge_user_id = @judge_user_id
);
DELETE FROM judging.Evaluation WHERE round_id = @round_id AND submission_id = @submission_id AND judge_user_id = @judge_user_id;

-- Session 1: Inserts evaluation in active transaction
BEGIN TRANSACTION;

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score)
VALUES (@round_id, @submission_id, @judge_user_id, N'DRAFT', 0.00);
SET @eval1_id = SCOPE_IDENTITY();
SET @eval1_success = 1;

-- Session 2 simulation: Concurrent attempt to insert evaluation for same (round_id, submission_id, judge_user_id)
BEGIN TRY
    INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score)
    VALUES (@round_id, @submission_id, @judge_user_id, N'DRAFT', 0.00);
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() IN (2627, 2601)
    BEGIN
        SET @eval2_failure = 1;
        PRINT 'PASS: concurrent duplicate evaluation was rejected by unique constraint (2627/2601).';
    END;
END CATCH;

COMMIT TRANSACTION;

-- Clean up test evaluation
DELETE FROM judging.Evaluation WHERE evaluation_id = @eval1_id;

IF @eval1_success = 1 AND @eval2_failure = 1
    PRINT 'PASS: concurrency test verified unique judge evaluation protection against double-evaluation.';
ELSE
    THROW 70473, 'TST-CONC-003 failed: concurrent duplicate evaluation was accepted.', 1;
GO
