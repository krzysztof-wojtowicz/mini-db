-- Tworzymy tabelę tymczasową z danymi testowymi
DECLARE @TestOrders TABLE (nazwisko NVARCHAR(50), wozek_id INT, ilosc INT);
INSERT INTO @TestOrders VALUES 
('Kowalski', 1, 5),
('Nowak', 2, 10),
('Wiśniewski', 1, 2),
('Wójcik', 3, 1),
('Kowalczyk', 2, 7);

DECLARE @cur_nazwisko NVARCHAR(50), @cur_wozek_id INT, @cur_ilosc INT;

-- Deklaracja kursora
DECLARE c_Zamowienia CURSOR FOR 
SELECT nazwisko, wozek_id, ilosc FROM @TestOrders;

OPEN c_Zamowienia;
FETCH NEXT FROM c_Zamowienia INTO @cur_nazwisko, @cur_wozek_id, @cur_ilosc;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Odpalenie procedury
    EXEC ZlozZamowienie @nazwisko = @cur_nazwisko, @wozek_id = @cur_wozek_id, @ilosc = @cur_ilosc;
    FETCH NEXT FROM c_Zamowienia INTO @cur_nazwisko, @cur_wozek_id, @cur_ilosc;
END;

CLOSE c_Zamowienia;
DEALLOCATE c_Zamowienia;
