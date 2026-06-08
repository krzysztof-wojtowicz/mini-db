DROP PROCEDURE IF EXISTS CalculateCustomerDiscounts_Cursor;
GO

CREATE PROCEDURE CalculateCustomerDiscounts_Cursor
@CustomerId NCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    -- Deklaracja zmiennych, do których będziemy wczytywać dane wiersz po wierszu z kursora
    DECLARE @CurrentOrderID INT;
    DECLARE @CurrentProductID INT;
    DECLARE @CurrentOrderDate DATETIME;

    -- Zmienne pomocnicze do obliczeń wewnątrz pętli
    DECLARE @PreviousOrdersCount INT;
    DECLARE @NewDiscount REAL;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. DECLARE: Definiujemy kursor. Wybieramy zamówienia klienta, chronologicznie.
        DECLARE order_cursor CURSOR FOR
            SELECT od.OrderID, od.ProductID, o.OrderDate
            FROM [Order Details] od
                     JOIN Orders o ON od.OrderID = o.OrderID
            WHERE o.CustomerID = @CustomerId
            ORDER BY o.OrderDate ASC, od.OrderID ASC;

        -- 2. OPEN: Otwieramy kursor
        OPEN order_cursor;

        -- 3. FETCH: Pobieramy pierwszy wiersz do naszych zmiennych
        FETCH NEXT FROM order_cursor INTO @CurrentOrderID, @CurrentProductID, @CurrentOrderDate;

        -- 4. PĘTLA: @@FETCH_STATUS = 0 oznacza, że pomyślnie pobrano wiersz
        WHILE @@FETCH_STATUS = 0
            BEGIN

                -- KROK A: Liczymy ile było zamówień na ten sam produkt wcześniej (historycznie)
                SELECT @PreviousOrdersCount = COUNT(*)
                FROM [Order Details] od2
                         JOIN Orders o2 ON od2.OrderID = o2.OrderID
                WHERE o2.CustomerID = @CustomerId
                  AND od2.ProductID = @CurrentProductID
                  -- Musi być to zamówienie wcześniejsze (starsza data, lub ta sama data ale mniejsze ID)
                  AND (o2.OrderDate < @CurrentOrderDate
                    OR (o2.OrderDate = @CurrentOrderDate AND o2.OrderID < @CurrentOrderID));

                -- KROK B: Ustalamy wysokość rabatu na podstawie zmiennej
                IF @PreviousOrdersCount = 0
                    SET @NewDiscount = 0.00;
                ELSE IF @PreviousOrdersCount IN (1, 2)
                    SET @NewDiscount = 0.05;
                ELSE IF @PreviousOrdersCount = 3
                    SET @NewDiscount = 0.10;
                ELSE
                    SET @NewDiscount = 0.20;

                -- KROK C: Wykonujemy UPDATE tylko dla tego JEDNEGO konkretnego wiersza
                UPDATE [Order Details]
                SET Discount = @NewDiscount
                WHERE OrderID = @CurrentOrderID AND ProductID = @CurrentProductID;

                -- KROK D: Pobieramy KOLEJNY wiersz z kursora. Jeśli wierszy zabraknie,
                -- funkcja @@FETCH_STATUS zwróci -1 i pętla się zakończy.
                FETCH NEXT FROM order_cursor INTO @CurrentOrderID, @CurrentProductID, @CurrentOrderDate;
            END

        -- 5. CLOSE i DEALLOCATE: Zamykamy i zwalniamy pamięć z kursorem
        CLOSE order_cursor;
        DEALLOCATE order_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- Zabezpieczenie: jeśli był błąd, upewniamy się, że kursor nie zawisł w pamięci
        IF CURSOR_STATUS('global', 'order_cursor') >= -1
            BEGIN
                CLOSE order_cursor;
                DEALLOCATE order_cursor;
            END

        THROW;
    END CATCH
END;
GO