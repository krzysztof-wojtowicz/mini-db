USE edu_courses;
GO

-- 1. Wstawianie danych do tabeli users_user
INSERT INTO users_user (email, first_name, last_name, is_active, phone_number)
VALUES
    ('j.kowalski@poczta.pl', 'Jan', 'Kowalski', 1, '111-222-333'),
    ('a.nowak@poczta.pl', 'Anna', 'Nowak', 1, '444-555-666'),
    ('m.wisniewski@poczta.pl', 'Michal', 'Wisniewski', 0, '777-888-999');

-- 2. Wstawianie danych do tabeli course
INSERT INTO course (course_name, base_price, planned_groups_amount, date_start, date_end, is_active)
VALUES
    ('Podstawy SQL', 1500.00, 2, '2024-01-10', '2024-02-10', 1),
    ('Zaawansowany Python', 2500.00, 1, '2024-03-01', '2024-04-15', 1),
    ('Analiza Danych', 2000.00, 2, '2024-05-01', '2024-06-30', 1);

-- 3. Wstawianie danych do tabeli group
INSERT INTO [group] (group_type, course_id, max_group_capacity)
VALUES
    ('wykladowa', 1, 50),
    ('zajeciowa', 1, 20),
    ('zajeciowa', 2, 15);

-- 4. Wstawianie danych do tabeli group_timetable
INSERT INTO group_timetable (group_id, room, datetime_start, datetime_end)
VALUES
    (1, 'Aula A', '2024-01-12 16:00:00', '2024-01-12 18:00:00'),
    (2, 'Lab 101', '2024-01-13 10:00:00', '2024-01-13 12:00:00'),
    (3, 'Lab 205', '2024-03-05 18:00:00', '2024-03-05 20:00:00');

-- 5. Wstawianie danych do tabeli course_enrollment
-- Zauwaz, ze uzywamy ID wygenerowanych powyzej (user_id od 1 do 3, group_id od 1 do 3)
INSERT INTO course_enrollment (user_id, group_id, enrollment_date, total_cost, discount_type, discount_value, is_completed, is_dropped)
VALUES
    (1, 2, '2024-01-05 10:30:00', 1400.00, 'bezwarunkowy', 100.00, 0, 0),
    (2, 2, '2024-01-08 14:15:00', 1500.00, 'brak', 0.00, 0, 0),
    (3, 3, '2024-02-20 09:00:00', 2500.00, 'brak', 0.00, 0, 1);