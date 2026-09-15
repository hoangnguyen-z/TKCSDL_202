USE FilmContestDB;
GO

PRINT 'TST-BOUNDARY-001 - Status, score, weight, rank and date boundaries';
BEGIN TRANSACTION;

DECLARE
    @rejected_count INT = 0,
    @score_gap BIT = 0,
    @submission_id INT = (SELECT TOP (1) submission_id FROM submission.Submission ORDER BY submission_id),
    @criterion_id INT = (SELECT TOP (1) criterion_id FROM contest.ScoringCriterion ORDER BY criterion_id),
    @result_id INT = (SELECT TOP (1) result_id FROM result.Result ORDER BY result_id),
    @contest_id INT = (SELECT TOP (1) contest_id FROM contest.Contest ORDER BY contest_id),
    @evaluation_score_id INT = (SELECT TOP (1) evaluation_score_id FROM judging.EvaluationScore ORDER BY evaluation_score_id),
    @score_max DECIMAL(5,2),
    @score_value DECIMAL(5,2);

IF @submission_id IS NULL OR @criterion_id IS NULL OR @result_id IS NULL OR @contest_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70221, 'TST-BOUNDARY-001 blocked: required demo fixtures are missing.', 1;
END;

BEGIN TRY
    UPDATE submission.Submission
    SET submission_status = N'INVALID_STATUS'
    WHERE submission_id = @submission_id;
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: invalid submission status was rejected.';
END CATCH;

BEGIN TRY
    UPDATE contest.ScoringCriterion
    SET weight_percent = 0.00
    WHERE criterion_id = @criterion_id;
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: zero criterion weight was rejected.';
END CATCH;

BEGIN TRY
    UPDATE result.Result
    SET final_rank = 0
    WHERE result_id = @result_id;
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: zero final rank was rejected.';
END CATCH;

BEGIN TRY
    UPDATE contest.Contest
    SET registration_open_at = registration_close_at,
        registration_close_at = DATEADD(DAY, -1, registration_open_at)
    WHERE contest_id = @contest_id;
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: invalid registration date window was rejected.';
END CATCH;

IF @evaluation_score_id IS NOT NULL
BEGIN
    SELECT
        @score_max = c.score_max_value,
        @score_value = s.score_value
    FROM judging.EvaluationScore AS s
    INNER JOIN contest.ScoringCriterion AS c ON c.criterion_id = s.criterion_id
    WHERE s.evaluation_score_id = @evaluation_score_id;

    BEGIN TRY
        UPDATE judging.EvaluationScore
        SET score_value = @score_max + 1.00
        WHERE evaluation_score_id = @evaluation_score_id;

        SET @score_gap = 1;
        PRINT 'GAP: score outside the criterion range was accepted; no direct CHECK constraint currently enforces it.';
    END TRY
    BEGIN CATCH
        PRINT 'PASS: score above the criterion maximum was rejected.';
    END CATCH;
END;

IF @rejected_count <> 4
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70222, 'TST-BOUNDARY-001 failed: one or more declared status/weight/rank/date boundaries were accepted.', 1;
END;

IF @score_gap = 0
    PRINT 'PASS: score boundary is enforced.';

ROLLBACK TRANSACTION;
PRINT 'PASS: declared status, weight, rank and date boundary checks completed.';
GO
