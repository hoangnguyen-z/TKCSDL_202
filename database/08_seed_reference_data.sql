USE FilmContestDB;
GO

IF NOT EXISTS (SELECT 1 FROM iam.Role WHERE role_code = N'ADMINISTRATOR')
    INSERT INTO iam.Role (role_code, role_name, role_description)
    VALUES (N'ADMINISTRATOR', N'Administrator', N'Platform governance and master data management');
GO
IF NOT EXISTS (SELECT 1 FROM iam.Role WHERE role_code = N'ORGANIZER')
    INSERT INTO iam.Role (role_code, role_name, role_description)
    VALUES (N'ORGANIZER', N'Organizer', N'Contest operation and result management');
GO
IF NOT EXISTS (SELECT 1 FROM iam.Role WHERE role_code = N'JUDGE')
    INSERT INTO iam.Role (role_code, role_name, role_description)
    VALUES (N'JUDGE', N'Judge', N'Judging and scoring responsibilities');
GO
IF NOT EXISTS (SELECT 1 FROM iam.Role WHERE role_code = N'PARTICIPANT')
    INSERT INTO iam.Role (role_code, role_name, role_description)
    VALUES (N'PARTICIPANT', N'Participant', N'Contest registration and submission role');
GO

IF NOT EXISTS (SELECT 1 FROM reference.FilmStock WHERE brand_name = N'Kodak' AND stock_name = N'Portra 400' AND film_format_code = N'35MM')
    INSERT INTO reference.FilmStock (brand_name, stock_name, iso_native, film_format_code)
    VALUES (N'Kodak', N'Portra 400', 400, N'35MM');
GO
IF NOT EXISTS (SELECT 1 FROM reference.FilmStock WHERE brand_name = N'Ilford' AND stock_name = N'HP5 Plus' AND film_format_code = N'35MM')
    INSERT INTO reference.FilmStock (brand_name, stock_name, iso_native, film_format_code)
    VALUES (N'Ilford', N'HP5 Plus', 400, N'35MM');
GO
IF NOT EXISTS (SELECT 1 FROM reference.FilmStock WHERE brand_name = N'Kodak' AND stock_name = N'Gold 200' AND film_format_code = N'35MM')
    INSERT INTO reference.FilmStock (brand_name, stock_name, iso_native, film_format_code)
    VALUES (N'Kodak', N'Gold 200', 200, N'35MM');
GO

IF NOT EXISTS (SELECT 1 FROM reference.Camera WHERE brand_name = N'Nikon' AND model_name = N'F3')
    INSERT INTO reference.Camera (brand_name, model_name, camera_type)
    VALUES (N'Nikon', N'F3', N'SLR');
GO
IF NOT EXISTS (SELECT 1 FROM reference.Camera WHERE brand_name = N'Canon' AND model_name = N'AE-1 Program')
    INSERT INTO reference.Camera (brand_name, model_name, camera_type)
    VALUES (N'Canon', N'AE-1 Program', N'SLR');
GO
IF NOT EXISTS (SELECT 1 FROM reference.Camera WHERE brand_name = N'Olympus' AND model_name = N'OM-1')
    INSERT INTO reference.Camera (brand_name, model_name, camera_type)
    VALUES (N'Olympus', N'OM-1', N'SLR');
GO

IF NOT EXISTS (SELECT 1 FROM reference.Lens WHERE brand_name = N'Nikon' AND model_name = N'Nikkor 50mm' AND focal_description = N'50mm f/1.4')
    INSERT INTO reference.Lens (brand_name, model_name, focal_description)
    VALUES (N'Nikon', N'Nikkor 50mm', N'50mm f/1.4');
GO
IF NOT EXISTS (SELECT 1 FROM reference.Lens WHERE brand_name = N'Canon' AND model_name = N'FD 35mm' AND focal_description = N'35mm f/2.8')
    INSERT INTO reference.Lens (brand_name, model_name, focal_description)
    VALUES (N'Canon', N'FD 35mm', N'35mm f/2.8');
GO
IF NOT EXISTS (SELECT 1 FROM reference.Lens WHERE brand_name = N'Olympus' AND model_name = N'Zuiko 28mm' AND focal_description = N'28mm f/2.8')
    INSERT INTO reference.Lens (brand_name, model_name, focal_description)
    VALUES (N'Olympus', N'Zuiko 28mm', N'28mm f/2.8');
GO

IF NOT EXISTS (SELECT 1 FROM reference.Lab WHERE lab_name = N'Silver Lab' AND city_name = N'Ho Chi Minh City')
    INSERT INTO reference.Lab (lab_name, city_name, country_code)
    VALUES (N'Silver Lab', N'Ho Chi Minh City', N'VN');
GO
IF NOT EXISTS (SELECT 1 FROM reference.Lab WHERE lab_name = N'Analog Corner Lab' AND city_name = N'Hanoi')
    INSERT INTO reference.Lab (lab_name, city_name, country_code)
    VALUES (N'Analog Corner Lab', N'Hanoi', N'VN');
GO
