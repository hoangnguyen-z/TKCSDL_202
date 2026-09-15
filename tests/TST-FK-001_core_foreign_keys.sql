USE FilmContestDB;
GO

PRINT 'TST-FK-001 - Core foreign keys must reject invalid parent references';
BEGIN TRANSACTION;

DECLARE @rejected_count INT = 0;

BEGIN TRY
    INSERT INTO participant.Registration (contest_id, participant_id)
    VALUES (-900001, -900001);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: registration invalid parent reference was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO submission.Submission
    (
        registration_id, contest_id, category_id, frame_id,
        submission_title, scanned_image_uri
    )
    VALUES (-900002, -900002, -900002, -900002, N'Invalid FK', N'https://invalid.local/image');
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: submission invalid parent reference was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO verification.VerificationCase (submission_id)
    VALUES (-900003);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: verification invalid submission reference was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id)
    VALUES (-900004, -900004, -900004);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: evaluation invalid parent reference was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO result.Result (category_id, submission_id, final_score, final_rank)
    VALUES (-900005, -900005, 0, 1);
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: result invalid parent reference was rejected.';
END CATCH;

BEGIN TRY
    INSERT INTO archive.ArchiveItem
    (
        result_id, submission_id, archived_by_user_id,
        contest_snapshot, category_snapshot, participant_snapshot,
        technical_snapshot, judging_snapshot, image_uri_snapshot
    )
    VALUES (-900006, -900006, -900006, N'{}', N'{}', N'{}', N'{}', N'{}', N'https://invalid.local/image');
END TRY
BEGIN CATCH
    SET @rejected_count += 1;
    PRINT 'PASS: archive invalid parent reference was rejected.';
END CATCH;

IF @rejected_count <> 6
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70201, 'TST-FK-001 failed: one or more core foreign keys accepted invalid references.', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM participant.Registration
    WHERE contest_id <= -900000 OR participant_id <= -900000
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70202, 'TST-FK-001 failed: invalid registration row remained after checks.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: all six core foreign-key checks rejected invalid references and left no rows.';
GO
