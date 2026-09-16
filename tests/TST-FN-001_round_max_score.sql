USE FilmContestDB;
GO

PRINT 'TST-FN-001 - Round maximum score function matches expected aggregate values';

DECLARE @mismatch_count INT = 0;

IF judging.fn_round_max_total_score(NULL) <> 0
BEGIN
    THROW 70331, 'TST-FN-001 failed: NULL round did not return zero.', 1;
END;

IF judging.fn_round_max_total_score(-903301) <> 0
BEGIN
    THROW 70332, 'TST-FN-001 failed: unknown round did not return zero.', 1;
END;

;WITH Expected AS
(
    SELECT
        jr.round_id,
        CAST(COALESCE(SUM(CASE WHEN sc.criterion_status = N'ACTIVE' THEN sc.score_max_value ELSE 0 END), 0) AS DECIMAL(6,2)) AS expected_total
    FROM contest.JudgingRound AS jr
    LEFT JOIN contest.ScoringCriterion AS sc ON sc.round_id = jr.round_id
    GROUP BY jr.round_id
), Actual AS
(
    SELECT
        e.round_id,
        e.expected_total,
        judging.fn_round_max_total_score(e.round_id) AS actual_total
    FROM Expected AS e
)
SELECT @mismatch_count = COUNT(*)
FROM Actual
WHERE actual_total <> expected_total;

IF @mismatch_count <> 0
    THROW 70333, 'TST-FN-001 failed: function result differs from the expected active-criterion aggregate.', 1;

IF NOT EXISTS
(
    SELECT 1
    FROM contest.JudgingRound AS jr
    INNER JOIN contest.ScoringCriterion AS sc ON sc.round_id = jr.round_id
    WHERE sc.criterion_status = N'ACTIVE'
      AND judging.fn_round_max_total_score(jr.round_id) >= sc.score_max_value
)
BEGIN
    THROW 70334, 'TST-FN-001 failed: no populated round exercised the normal boundary case.', 1;
END;

PRINT 'PASS: round maximum score function matched expected values for all seeded rounds, NULL and unknown input.';
GO
