DROP PROCEDURE IF EXISTS CalculateCustomerDiscounts;
GO

CREATE PROCEDURE CalculateCustomerDiscounts
@CustomerId NCHAR(5) -- Parametr określający klienta
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Używamy CTE, aby "ponumerować" zamówienia
        -- danego produktu dla podanego klienta w czasie.
        WITH RankedProductOrders AS (
            SELECT
                od.OrderID,
                od.ProductID,
                -- ROW_NUMBER() numeruje wiersze od 1.
                -- Odejmując 1, otrzymujemy dokładnie "liczbę wcześniejszych zamówień" (0, 1, 2, 3...)
                ROW_NUMBER() OVER(
                    PARTITION BY od.ProductID -- Numerujemy osobno dla każdego produktu
                    ORDER BY o.OrderDate ASC, o.OrderID ASC -- Chronologicznie
                    ) - 1 AS PreviousOrdersCount
            FROM [Order Details] od
                     JOIN Orders o ON od.OrderID = o.OrderID
            WHERE o.CustomerID = @CustomerId
        )
        -- Główna aktualizacja korzystająca z naszych wyliczeń w CTE
        UPDATE od
        SET Discount = CASE
                           WHEN r.PreviousOrdersCount = 0 THEN 0.00             -- Pierwsze zamówienie: zniżka 0%
                           WHEN r.PreviousOrdersCount IN (1, 2) THEN 0.05       -- 1 do 2 wcześniejszych: zniżka 5%
                           WHEN r.PreviousOrdersCount = 3 THEN 0.10             -- 3 wcześniejsze: zniżka 10%
                           WHEN r.PreviousOrdersCount > 3 THEN 0.20             -- Powyżej 3: zniżka 20%
            END
        FROM [Order Details] od
                 JOIN RankedProductOrders r ON od.OrderID = r.OrderID AND od.ProductID = r.ProductID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO