USE FilmContestDB;
GO

PRINT 'TST-SEED-002 - Demo data graph, ownership and business-key consistency';

DECLARE @violation_count INT = 0;

IF EXISTS
(
    SELECT 1
    FROM iam.UserRole AS ur
    LEFT JOIN iam.UserAccount AS u ON u.user_id = ur.user_id
    LEFT JOIN iam.Role AS r ON r.role_id = ur.role_id
    WHERE u.user_id IS NULL OR r.role_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: user-role graph contains an orphan row.';
END;

IF EXISTS
(
    SELECT 1
    FROM participant.ParticipantProfile AS p
    LEFT JOIN iam.UserAccount AS u ON u.user_id = p.user_id
    WHERE u.user_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: participant profile has no user owner.';
END;

IF EXISTS
(
    SELECT 1
    FROM participant.Registration AS r
    LEFT JOIN contest.Contest AS c ON c.contest_id = r.contest_id
    LEFT JOIN participant.ParticipantProfile AS p ON p.participant_id = r.participant_id
    WHERE c.contest_id IS NULL OR p.participant_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: registration graph contains an orphan contest or participant.';
END;

IF EXISTS
(
    SELECT 1
    FROM film.FilmRoll AS r
    LEFT JOIN participant.ParticipantProfile AS p ON p.participant_id = r.participant_id
    WHERE p.participant_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: film roll has no participant owner.';
END;

IF EXISTS
(
    SELECT 1
    FROM film.FilmFrame AS f
    LEFT JOIN film.FilmRoll AS r ON r.roll_id = f.roll_id
    WHERE r.roll_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: film frame has no parent roll.';
END;

IF EXISTS
(
    SELECT 1
    FROM contest.ContestCategory AS cc
    LEFT JOIN contest.Contest AS c ON c.contest_id = cc.contest_id
    WHERE c.contest_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: contest category has no parent contest.';
END;

IF EXISTS
(
    SELECT 1
    FROM contest.JudgingRound AS jr
    LEFT JOIN contest.ContestCategory AS cc ON cc.category_id = jr.category_id
    WHERE cc.category_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: judging round has no parent category.';
END;

IF EXISTS
(
    SELECT 1
    FROM contest.ScoringCriterion AS sc
    LEFT JOIN contest.JudgingRound AS jr ON jr.round_id = sc.round_id
    WHERE jr.round_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: scoring criterion has no parent round.';
END;

IF EXISTS
(
    SELECT 1
    FROM submission.Submission AS s
    LEFT JOIN participant.Registration AS r ON r.registration_id = s.registration_id
    LEFT JOIN contest.ContestCategory AS cc ON cc.category_id = s.category_id
    LEFT JOIN film.FilmFrame AS f ON f.frame_id = s.frame_id
    WHERE r.registration_id IS NULL OR cc.category_id IS NULL OR f.frame_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: submission graph contains an orphan registration, category or frame.';
END;

IF EXISTS
(
    SELECT 1
    FROM submission.Submission AS s
    INNER JOIN participant.Registration AS r ON r.registration_id = s.registration_id
    INNER JOIN film.FilmFrame AS f ON f.frame_id = s.frame_id
    INNER JOIN film.FilmRoll AS fr ON fr.roll_id = f.roll_id
    INNER JOIN participant.ParticipantProfile AS p ON p.participant_id = r.participant_id
    WHERE fr.participant_id <> p.participant_id
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: submission owner does not match the registered participant.';
END;

IF EXISTS
(
    SELECT 1
    FROM verification.VerificationCase AS vc
    LEFT JOIN submission.Submission AS s ON s.submission_id = vc.submission_id
    WHERE s.submission_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: verification case has no submission.';
END;

IF EXISTS
(
    SELECT 1
    FROM judging.Evaluation AS e
    LEFT JOIN contest.JudgingRound AS jr ON jr.round_id = e.round_id
    LEFT JOIN submission.Submission AS s ON s.submission_id = e.submission_id
    LEFT JOIN iam.UserAccount AS u ON u.user_id = e.judge_user_id
    WHERE jr.round_id IS NULL OR s.submission_id IS NULL OR u.user_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: evaluation graph contains an orphan round, submission or judge.';
END;

IF EXISTS
(
    SELECT 1
    FROM judging.EvaluationScore AS es
    LEFT JOIN judging.Evaluation AS e ON e.evaluation_id = es.evaluation_id
    LEFT JOIN contest.ScoringCriterion AS sc ON sc.criterion_id = es.criterion_id
    WHERE e.evaluation_id IS NULL OR sc.criterion_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: evaluation score has no evaluation or criterion.';
END;

IF EXISTS
(
    SELECT 1
    FROM result.Result AS r
    LEFT JOIN contest.ContestCategory AS cc ON cc.category_id = r.category_id
    LEFT JOIN submission.Submission AS s ON s.submission_id = r.submission_id
    WHERE cc.category_id IS NULL OR s.submission_id IS NULL OR s.category_id <> r.category_id
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: result category/submission graph is inconsistent.';
END;

IF EXISTS
(
    SELECT 1
    FROM archive.ArchiveItem AS a
    LEFT JOIN result.Result AS r ON r.result_id = a.result_id
    LEFT JOIN submission.Submission AS s ON s.submission_id = a.submission_id
    WHERE r.result_id IS NULL OR s.submission_id IS NULL
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: archive item has no result or submission source.';
END;

IF EXISTS
(
    SELECT contest_id, participant_id
    FROM participant.Registration
    GROUP BY contest_id, participant_id
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate registration business key detected.';
END;

IF EXISTS
(
    SELECT contest_id, frame_id
    FROM submission.Submission
    GROUP BY contest_id, frame_id
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate submission business key detected.';
END;

IF @violation_count <> 0
    THROW 70241, 'TST-SEED-002 failed: demo data graph consistency violations were detected.', 1;

PRINT 'PASS: demo data graph, ownership links and key consistency checks returned zero violations.';
GO
