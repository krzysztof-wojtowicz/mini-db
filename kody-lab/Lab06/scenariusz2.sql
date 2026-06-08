-- Dodanie kolumny IsCancelled do tabeli Orders
ALTER TABLE Orders
    ADD IsCancelled INT;

-- Transakcja wprowadzająca zmiany

BEGIN TRANSACTION;

-- 1. Ustawienie IsCancelled = 0 dla wszystkich klientów oprócz ALFKI
UPDATE Orders
SET IsCancelled = 0
WHERE CustomerID <> 'ALFKI';

-- 2. Ustawienie IsCancelled = 1 dla zamówień klienta ALFKI
UPDATE Orders
SET IsCancelled = 1
WHERE CustomerID = 'ALFKI';

-- 3. Wyzerowanie ilości (Quantity) w szczegółach zamówień dla klienta ALFKI.
-- Tabela [Order Details] nie ma kolumny CustomerID, więc musimy
-- znaleźć odpowiednie OrderID w tabeli Orders za pomocą podzapytania.
UPDATE [Order Details]
SET Quantity = 0
WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE CustomerID = 'ALFKI'

-- Alternatywna metoda: UPDATE z użyciem JOIN
-- UPDATE od
-- SET od.Quantity = 0
-- FROM [Order Details] od
--          JOIN Orders o ON od.OrderID = o.OrderID
-- WHERE o.CustomerID = 'ALFKI';
);

COMMIT TRANSACTION;