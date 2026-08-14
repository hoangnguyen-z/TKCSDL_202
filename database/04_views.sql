USE FilmContestDB;
GO

CREATE OR ALTER VIEW reporting.vw_submission_overview
AS
SELECT
    s.submission_id,
    c.contest_code,
    c.contest_title,
    cc.category_code,
    cc.category_name,
    pp.participant_id,
    pp.display_name AS participant_display_name,
    fr.roll_code,
    ff.frame_number,
    ff.frame_title,
    s.submission_title,
    s.submitted_at,
    s.submission_status,
    vc.verification_status,
    vc.final_decision_code
FROM submission.Submission AS s
INNER JOIN contest.Contest AS c
    ON c.contest_id = s.contest_id
INNER JOIN contest.ContestCategory AS cc
    ON cc.category_id = s.category_id
INNER JOIN participant.Registration AS r
    ON r.registration_id = s.registration_id
INNER JOIN participant.ParticipantProfile AS pp
    ON pp.participant_id = r.participant_id
INNER JOIN film.FilmFrame AS ff
    ON ff.frame_id = s.frame_id
INNER JOIN film.FilmRoll AS fr
    ON fr.roll_id = ff.roll_id
LEFT JOIN verification.VerificationCase AS vc
    ON vc.submission_id = s.submission_id;
GO

CREATE OR ALTER VIEW reporting.vw_verification_queue
AS
SELECT
    s.submission_id,
    c.contest_code,
    cc.category_code,
    pp.display_name AS participant_display_name,
    s.submission_title,
    s.submitted_at,
    vc.verification_status,
    vc.completeness_status,
    vc.technical_status
FROM submission.Submission AS s
INNER JOIN verification.VerificationCase AS vc
    ON vc.submission_id = s.submission_id
INNER JOIN contest.Contest AS c
    ON c.contest_id = s.contest_id
INNER JOIN contest.ContestCategory AS cc
    ON cc.category_id = s.category_id
INNER JOIN participant.Registration AS r
    ON r.registration_id = s.registration_id
INNER JOIN participant.ParticipantProfile AS pp
    ON pp.participant_id = r.participant_id
WHERE vc.verification_status IN (N'PENDING', N'UNDER_REVIEW', N'NEEDS_CLARIFICATION');
GO

CREATE OR ALTER VIEW reporting.vw_judge_work_queue
AS
SELECT
    ja.judge_assignment_id,
    ja.judge_user_id,
    ua.display_name AS judge_display_name,
    jr.round_id,
    jr.round_name,
    jr.round_status,
    cc.category_id,
    cc.category_code,
    cc.category_name,
    c.contest_id,
    c.contest_code,
    e.evaluation_id,
    e.submission_id,
    e.evaluation_status,
    e.total_score,
    e.submitted_at
FROM judging.JudgeAssignment AS ja
INNER JOIN iam.UserAccount AS ua
    ON ua.user_id = ja.judge_user_id
INNER JOIN contest.JudgingRound AS jr
    ON jr.round_id = ja.round_id
INNER JOIN contest.ContestCategory AS cc
    ON cc.category_id = jr.category_id
INNER JOIN contest.Contest AS c
    ON c.contest_id = cc.contest_id
LEFT JOIN judging.Evaluation AS e
    ON e.round_id = ja.round_id
   AND e.judge_user_id = ja.judge_user_id;
GO

CREATE OR ALTER VIEW reporting.vw_result_summary
AS
SELECT
    r.result_id,
    c.contest_code,
    cc.category_code,
    cc.category_name,
    s.submission_id,
    s.submission_title,
    pp.display_name AS participant_display_name,
    r.final_score,
    r.final_rank,
    r.result_status,
    r.published_at,
    ad.award_code,
    ad.award_name
FROM result.Result AS r
INNER JOIN contest.ContestCategory AS cc
    ON cc.category_id = r.category_id
INNER JOIN contest.Contest AS c
    ON c.contest_id = cc.contest_id
INNER JOIN submission.Submission AS s
    ON s.submission_id = r.submission_id
INNER JOIN participant.Registration AS reg
    ON reg.registration_id = s.registration_id
INNER JOIN participant.ParticipantProfile AS pp
    ON pp.participant_id = reg.participant_id
LEFT JOIN result.AwardAssignment AS aa
    ON aa.result_id = r.result_id
LEFT JOIN contest.AwardDefinition AS ad
    ON ad.award_definition_id = aa.award_definition_id;
GO

CREATE OR ALTER VIEW reporting.vw_archive_catalog
AS
SELECT
    ai.archive_item_id,
    ai.archive_status,
    ai.archived_at,
    r.result_id,
    r.final_rank,
    r.final_score,
    s.submission_id,
    s.submission_title,
    ai.image_uri_snapshot,
    ai.contest_snapshot,
    ai.category_snapshot,
    ai.participant_snapshot
FROM archive.ArchiveItem AS ai
INNER JOIN result.Result AS r
    ON r.result_id = ai.result_id
INNER JOIN submission.Submission AS s
    ON s.submission_id = ai.submission_id;
GO
