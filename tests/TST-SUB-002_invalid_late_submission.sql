USE FilmContestDB;
GO

PRINT 'TST-SUB-002 - Late submission should fail';
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
            WHERE c.contest_code = N'FILM2026-SPRING'
              AND ua.email = N'lan.participant@filmplatform.local'
        ),
        @category_id INT = (
            SELECT cc.category_id
            FROM contest.ContestCategory AS cc
            INNER JOIN contest.Contest AS c
                ON c.contest_id = cc.contest_id
            WHERE c.contest_code = N'FILM2026-SPRING'
              AND cc.category_code = N'LANDSCAPE'
        ),
        @frame_id INT = (
            SELECT ff.frame_id
            FROM film.FilmFrame AS ff
            INNER JOIN film.FilmRoll AS fr
                ON fr.roll_id = ff.roll_id
            WHERE fr.roll_code = N'LAN-R01'
              AND ff.frame_number = 24
        );

    EXEC submission.usp_create_submission
        @registration_id = @registration_id,
        @category_id = @category_id,
        @frame_id = @frame_id,
        @submission_title = N'Should Fail',
        @submission_statement = N'Late submission test.',
        @scanned_image_uri = N'https://storage.example/tests/late.jpg',
        @thumbnail_image_uri = N'https://storage.example/tests/late-thumb.jpg';

    ROLLBACK TRANSACTION;
    THROW 70005, 'TST-SUB-002 failed: late submission was accepted.', 1;
END TRY
BEGIN CATCH
    PRINT 'PASS: late submission was rejected as expected.';
    ROLLBACK TRANSACTION;
END CATCH;
GO
