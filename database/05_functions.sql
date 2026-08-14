USE FilmContestDB;
GO

CREATE OR ALTER FUNCTION judging.fn_round_max_total_score
(
    @round_id INT
)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @max_total DECIMAL(6,2);

    SELECT @max_total = COALESCE(SUM(score_max_value), 0)
    FROM contest.ScoringCriterion
    WHERE round_id = @round_id
      AND criterion_status = N'ACTIVE';

    RETURN COALESCE(@max_total, 0);
END;
GO
