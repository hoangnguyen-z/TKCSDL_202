USE FilmContestDB;
GO

PRINT 'TST-FRAME-001 - Duplicate frame number in same roll must fail';
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @roll_id INT = (SELECT roll_id FROM film.FilmRoll WHERE roll_code = N'LAN-R01'),
        @camera_id INT = (SELECT camera_id FROM reference.Camera WHERE brand_name = N'Nikon' AND model_name = N'F3'),
        @lens_id INT = (SELECT lens_id FROM reference.Lens WHERE brand_name = N'Nikon' AND model_name = N'Nikkor 50mm');

    INSERT INTO film.FilmFrame
    (
        roll_id,
        camera_id,
        lens_id,
        frame_number,
        frame_title,
        frame_status
    )
    VALUES
    (
        @roll_id,
        @camera_id,
        @lens_id,
        12,
        N'Duplicate Frame',
        N'DRAFT'
    );

    ROLLBACK TRANSACTION;
    THROW 70002, 'TST-FRAME-001 failed: duplicate frame number was inserted.', 1;
END TRY
BEGIN CATCH
    PRINT 'PASS: duplicate frame number was rejected as expected.';
    ROLLBACK TRANSACTION;
END CATCH;
GO
