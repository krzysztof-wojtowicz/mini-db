USE edu_courses;
GO

CREATE OR ALTER PROCEDURE EnrollUserToCourse
    @email NVARCHAR(255),
    @course_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Zmienne lokalne do przechowania informacji z bazy
        DECLARE @user_id INT;
        DECLARE @is_user_active BIT;
        DECLARE @is_course_active BIT;
        DECLARE @base_price MONEY;
        DECLARE @available_group_id INT;
        DECLARE @user_courses_count INT;
        DECLARE @discount_type VARCHAR(100);
        DECLARE @discount_value MONEY;
        DECLARE @total_cost MONEY;
        DECLARE @N INT;

        -- 1. Obsluga uzytkownika (walidacja i ewentualne tworzenie)
        SELECT @user_id = user_id, @is_user_active = is_active
        FROM users_user
        WHERE email = @email;

        IF @user_id IS NULL
            BEGIN
                -- Uzytkownik nie istnieje, wiec go tworzymy (wymagane pola to email, first_name, last_name i is_active)
                INSERT INTO users_user (email, first_name, last_name, is_active)
                VALUES (@email, 'Nowy', 'Uzytkownik', 1);

                -- Pobieramy ID nowo utworzonego uzytkownika
                SET @user_id = SCOPE_IDENTITY();
                SET @is_user_active = 1;
            END
        ELSE IF @is_user_active = 0
            BEGIN
                -- Rzucamy blad jesli uzytkownik jest nieaktywny
                THROW 50001, 'Uzytkownik jest nieaktywny i nie moze zostac zapisany na kurs.', 1;
            END

        -- 2. Sprawdzenie statusu kursu
        SELECT @is_course_active = is_active, @base_price = base_price
        FROM course
        WHERE course_id = @course_id;

        IF @is_course_active IS NULL OR @is_course_active = 0
            BEGIN
                THROW 50002, 'Podany kurs nie istnieje lub jest nieaktywny.', 1;
            END

        -- 3. Szukanie pierwszej wolnej grupy dla tego kursu
        -- Zliczamy aktualnych kursantow w kazdej grupie i sprawdzamy pojemnosc
        SELECT TOP 1 @available_group_id = g.group_id
        FROM [group] g
                 LEFT JOIN course_enrollment ce ON g.group_id = ce.group_id
        WHERE g.course_id = @course_id
        GROUP BY g.group_id, g.max_group_capacity
        HAVING COUNT(ce.user_id) < g.max_group_capacity
        ORDER BY g.group_id;

        IF @available_group_id IS NULL
            BEGIN
                THROW 50003, 'Brak wolnych miejsc w grupach dla tego kursu.', 1;
            END

        -- Zabezpieczenie: sprawdzenie czy uzytkownik nie jest juz zapisany na ten sam kurs
        IF EXISTS (
            SELECT 1 FROM course_enrollment ce
                              JOIN [group] g ON ce.group_id = g.group_id
            WHERE ce.user_id = @user_id AND g.course_id = @course_id
        )
            BEGIN
                THROW 50004, 'Ten uzytkownik jest juz zapisany na ten kurs.', 1;
            END

        -- 4. Obliczanie kosztow i rabatow na podstawie historii
        -- Liczymy ile kursow dotychczas kupil ten klient (z wylaczeniem tych z ktorych zrezygnowal)
        SELECT @user_courses_count = COUNT(*)
        FROM course_enrollment
        WHERE user_id = @user_id AND is_dropped = 0;

        -- Obecny kurs bedzie kursem N-tym
        SET @N = @user_courses_count + 1;

        IF @N = 1
            BEGIN
                SET @discount_type = 'Pierwszy kurs - 100 zl';
                SET @discount_value = 100.00;

                -- Zabezpieczenie zeby cena nie spadla ponizej 0 jesli kurs kosztuje np 50 zl
                IF @base_price < 100.00
                    SET @total_cost = 0;
                ELSE
                    SET @total_cost = @base_price - 100.00;
            END
        ELSE IF @N = 2
            BEGIN
                SET @discount_type = 'Staly rabat - 5%';
                SET @discount_value = @base_price * 0.05;
                SET @total_cost = @base_price - @discount_value;
            END
        ELSE -- Czyli N >= 3 (lojalnosciowy)
            BEGIN
                -- N-ty kurs daje rabat n% dodany do stalego 5%
                SET @discount_type = 'Lojalnosciowy (' + CAST(5 + @N AS VARCHAR) + '%)';
                SET @discount_value = @base_price * ((5.0 + CAST(@N AS FLOAT)) / 100.0);
                SET @total_cost = @base_price - @discount_value;
            END

        -- 5. Fizyczny zapis na kurs
        INSERT INTO course_enrollment (user_id, group_id, enrollment_date, total_cost, discount_type, discount_value)
        VALUES (@user_id, @available_group_id, GETDATE(), @total_cost, @discount_type, @discount_value);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Wycofanie wszystkich operacji w przypadku wylapania jakiegokolwiek bledu
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Wyrzucenie bledu wyzej, zeby uzytkownik/aplikacja wiedzieli co poszlo nie tak
        THROW;
    END CATCH
END;
GO