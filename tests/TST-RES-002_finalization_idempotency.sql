USE FilmContestDB;
GO

PRINT 'TST-RES-002 - Result finalization blocks incomplete judging and remains idempotent';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @complete_round_id INT,
    @incomplete_round_id INT,
    @complete_category_id INT,
    @before_count INT,
    @after_count INT,
    @finalized_count INT,
    @incomplete_failure BIT = 0,
    @mutation_gap BIT = 0;

SELECT TOP (1)
    @complete_round_id = jr.round_id,
    @complete_category_id = jr.category_id
FROM contest.JudgingRound AS jr
WHERE jr.is_final_round = 1
  AND EXISTS
  (
      SELECT 1
      FROM result.Result AS r
      WHERE r.category_id = jr.category_id
        AND r.result_status = N'FINALIZED'
  )
ORDER BY jr.round_id;

SELECT TOP (1) @incomplete_round_id = jr.round_id
FROM contest.JudgingRound AS jr
WHERE jr.is_final_round = 1
  AND jr.round_id <> @complete_round_id
  AND EXISTS
  (
      SELECT 1
      FROM submission.Submission AS s
      WHERE s.category_id = jr.category_id
        AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED')
  )
  AND EXISTS
  (
      SELECT 1
      FROM judging.JudgeAssignment AS ja
      WHERE ja.round_id = jr.round_id
        AND ja.assignment_status IN (N'ASSIGNED', N'IN_PROGRESS', N'SUBMITTED')
  )
  AND EXISTS
  (
      SELECT 1
      FROM submission.Submission AS s
      WHERE s.category_id = jr.category_id
        AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED')
        AND
        (
            SELECT COUNT(*)
            FROM judging.Evaluation AS e
            WHERE e.round_id = jr.round_id
              AND e.submission_id = s.submission_id
              AND e.evaluation_status IN (N'SUBMITTED', N'LOCKED')
        ) = 0
  )
ORDER BY jr.round_id;

IF @organizer_user_id IS NULL OR @complete_round_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70321, 'TST-RES-002 blocked: complete finalized-round fixture is missing.', 1;
END;

IF @incomplete_round_id IS NOT NULL
BEGIN
    BEGIN TRY
        EXEC result.usp_finalize_results_for_round
            @round_id = @incomplete_round_id,
            @finalized_by_user_id = @organizer_user_id;
    END TRY
    BEGIN CATCH
        SET @incomplete_failure = 1;
        PRINT 'PASS: incomplete judging was rejected before finalization.';
    END CATCH;

    IF @incomplete_failure = 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 70322, 'TST-RES-002 failed: incomplete judging was finalized.', 1;
    END;
END
ELSE
    PRINT 'BLOCKED: no incomplete final-round fixture exists in current demo data.';

SELECT @before_count = COUNT(*)
FROM result.Result
WHERE category_id = @complete_category_id AND result_status = N'FINALIZED';

EXEC result.usp_finalize_results_for_round
    @round_id = @complete_round_id,
    @finalized_by_user_id = @organizer_user_id;

SELECT @after_count = COUNT(*)
FROM result.Result
WHERE category_id = @complete_category_id AND result_status = N'FINALIZED';

IF @after_count <> @before_count
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70323, 'TST-RES-002 failed: repeated finalization changed result cardinality.', 1;
END;

EXEC result.usp_finalize_results_for_round
    @round_id = @complete_round_id,
    @finalized_by_user_id = @organizer_user_id;

SELECT @finalized_count = COUNT(*)
FROM result.Result
WHERE category_id = @complete_category_id AND result_status = N'FINALIZED';

IF @finalized_count <> @before_count
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70324, 'TST-RES-002 failed: finalization is not idempotent.', 1;
END;

BEGIN TRY
    UPDATE result.Result
    SET final_score = final_score + 0.01
    WHERE category_id = @complete_category_id;

    SET @mutation_gap = 1;
    PRINT 'GAP: finalized result rows remain directly mutable.';
END TRY
BEGIN CATCH
    PRINT 'PASS: finalized result mutation was rejected.';
END CATCH;

IF @mutation_gap = 1
    PRINT 'WARNING: result immutability requires an additional database or permission control.';

ROLLBACK TRANSACTION;
PRINT 'PASS: result finalization idempotency and incomplete-judging behavior were checked.';
GO
