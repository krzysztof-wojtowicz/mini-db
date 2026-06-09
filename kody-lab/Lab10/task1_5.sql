-- Indeks przyspieszający łączenie składu wózka i filtrowanie
CREATE INDEX IX_SkladWozka_IdWozka_IdCzesci 
ON SkladWozka(id_wozka, id_czesci) INCLUDE (liczba_sztuk);

-- Indeksy pomagające przy grupowaniu po kategoriach i materiałach
CREATE INDEX IX_Wozki_Kategoria ON Wozki(kategoria);
CREATE INDEX IX_Czesci_Material ON Czesci(material);

-- Indeks na nazwisko klienta, aby procedura ZlozZamowienie działała szybciej
CREATE INDEX IX_Klienci_Nazwisko ON Klienci(nazwisko);
