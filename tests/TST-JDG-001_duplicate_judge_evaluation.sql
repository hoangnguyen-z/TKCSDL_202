USE FilmContestDB;
GO

PRINT 'TST-JDG-001 - Duplicate judge evaluation in same round must fail';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @round_id INT = (
            SELECT jr.round_id
            FROM contest.JudgingRound AS jr
            INNER JOIN contest.ContestCategory AS cc
                ON cc.category_id = jr.category_id
            INNER JOIN contest.Contest AS c
                ON c.contest_id = cc.contest_id
            WHERE c.contest_code = N'FILM2026-FALL'
              AND cc.category_code = N'PORTRAIT'
              AND jr.round_number = 2
        ),
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
        @judge_user_id INT = (
            SELECT user_id
            FROM iam.UserAccount
            WHERE email = N'mina.judge@filmplatform.local'
        );

    INSERT INTO judging.Evaluation
    (
        round_id,
        submission_id,
        judge_user_id,
        evaluation_status,
        total_score
    )
    VALUES
    (
        @round_id,
        @submission_id,
        @judge_user_id,
        N'DRAFT',
        0
    );

    ROLLBACK TRANSACTION;
    THROW 70008, 'TST-JDG-001 failed: duplicate evaluation was inserted.', 1;
END TRY
BEGIN CATCH
    PRINT 'PASS: duplicate judge evaluation was rejected as expected.';
    ROLLBACK TRANSACTION;
END CATCH;
GO
