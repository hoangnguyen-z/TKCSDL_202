USE FilmContestDB;
GO

PRINT 'TST-RES-001 - Final round result finalization should succeed';
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
        @organizer_user_id INT = (
            SELECT user_id
            FROM iam.UserAccount
            WHERE email = N'olivia.organizer@filmplatform.local'
        ),
        @category_id INT = (
            SELECT cc.category_id
            FROM contest.ContestCategory AS cc
            INNER JOIN contest.Contest AS c
                ON c.contest_id = cc.contest_id
            WHERE c.contest_code = N'FILM2026-FALL'
              AND cc.category_code = N'PORTRAIT'
        );

    EXEC result.usp_finalize_results_for_round
        @round_id = @round_id,
        @finalized_by_user_id = @organizer_user_id;

    IF (SELECT COUNT(*) FROM result.Result WHERE category_id = @category_id AND result_status = N'FINALIZED') <> 2
        THROW 70010, 'Expected two finalized result rows for portrait category.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM result.Result
        WHERE category_id = @category_id
          AND final_rank = 1
          AND final_score > 0
    )
        THROW 70011, 'Top ranked result was not created correctly.', 1;

    PRINT 'PASS: result finalization succeeded for the final round.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
