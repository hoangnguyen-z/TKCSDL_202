USE FilmContestDB;
GO

PRINT 'TST-ASSET-001 - Asset metadata structure, QC validation, and integrity checks';
BEGIN TRANSACTION;

DECLARE
    @organizer_user_id INT = (SELECT TOP (1) user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @frame_id INT = (SELECT TOP (1) frame_id FROM film.FilmFrame WHERE frame_number = 12),
    @expected_failure_observed BIT = 0;

IF @frame_id IS NULL OR @organizer_user_id IS NULL
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70411, 'TST-ASSET-001 blocked: frame fixture or organizer is missing.', 1;
END;

-- 1. Valid insertion
INSERT INTO film.AssetMetadata
(
    frame_id, asset_type_code, file_uri, file_extension, mime_type, file_size_bytes, width_px, height_px,
    color_space, bit_depth, dpi, checksum_sha256, scanner_model, scan_software, qc_status, qc_checked_at, qc_checked_by_user_id, qc_notes
)
VALUES
(
    @frame_id, N'RAW_TIFF', N'https://storage.test.local/raw/lan-12.tif', N'tif', N'image/tiff',
    35000000, 6000, 4000, N'Adobe RGB', 16, 4000,
    N'0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    N'Hasselblad Flextight X5', N'FlexColor 4.8', N'PASSED', SYSUTCDATETIME(), @organizer_user_id, N'Precision drum scan passed QC.'
);

-- 2. Negative test: SHA-256 length not 64 chars
SET @expected_failure_observed = 0;
BEGIN TRY
    INSERT INTO film.AssetMetadata
    (
        frame_id, asset_type_code, file_uri, file_extension, mime_type, file_size_bytes, width_px, height_px,
        color_space, bit_depth, dpi, checksum_sha256, qc_status
    )
    VALUES
    (
        @frame_id, N'PREVIEW_JPEG', N'https://storage.test.local/preview/lan-12.jpg', N'jpg', N'image/jpeg',
        500000, 1200, 800, N'sRGB', 8, 300,
        N'short_hash_invalid', N'PENDING'
    );
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: invalid SHA-256 checksum length was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70412, 'TST-ASSET-001 failed: invalid SHA-256 checksum length was accepted.', 1;
END;

-- 3. Negative test: invalid bit depth
SET @expected_failure_observed = 0;
BEGIN TRY
    INSERT INTO film.AssetMetadata
    (
        frame_id, asset_type_code, file_uri, file_extension, mime_type, file_size_bytes, width_px, height_px,
        color_space, bit_depth, dpi, checksum_sha256, qc_status
    )
    VALUES
    (
        @frame_id, N'PREVIEW_JPEG', N'https://storage.test.local/preview/lan-12.jpg', N'jpg', N'image/jpeg',
        500000, 1200, 800, N'sRGB', 10, 300,
        N'0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', N'PENDING'
    );
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: invalid bit depth (10-bit) was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70413, 'TST-ASSET-001 failed: invalid bit depth was accepted.', 1;
END;

-- 4. Negative test: duplicate (frame_id, asset_type_code)
SET @expected_failure_observed = 0;
BEGIN TRY
    INSERT INTO film.AssetMetadata
    (
        frame_id, asset_type_code, file_uri, file_extension, mime_type, file_size_bytes, width_px, height_px,
        color_space, bit_depth, dpi, checksum_sha256, qc_status
    )
    VALUES
    (
        @frame_id, N'RAW_TIFF', N'https://storage.test.local/raw/lan-12-dup.tif', N'tif', N'image/tiff',
        35000000, 6000, 4000, N'Adobe RGB', 16, 4000,
        N'0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', N'PENDING'
    );
END TRY
BEGIN CATCH
    SET @expected_failure_observed = 1;
    PRINT 'PASS: duplicate asset type for same film frame was rejected as expected.';
END CATCH;

IF @expected_failure_observed = 0
BEGIN
    ROLLBACK TRANSACTION;
    THROW 70414, 'TST-ASSET-001 failed: duplicate asset type was accepted.', 1;
END;

ROLLBACK TRANSACTION;
PRINT 'PASS: asset metadata integrity, SHA-256 validation, bit depth check, and uniqueness verified.';
GO
