USE FilmContestDB;
GO

PRINT 'TST-SEED-001 - Reference seed completeness, uniqueness and referential consistency';

DECLARE @violation_count INT = 0;

IF (SELECT COUNT(*) FROM iam.Role WHERE role_code IN (N'ADMINISTRATOR', N'ORGANIZER', N'JUDGE', N'PARTICIPANT')) <> 4
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: required role reference codes are incomplete.';
END;

IF (SELECT COUNT(*) FROM reference.FilmStock) < 3
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: expected at least three seeded film stocks.';
END;

IF (SELECT COUNT(*) FROM reference.Camera) < 3
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: expected at least three seeded cameras.';
END;

IF (SELECT COUNT(*) FROM reference.Lens) < 3
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: expected at least three seeded lenses.';
END;

IF (SELECT COUNT(*) FROM reference.Lab) < 2
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: expected at least two seeded labs.';
END;

IF EXISTS
(
    SELECT brand_name, stock_name, film_format_code
    FROM reference.FilmStock
    GROUP BY brand_name, stock_name, film_format_code
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate film stock reference key detected.';
END;

IF EXISTS
(
    SELECT brand_name, model_name
    FROM reference.Camera
    GROUP BY brand_name, model_name
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate camera reference key detected.';
END;

IF EXISTS
(
    SELECT brand_name, model_name, focal_description
    FROM reference.Lens
    GROUP BY brand_name, model_name, focal_description
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate lens reference key detected.';
END;

IF EXISTS
(
    SELECT lab_name, city_name, country_code
    FROM reference.Lab
    GROUP BY lab_name, city_name, country_code
    HAVING COUNT(*) > 1
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: duplicate lab reference key detected.';
END;

IF EXISTS
(
    SELECT r.roll_id
    FROM film.FilmRoll AS r
    LEFT JOIN reference.FilmStock AS s ON s.film_stock_id = r.film_stock_id
    LEFT JOIN reference.Lab AS l ON l.lab_id = r.lab_id
    WHERE (r.film_stock_id IS NOT NULL AND s.film_stock_id IS NULL)
       OR (r.lab_id IS NOT NULL AND l.lab_id IS NULL)
)
BEGIN
    SET @violation_count += 1;
    PRINT 'FAIL: film roll contains an orphan reference-data link.';
END;

IF @violation_count <> 0
    THROW 70231, 'TST-SEED-001 failed: reference seed integrity violations were detected.', 1;

PRINT 'PASS: reference seed has required coverage, unique business keys and no orphan film-roll references.';
GO
