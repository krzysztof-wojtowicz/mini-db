USE edu_courses;
GO

-- 1. Czeste laczenie tabel users_user i course_enrollment.
-- Baza najczesciej laczy te tabele po kolumnie user_id. W tabeli users_user
-- jest to klucz glowny (wiec ma juz indeks), ale w course_enrollment to klucz
-- obcy, wiec warto dodac na nim indeks niezgrupowany, aby bardzo przyspieszyc JOIN.
CREATE NONCLUSTERED INDEX IX_course_enrollment_user_id
    ON course_enrollment (user_id);

-- 2. Unikalnosc email w tabeli users_user.
-- Tworzymy indeks unikalny niezgrupowany. Wymusza on, aby w bazie nie
-- zarejestrowaly sie dwie osoby z tym samym mailem, a jednoczesnie
-- drastycznie przyspiesza logowanie (wyszukiwanie po mailu).
CREATE UNIQUE NONCLUSTERED INDEX UX_users_user_email
    ON users_user (email);

-- 3. Czeste wyszukiwanie danych wedlug daty rozpoczecia i zakonczenia kursu.
-- Tworzymy zlozony (wielokolumnowy) indeks niezgrupowany na tabeli course.
CREATE NONCLUSTERED INDEX IX_course_dates
    ON course (date_start, date_end);

-- 4. Zlozony zgrupowany indeks w tabeli course_enrollment.
-- Tabela ta ma klucz glowny (PK) skladajacy sie z (user_id, group_id).
-- W SQL Server Primary Key z definicji staje sie indeksem zgrupowanym (CLUSTERED),
-- wiec technicznie ten wymog zostal spelniony w zadaniu 1.
-- Gdybysmy jednak musieli go utworzyc jawnie i recznie, skladnia wyglada tak:
CREATE CLUSTERED INDEX CX_course_enrollment_user_group
    ON course_enrollment (user_id, group_id);

-- 5. Filtracja userow wedlug imienia i nazwiska.
-- Tworzymy zlozony indeks niezgrupowany. Zazwyczaj w aplikacjach filtruje sie
-- "Kowalski Jan", dlatego dobrym zwyczajem jest ustawienie nazwiska jako
-- pierwszej kolumny w kluczu indeksu, a imienia jako drugiej.
CREATE NONCLUSTERED INDEX IX_users_user_names
    ON users_user (last_name, first_name);