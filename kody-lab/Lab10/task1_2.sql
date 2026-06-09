CREATE PROCEDURE ZlozZamowienie
    @nazwisko NVARCHAR(50),
    @wozek_id INT,
    @ilosc INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Sprawdzenie/Dodanie Klienta
    DECLARE @id_klienta INT;
    SELECT @id_klienta = id_klienta FROM Klienci WHERE nazwisko = @nazwisko;

    IF @id_klienta IS NULL
    BEGIN
        INSERT INTO Klienci (imie, nazwisko, email, telefon, adres, miasto, kraj)
        VALUES ('DefaultName', @nazwisko, 'brak', 'brak', 'brak', 'brak', 'brak');
        SET @id_klienta = SCOPE_IDENTITY(); -- Pobiera ID nowo utworzonego klienta
    END

    -- 2. Parametry wózka: Całkowita liczba elementów
    DECLARE @calkowita_liczba_elementow INT;
    SELECT @calkowita_liczba_elementow = ISNULL(SUM(liczba_sztuk), 0) 
    FROM SkladWozka 
    WHERE id_wozka = @wozek_id;

    -- Ustalenie terminu realizacji
    DECLARE @data_realizacji DATE;
    IF @calkowita_liczba_elementow <= 50 
        SET @data_realizacji = DATEADD(day, 30, GETDATE());
    ELSE IF @calkowita_liczba_elementow <= 100 
        SET @data_realizacji = DATEADD(day, 60, GETDATE());
    ELSE IF @calkowita_liczba_elementow <= 1000 
        SET @data_realizacji = DATEADD(day, 90, GETDATE());
    ELSE IF @calkowita_liczba_elementow <= 10000 
        SET @data_realizacji = DATEADD(month, 6, GETDATE());
    ELSE 
        SET @data_realizacji = DATEADD(year, 2, GETDATE());

    -- Wyznaczenie dominującego materiału
    DECLARE @dominujacy_material NVARCHAR(50);
    SELECT TOP 1 @dominujacy_material = c.material
    FROM SkladWozka sw
    JOIN Czesci c ON sw.id_czesci = c.id_czesci
    WHERE sw.id_wozka = @wozek_id
    GROUP BY c.material
    ORDER BY SUM(sw.liczba_sztuk) DESC;

    -- Wyznaczenie współczynnika złożoności
    -- Wzór: liczba różnych części * średnia liczba sztuk części * liczba różnych materiałów
    DECLARE @wsp_zlozonosci DECIMAL(18,2);
    
    SELECT 
        @wsp_zlozonosci = COUNT(DISTINCT sw.id_czesci) * AVG(CAST(sw.liczba_sztuk AS DECIMAL(18,2))) * COUNT(DISTINCT c.material)
    FROM SkladWozka sw
    JOIN Czesci c ON sw.id_czesci = c.id_czesci
    WHERE sw.id_wozka = @wozek_id;

    -- 3. Zapisanie zamówienia w bazie
    INSERT INTO Zamowienia (id_klienta, termin_realizacji_data, wspolczynnik_zlozonosci, dominujacy_material)
    VALUES (@id_klienta, @data_realizacji, @wsp_zlozonosci, @dominujacy_material);
    
    DECLARE @id_nowego_zamowienia INT = SCOPE_IDENTITY();

    -- Zapisanie detali
    INSERT INTO SzczegolyZamowienia (id_zamowienia, id_wozka, ilosc)
    VALUES (@id_nowego_zamowienia, @wozek_id, @ilosc);

END;
