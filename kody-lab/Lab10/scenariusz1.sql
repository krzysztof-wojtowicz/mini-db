DROP PROCEDURE IF EXISTS ArchiveOrders;
GO

CREATE PROCEDURE ArchiveOrders
@MinimalAgeInYears INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Deklaracja zmiennej lokalnej i zapisanie do niej bieżącej daty i czasu
    DECLARE @CurrentDate DATETIME;
    SET @CurrentDate = GETDATE();

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Krok 1: Wstawiamy nagłówki zamówień
        INSERT INTO ArchivedOrders (
            OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
            ShipPostalCode, ShipCountry, ArchiveDate
        )
        SELECT
            OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
            ShipPostalCode, ShipCountry,
            @CurrentDate
        FROM Orders
        WHERE DATEDIFF(year, OrderDate, @CurrentDate) >= @MinimalAgeInYears;

        -- Krok 2: Wstawiamy szczegóły zamówień
        INSERT INTO ArchivedOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
        SELECT od.OrderID, od.ProductID, od.UnitPrice, od.Quantity, od.Discount
        FROM [Order Details] od
                 JOIN Orders o ON od.OrderID = o.OrderID
        WHERE DATEDIFF(year, o.OrderDate, @CurrentDate) >= @MinimalAgeInYears;

        -- Krok 3: Usuwamy przeniesione detale z oryginalnej tabeli
        DELETE FROM [Order Details]
        WHERE OrderID IN (
            SELECT OrderID
            FROM Orders
            WHERE DATEDIFF(year, OrderDate, @CurrentDate) >= @MinimalAgeInYears
        );

        -- Krok 4: Usuwamy przeniesione nagłówki z oryginalnej tabeli
        DELETE FROM Orders
        WHERE DATEDIFF(year, OrderDate, @CurrentDate) >= @MinimalAgeInYears;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO