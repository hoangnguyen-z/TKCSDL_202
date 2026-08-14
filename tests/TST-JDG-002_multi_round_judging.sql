USE FilmContestDB;
GO

PRINT 'TST-JDG-002 - Multi-round judging data should exist end-to-end';

DECLARE
    @submission_id INT = (
        SELECT s.submission_id
        FROM submission.Submission AS s
        INNER JOIN contest.Contest AS c
            ON c.contest_id = s.contest_id
        INNER JOIN contest.ContestCategory AS cc
            ON cc.category_id = s.category_id
        WHERE c.contest_code = N'FILM2026-FALL'
          AND cc.category_code = N'PORTRAIT'
          AND s.submission_title = N'Quiet Portrait'
    ),
    @round_count INT,
    @submitted_eval_count INT;

SELECT @round_count = COUNT(DISTINCT e.round_id),
       @submitted_eval_count = COUNT(*)
FROM judging.Evaluation AS e
WHERE e.submission_id = @submission_id
  AND e.evaluation_status = N'SUBMITTED';

IF @round_count < 2 OR @submitted_eval_count < 4
    THROW 70009, 'TST-JDG-002 failed: expected multi-round submitted evaluations were not found.', 1;

PRINT 'PASS: multi-round judging chain exists for the seeded submission.';
GO
