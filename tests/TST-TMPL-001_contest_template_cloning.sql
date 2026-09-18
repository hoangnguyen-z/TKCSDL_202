USE FilmContestDB;
GO

PRINT 'TST-TMPL-001 - Contest template cloning and structure replication';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @template_id INT = (SELECT TOP (1) template_id FROM contest.ContestTemplate WHERE template_code = N'TMPL_STANDARD_35MM'),
    @new_contest_code NVARCHAR(30) = N'TST-TMPL-' + CONVERT(NVARCHAR(10), ABS(CHECKSUM(NEWID()))),
    @cloned_contest_id INT,
    @cloned_cat_count INT,
    @cloned_round_count INT,
    @cloned_crit_count INT,
    @cloned_award_count INT;

IF @template_id IS NULL OR @organizer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70401, 'TST-TMPL-001 blocked: template fixture or organizer user is missing.', 1;
END;

-- Execute cloning procedure
EXEC contest.usp_create_contest_from_template
    @template_id = @template_id,
    @contest_code = @new_contest_code,
    @contest_title = N'Cloned 35mm Analog Contest',
    @contest_theme = N'Analog Masters',
    @contest_summary = N'Automated test contest created from template.',
    @registration_open_at = '2026-10-01T00:00:00',
    @registration_close_at = '2026-10-15T23:59:59',
    @submission_open_at = '2026-10-05T00:00:00',
    @submission_close_at = '2026-10-25T23:59:59',
    @created_by_user_id = @organizer_user_id;

SELECT @cloned_contest_id = contest_id
FROM contest.Contest
WHERE contest_code = @new_contest_code;

IF @cloned_contest_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70402, 'TST-TMPL-001 failed: contest was not created from template.', 1;
END;

-- Verify cloned categories count matches template
SELECT @cloned_cat_count = COUNT(*)
FROM contest.ContestCategory
WHERE contest_id = @cloned_contest_id;

IF @cloned_cat_count <> 2
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70403, 'TST-TMPL-001 failed: category count mismatch after cloning.', 1;
END;

-- Verify cloned rounds count
SELECT @cloned_round_count = COUNT(*)
FROM contest.JudgingRound AS jr
INNER JOIN contest.ContestCategory AS cc ON cc.category_id = jr.category_id
WHERE cc.contest_id = @cloned_contest_id;

IF @cloned_round_count <> 4
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70404, 'TST-TMPL-001 failed: judging round count mismatch after cloning.', 1;
END;

-- Verify criteria and awards cloned
SELECT @cloned_crit_count = COUNT(*)
FROM contest.ScoringCriterion AS sc
INNER JOIN contest.JudgingRound AS jr ON jr.round_id = sc.round_id
INNER JOIN contest.ContestCategory AS cc ON cc.category_id = jr.category_id
WHERE cc.contest_id = @cloned_contest_id;

SELECT @cloned_award_count = COUNT(*)
FROM contest.AwardDefinition AS ad
INNER JOIN contest.ContestCategory AS cc ON cc.category_id = ad.category_id
WHERE cc.contest_id = @cloned_contest_id;

IF @cloned_crit_count = 0 OR @cloned_award_count = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70405, 'TST-TMPL-001 failed: scoring criteria or awards were not cloned.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: contest template cloning replicated categories, rounds, criteria, and awards successfully.';
GO
