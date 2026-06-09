-- 1. Tabela Klient
CREATE TABLE Klienci (
    id_klienta INT IDENTITY(1,1) PRIMARY KEY,
    imie NVARCHAR(50),
    nazwisko NVARCHAR(50) NOT NULL,
    email NVARCHAR(100),
    telefon NVARCHAR(20),
    adres NVARCHAR(100),
    miasto NVARCHAR(50),
    kraj NVARCHAR(50)
);

-- 2. Tabela Wózek
CREATE TABLE Wozki (
    id_wozka INT IDENTITY(1,1) PRIMARY KEY,
    model NVARCHAR(50) NOT NULL,
    kategoria NVARCHAR(50),
    udzwig DECIMAL(10,2),
    cena DECIMAL(10,2)
);

-- 3. Tabela Części
CREATE TABLE Czesci (
    id_czesci INT IDENTITY(1,1) PRIMARY KEY,
    nazwa NVARCHAR(100) NOT NULL,
    typ_czesci NVARCHAR(50),
    material NVARCHAR(50),
    kraj_produkcji NVARCHAR(50),
    masa DECIMAL(10,2)
);

-- 4. Tabela Skład Wózka (wiele do wielu: wózek składa się z wielu części, część może być w wielu wózkach)
CREATE TABLE SkladWozka (
    id_wozka INT FOREIGN KEY REFERENCES Wozki(id_wozka),
    id_czesci INT FOREIGN KEY REFERENCES Czesci(id_czesci),
    liczba_sztuk INT NOT NULL,
    PRIMARY KEY (id_wozka, id_czesci)
);

-- 5. Tabela Zamówienia (nagłówek)
CREATE TABLE Zamowienia (
    id_zamowienia INT IDENTITY(1,1) PRIMARY KEY,
    id_klienta INT FOREIGN KEY REFERENCES Klienci(id_klienta),
    data_zlozenia DATE DEFAULT GETDATE(),
    termin_realizacji_data DATE, -- wyliczona data
    wspolczynnik_zlozonosci DECIMAL(18,2),
    dominujacy_material NVARCHAR(50)
);

-- 6. Tabela Detale Zamówienia
CREATE TABLE SzczegolyZamowienia (
    id_detalu INT IDENTITY(1,1) PRIMARY KEY,
    id_zamowienia INT FOREIGN KEY REFERENCES Zamowienia(id_zamowienia),
    id_wozka INT FOREIGN KEY REFERENCES Wozki(id_wozka),
    ilosc INT NOT NULL
);
