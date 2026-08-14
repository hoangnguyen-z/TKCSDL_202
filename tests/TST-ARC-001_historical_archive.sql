USE FilmContestDB;
GO

PRINT 'TST-ARC-001 - Archive snapshot should remain stable if live profile changes';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @archive_item_id INT = (
            SELECT ai.archive_item_id
            FROM archive.ArchiveItem AS ai
            INNER JOIN result.Result AS r
                ON r.result_id = ai.result_id
            INNER JOIN contest.ContestCategory AS cc
                ON cc.category_id = r.category_id
            INNER JOIN contest.Contest AS c
                ON c.contest_id = cc.contest_id
            WHERE c.contest_code = N'FILM2026-SPRING'
              AND cc.category_code = N'LANDSCAPE'
        ),
        @participant_id INT = (
            SELECT pp.participant_id
            FROM participant.ParticipantProfile AS pp
            INNER JOIN iam.UserAccount AS ua
                ON ua.user_id = pp.user_id
            WHERE ua.email = N'lan.participant@filmplatform.local'
        ),
        @before_snapshot NVARCHAR(MAX),
        @after_snapshot NVARCHAR(MAX);

    SELECT @before_snapshot = participant_snapshot
    FROM archive.ArchiveItem
    WHERE archive_item_id = @archive_item_id;

    UPDATE participant.ParticipantProfile
    SET display_name = N'Lan Nguyen Updated For Test',
        updated_at = SYSUTCDATETIME()
    WHERE participant_id = @participant_id;

    SELECT @after_snapshot = participant_snapshot
    FROM archive.ArchiveItem
    WHERE archive_item_id = @archive_item_id;

    IF @before_snapshot <> @after_snapshot
        THROW 70012, 'Archive snapshot changed after live profile update.', 1;

    PRINT 'PASS: archive snapshot remained stable.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
