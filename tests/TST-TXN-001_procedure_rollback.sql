USE FilmContestDB;
GO

PRINT 'TST-TXN-001 - Procedure failure rolls back partial verification changes';

DECLARE
    @submission_id INT,
    @verification_id INT,
    @initial_verification_status NVARCHAR(30),
    @initial_final_decision NVARCHAR(30),
    @initial_submission_status NVARCHAR(30),
    @initial_audit_count INT,
    @xact_state_after_error INT = 0,
    @expected_failure BIT = 0;

SELECT TOP (1)
    @submission_id = s.submission_id,
    @initial_submission_status = s.submission_status
FROM submission.Submission AS s
INNER JOIN verification.VerificationCase AS vc ON vc.submission_id = s.submission_id
ORDER BY s.submission_id;

SELECT
    @verification_id = verification_id,
    @initial_verification_status = verification_status,
    @initial_final_decision = final_decision_code
FROM verification.VerificationCase
WHERE submission_id = @submission_id;

SELECT @initial_audit_count = COUNT(*)
FROM audit.AuditLog
WHERE entity_name = N'verification.VerificationCase'
  AND entity_id = @verification_id;

IF @submission_id IS NULL OR @verification_id IS NULL
    THROW 70341, 'TST-TXN-001 blocked: verification fixture is missing.', 1;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC verification.usp_record_verification_decision
        @submission_id = @submission_id,
        @reviewed_by_user_id = -903401,
        @completeness_status = N'PASS',
        @technical_status = N'PASS',
        @final_decision_code = N'VERIFIED',
        @review_notes = N'Invalid reviewer must force rollback.';
END TRY
BEGIN CATCH
    SET @expected_failure = 1;
    SET @xact_state_after_error = XACT_STATE();
    PRINT 'PASS: invalid reviewer caused the procedure to fail.';
END CATCH;

IF @expected_failure = 0
BEGIN
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW 70342, 'TST-TXN-001 failed: invalid reviewer was accepted.', 1;
END;

IF @xact_state_after_error NOT IN (0, 1, -1)
BEGIN
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW 70343, 'TST-TXN-001 failed: unexpected XACT_STATE value.', 1;
END;

IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

IF EXISTS
(
    SELECT 1
    FROM verification.VerificationCase
    WHERE verification_id = @verification_id
      AND (verification_status <> @initial_verification_status
           OR ISNULL(final_decision_code, N'') <> ISNULL(@initial_final_decision, N''))
)
    THROW 70344, 'TST-TXN-001 failed: verification row was partially changed after rollback.', 1;

IF EXISTS
(
    SELECT 1
    FROM submission.Submission
    WHERE submission_id = @submission_id
      AND submission_status <> @initial_submission_status
)
    THROW 70345, 'TST-TXN-001 failed: submission row was partially changed after rollback.', 1;

IF (SELECT COUNT(*) FROM audit.AuditLog WHERE entity_name = N'verification.VerificationCase' AND entity_id = @verification_id) <> @initial_audit_count
    THROW 70346, 'TST-TXN-001 failed: audit row remained after rollback.', 1;

PRINT 'PASS: failed procedure left verification, submission and audit state unchanged.';
GO
