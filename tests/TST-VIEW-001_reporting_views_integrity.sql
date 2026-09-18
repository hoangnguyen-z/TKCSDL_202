USE FilmContestDB;
GO

PRINT 'TST-VIEW-001 - Reporting views runtime integrity and query execution';

DECLARE
    @overview_count INT,
    @vqueue_count INT,
    @jqueue_count INT,
    @result_count INT,
    @archive_count INT;

SELECT @overview_count = COUNT(*) FROM reporting.vw_submission_overview;
SELECT @vqueue_count = COUNT(*) FROM reporting.vw_verification_queue;
SELECT @jqueue_count = COUNT(*) FROM reporting.vw_judge_work_queue;
SELECT @result_count = COUNT(*) FROM reporting.vw_result_summary;
SELECT @archive_count = COUNT(*) FROM reporting.vw_archive_catalog;

IF @overview_count = 0
    THROW 70461, 'TST-VIEW-001 failed: vw_submission_overview returned no rows.', 1;

IF @result_count = 0
    THROW 70462, 'TST-VIEW-001 failed: vw_result_summary returned no rows.', 1;

IF @archive_count = 0
    THROW 70463, 'TST-VIEW-001 failed: vw_archive_catalog returned no rows.', 1;

-- Verify JSON snapshot integrity in vw_archive_catalog
IF EXISTS (
    SELECT 1
    FROM reporting.vw_archive_catalog
    WHERE ISJSON(contest_snapshot) <> 1
       OR ISJSON(category_snapshot) <> 1
       OR ISJSON(participant_snapshot) <> 1
       OR ISJSON(technical_snapshot) <> 1
       OR ISJSON(judging_snapshot) <> 1
)
    THROW 70464, 'TST-VIEW-001 failed: vw_archive_catalog contains invalid JSON snapshots.', 1;

PRINT 'PASS: all reporting views executed with valid counts and valid JSON schema structure.';
GO
