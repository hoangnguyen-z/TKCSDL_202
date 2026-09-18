USE FilmContestDB;
GO

PRINT 'TST-REG-001 - Duplicate registration must fail';
BEGIN TRANSACTION;

DECLARE @expected_failure_observed BIT = 0;

BEGIN TRY
    DECLARE
        @contest_id INT = (SELECT contest_id FROM contest.Contest WHERE contest_code = N'FILM2026-FALL'),
        @participant_id INT = (
            SELECT pp.participant_id
            FROM participant.ParticipantProfile AS pp
            INNER JOIN iam.UserAccount AS ua
                ON ua.user_id = pp.user_id
            WHERE ua.email = N'lan.participant@filmplatform.local'
        );

    INSERT INTO participant.Registration
    (
        contest_id,
        participant_id,
        registration_status,
        eligibility_status
    )
    VALUES
    (
        @contest_id,
        @participant_id,
        N'PENDING',
        N'PENDING'
    );
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: duplicate registration was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70001, 'TST-REG-001 failed: duplicate registration was inserted.', 1;
END;

ROLLBACK TRANSACTION;
GO
