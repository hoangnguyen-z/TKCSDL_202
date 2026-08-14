USE FilmContestDB;
GO

PRINT 'TST-AUD-001 - Submission status change should create audit entry';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @submission_id INT = (
        SELECT TOP 1 submission_id
        FROM submission.Submission
        WHERE submission_status = N'PENDING_VERIFICATION'
        ORDER BY submission_id
    );

    UPDATE submission.Submission
    SET submission_status = N'NEEDS_CLARIFICATION',
        updated_at = SYSUTCDATETIME()
    WHERE submission_id = @submission_id;

    IF NOT EXISTS (
        SELECT 1
        FROM audit.AuditLog
        WHERE entity_name = N'submission.Submission'
          AND entity_id = @submission_id
          AND action_code = N'STATUS_CHANGE'
    )
        THROW 70013, 'Expected audit log entry was not created.', 1;

    PRINT 'PASS: submission status change generated an audit log entry.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
