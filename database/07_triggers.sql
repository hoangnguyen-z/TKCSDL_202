USE FilmContestDB;
GO

CREATE OR ALTER TRIGGER judging.TR_EvaluationScore_AIU_RecalcEvaluation
ON judging.EvaluationScore
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        INNER JOIN judging.Evaluation AS e
            ON e.evaluation_id = i.evaluation_id
        INNER JOIN contest.ScoringCriterion AS c
            ON c.criterion_id = i.criterion_id
        WHERE c.round_id <> e.round_id
           OR i.score_value < c.score_min_value
           OR i.score_value > c.score_max_value
    )
    BEGIN
        THROW 55000, 'Evaluation score is invalid for the target criterion or round.', 1;
    END;

    ;WITH affected AS
    (
        SELECT evaluation_id FROM inserted
    )
    UPDATE e
    SET
        total_score = src.total_score,
        updated_at = SYSUTCDATETIME()
    FROM judging.Evaluation AS e
    INNER JOIN
    (
        SELECT
            es.evaluation_id,
            CAST(SUM(es.score_value) AS DECIMAL(6,2)) AS total_score
        FROM judging.EvaluationScore AS es
        WHERE es.evaluation_id IN (SELECT evaluation_id FROM affected)
        GROUP BY es.evaluation_id
    ) AS src
        ON src.evaluation_id = e.evaluation_id;
END;
GO

CREATE OR ALTER TRIGGER submission.TR_Submission_AU_AuditStatus
ON submission.Submission
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

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
    SELECT
        N'submission.Submission',
        i.submission_id,
        N'STATUS_CHANGE',
        NULL,
        SYSUTCDATETIME(),
        CONCAT(N'Submission status changed from ', d.submission_status, N' to ', i.submission_status, N'.'),
        CONCAT(N'{"old_status":"', d.submission_status, N'","new_status":"', i.submission_status, N'"}')
    FROM inserted AS i
    INNER JOIN deleted AS d
        ON d.submission_id = i.submission_id
    WHERE ISNULL(i.submission_status, N'') <> ISNULL(d.submission_status, N'');
END;
GO

CREATE OR ALTER TRIGGER result.TR_Result_AU_AuditStatus
ON result.Result
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

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
    SELECT
        N'result.Result',
        i.result_id,
        N'STATUS_CHANGE',
        i.finalized_by_user_id,
        SYSUTCDATETIME(),
        CONCAT(N'Result status changed from ', d.result_status, N' to ', i.result_status, N'.'),
        CONCAT(N'{"old_status":"', d.result_status, N'","new_status":"', i.result_status, N'"}')
    FROM inserted AS i
    INNER JOIN deleted AS d
        ON d.result_id = i.result_id
    WHERE ISNULL(i.result_status, N'') <> ISNULL(d.result_status, N'');
END;
GO
