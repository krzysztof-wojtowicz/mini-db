-- =========================================================================
-- ŚCIĄGAWKA SQL SERVER - KOLOKWIUM
-- =========================================================================

-- Zawsze upewnij się, że pracujesz na właściwej bazie!
USE NORTHWND;
GO

-- =========================================================================
-- 1. DDL (Data Definition Language) - Zmiany w strukturze
-- =========================================================================

-- Tworzenie tabeli (przydatne do zadań z "logowaniem operacji")
-- Słowo IDENTITY(1,1) to auto-inkrementacja (zaczyna od 1, rośnie co 1).
CREATE TABLE MyExamLog (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    OperationType VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    OperationDate DATETIME DEFAULT GETDATE() -- Domyślnie wstawia obecną datę i czas
);

-- Zmiana struktury istniejącej tabeli (np. polecenie: "dodaj nową kolumnę do tabeli")
ALTER TABLE Employees ADD PersonalEmail VARCHAR(100);

-- Usunięcie kolumny, jeśli zrobisz błąd
ALTER TABLE Employees DROP COLUMN PersonalEmail;

-- =========================================================================
-- 2. DML (Data Manipulation Language) - INSERT, UPDATE, DELETE
-- =========================================================================

-- Klasyczny INSERT
INSERT INTO Customers (CustomerID, CompanyName, ContactName, City, Country)
VALUES ('STUD1', 'Uczelnia Sp. z o.o.', 'Jan Student', 'Warszawa', 'Poland');

-- INSERT INTO ... SELECT (Bardzo ważne!)
-- Przydaje się, gdy musisz np. zarchiwizować dane lub skopiować rekordy do logu.
INSERT INTO MyExamLog (OperationType, Description)
SELECT 'BACKUP', 'Skopiowano klienta: ' + CompanyName 
FROM Customers 
WHERE Country = 'Poland';

-- Klasyczny UPDATE (Zawsze pamiętaj o klauzuli WHERE, inaczej zaktualizujesz całą tabelę!)
UPDATE Customers
SET City = 'Kraków', 
    ContactName = 'Anna Studentka'
WHERE CustomerID = 'STUD1';

-- UPDATE z operacjami matematycznymi (np. "Podnieś ceny wszystkich produktów z kategorii 1 o 10%")
UPDATE Products
SET UnitPrice = UnitPrice * 1.10
WHERE CategoryID = 1;

-- BATCH UPDATE - operacje masowe na tekście (jak z Twojego zadania)
-- Funkcja REPLACE szuka podciągu i zamienia go na inny.
UPDATE Customers
SET Phone = REPLACE(Phone, '5', '3')
WHERE Country = 'France';

-- DELETE - usuwanie rekordów
DELETE FROM Customers
WHERE CustomerID = 'STUD1';

-- =========================================================================
-- 3. TRANSAKCJE W SQL (T-SQL) - Ochrona przed awarią
-- =========================================================================
-- W Javie robiliśmy to przez conn.setAutoCommit(false), ale na kolokwium
-- mogą poprosić, żebyś napisał to bezpośrednio w SQL (np. wewnątrz procedury).

BEGIN TRY
    BEGIN TRAN; -- Rozpoczęcie transakcji
    
    -- Wykonujemy jakieś operacje (np. ściągamy kasę i dodajemy towar)
    UPDATE Products SET UnitsInStock = UnitsInStock - 5 WHERE ProductID = 1;
    INSERT INTO MyExamLog (OperationType) VALUES ('SPRZEDAŻ');
    
    -- Jeśli wszystko poszło gładko:
    COMMIT TRAN; 
END TRY
BEGIN CATCH
    -- Jeśli cokolwiek wywali błąd (np. brak ID), trafiamy tutaj
    IF @@TRANCOUNT > 0 
        ROLLBACK TRAN; -- Wycofanie wszystkich zmian
    
    -- Wypisanie błędu (przydatne do debugowania)
    PRINT 'ERROR: ' + ERROR_MESSAGE(); 
END CATCH;

-- =========================================================================
-- 4. PROCEDURY SKŁADOWANE (Stored Procedures)
-- =========================================================================

-- Separator GO jest wymagany przed komendą CREATE PROCEDURE.
GO

-- Słowo ALTER używasz, gdy procedura już istnieje i chcesz wgrać nową wersję (podmienić kod).
-- Słowo CREATE, gdy tworzysz ją po raz pierwszy.
CREATE PROCEDURE p_UpdateEmployeeRegion
    @EmpID INT,               -- Parametry wejściowe z @
    @NewRegion NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; -- Dobry nawyk, zapobiega śmieceniu komunikatami "1 row affected" w Javie

    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE Employees 
        SET Region = @NewRegion 
        WHERE EmployeeID = @EmpID;
        
        INSERT INTO MyExamLog (OperationType, Description) 
        VALUES ('UPDATE_EMP', 'Zmieniono region dla pracownika: ' + CAST(@EmpID AS VARCHAR));
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW; -- Odrzuca błąd "w górę" (np. żeby złapał go Twój catch w Javie)
    END CATCH
END;
GO

-- Jak wywołać procedurę ręcznie z poziomu bazy (żeby sprawdzić, czy działa, zanim napiszesz kod w Javie):
EXEC p_UpdateEmployeeRegion @EmpID = 1, @NewRegion = 'Mazowieckie';

-- =========================================================================
-- ŚCIĄGAWKA SQL SERVER - TWORZENIE TABEL (CREATE TABLE)
-- =========================================================================

-- Pamiętaj, żeby wybrać właściwą bazę!
USE NORTHWND;
GO

-- -------------------------------------------------------------------------
-- 1. PODSTAWOWA TABELA Z KLUCZEM GŁÓWNYM
-- -------------------------------------------------------------------------
-- IDENTITY(1,1) sprawia, że serwer sam nadaje kolejne numery (1, 2, 3...)
-- PRIMARY KEY oznacza, że wartość musi być unikalna i nie może być NULL.

CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL -- NOT NULL wymusza podanie nazwy (nie można zostawić pustego)
);

-- -------------------------------------------------------------------------
-- 2. ZAAWANSOWANA TABELA - WSZYSTKIE NAJWAŻNIEJSZE CONSTRAINTS
-- -------------------------------------------------------------------------

CREATE TABLE Employees_Advanced (
    -- Klucz główny
    EmpID INT IDENTITY(1,1) PRIMARY KEY,

    -- Zwykły tekst, wymagany (NOT NULL)
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,

    -- UNIQUE: Wartość musi być unikalna w całej tabeli (nikt inny nie może mieć takiego e-maila),
    -- ale w przeciwieństwie do PRIMARY KEY, pozwala na przechowywanie wartości NULL (jeśli usuniemy NOT NULL).
    Email VARCHAR(100) UNIQUE NOT NULL,

    -- DEFAULT: Jeśli przy INSERT nie podasz wartości dla tej kolumny, 
    -- baza automatycznie wstawi tutaj napis 'Brak danych'.
    JobTitle VARCHAR(50) DEFAULT 'Brak danych',

    -- CHECK: Nakłada warunek logiczny na wprowadzane dane.
    -- Tutaj upewniamy się, że pensja nie może być ujemna.
    Salary DECIMAL(10, 2) CHECK (Salary >= 0),

    -- CHECK (inny przykład): Wymuszamy, żeby płeć była tylko 'M' lub 'K'.
    Gender CHAR(1) CHECK (Gender IN ('M', 'K')),

    -- DEFAULT z funkcją systemową: GETDATE() automatycznie wstawia obecną datę i czas.
    -- Bardzo przydatne do logowania, kiedy rekord został utworzony.
    HireDate DATETIME DEFAULT GETDATE(),

    -- KLUCZ OBCY (FOREIGN KEY): Tworzy relację z inną tabelą.
    -- Ten wpis gwarantuje, że nie można przypisać pracownika do działu (DepartmentID), 
    -- który nie istnieje w tabeli Departments.
    DeptID INT FOREIGN KEY REFERENCES Departments(DepartmentID)
);

-- -------------------------------------------------------------------------
-- 3. TWORZENIE TABELI Z KLUCZEM ZŁOŻONYM (Composite Key)
-- -------------------------------------------------------------------------
-- Czasami jeden klucz (np. OrderID) to za mało. W tabeli łącznikowej 
-- (jak OrderDetails) kluczem głównym jest kombinacja dwóch kolumn.

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT DEFAULT 1,
    
    -- Tak definiujemy klucz główny składający się z wielu kolumn:
    PRIMARY KEY (OrderID, ProductID),

    -- Definiowanie kluczy obcych na końcu tabeli:
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- -------------------------------------------------------------------------
-- 4. TWORZENIE TABELI "Z KASKADĄ" (ON DELETE CASCADE)
-- -------------------------------------------------------------------------
-- Co ma się stać, jeśli usuniemy dział z tabeli Departments, w którym pracują jacyś ludzie?
-- Domyślnie baza wyrzuci błąd (ochrona przed sierotami).
-- Zastosowanie ON DELETE CASCADE sprawi, że usunięcie działu 
-- automatycznie usunie wszystkich przypisanych do niego pracowników (przydatne np. przy usuwaniu konta użytkownika i jego postów).

CREATE TABLE ProjectAssignments (
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    
    DepartmentID INT,
    
    -- Jeśli usuniesz Dział (DepartmentID), wszystkie przypisane tu projekty
    -- zostaną usunięte razem z nim!
    CONSTRAINT FK_Dept_Projects FOREIGN KEY (DepartmentID) 
    REFERENCES Departments(DepartmentID) 
    ON DELETE CASCADE
);

-- (Inną opcją jest ON DELETE SET NULL - wtedy usunięcie działu zostawi projekt w bazie, ale w polu DepartmentID wpisze NULL).
