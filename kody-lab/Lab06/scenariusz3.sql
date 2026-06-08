-- 1. Utworzenie tabeli PriceList
CREATE TABLE PriceList (
                           productId INT NOT NULL,
                           price MONEY NOT NULL,
                           date_from DATETIME NOT NULL,
                           date_to DATETIME NULL,

    -- Klucz podstawowy (jeden produkt może mieć wiele cen, ale tylko jedną w danym czasie)
                           CONSTRAINT PK_PriceList PRIMARY KEY (productId, date_from),

    -- Klucz obcy do tabeli Products
                           CONSTRAINT FK_PriceList_Products FOREIGN KEY (productId) REFERENCES Products(ProductID)
);

-- 2. Wstawienie testowych cen dla poszczególnych lat
INSERT INTO PriceList (productId, price, date_from, date_to)
SELECT
    p.ProductID,
    -- Symulacja zmiany ceny: cena bazowa * mnożnik zależny od roku
    p.UnitPrice * (1.0 + (Lata.OrderYear - 1996) * 0.1) AS test_price,
    -- Ustawienie początku roku (1 stycznia)
    DATETIMEFROMPARTS(Lata.OrderYear, 1, 1, 0, 0, 0, 0) AS date_from,
    -- Ustawienie końca roku (31 grudnia)
    DATETIMEFROMPARTS(Lata.OrderYear, 12, 31, 23, 59, 59, 999) AS date_to
FROM Products p
     CROSS JOIN (
        -- Wyciągamy unikalne lata z tabeli Orders
        SELECT DISTINCT YEAR(OrderDate) AS OrderYear
        FROM Orders
        WHERE OrderDate IS NOT NULL
) Lata;

-- 3. Dodanie kolumny TotalValue do tabeli Orders
ALTER TABLE Orders
    ADD TotalValue MONEY;

-- 4. Aktualizacja TotalValue na podstawie cennika obowiązującego w dniu zamówienia
UPDATE o
SET TotalValue = (
    -- Podzapytanie liczące całkowitą wartość zamówienia
    SELECT SUM(od.Quantity * pl.price)
    FROM [Order Details] od
             JOIN PriceList pl ON od.ProductID = pl.productId
    -- Szukamy ceny obowiązującej w momencie złożenia zamówienia o.OrderDate
    WHERE od.OrderID = o.OrderID
      AND o.OrderDate >= pl.date_from
      AND o.OrderDate <= pl.date_to
)
FROM Orders o;