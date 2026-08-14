USE FilmContestDB;
GO

PRINT 'TST-SUB-001 - Normal submission should succeed';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @registration_id INT = (
            SELECT r.registration_id
            FROM participant.Registration AS r
            INNER JOIN contest.Contest AS c
                ON c.contest_id = r.contest_id
            INNER JOIN participant.ParticipantProfile AS pp
                ON pp.participant_id = r.participant_id
            INNER JOIN iam.UserAccount AS ua
                ON ua.user_id = pp.user_id
            WHERE c.contest_code = N'FILM2026-FALL'
              AND ua.email = N'lan.participant@filmplatform.local'
        ),
        @category_id INT = (
            SELECT cc.category_id
            FROM contest.ContestCategory AS cc
            INNER JOIN contest.Contest AS c
                ON c.contest_id = cc.contest_id
            WHERE c.contest_code = N'FILM2026-FALL'
              AND cc.category_code = N'STREET'
        ),
        @frame_id INT = (
            SELECT ff.frame_id
            FROM film.FilmFrame AS ff
            INNER JOIN film.FilmRoll AS fr
                ON fr.roll_id = ff.roll_id
            WHERE fr.roll_code = N'LAN-R01'
              AND ff.frame_number = 24
        );

    DECLARE @created TABLE (submission_id INT);

    INSERT INTO @created (submission_id)
    EXEC submission.usp_create_submission
        @registration_id = @registration_id,
        @category_id = @category_id,
        @frame_id = @frame_id,
        @submission_title = N'Old Cafe Window',
        @submission_statement = N'Test submission created during database testing.',
        @scanned_image_uri = N'https://storage.example/tests/old-cafe-window.jpg',
        @thumbnail_image_uri = N'https://storage.example/tests/old-cafe-window-thumb.jpg';

    DECLARE @submission_id INT = (SELECT TOP 1 submission_id FROM @created);

    IF @submission_id IS NULL
        THROW 70003, 'Submission procedure did not return a submission id.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM verification.VerificationCase
        WHERE submission_id = @submission_id
          AND verification_status = N'PENDING'
    )
        THROW 70004, 'Verification case was not created for the submission.', 1;

    PRINT 'PASS: normal submission was created successfully.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
