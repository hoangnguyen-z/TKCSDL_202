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
    -- SET XACT_ABORT ON;

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
    -- SET XACT_ABORT ON;

    DECLARE
        @verification_id INT,
        @current_verification_status NVARCHAR(30),
        @verification_status NVARCHAR(30),
        @submission_status NVARCHAR(30),
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT @verification_id = verification_id,
           @current_verification_status = verification_status
    FROM verification.VerificationCase
    WHERE submission_id = @submission_id;

    IF @verification_id IS NULL
        THROW 52000, 'Verification case does not exist for the submission.', 1;

    IF @current_verification_status IN (N'VERIFIED', N'REJECTED')
        THROW 52004, 'Verification case has already reached a terminal state and cannot be modified.', 1;

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
    -- SET XACT_ABORT ON;

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
    -- SET XACT_ABORT ON;

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

CREATE OR ALTER PROCEDURE archive.usp_create_archive_item
    @result_id INT,
    @archived_by_user_id INT,
    @retention_note NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- SET XACT_ABORT ON;

    DECLARE
        @submission_id INT,
        @category_id INT,
        @frame_id INT,
        @result_status NVARCHAR(20),
        @archive_id INT,
        @contest_snapshot NVARCHAR(MAX),
        @category_snapshot NVARCHAR(MAX),
        @participant_snapshot NVARCHAR(MAX),
        @technical_snapshot NVARCHAR(MAX),
        @judging_snapshot NVARCHAR(MAX),
        @image_uri_snapshot NVARCHAR(500),
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT
        @submission_id = r.submission_id,
        @category_id = r.category_id,
        @result_status = r.result_status
    FROM result.Result AS r
    WHERE r.result_id = @result_id;

    IF @result_status IS NULL
        THROW 55000, 'Result does not exist.', 1;

    IF @result_status NOT IN (N'FINALIZED', N'PUBLISHED')
        THROW 55001, 'Only FINALIZED or PUBLISHED results can be archived.', 1;

    IF EXISTS (
        SELECT 1
        FROM archive.ArchiveItem
        WHERE result_id = @result_id
    )
        THROW 55002, 'Result has already been archived.', 1;

    SELECT
        @frame_id = frame_id,
        @image_uri_snapshot = scanned_image_uri
    FROM submission.Submission
    WHERE submission_id = @submission_id;

    -- Build JSON snapshots matching archive.ArchiveItem schema
    SELECT @contest_snapshot = (
        SELECT c.contest_code, c.contest_title, c.contest_theme
        FROM submission.Submission AS s
        INNER JOIN contest.Contest AS c ON c.contest_id = s.contest_id
        WHERE s.submission_id = @submission_id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @category_snapshot = (
        SELECT cc.category_code, cc.category_name
        FROM submission.Submission AS s
        INNER JOIN contest.ContestCategory AS cc ON cc.category_id = s.category_id
        WHERE s.submission_id = @submission_id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @participant_snapshot = (
        SELECT p.participant_id, p.display_name, u.email
        FROM submission.Submission AS s
        INNER JOIN participant.Registration AS reg ON reg.registration_id = s.registration_id
        INNER JOIN participant.ParticipantProfile AS p ON p.participant_id = reg.participant_id
        INNER JOIN iam.UserAccount AS u ON u.user_id = p.user_id
        WHERE s.submission_id = @submission_id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @technical_snapshot = (
        SELECT
            ff.frame_number,
            fr.roll_code,
            fs.brand_name AS film_brand,
            fs.stock_name AS film_stock,
            cam.model_name AS camera_model,
            lens.model_name AS lens_model
        FROM submission.Submission AS s
        INNER JOIN film.FilmFrame AS ff ON ff.frame_id = s.frame_id
        INNER JOIN film.FilmRoll AS fr ON fr.roll_id = ff.roll_id
        LEFT JOIN reference.FilmStock AS fs ON fs.film_stock_id = fr.film_stock_id
        LEFT JOIN reference.Camera AS cam ON cam.camera_id = ff.camera_id
        LEFT JOIN reference.Lens AS lens ON lens.lens_id = ff.lens_id
        WHERE s.submission_id = @submission_id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @judging_snapshot = (
        SELECT
            r.final_score,
            r.final_rank,
            r.finalized_at,
            (
                SELECT
                    ad.award_code,
                    ad.award_name,
                    ad.award_type,
                    ad.prize_description,
                    aa.assigned_at
                FROM result.AwardAssignment AS aa
                INNER JOIN contest.AwardDefinition AS ad ON ad.award_definition_id = aa.award_definition_id
                WHERE aa.result_id = r.result_id
                FOR JSON PATH
            ) AS awards
        FROM result.Result AS r
        WHERE r.result_id = @result_id
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    BEGIN TRANSACTION;

    INSERT INTO archive.ArchiveItem
    (
        result_id,
        submission_id,
        archive_status,
        archived_at,
        archived_by_user_id,
        contest_snapshot,
        category_snapshot,
        participant_snapshot,
        technical_snapshot,
        judging_snapshot,
        image_uri_snapshot,
        retention_note,
        created_at,
        updated_at
    )
    VALUES
    (
        @result_id,
        @submission_id,
        N'ARCHIVED',
        @now,
        @archived_by_user_id,
        ISNULL(@contest_snapshot, N'{}'),
        ISNULL(@category_snapshot, N'{}'),
        ISNULL(@participant_snapshot, N'{}'),
        ISNULL(@technical_snapshot, N'{}'),
        ISNULL(@judging_snapshot, N'{}'),
        ISNULL(@image_uri_snapshot, N''),
        @retention_note,
        @now,
        @now
    );

    SET @archive_id = SCOPE_IDENTITY();

    UPDATE submission.Submission
    SET submission_status = N'ARCHIVED',
        updated_at = @now
    WHERE submission_id = @submission_id;

    UPDATE film.FilmFrame
    SET frame_status = N'ARCHIVED',
        updated_at = @now
    WHERE frame_id = @frame_id;

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
        N'archive.ArchiveItem',
        @archive_id,
        N'CREATE_ARCHIVE_ITEM',
        @archived_by_user_id,
        @now,
        N'Archive item created successfully from finalized result.',
        CONCAT(N'{"archive_id":', @archive_id, N',"result_id":', @result_id, N',"submission_id":', @submission_id, N'}')
    );

    COMMIT TRANSACTION;

    SELECT @archive_id AS archive_id;
END;
GO

CREATE OR ALTER PROCEDURE contest.usp_create_contest_from_template
    @template_id INT,
    @contest_code NVARCHAR(30),
    @contest_title NVARCHAR(200),
    @contest_theme NVARCHAR(200) = NULL,
    @contest_summary NVARCHAR(1000) = NULL,
    @registration_open_at DATETIME2(0),
    @registration_close_at DATETIME2(0),
    @submission_open_at DATETIME2(0),
    @submission_close_at DATETIME2(0),
    @created_by_user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- SET XACT_ABORT ON;

    DECLARE
        @template_status NVARCHAR(20),
        @contest_id INT,
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT @template_status = template_status
    FROM contest.ContestTemplate
    WHERE template_id = @template_id;

    IF @template_status IS NULL
        THROW 51100, 'Contest template does not exist.', 1;

    IF @template_status <> N'ACTIVE'
        THROW 51101, 'Contest template is not ACTIVE.', 1;

    IF @registration_open_at > @registration_close_at
        THROW 51102, 'Registration open date must be prior to registration close date.', 1;

    IF @submission_open_at > @submission_close_at
        THROW 51103, 'Submission open date must be prior to submission close date.', 1;

    BEGIN TRANSACTION;

    INSERT INTO contest.Contest
    (
        source_template_id,
        contest_code,
        contest_title,
        contest_theme,
        contest_summary,
        registration_open_at,
        registration_close_at,
        submission_open_at,
        submission_close_at,
        contest_status,
        created_by_user_id,
        updated_by_user_id,
        created_at,
        updated_at
    )
    VALUES
    (
        @template_id,
        @contest_code,
        @contest_title,
        @contest_theme,
        @contest_summary,
        @registration_open_at,
        @registration_close_at,
        @submission_open_at,
        @submission_close_at,
        N'DRAFT',
        @created_by_user_id,
        @created_by_user_id,
        @now,
        @now
    );

    SET @contest_id = SCOPE_IDENTITY();

    -- Clone categories and mapping table for child cloning
    DECLARE @CatMap TABLE (template_cat_id INT PRIMARY KEY, new_cat_id INT);

    MERGE contest.ContestCategory AS tgt
    USING (
        SELECT template_category_id, category_code, category_name, category_description, sort_order
        FROM contest.TemplateCategory
        WHERE template_id = @template_id
    ) AS src
    ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT (contest_id, category_code, category_name, category_description, sort_order, category_status, created_by_user_id, created_at, updated_at)
        VALUES (@contest_id, src.category_code, src.category_name, src.category_description, src.sort_order, N'ACTIVE', @created_by_user_id, @now, @now)
    OUTPUT src.template_category_id, inserted.category_id INTO @CatMap (template_cat_id, new_cat_id);

    -- Clone judging rounds and mapping table
    DECLARE @RoundMap TABLE (template_round_id INT PRIMARY KEY, new_round_id INT);

    MERGE contest.JudgingRound AS tgt
    USING (
        SELECT tr.template_round_id, cm.new_cat_id, tr.round_number, tr.round_name, tr.round_sequence, tr.is_final_round
        FROM contest.TemplateJudgingRound AS tr
        INNER JOIN @CatMap AS cm ON cm.template_cat_id = tr.template_category_id
    ) AS src
    ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT (category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id, created_at, updated_at)
        VALUES (src.new_cat_id, src.round_number, src.round_name, src.round_sequence, N'DRAFT', @submission_close_at, DATEADD(DAY, 14, @submission_close_at), src.is_final_round, @created_by_user_id, @now, @now)
    OUTPUT src.template_round_id, inserted.round_id INTO @RoundMap (template_round_id, new_round_id);

    -- Clone scoring criteria
    INSERT INTO contest.ScoringCriterion
    (
        round_id,
        criterion_code,
        criterion_name,
        criterion_description,
        weight_percent,
        score_min_value,
        score_max_value,
        sort_order,
        criterion_status,
        created_by_user_id,
        created_at,
        updated_at
    )
    SELECT
        rm.new_round_id,
        tc.criterion_code,
        tc.criterion_name,
        tc.criterion_description,
        tc.weight_percent,
        tc.score_min_value,
        tc.score_max_value,
        tc.sort_order,
        N'ACTIVE',
        @created_by_user_id,
        @now,
        @now
    FROM contest.TemplateScoringCriterion AS tc
    INNER JOIN @RoundMap AS rm ON rm.template_round_id = tc.template_round_id;

    -- Clone award definitions
    INSERT INTO contest.AwardDefinition
    (
        category_id,
        award_code,
        award_name,
        rank_order,
        award_type,
        prize_description,
        award_status,
        created_by_user_id,
        created_at,
        updated_at
    )
    SELECT
        cm.new_cat_id,
        ta.award_code,
        ta.award_name,
        ta.rank_order,
        ta.award_type,
        ta.prize_description,
        N'ACTIVE',
        @created_by_user_id,
        @now,
        @now
    FROM contest.TemplateAwardDefinition AS ta
    INNER JOIN @CatMap AS cm ON cm.template_cat_id = ta.template_category_id;

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
        N'contest.Contest',
        @contest_id,
        N'CREATE_CONTEST_FROM_TEMPLATE',
        @created_by_user_id,
        @now,
        N'Contest created from template with cloned categories, rounds, criteria, and awards.',
        CONCAT(N'{"contest_id":', @contest_id, N',"template_id":', @template_id, N'}')
    );

    COMMIT TRANSACTION;

    SELECT @contest_id AS contest_id;
END;
GO

CREATE OR ALTER PROCEDURE contest.usp_publish_contest
    @contest_id INT,
    @published_by_user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- SET XACT_ABORT ON;

    DECLARE
        @contest_status NVARCHAR(20),
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT @contest_status = contest_status
    FROM contest.Contest
    WHERE contest_id = @contest_id;

    IF @contest_status IS NULL
        THROW 51200, 'Contest does not exist.', 1;

    IF @contest_status <> N'DRAFT'
        THROW 51201, 'Only DRAFT contests can be published.', 1;

    -- Enforce publication completeness:
    -- 1. At least one active category
    IF NOT EXISTS (
        SELECT 1
        FROM contest.ContestCategory
        WHERE contest_id = @contest_id
          AND category_status = N'ACTIVE'
    )
        THROW 51202, 'Contest must have at least one active category before publishing.', 1;

    -- 2. Every active category must have at least one judging round
    IF EXISTS (
        SELECT 1
        FROM contest.ContestCategory AS cc
        WHERE cc.contest_id = @contest_id
          AND cc.category_status = N'ACTIVE'
          AND NOT EXISTS (
              SELECT 1
              FROM contest.JudgingRound AS jr
              WHERE jr.category_id = cc.category_id
          )
    )
        THROW 51203, 'Every active category must have at least one judging round before publishing.', 1;

    -- 3. Every judging round must have at least one active scoring criterion
    IF EXISTS (
        SELECT 1
        FROM contest.ContestCategory AS cc
        INNER JOIN contest.JudgingRound AS jr
            ON jr.category_id = cc.category_id
        WHERE cc.contest_id = @contest_id
          AND cc.category_status = N'ACTIVE'
          AND NOT EXISTS (
              SELECT 1
              FROM contest.ScoringCriterion AS sc
              WHERE sc.round_id = jr.round_id
                AND sc.criterion_status = N'ACTIVE'
          )
    )
        THROW 51204, 'Every judging round must have at least one active scoring criterion before publishing.', 1;

    -- 4. Every active category must have at least one award definition
    IF EXISTS (
        SELECT 1
        FROM contest.ContestCategory AS cc
        WHERE cc.contest_id = @contest_id
          AND cc.category_status = N'ACTIVE'
          AND NOT EXISTS (
              SELECT 1
              FROM contest.AwardDefinition AS ad
              WHERE ad.category_id = cc.category_id
                AND ad.award_status = N'ACTIVE'
          )
    )
        THROW 51205, 'Every active category must have at least one award definition before publishing.', 1;

    BEGIN TRANSACTION;

    UPDATE contest.Contest
    SET contest_status = N'PUBLISHED',
        updated_by_user_id = @published_by_user_id,
        updated_at = @now
    WHERE contest_id = @contest_id;

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
        N'contest.Contest',
        @contest_id,
        N'PUBLISH_CONTEST',
        @published_by_user_id,
        @now,
        N'Contest passed publication completeness checks and was published.',
        CONCAT(N'{"contest_id":', @contest_id, N'}')
    );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE result.usp_assign_award
    @award_definition_id INT,
    @result_id INT,
    @assigned_by_user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- SET XACT_ABORT ON;

    DECLARE
        @award_category_id INT,
        @result_category_id INT,
        @result_status NVARCHAR(20),
        @now DATETIME2(0) = SYSUTCDATETIME();

    SELECT @award_category_id = category_id
    FROM contest.AwardDefinition
    WHERE award_definition_id = @award_definition_id
      AND award_status = N'ACTIVE';

    IF @award_category_id IS NULL
        THROW 54100, 'Award definition does not exist or is not active.', 1;

    SELECT
        @result_category_id = category_id,
        @result_status = result_status
    FROM result.Result
    WHERE result_id = @result_id;

    IF @result_category_id IS NULL
        THROW 54101, 'Result does not exist.', 1;

    IF @result_status NOT IN (N'FINALIZED', N'PUBLISHED')
        THROW 54102, 'Only FINALIZED or PUBLISHED results can receive awards.', 1;

    IF @award_category_id <> @result_category_id
        THROW 54103, 'Award category does not match result category.', 1;

    IF EXISTS (
        SELECT 1
        FROM result.AwardAssignment
        WHERE award_definition_id = @award_definition_id
          AND result_id = @result_id
    )
        THROW 54104, 'Award has already been assigned to this result.', 1;

    BEGIN TRANSACTION;

    INSERT INTO result.AwardAssignment
    (
        award_definition_id,
        result_id,
        assigned_by_user_id,
        assigned_at,
        created_at
    )
    VALUES
    (
        @award_definition_id,
        @result_id,
        @assigned_by_user_id,
        @now,
        @now
    );

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
        N'result.AwardAssignment',
        @result_id,
        N'ASSIGN_AWARD',
        @assigned_by_user_id,
        @now,
        N'Award assigned to contest result.',
        CONCAT(N'{"award_definition_id":', @award_definition_id, N',"result_id":', @result_id, N'}')
    );

    COMMIT TRANSACTION;
END;
GO

