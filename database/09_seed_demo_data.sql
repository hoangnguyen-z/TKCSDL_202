USE FilmContestDB;
GO

IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'admin@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'admin@filmplatform.local', N'admin_root', N'System Administrator');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'olivia.organizer@filmplatform.local', N'olivia_organizer', N'Olivia Organizer');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'mina.judge@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'mina.judge@filmplatform.local', N'mina_judge', N'Mina Judge');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'quang.judge@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'quang.judge@filmplatform.local', N'quang_judge', N'Quang Judge');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'lan.participant@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'lan.participant@filmplatform.local', N'lan_participant', N'Lan Participant');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'bao.participant@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'bao.participant@filmplatform.local', N'bao_participant', N'Bao Participant');
GO
IF NOT EXISTS (SELECT 1 FROM iam.UserAccount WHERE email = N'son.hybrid@filmplatform.local')
    INSERT INTO iam.UserAccount (email, username, display_name)
    VALUES (N'son.hybrid@filmplatform.local', N'son_hybrid', N'Son Hybrid');
GO

DECLARE
    @admin_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'admin@filmplatform.local'),
    @organizer_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'olivia.organizer@filmplatform.local'),
    @judge_mina_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'mina.judge@filmplatform.local'),
    @judge_quang_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'quang.judge@filmplatform.local'),
    @participant_lan_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'lan.participant@filmplatform.local'),
    @participant_bao_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'bao.participant@filmplatform.local'),
    @hybrid_user_id INT = (SELECT user_id FROM iam.UserAccount WHERE email = N'son.hybrid@filmplatform.local');

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @admin_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'ADMINISTRATOR'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @admin_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @organizer_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'ORGANIZER'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @organizer_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @judge_mina_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'JUDGE'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @judge_mina_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @judge_quang_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'JUDGE'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @judge_quang_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @participant_lan_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'PARTICIPANT'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @participant_lan_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @participant_bao_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code = N'PARTICIPANT'
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @participant_bao_user_id AND role_id = r.role_id);

INSERT INTO iam.UserRole (user_id, role_id, assigned_by_user_id)
SELECT @hybrid_user_id, r.role_id, @admin_user_id
FROM iam.Role AS r
WHERE r.role_code IN (N'ORGANIZER', N'JUDGE')
  AND NOT EXISTS (SELECT 1 FROM iam.UserRole WHERE user_id = @hybrid_user_id AND role_id = r.role_id);

IF NOT EXISTS (SELECT 1 FROM participant.ParticipantProfile WHERE user_id = @participant_lan_user_id)
    INSERT INTO participant.ParticipantProfile (user_id, display_name, biography, portfolio_url, country_code)
    VALUES (@participant_lan_user_id, N'Lan Nguyen', N'Film street and portrait photographer based in Ho Chi Minh City.', N'https://portfolio.example/lan', N'VN');

IF NOT EXISTS (SELECT 1 FROM participant.ParticipantProfile WHERE user_id = @participant_bao_user_id)
    INSERT INTO participant.ParticipantProfile (user_id, display_name, biography, portfolio_url, country_code)
    VALUES (@participant_bao_user_id, N'Bao Tran', N'Analog photographer interested in documentary city life.', N'https://portfolio.example/bao', N'VN');

DECLARE
    @participant_lan_id INT = (SELECT participant_id FROM participant.ParticipantProfile WHERE user_id = @participant_lan_user_id),
    @participant_bao_id INT = (SELECT participant_id FROM participant.ParticipantProfile WHERE user_id = @participant_bao_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.Contest WHERE contest_code = N'FILM2026-FALL')
    INSERT INTO contest.Contest
    (
        contest_code,
        contest_title,
        contest_theme,
        contest_summary,
        registration_open_at,
        registration_close_at,
        submission_open_at,
        submission_close_at,
        contest_status,
        created_by_user_id
    )
    VALUES
    (
        N'FILM2026-FALL',
        N'Saigon Analog Autumn 2026',
        N'Urban Memory',
        N'Open contest for film photography with a focus on analog storytelling and technical provenance.',
        '2026-08-01T00:00:00',
        '2026-09-10T23:59:59',
        '2026-08-05T00:00:00',
        '2026-09-15T23:59:59',
        N'OPEN',
        @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.Contest WHERE contest_code = N'FILM2026-SPRING')
    INSERT INTO contest.Contest
    (
        contest_code,
        contest_title,
        contest_theme,
        contest_summary,
        registration_open_at,
        registration_close_at,
        submission_open_at,
        submission_close_at,
        result_publish_at,
        contest_status,
        created_by_user_id
    )
    VALUES
    (
        N'FILM2026-SPRING',
        N'Vietnam Film Landscape Spring 2026',
        N'Landscape and Light',
        N'Completed contest used for result and archive demonstration.',
        '2026-03-01T00:00:00',
        '2026-04-01T23:59:59',
        '2026-03-05T00:00:00',
        '2026-04-15T23:59:59',
        '2026-06-15T09:00:00',
        N'FINALIZED',
        @organizer_user_id
    );

DECLARE
    @contest_fall_id INT = (SELECT contest_id FROM contest.Contest WHERE contest_code = N'FILM2026-FALL'),
    @contest_spring_id INT = (SELECT contest_id FROM contest.Contest WHERE contest_code = N'FILM2026-SPRING');

IF NOT EXISTS (SELECT 1 FROM contest.ContestCategory WHERE contest_id = @contest_fall_id AND category_code = N'STREET')
    INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_description, category_status, sort_order, created_by_user_id)
    VALUES (@contest_fall_id, N'STREET', N'Street', N'Urban street photography on film.', N'ACTIVE', 1, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.ContestCategory WHERE contest_id = @contest_fall_id AND category_code = N'PORTRAIT')
    INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_description, category_status, sort_order, created_by_user_id)
    VALUES (@contest_fall_id, N'PORTRAIT', N'Portrait', N'Film-based portrait storytelling.', N'ACTIVE', 2, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.ContestCategory WHERE contest_id = @contest_spring_id AND category_code = N'LANDSCAPE')
    INSERT INTO contest.ContestCategory (contest_id, category_code, category_name, category_description, category_status, sort_order, created_by_user_id)
    VALUES (@contest_spring_id, N'LANDSCAPE', N'Landscape', N'Landscape and natural light category.', N'ACTIVE', 1, @organizer_user_id);

DECLARE
    @fall_street_category_id INT = (SELECT category_id FROM contest.ContestCategory WHERE contest_id = @contest_fall_id AND category_code = N'STREET'),
    @fall_portrait_category_id INT = (SELECT category_id FROM contest.ContestCategory WHERE contest_id = @contest_fall_id AND category_code = N'PORTRAIT'),
    @spring_landscape_category_id INT = (SELECT category_id FROM contest.ContestCategory WHERE contest_id = @contest_spring_id AND category_code = N'LANDSCAPE');

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @fall_street_category_id AND round_number = 1)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @fall_street_category_id, 1, N'Street Round 1', 1, N'OPEN', '2026-09-16T00:00:00', '2026-09-20T23:59:59', 0, @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @fall_street_category_id AND round_number = 2)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @fall_street_category_id, 2, N'Street Final Round', 2, N'DRAFT', '2026-09-22T00:00:00', '2026-09-25T23:59:59', 1, @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @fall_portrait_category_id AND round_number = 1)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @fall_portrait_category_id, 1, N'Portrait Round 1', 1, N'CLOSED', '2026-08-01T00:00:00', '2026-08-07T23:59:59', 0, @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @fall_portrait_category_id AND round_number = 2)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @fall_portrait_category_id, 2, N'Portrait Final Round', 2, N'CLOSED', '2026-08-08T00:00:00', '2026-08-13T23:59:59', 1, @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @spring_landscape_category_id AND round_number = 1)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @spring_landscape_category_id, 1, N'Landscape Round 1', 1, N'FINALIZED', '2026-04-20T00:00:00', '2026-04-25T23:59:59', 0, @organizer_user_id
    );

IF NOT EXISTS (SELECT 1 FROM contest.JudgingRound WHERE category_id = @spring_landscape_category_id AND round_number = 2)
    INSERT INTO contest.JudgingRound
    (
        category_id, round_number, round_name, round_sequence, round_status, evaluation_open_at, evaluation_close_at, is_final_round, created_by_user_id
    )
    VALUES
    (
        @spring_landscape_category_id, 2, N'Landscape Final Round', 2, N'FINALIZED', '2026-04-27T00:00:00', '2026-05-02T23:59:59', 1, @organizer_user_id
    );

DECLARE
    @portrait_round1_id INT = (SELECT round_id FROM contest.JudgingRound WHERE category_id = @fall_portrait_category_id AND round_number = 1),
    @portrait_round2_id INT = (SELECT round_id FROM contest.JudgingRound WHERE category_id = @fall_portrait_category_id AND round_number = 2),
    @street_round1_id INT = (SELECT round_id FROM contest.JudgingRound WHERE category_id = @fall_street_category_id AND round_number = 1),
    @spring_landscape_round2_id INT = (SELECT round_id FROM contest.JudgingRound WHERE category_id = @spring_landscape_category_id AND round_number = 2);

IF NOT EXISTS (SELECT 1 FROM contest.ScoringCriterion WHERE round_id = @portrait_round1_id AND criterion_code = N'COMPOSITION')
    INSERT INTO contest.ScoringCriterion (round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, sort_order, created_by_user_id)
    VALUES
    (@portrait_round1_id, N'COMPOSITION', N'Composition', 50.00, 0.00, 10.00, 1, @organizer_user_id),
    (@portrait_round1_id, N'CHARACTER', N'Character Presence', 50.00, 0.00, 10.00, 2, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.ScoringCriterion WHERE round_id = @portrait_round2_id AND criterion_code = N'EMOTION')
    INSERT INTO contest.ScoringCriterion (round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, sort_order, created_by_user_id)
    VALUES
    (@portrait_round2_id, N'EMOTION', N'Emotional Impact', 40.00, 0.00, 10.00, 1, @organizer_user_id),
    (@portrait_round2_id, N'TONAL', N'Tonal Range', 30.00, 0.00, 10.00, 2, @organizer_user_id),
    (@portrait_round2_id, N'TECH', N'Technical Execution', 30.00, 0.00, 10.00, 3, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.ScoringCriterion WHERE round_id = @street_round1_id AND criterion_code = N'STORY')
    INSERT INTO contest.ScoringCriterion (round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, sort_order, created_by_user_id)
    VALUES
    (@street_round1_id, N'STORY', N'Storytelling', 50.00, 0.00, 10.00, 1, @organizer_user_id),
    (@street_round1_id, N'TIMING', N'Moment and Timing', 50.00, 0.00, 10.00, 2, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.ScoringCriterion WHERE round_id = @spring_landscape_round2_id AND criterion_code = N'LIGHT')
    INSERT INTO contest.ScoringCriterion (round_id, criterion_code, criterion_name, weight_percent, score_min_value, score_max_value, sort_order, created_by_user_id)
    VALUES
    (@spring_landscape_round2_id, N'LIGHT', N'Light Control', 40.00, 0.00, 10.00, 1, @organizer_user_id),
    (@spring_landscape_round2_id, N'COMPOSITION', N'Composition', 35.00, 0.00, 10.00, 2, @organizer_user_id),
    (@spring_landscape_round2_id, N'ATMOSPHERE', N'Atmosphere', 25.00, 0.00, 10.00, 3, @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.AwardDefinition WHERE category_id = @fall_portrait_category_id AND award_code = N'FIRST')
    INSERT INTO contest.AwardDefinition (category_id, award_code, award_name, rank_order, award_type, prize_description, created_by_user_id)
    VALUES
    (@fall_portrait_category_id, N'FIRST', N'First Prize', 1, N'RANK', N'Portrait first prize', @organizer_user_id),
    (@fall_portrait_category_id, N'SECOND', N'Second Prize', 2, N'RANK', N'Portrait second prize', @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM contest.AwardDefinition WHERE category_id = @spring_landscape_category_id AND award_code = N'FIRST')
    INSERT INTO contest.AwardDefinition (category_id, award_code, award_name, rank_order, award_type, prize_description, created_by_user_id)
    VALUES
    (@spring_landscape_category_id, N'FIRST', N'First Prize', 1, N'RANK', N'Landscape first prize', @organizer_user_id);

IF NOT EXISTS (SELECT 1 FROM participant.Registration WHERE contest_id = @contest_fall_id AND participant_id = @participant_lan_id)
    INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note)
    VALUES (@contest_fall_id, @participant_lan_id, N'APPROVED', N'ELIGIBLE', '2026-08-02T09:00:00', '2026-08-03T10:00:00', @organizer_user_id, N'Eligible for submission');

IF NOT EXISTS (SELECT 1 FROM participant.Registration WHERE contest_id = @contest_fall_id AND participant_id = @participant_bao_id)
    INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note)
    VALUES (@contest_fall_id, @participant_bao_id, N'APPROVED', N'ELIGIBLE', '2026-08-02T11:00:00', '2026-08-03T10:30:00', @organizer_user_id, N'Eligible for submission');

IF NOT EXISTS (SELECT 1 FROM participant.Registration WHERE contest_id = @contest_spring_id AND participant_id = @participant_lan_id)
    INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note)
    VALUES (@contest_spring_id, @participant_lan_id, N'APPROVED', N'ELIGIBLE', '2026-03-02T09:00:00', '2026-03-04T10:00:00', @organizer_user_id, N'Eligible for landscape category');

IF NOT EXISTS (SELECT 1 FROM participant.Registration WHERE contest_id = @contest_spring_id AND participant_id = @participant_bao_id)
    INSERT INTO participant.Registration (contest_id, participant_id, registration_status, eligibility_status, applied_at, reviewed_at, reviewed_by_user_id, review_note)
    VALUES (@contest_spring_id, @participant_bao_id, N'APPROVED', N'ELIGIBLE', '2026-03-02T12:00:00', '2026-03-04T10:15:00', @organizer_user_id, N'Eligible for landscape category');

DECLARE
    @registration_fall_lan_id INT = (SELECT registration_id FROM participant.Registration WHERE contest_id = @contest_fall_id AND participant_id = @participant_lan_id),
    @registration_fall_bao_id INT = (SELECT registration_id FROM participant.Registration WHERE contest_id = @contest_fall_id AND participant_id = @participant_bao_id),
    @registration_spring_lan_id INT = (SELECT registration_id FROM participant.Registration WHERE contest_id = @contest_spring_id AND participant_id = @participant_lan_id);

DECLARE
    @kodak_portra_id INT = (SELECT film_stock_id FROM reference.FilmStock WHERE brand_name = N'Kodak' AND stock_name = N'Portra 400'),
    @ilford_hp5_id INT = (SELECT film_stock_id FROM reference.FilmStock WHERE brand_name = N'Ilford' AND stock_name = N'HP5 Plus'),
    @kodak_gold_id INT = (SELECT film_stock_id FROM reference.FilmStock WHERE brand_name = N'Kodak' AND stock_name = N'Gold 200'),
    @silver_lab_id INT = (SELECT lab_id FROM reference.Lab WHERE lab_name = N'Silver Lab'),
    @analog_corner_lab_id INT = (SELECT lab_id FROM reference.Lab WHERE lab_name = N'Analog Corner Lab'),
    @nikon_f3_id INT = (SELECT camera_id FROM reference.Camera WHERE brand_name = N'Nikon' AND model_name = N'F3'),
    @canon_ae1_id INT = (SELECT camera_id FROM reference.Camera WHERE brand_name = N'Canon' AND model_name = N'AE-1 Program'),
    @olympus_om1_id INT = (SELECT camera_id FROM reference.Camera WHERE brand_name = N'Olympus' AND model_name = N'OM-1'),
    @nikkor_50_id INT = (SELECT lens_id FROM reference.Lens WHERE brand_name = N'Nikon' AND model_name = N'Nikkor 50mm'),
    @canon_35_id INT = (SELECT lens_id FROM reference.Lens WHERE brand_name = N'Canon' AND model_name = N'FD 35mm'),
    @zuiko_28_id INT = (SELECT lens_id FROM reference.Lens WHERE brand_name = N'Olympus' AND model_name = N'Zuiko 28mm');

IF NOT EXISTS (SELECT 1 FROM film.FilmRoll WHERE participant_id = @participant_lan_id AND roll_code = N'LAN-R01')
    INSERT INTO film.FilmRoll (participant_id, film_stock_id, lab_id, roll_code, film_format_code, iso_setting, developed_at, scanned_at, scan_notes, roll_status)
    VALUES (@participant_lan_id, @kodak_portra_id, @silver_lab_id, N'LAN-R01', N'35MM', 400, '2026-07-22', '2026-07-24', N'Frontier scan, medium resolution', N'READY');

IF NOT EXISTS (SELECT 1 FROM film.FilmRoll WHERE participant_id = @participant_lan_id AND roll_code = N'LAN-R02')
    INSERT INTO film.FilmRoll (participant_id, film_stock_id, lab_id, roll_code, film_format_code, iso_setting, developed_at, scanned_at, scan_notes, roll_status)
    VALUES (@participant_lan_id, @ilford_hp5_id, @analog_corner_lab_id, N'LAN-R02', N'35MM', 400, '2026-03-20', '2026-03-22', N'Black and white high contrast scan', N'READY');

IF NOT EXISTS (SELECT 1 FROM film.FilmRoll WHERE participant_id = @participant_bao_id AND roll_code = N'BAO-R01')
    INSERT INTO film.FilmRoll (participant_id, film_stock_id, lab_id, roll_code, film_format_code, iso_setting, developed_at, scanned_at, scan_notes, roll_status)
    VALUES (@participant_bao_id, @kodak_gold_id, @silver_lab_id, N'BAO-R01', N'35MM', 200, '2026-07-18', '2026-07-20', N'Warm color scan', N'READY');

DECLARE
    @lan_roll1_id INT = (SELECT roll_id FROM film.FilmRoll WHERE participant_id = @participant_lan_id AND roll_code = N'LAN-R01'),
    @lan_roll2_id INT = (SELECT roll_id FROM film.FilmRoll WHERE participant_id = @participant_lan_id AND roll_code = N'LAN-R02'),
    @bao_roll1_id INT = (SELECT roll_id FROM film.FilmRoll WHERE participant_id = @participant_bao_id AND roll_code = N'BAO-R01');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 12)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@lan_roll1_id, @nikon_f3_id, @nikkor_50_id, 12, N'Rain on Saigon Street', '2026-07-10', N'Ho Chi Minh City', N'Available for future contest submission.', N'READY', N'https://storage.example/negatives/lan-r01-f12.jpg', N'https://storage.example/contact/lan-r01.jpg');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 24)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@lan_roll1_id, @nikon_f3_id, @nikkor_50_id, 24, N'Old Cafe Window', '2026-07-12', N'Ho Chi Minh City', N'Will be used in submission success test.', N'READY', N'https://storage.example/negatives/lan-r01-f24.jpg', N'https://storage.example/contact/lan-r01.jpg');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 36)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@lan_roll1_id, @canon_ae1_id, @canon_35_id, 36, N'Quiet Portrait', '2026-07-14', N'Ho Chi Minh City', N'Portrait category seeded submission.', N'SUBMITTED', N'https://storage.example/negatives/lan-r01-f36.jpg', N'https://storage.example/contact/lan-r01.jpg');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @lan_roll2_id AND frame_number = 5)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@lan_roll2_id, @olympus_om1_id, @zuiko_28_id, 5, N'Night River', '2026-03-10', N'Da Lat', N'Spring contest landscape winner.', N'SUBMITTED', N'https://storage.example/negatives/lan-r02-f05.jpg', N'https://storage.example/contact/lan-r02.jpg');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @bao_roll1_id AND frame_number = 1)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@bao_roll1_id, @canon_ae1_id, @canon_35_id, 1, N'Morning Market', '2026-07-11', N'Cho Lon', N'Pending verification street submission.', N'SUBMITTED', N'https://storage.example/negatives/bao-r01-f01.jpg', N'https://storage.example/contact/bao-r01.jpg');

IF NOT EXISTS (SELECT 1 FROM film.FilmFrame WHERE roll_id = @bao_roll1_id AND frame_number = 7)
    INSERT INTO film.FilmFrame (roll_id, camera_id, lens_id, frame_number, frame_title, captured_on, capture_location, frame_notes, frame_status, negative_image_uri, contact_sheet_uri)
    VALUES (@bao_roll1_id, @canon_ae1_id, @canon_35_id, 7, N'Cyclo Driver', '2026-07-16', N'Ho Chi Minh City', N'Portrait category seeded submission.', N'SUBMITTED', N'https://storage.example/negatives/bao-r01-f07.jpg', N'https://storage.example/contact/bao-r01.jpg');

DECLARE
    @lan_frame12_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 12),
    @lan_frame24_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 24),
    @lan_frame36_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @lan_roll1_id AND frame_number = 36),
    @lan_frame5_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @lan_roll2_id AND frame_number = 5),
    @bao_frame1_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @bao_roll1_id AND frame_number = 1),
    @bao_frame7_id INT = (SELECT frame_id FROM film.FilmFrame WHERE roll_id = @bao_roll1_id AND frame_number = 7);

IF NOT EXISTS (SELECT 1 FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @bao_frame1_id)
    INSERT INTO submission.Submission (registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, thumbnail_image_uri, submitted_at, submission_status)
    VALUES (@registration_fall_bao_id, @contest_fall_id, @fall_street_category_id, @bao_frame1_id, N'Morning Market', N'Color street scene captured on Kodak Gold.', N'https://storage.example/submissions/fall/bao-morning-market.jpg', N'https://storage.example/submissions/fall/thumb-bao-morning-market.jpg', '2026-08-11T08:00:00', N'PENDING_VERIFICATION');

IF NOT EXISTS (SELECT 1 FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @lan_frame36_id)
    INSERT INTO submission.Submission (registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, thumbnail_image_uri, submitted_at, submission_status)
    VALUES (@registration_fall_lan_id, @contest_fall_id, @fall_portrait_category_id, @lan_frame36_id, N'Quiet Portrait', N'Portrait study with soft indoor light.', N'https://storage.example/submissions/fall/lan-quiet-portrait.jpg', N'https://storage.example/submissions/fall/thumb-lan-quiet-portrait.jpg', '2026-08-08T09:15:00', N'VERIFIED');

IF NOT EXISTS (SELECT 1 FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @bao_frame7_id)
    INSERT INTO submission.Submission (registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, thumbnail_image_uri, submitted_at, submission_status)
    VALUES (@registration_fall_bao_id, @contest_fall_id, @fall_portrait_category_id, @bao_frame7_id, N'Cyclo Driver', N'Environmental portrait on film.', N'https://storage.example/submissions/fall/bao-cyclo-driver.jpg', N'https://storage.example/submissions/fall/thumb-bao-cyclo-driver.jpg', '2026-08-08T10:20:00', N'VERIFIED');

IF NOT EXISTS (SELECT 1 FROM submission.Submission WHERE contest_id = @contest_spring_id AND frame_id = @lan_frame5_id)
    INSERT INTO submission.Submission (registration_id, contest_id, category_id, frame_id, submission_title, submission_statement, scanned_image_uri, thumbnail_image_uri, submitted_at, submission_status)
    VALUES (@registration_spring_lan_id, @contest_spring_id, @spring_landscape_category_id, @lan_frame5_id, N'Night River', N'Landscape frame captured during spring travel.', N'https://storage.example/submissions/spring/lan-night-river.jpg', N'https://storage.example/submissions/spring/thumb-lan-night-river.jpg', '2026-04-01T18:30:00', N'FINALIZED');

DECLARE
    @sub_bao_street_pending_id INT = (SELECT submission_id FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @bao_frame1_id),
    @sub_lan_portrait_id INT = (SELECT submission_id FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @lan_frame36_id),
    @sub_bao_portrait_id INT = (SELECT submission_id FROM submission.Submission WHERE contest_id = @contest_fall_id AND frame_id = @bao_frame7_id),
    @sub_lan_landscape_id INT = (SELECT submission_id FROM submission.Submission WHERE contest_id = @contest_spring_id AND frame_id = @lan_frame5_id);

IF NOT EXISTS (SELECT 1 FROM verification.VerificationCase WHERE submission_id = @sub_bao_street_pending_id)
    INSERT INTO verification.VerificationCase (submission_id, verification_status, completeness_status, technical_status, created_at, updated_at)
    VALUES (@sub_bao_street_pending_id, N'PENDING', N'PASS', N'PASS', SYSUTCDATETIME(), SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM verification.VerificationCase WHERE submission_id = @sub_lan_portrait_id)
    INSERT INTO verification.VerificationCase (submission_id, verification_status, completeness_status, technical_status, final_decision_code, reviewed_by_user_id, reviewed_at, review_notes, created_at, updated_at)
    VALUES (@sub_lan_portrait_id, N'VERIFIED', N'PASS', N'PASS', N'VERIFIED', @organizer_user_id, '2026-08-09T08:00:00', N'All requirements satisfied.', SYSUTCDATETIME(), SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM verification.VerificationCase WHERE submission_id = @sub_bao_portrait_id)
    INSERT INTO verification.VerificationCase (submission_id, verification_status, completeness_status, technical_status, final_decision_code, reviewed_by_user_id, reviewed_at, review_notes, created_at, updated_at)
    VALUES (@sub_bao_portrait_id, N'VERIFIED', N'PASS', N'PASS', N'VERIFIED', @organizer_user_id, '2026-08-09T08:10:00', N'All requirements satisfied.', SYSUTCDATETIME(), SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM verification.VerificationCase WHERE submission_id = @sub_lan_landscape_id)
    INSERT INTO verification.VerificationCase (submission_id, verification_status, completeness_status, technical_status, final_decision_code, reviewed_by_user_id, reviewed_at, review_notes, created_at, updated_at)
    VALUES (@sub_lan_landscape_id, N'VERIFIED', N'PASS', N'PASS', N'VERIFIED', @organizer_user_id, '2026-04-05T12:00:00', N'Verified in spring contest.', SYSUTCDATETIME(), SYSUTCDATETIME());

IF NOT EXISTS (SELECT 1 FROM verification.AIAnalysisResult WHERE submission_id = @sub_bao_street_pending_id AND analysis_type_code = N'SIMILARITY')
    INSERT INTO verification.AIAnalysisResult
    (
        submission_id, analysis_type_code, analysis_outcome_code, confidence_score, model_name, model_version, related_submission_id, review_decision_code, analysis_summary
    )
    VALUES
    (
        @sub_bao_street_pending_id, N'SIMILARITY', N'FLAGGED', 0.9300, N'SimilarityNet', N'1.3.0', @sub_lan_landscape_id, N'PENDING_REVIEW', N'High similarity score against an earlier contest submission.'
    );

IF NOT EXISTS (SELECT 1 FROM verification.AIAnalysisResult WHERE submission_id = @sub_bao_street_pending_id AND analysis_type_code = N'AI_GENERATED')
    INSERT INTO verification.AIAnalysisResult
    (
        submission_id, analysis_type_code, analysis_outcome_code, confidence_score, model_name, model_version, review_decision_code, analysis_summary
    )
    VALUES
    (
        @sub_bao_street_pending_id, N'AI_GENERATED', N'LOW_RISK', 0.1400, N'AuthenticityNet', N'2.0.1', N'PENDING_REVIEW', N'Low probability of AI-generated characteristics.'
    );

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @portrait_round1_id, @judge_mina_user_id, N'SUBMITTED', '2026-08-01T08:00:00', @organizer_user_id, N'Portrait round 1 assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @portrait_round1_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @portrait_round1_id, @judge_quang_user_id, N'SUBMITTED', '2026-08-01T08:00:00', @organizer_user_id, N'Portrait round 1 assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @portrait_round1_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @portrait_round2_id, @judge_mina_user_id, N'SUBMITTED', '2026-08-08T08:00:00', @organizer_user_id, N'Portrait final round assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @portrait_round2_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @portrait_round2_id, @judge_quang_user_id, N'SUBMITTED', '2026-08-08T08:00:00', @organizer_user_id, N'Portrait final round assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @portrait_round2_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @spring_landscape_round2_id, @judge_mina_user_id, N'SUBMITTED', '2026-04-27T08:00:00', @organizer_user_id, N'Landscape final round assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @spring_landscape_round2_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.JudgeAssignment (round_id, judge_user_id, assignment_status, assigned_at, assigned_by_user_id, assignment_note)
SELECT @spring_landscape_round2_id, @judge_quang_user_id, N'SUBMITTED', '2026-04-27T08:00:00', @organizer_user_id, N'Landscape final round assignment'
WHERE NOT EXISTS (SELECT 1 FROM judging.JudgeAssignment WHERE round_id = @spring_landscape_round2_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round1_id, @sub_lan_portrait_id, @judge_mina_user_id, N'SUBMITTED', 18.00, N'Strong character and balance.', '2026-08-05T09:00:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round1_id, @sub_lan_portrait_id, @judge_quang_user_id, N'SUBMITTED', 17.00, N'Solid portrait with calm atmosphere.', '2026-08-05T09:15:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round1_id, @sub_bao_portrait_id, @judge_mina_user_id, N'SUBMITTED', 16.00, N'Good gesture and framing.', '2026-08-05T10:00:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round1_id, @sub_bao_portrait_id, @judge_quang_user_id, N'SUBMITTED', 15.00, N'Interesting subject but slightly weaker impact.', '2026-08-05T10:10:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round2_id, @sub_lan_portrait_id, @judge_mina_user_id, N'SUBMITTED', 25.00, N'Best emotional resonance in the set.', '2026-08-12T09:00:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round2_id, @sub_lan_portrait_id, @judge_quang_user_id, N'SUBMITTED', 24.00, N'Strong tonal depth and expression.', '2026-08-12T09:10:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round2_id, @sub_bao_portrait_id, @judge_mina_user_id, N'SUBMITTED', 21.00, N'Good presence but less tonal nuance.', '2026-08-12T10:00:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @portrait_round2_id, @sub_bao_portrait_id, @judge_quang_user_id, N'SUBMITTED', 20.00, N'Consistent but slightly less memorable than the leading portrait.', '2026-08-12T10:10:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @spring_landscape_round2_id, @sub_lan_landscape_id, @judge_mina_user_id, N'SUBMITTED', 26.00, N'Excellent use of light and atmosphere.', '2026-04-29T09:00:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @spring_landscape_round2_id AND submission_id = @sub_lan_landscape_id AND judge_user_id = @judge_mina_user_id);

INSERT INTO judging.Evaluation (round_id, submission_id, judge_user_id, evaluation_status, total_score, overall_comment, submitted_at, created_at, updated_at)
SELECT @spring_landscape_round2_id, @sub_lan_landscape_id, @judge_quang_user_id, N'SUBMITTED', 25.00, N'Beautiful composition and atmosphere.', '2026-04-29T09:05:00', SYSUTCDATETIME(), SYSUTCDATETIME()
WHERE NOT EXISTS (SELECT 1 FROM judging.Evaluation WHERE round_id = @spring_landscape_round2_id AND submission_id = @sub_lan_landscape_id AND judge_user_id = @judge_quang_user_id);

DECLARE
    @crit_portrait_r1_comp INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @portrait_round1_id AND criterion_code = N'COMPOSITION'),
    @crit_portrait_r1_char INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @portrait_round1_id AND criterion_code = N'CHARACTER'),
    @crit_portrait_r2_emotion INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @portrait_round2_id AND criterion_code = N'EMOTION'),
    @crit_portrait_r2_tonal INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @portrait_round2_id AND criterion_code = N'TONAL'),
    @crit_portrait_r2_tech INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @portrait_round2_id AND criterion_code = N'TECH'),
    @crit_landscape_light INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @spring_landscape_round2_id AND criterion_code = N'LIGHT'),
    @crit_landscape_comp INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @spring_landscape_round2_id AND criterion_code = N'COMPOSITION'),
    @crit_landscape_atm INT = (SELECT criterion_id FROM contest.ScoringCriterion WHERE round_id = @spring_landscape_round2_id AND criterion_code = N'ATMOSPHERE');

DECLARE
    @eval_pr1_lan_mina INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_mina_user_id),
    @eval_pr1_lan_quang INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_quang_user_id),
    @eval_pr1_bao_mina INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_mina_user_id),
    @eval_pr1_bao_quang INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round1_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_quang_user_id),
    @eval_pr2_lan_mina INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_mina_user_id),
    @eval_pr2_lan_quang INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_lan_portrait_id AND judge_user_id = @judge_quang_user_id),
    @eval_pr2_bao_mina INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_mina_user_id),
    @eval_pr2_bao_quang INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @portrait_round2_id AND submission_id = @sub_bao_portrait_id AND judge_user_id = @judge_quang_user_id),
    @eval_land_lan_mina INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @spring_landscape_round2_id AND submission_id = @sub_lan_landscape_id AND judge_user_id = @judge_mina_user_id),
    @eval_land_lan_quang INT = (SELECT evaluation_id FROM judging.Evaluation WHERE round_id = @spring_landscape_round2_id AND submission_id = @sub_lan_landscape_id AND judge_user_id = @judge_quang_user_id);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_lan_mina, @crit_portrait_r1_comp, 9.00, N'Balanced composition'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_lan_mina AND criterion_id = @crit_portrait_r1_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_lan_mina, @crit_portrait_r1_char, 9.00, N'Strong subject presence'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_lan_mina AND criterion_id = @crit_portrait_r1_char);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_lan_quang, @crit_portrait_r1_comp, 8.00, N'Good framing'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_lan_quang AND criterion_id = @crit_portrait_r1_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_lan_quang, @crit_portrait_r1_char, 9.00, N'Calm but strong expression'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_lan_quang AND criterion_id = @crit_portrait_r1_char);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_bao_mina, @crit_portrait_r1_comp, 8.00, N'Solid framing'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_bao_mina AND criterion_id = @crit_portrait_r1_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_bao_mina, @crit_portrait_r1_char, 8.00, N'Interesting presence'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_bao_mina AND criterion_id = @crit_portrait_r1_char);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_bao_quang, @crit_portrait_r1_comp, 7.00, N'Decent structure'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_bao_quang AND criterion_id = @crit_portrait_r1_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr1_bao_quang, @crit_portrait_r1_char, 8.00, N'Good moment'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr1_bao_quang AND criterion_id = @crit_portrait_r1_char);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_mina, @crit_portrait_r2_emotion, 9.00, N'Strong emotion'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_mina AND criterion_id = @crit_portrait_r2_emotion);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_mina, @crit_portrait_r2_tonal, 8.00, N'Excellent tonal range'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_mina AND criterion_id = @crit_portrait_r2_tonal);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_mina, @crit_portrait_r2_tech, 8.00, N'Clean technical execution'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_mina AND criterion_id = @crit_portrait_r2_tech);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_quang, @crit_portrait_r2_emotion, 8.00, N'Subtle emotion'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_quang AND criterion_id = @crit_portrait_r2_emotion);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_quang, @crit_portrait_r2_tonal, 8.00, N'Rich tones'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_quang AND criterion_id = @crit_portrait_r2_tonal);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_lan_quang, @crit_portrait_r2_tech, 8.00, N'Well scanned'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_lan_quang AND criterion_id = @crit_portrait_r2_tech);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_mina, @crit_portrait_r2_emotion, 7.00, N'Good but less striking'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_mina AND criterion_id = @crit_portrait_r2_emotion);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_mina, @crit_portrait_r2_tonal, 7.00, N'Adequate tonal handling'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_mina AND criterion_id = @crit_portrait_r2_tonal);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_mina, @crit_portrait_r2_tech, 7.00, N'Technically solid'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_mina AND criterion_id = @crit_portrait_r2_tech);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_quang, @crit_portrait_r2_emotion, 7.00, N'Less emotional impact'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_quang AND criterion_id = @crit_portrait_r2_emotion);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_quang, @crit_portrait_r2_tonal, 6.00, N'Tones slightly flatter'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_quang AND criterion_id = @crit_portrait_r2_tonal);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_pr2_bao_quang, @crit_portrait_r2_tech, 7.00, N'Fine technical quality'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_pr2_bao_quang AND criterion_id = @crit_portrait_r2_tech);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_mina, @crit_landscape_light, 9.00, N'Excellent light'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_mina AND criterion_id = @crit_landscape_light);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_mina, @crit_landscape_comp, 9.00, N'Strong composition'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_mina AND criterion_id = @crit_landscape_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_mina, @crit_landscape_atm, 8.00, N'Excellent atmosphere'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_mina AND criterion_id = @crit_landscape_atm);

INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_quang, @crit_landscape_light, 8.00, N'Beautiful light quality'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_quang AND criterion_id = @crit_landscape_light);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_quang, @crit_landscape_comp, 9.00, N'Excellent composition'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_quang AND criterion_id = @crit_landscape_comp);
INSERT INTO judging.EvaluationScore (evaluation_id, criterion_id, score_value, score_comment)
SELECT @eval_land_lan_quang, @crit_landscape_atm, 8.00, N'Great sense of place'
WHERE NOT EXISTS (SELECT 1 FROM judging.EvaluationScore WHERE evaluation_id = @eval_land_lan_quang AND criterion_id = @crit_landscape_atm);

IF NOT EXISTS (SELECT 1 FROM result.Result WHERE category_id = @spring_landscape_category_id AND submission_id = @sub_lan_landscape_id)
    INSERT INTO result.Result (category_id, submission_id, final_score, final_rank, result_status, finalized_at, finalized_by_user_id, published_at)
    VALUES (@spring_landscape_category_id, @sub_lan_landscape_id, 25.50, 1, N'PUBLISHED', '2026-05-05T09:00:00', @organizer_user_id, '2026-06-15T09:00:00');

DECLARE
    @spring_landscape_result_id INT = (SELECT result_id FROM result.Result WHERE category_id = @spring_landscape_category_id AND submission_id = @sub_lan_landscape_id),
    @spring_first_award_definition_id INT = (SELECT award_definition_id FROM contest.AwardDefinition WHERE category_id = @spring_landscape_category_id AND award_code = N'FIRST');

IF NOT EXISTS (SELECT 1 FROM result.AwardAssignment WHERE award_definition_id = @spring_first_award_definition_id AND result_id = @spring_landscape_result_id)
    INSERT INTO result.AwardAssignment (award_definition_id, result_id, assigned_by_user_id, assignment_note)
    VALUES (@spring_first_award_definition_id, @spring_landscape_result_id, @organizer_user_id, N'Published first prize assignment');

IF NOT EXISTS (SELECT 1 FROM archive.ArchiveItem WHERE result_id = @spring_landscape_result_id)
    INSERT INTO archive.ArchiveItem
    (
        result_id,
        submission_id,
        archive_status,
        archived_at,
        archived_by_user_id,
        contest_snapshot,
        category_snapshot,
        participant_snapshot,
        technical_snapshot,
        judging_snapshot,
        image_uri_snapshot,
        retention_note
    )
    VALUES
    (
        @spring_landscape_result_id,
        @sub_lan_landscape_id,
        N'ARCHIVED',
        '2026-06-20T10:00:00',
        @organizer_user_id,
        N'{"contest_code":"FILM2026-SPRING","contest_title":"Vietnam Film Landscape Spring 2026"}',
        N'{"category_code":"LANDSCAPE","category_name":"Landscape"}',
        N'{"participant_display_name":"Lan Nguyen"}',
        N'{"film_stock":"Ilford HP5 Plus","roll_code":"LAN-R02","frame_number":5,"camera":"Olympus OM-1","lens":"Zuiko 28mm"}',
        N'{"final_score":25.50,"final_rank":1,"published_at":"2026-06-15T09:00:00"}',
        N'https://storage.example/submissions/spring/lan-night-river.jpg',
        N'Retain as historical exhibition sample.'
    );

IF NOT EXISTS (
    SELECT 1
    FROM audit.AuditLog
    WHERE entity_name = N'participant.Registration'
      AND entity_id = @registration_fall_lan_id
      AND action_code = N'REGISTRATION_APPROVED'
)
    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'participant.Registration',
        @registration_fall_lan_id,
        N'REGISTRATION_APPROVED',
        @organizer_user_id,
        '2026-08-03T10:00:00',
        N'Lan registration approved for FILM2026-FALL.',
        N'{"contest_code":"FILM2026-FALL","participant":"Lan Nguyen"}'
    );

IF NOT EXISTS (
    SELECT 1
    FROM audit.AuditLog
    WHERE entity_name = N'verification.VerificationCase'
      AND entity_id = (SELECT verification_id FROM verification.VerificationCase WHERE submission_id = @sub_lan_landscape_id)
      AND action_code = N'VERIFICATION_DECISION'
)
    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'verification.VerificationCase',
        (SELECT verification_id FROM verification.VerificationCase WHERE submission_id = @sub_lan_landscape_id),
        N'VERIFICATION_DECISION',
        @organizer_user_id,
        '2026-04-05T12:00:00',
        N'Spring landscape submission verified.',
        N'{"submission_title":"Night River","decision":"VERIFIED"}'
    );

IF NOT EXISTS (
    SELECT 1
    FROM audit.AuditLog
    WHERE entity_name = N'result.Result'
      AND entity_id = @spring_landscape_result_id
      AND action_code = N'PUBLISH_RESULT'
)
    INSERT INTO audit.AuditLog
    (
        entity_name,
        entity_id,
        action_code,
        actor_user_id,
        action_at,
        action_summary,
        detail_payload
    )
    VALUES
    (
        N'result.Result',
        @spring_landscape_result_id,
        N'PUBLISH_RESULT',
        @organizer_user_id,
        '2026-06-15T09:00:00',
        N'Landscape result published.',
        N'{"contest_code":"FILM2026-SPRING","rank":1}'
    );
