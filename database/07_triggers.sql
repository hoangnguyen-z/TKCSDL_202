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

CREATE OR ALTER TRIGGER result.TR_Result_BUD_ProtectFinalized
ON result.Result
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Block DELETE of finalized/published results
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (
        SELECT 1
        FROM deleted
        WHERE result_status IN (N'FINALIZED', N'PUBLISHED')
    )
    BEGIN
        THROW 54010, 'Cannot delete a finalized or published result. Record is immutable.', 1;
    END;

    -- Block illegal modifications of finalized/published results
    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        INNER JOIN inserted AS i ON i.result_id = d.result_id
        WHERE d.result_status IN (N'FINALIZED', N'PUBLISHED')
          AND (
              i.category_id <> d.category_id
              OR i.submission_id <> d.submission_id
              OR i.final_score <> d.final_score
              OR i.final_rank <> d.final_rank
              OR (d.result_status = N'PUBLISHED' AND i.result_status <> N'PUBLISHED')
              OR (d.result_status = N'FINALIZED' AND i.result_status NOT IN (N'FINALIZED', N'PUBLISHED'))
          )
    )
    BEGIN
        THROW 54011, 'Cannot modify finalized or published result scores, rank, or category. Immutability violation.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER archive.TR_ArchiveItem_BUD_Immutable
ON archive.ArchiveItem
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        THROW 55010, 'ArchiveItem records are strictly immutable. Updates and deletes are prohibited.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER result.TR_AwardAssignment_BIU_CheckCategoryMatch
ON result.AwardAssignment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN contest.AwardDefinition AS ad ON ad.award_definition_id = i.award_definition_id
        INNER JOIN result.Result AS r ON r.result_id = i.result_id
        WHERE ad.category_id <> r.category_id
    )
    BEGIN
        THROW 54105, 'Award category mismatch: cannot assign an award defined for one category to a result in another category.', 1;
    END;
END;
GO
