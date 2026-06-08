USE edu_courses;
GO

-- a. Dodanie kolumny phone_number do tabeli users_user
ALTER TABLE users_user
    ADD phone_number VARCHAR(25);

-- b. Usuniecie kolumny age z tabeli users_user
ALTER TABLE users_user
    DROP COLUMN age;

-- c. Dodanie sprawdzenia, czy date_start jest wczesniejsza niz date_end
ALTER TABLE course
    ADD CONSTRAINT CHK_Course_Dates CHECK (date_start < date_end);