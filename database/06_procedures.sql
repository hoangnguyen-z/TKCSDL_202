USE FilmContestDB;
GO

CREATE OR ALTER PROCEDURE submission.usp_create_submission
    @registration_id INT,
    @category_id INT,
    @frame_id INT,
    @submission_title NVARCHAR(200),
    @submission_statement NVARCHAR(1000) = NULL,
    @scanned_image_uri NVARCHAR(500),
    @thumbnail_image_uri NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @contest_id INT,
        @category_contest_id INT,
        @participant_id INT,
        @frame_owner_participant_id INT,
        @registration_status NVARCHAR(20),
        @eligibility_status NVARCHAR(20),
        @submission_open_at DATETIME2(0),
        @submission_close_at DATETIME2(0),
        @submission_id INT,
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT
        @contest_id = r.contest_id,
        @participant_id = r.participant_id,
        @registration_status = r.registration_status,
        @eligibility_status = r.eligibility_status,
        @submission_open_at = c.submission_open_at,
        @submission_close_at = c.submission_close_at
    FROM participant.Registration AS r
    INNER JOIN contest.Contest AS c
        ON c.contest_id = r.contest_id
    WHERE r.registration_id = @registration_id;

    IF @contest_id IS NULL
        THROW 51000, 'Registration does not exist.', 1;

    IF @registration_status <> N'APPROVED' OR @eligibility_status <> N'ELIGIBLE'
        THROW 51001, 'Registration is not approved and eligible for submission.', 1;

    IF @now < @submission_open_at OR @now > @submission_close_at
        THROW 51002, 'Submission is outside the contest submission window.', 1;

    SELECT @category_contest_id = contest_id
    FROM contest.ContestCategory
    WHERE category_id = @category_id;

    IF @category_contest_id IS NULL
        THROW 51003, 'Contest category does not exist.', 1;

    IF @category_contest_id <> @contest_id
        THROW 51004, 'Contest category does not belong to the registration contest.', 1;

    SELECT @frame_owner_participant_id = fr.participant_id
    FROM film.FilmFrame AS ff
    INNER JOIN film.FilmRoll AS fr
        ON fr.roll_id = ff.roll_id
    WHERE ff.frame_id = @frame_id;

    IF @frame_owner_participant_id IS NULL
        THROW 51005, 'Film frame does not exist.', 1;

    IF @frame_owner_participant_id <> @participant_id
        THROW 51006, 'Film frame does not belong to the participant registration owner.', 1;

    IF EXISTS (
        SELECT 1
        FROM submission.Submission
        WHERE contest_id = @contest_id
          AND frame_id = @frame_id
    )
        THROW 51007, 'The same film frame has already been submitted to this contest.', 1;

    BEGIN TRANSACTION;

    INSERT INTO submission.Submission
    (
        registration_id,
        contest_id,
        category_id,
        frame_id,
        submission_title,
        submission_statement,
        scanned_image_uri,
        thumbnail_image_uri,
        submitted_at,
        submission_status,
        created_at,
        updated_at
    )
    VALUES
    (
        @registration_id,
        @contest_id,
        @category_id,
        @frame_id,
        @submission_title,
        @submission_statement,
        @scanned_image_uri,
        @thumbnail_image_uri,
        @now,
        N'PENDING_VERIFICATION',
        @now,
        @now
    );

    SET @submission_id = SCOPE_IDENTITY();

    INSERT INTO verification.VerificationCase
    (
        submission_id,
        verification_status,
        completeness_status,
        technical_status,
        created_at,
        updated_at
    )
    VALUES
    (
        @submission_id,
        N'PENDING',
        N'PENDING',
        N'PENDING',
        @now,
        @now
    );

    UPDATE film.FilmFrame
    SET frame_status = N'SUBMITTED',
        updated_at = @now
    WHERE frame_id = @frame_id
      AND frame_status <> N'ARCHIVED';

    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'submission.Submission',
        @submission_id,
        N'CREATE_SUBMISSION',
        NULL,
        @now,
        N'Submission created and placed into verification queue.',
        CONCAT(N'{"registration_id":', @registration_id, N',"category_id":', @category_id, N',"frame_id":', @frame_id, N'}')
    );

    COMMIT TRANSACTION;

    SELECT @submission_id AS submission_id;
END;
GO

CREATE OR ALTER PROCEDURE verification.usp_record_verification_decision
    @submission_id INT,
    @reviewed_by_user_id INT,
    @completeness_status NVARCHAR(20),
    @technical_status NVARCHAR(20),
    @final_decision_code NVARCHAR(30),
    @review_notes NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @verification_id INT,
        @verification_status NVARCHAR(30),
        @submission_status NVARCHAR(30),
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT @verification_id = verification_id
    FROM verification.VerificationCase
    WHERE submission_id = @submission_id;

    IF @verification_id IS NULL
        THROW 52000, 'Verification case does not exist for the submission.', 1;

    IF @completeness_status NOT IN (N'PASS', N'FAIL')
        THROW 52001, 'Completeness status must be PASS or FAIL.', 1;

    IF @technical_status NOT IN (N'PASS', N'FAIL')
        THROW 52002, 'Technical status must be PASS or FAIL.', 1;

    IF @final_decision_code NOT IN (N'VERIFIED', N'REJECTED', N'NEEDS_CLARIFICATION')
        THROW 52003, 'Invalid final decision code.', 1;

    SET @verification_status = @final_decision_code;
    SET @submission_status = @final_decision_code;

    BEGIN TRANSACTION;

    UPDATE verification.VerificationCase
    SET verification_status = @verification_status,
        completeness_status = @completeness_status,
        technical_status = @technical_status,
        final_decision_code = @final_decision_code,
        reviewed_by_user_id = @reviewed_by_user_id,
        reviewed_at = @now,
        review_notes = @review_notes,
        updated_at = @now
    WHERE verification_id = @verification_id;

    UPDATE submission.Submission
    SET submission_status = @submission_status,
        updated_at = @now
    WHERE submission_id = @submission_id;

    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'verification.VerificationCase',
        @verification_id,
        N'VERIFICATION_DECISION',
        @reviewed_by_user_id,
        @now,
        CONCAT(N'Verification completed with decision ', @final_decision_code, N'.'),
        CONCAT(N'{"submission_id":', @submission_id, N',"completeness_status":"', @completeness_status, N'","technical_status":"', @technical_status, N'"}')
    );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE judging.usp_submit_evaluation
    @evaluation_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @round_id INT,
        @judge_user_id INT,
        @evaluation_status NVARCHAR(20),
        @now DATETIME2(0) = SYSUTCDATETIME(),
        @required_criteria INT,
        @scored_criteria INT,
        @max_total DECIMAL(6,2),
        @current_total DECIMAL(6,2),
        @category_id INT,
        @verified_submission_count INT,
        @judge_submitted_count INT;

    SELECT
        @round_id = e.round_id,
        @judge_user_id = e.judge_user_id,
        @evaluation_status = e.evaluation_status
    FROM judging.Evaluation AS e
    WHERE e.evaluation_id = @evaluation_id;

    IF @round_id IS NULL
        THROW 53000, 'Evaluation does not exist.', 1;

    IF @evaluation_status = N'LOCKED'
        THROW 53001, 'Locked evaluations cannot be resubmitted.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM judging.JudgeAssignment
        WHERE round_id = @round_id
          AND judge_user_id = @judge_user_id
          AND assignment_status IN (N'ASSIGNED', N'IN_PROGRESS', N'SUBMITTED')
    )
        THROW 53002, 'Judge is not assigned to the round.', 1;

    SELECT @required_criteria = COUNT(*)
    FROM contest.ScoringCriterion
    WHERE round_id = @round_id
      AND criterion_status = N'ACTIVE';

    SELECT @scored_criteria = COUNT(*)
    FROM judging.EvaluationScore
    WHERE evaluation_id = @evaluation_id;

    IF @required_criteria = 0
        THROW 53003, 'The round has no active criteria.', 1;

    IF @scored_criteria <> @required_criteria
        THROW 53004, 'Evaluation must contain a score for every active criterion in the round.', 1;

    SELECT @current_total = total_score
    FROM judging.Evaluation
    WHERE evaluation_id = @evaluation_id;

    SET @max_total = judging.fn_round_max_total_score(@round_id);

    IF @current_total < 0 OR @current_total > @max_total
        THROW 53005, 'Evaluation total is outside the allowed round score range.', 1;

    BEGIN TRANSACTION;

    UPDATE judging.Evaluation
    SET evaluation_status = N'SUBMITTED',
        submitted_at = @now,
        updated_at = @now
    WHERE evaluation_id = @evaluation_id;

    SELECT @category_id = jr.category_id
    FROM contest.JudgingRound AS jr
    WHERE jr.round_id = @round_id;

    SELECT @verified_submission_count = COUNT(*)
    FROM submission.Submission AS s
    WHERE s.category_id = @category_id
      AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED');

    SELECT @judge_submitted_count = COUNT(*)
    FROM judging.Evaluation AS e
    INNER JOIN submission.Submission AS s
        ON s.submission_id = e.submission_id
    WHERE e.round_id = @round_id
      AND e.judge_user_id = @judge_user_id
      AND e.evaluation_status IN (N'SUBMITTED', N'LOCKED')
      AND s.category_id = @category_id;

    UPDATE judging.JudgeAssignment
    SET assignment_status = CASE
                                WHEN @judge_submitted_count >= @verified_submission_count THEN N'SUBMITTED'
                                ELSE N'IN_PROGRESS'
                            END,
        updated_at = @now
    WHERE round_id = @round_id
      AND judge_user_id = @judge_user_id;

    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'judging.Evaluation',
        @evaluation_id,
        N'SUBMIT_EVALUATION',
        @judge_user_id,
        @now,
        N'Judge submitted evaluation.',
        CONCAT(N'{"round_id":', @round_id, N',"total_score":', CONVERT(NVARCHAR(30), @current_total), N'}')
    );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE result.usp_finalize_results_for_round
    @round_id INT,
    @finalized_by_user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @category_id INT,
        @is_final_round BIT,
        @required_judges INT,
        @tie_count INT,
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT
        @category_id = category_id,
        @is_final_round = is_final_round
    FROM contest.JudgingRound
    WHERE round_id = @round_id;

    IF @category_id IS NULL
        THROW 54000, 'Judging round does not exist.', 1;

    IF @is_final_round <> 1
        THROW 54001, 'Only final rounds can be finalized into results.', 1;

    SELECT @required_judges = COUNT(*)
    FROM judging.JudgeAssignment
    WHERE round_id = @round_id
      AND assignment_status IN (N'ASSIGNED', N'IN_PROGRESS', N'SUBMITTED');

    IF @required_judges = 0
        THROW 54002, 'No judges are assigned to the round.', 1;

    IF EXISTS (
        SELECT 1
        FROM submission.Submission AS s
        WHERE s.category_id = @category_id
          AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED')
          AND (
                SELECT COUNT(*)
                FROM judging.Evaluation AS e
                WHERE e.round_id = @round_id
                  AND e.submission_id = s.submission_id
                  AND e.evaluation_status IN (N'SUBMITTED', N'LOCKED')
              ) < @required_judges
    )
        THROW 54003, 'Not all verified submissions have the required number of submitted evaluations.', 1;

    ;WITH AggregatedScore AS
    (
        SELECT
            s.submission_id,
            AVG(e.total_score) AS final_score
        FROM submission.Submission AS s
        INNER JOIN judging.Evaluation AS e
            ON e.submission_id = s.submission_id
           AND e.round_id = @round_id
           AND e.evaluation_status IN (N'SUBMITTED', N'LOCKED')
        WHERE s.category_id = @category_id
          AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED')
        GROUP BY s.submission_id
    )
    SELECT @tie_count = COUNT(*)
    FROM
    (
        SELECT final_score
        FROM AggregatedScore
        GROUP BY final_score
        HAVING COUNT(*) > 1
    ) AS t;

    IF @tie_count > 0
        THROW 54004, 'Tie detected. Manual organizer tie-break is required before finalization.', 1;

    BEGIN TRANSACTION;

    ;WITH AggregatedScore AS
    (
        SELECT
            s.submission_id,
            CAST(AVG(e.total_score) AS DECIMAL(6,2)) AS final_score
        FROM submission.Submission AS s
        INNER JOIN judging.Evaluation AS e
            ON e.submission_id = s.submission_id
           AND e.round_id = @round_id
           AND e.evaluation_status IN (N'SUBMITTED', N'LOCKED')
        WHERE s.category_id = @category_id
          AND s.submission_status IN (N'VERIFIED', N'JUDGED', N'FINALIZED')
        GROUP BY s.submission_id
    ),
    Ranked AS
    (
        SELECT
            @category_id AS category_id,
            submission_id,
            final_score,
            ROW_NUMBER() OVER (ORDER BY final_score DESC, submission_id ASC) AS final_rank
        FROM AggregatedScore
    )
    MERGE result.Result AS tgt
    USING Ranked AS src
       ON tgt.category_id = src.category_id
      AND tgt.submission_id = src.submission_id
    WHEN MATCHED THEN
        UPDATE SET
            final_score = src.final_score,
            final_rank = src.final_rank,
            result_status = N'FINALIZED',
            tie_break_note = NULL,
            finalized_at = @now,
            finalized_by_user_id = @finalized_by_user_id,
            updated_at = @now
    WHEN NOT MATCHED THEN
        INSERT
        (
            category_id,
            submission_id,
            final_score,
            final_rank,
            result_status,
            tie_break_note,
            finalized_at,
            finalized_by_user_id,
            created_at,
            updated_at
        )
        VALUES
        (
            src.category_id,
            src.submission_id,
            src.final_score,
            src.final_rank,
            N'FINALIZED',
            NULL,
            @now,
            @finalized_by_user_id,
            @now,
            @now
        );

    UPDATE submission.Submission
    SET submission_status = N'FINALIZED',
        updated_at = @now
    WHERE category_id = @category_id
      AND submission_status IN (N'VERIFIED', N'JUDGED');

    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'result.Result',
        @category_id,
        N'FINALIZE_RESULTS',
        @finalized_by_user_id,
        @now,
        N'Final results generated for category.',
        CONCAT(N'{"round_id":', @round_id, N',"category_id":', @category_id, N'}')
    );

    COMMIT TRANSACTION;
END;
GO
