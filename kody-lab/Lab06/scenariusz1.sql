-- 1. Tworzenie tabeli ArchivedOrders
CREATE TABLE ArchivedOrders (
                                OrderID INT NOT NULL,
                                CustomerID NCHAR(5) NULL,
                                EmployeeID INT NULL,
                                OrderDate DATETIME NULL,
                                RequiredDate DATETIME NULL,
                                ShippedDate DATETIME NULL,
                                ShipVia INT NULL,
                                Freight MONEY NULL,
                                ShipName NVARCHAR(40) NULL,
                                ShipAddress NVARCHAR(60) NULL,
                                ShipCity NVARCHAR(15) NULL,
                                ShipRegion NVARCHAR(15) NULL,
                                ShipPostalCode NVARCHAR(10) NULL,
                                ShipCountry NVARCHAR(15) NULL,
                                ArchiveDate DATETIME NOT NULL, -- Nowa kolumna

    -- Definicja klucza podstawowego
                                CONSTRAINT PK_ArchivedOrders PRIMARY KEY (OrderID),

    -- Definicja kluczy obcych odnoszących się do klientów i pracowników
                                CONSTRAINT FK_ArchivedOrders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
                                CONSTRAINT FK_ArchivedOrders_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- 2. Tworzenie tabeli ArchivedOrderDetails
CREATE TABLE ArchivedOrderDetails (
                                      OrderID INT NOT NULL,
                                      ProductID INT NOT NULL,
                                      UnitPrice MONEY NOT NULL,
                                      Quantity SMALLINT NOT NULL,
                                      Discount REAL NOT NULL,

                                      CONSTRAINT PK_ArchivedOrderDetails PRIMARY KEY (OrderID, ProductID),

                                      CONSTRAINT FK_ArchivedOrderDetails_ArchivedOrders FOREIGN KEY (OrderID) REFERENCES ArchivedOrders(OrderID),
                                      CONSTRAINT FK_ArchivedOrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Przenoszenie danych -> transakcja

BEGIN TRANSACTION;

-- 1. Skopiowanie zamówień z 1996 roku do ArchivedOrders
INSERT INTO ArchivedOrders (
    OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
    ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
    ShipPostalCode, ShipCountry, ArchiveDate
)
SELECT
    OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
    ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
    ShipPostalCode, ShipCountry,
    GETDATE() -- Ustawienie bieżącej daty archiwizacji
FROM Orders
WHERE YEAR(OrderDate) = 1996;

-- 2. Skopiowanie szczegółów dla zamówień z 1996 roku do ArchivedOrderDetails
INSERT INTO ArchivedOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT od.OrderID, od.ProductID, od.UnitPrice, od.Quantity, od.Discount
FROM [Order Details] od
         JOIN Orders o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1996;

-- 3. Usunięcie przeniesionych danych z oryginalnej tabeli [Order Details]
DELETE FROM [Order Details]
WHERE OrderID IN (
    SELECT OrderID FROM Orders WHERE YEAR(OrderDate) = 1996
);

-- 4. Usunięcie przeniesionych danych z oryginalnej tabeli Orders
DELETE FROM Orders
WHERE YEAR(OrderDate) = 1996;

-- Zatwierdzenie transakcji
COMMIT TRANSACTION;