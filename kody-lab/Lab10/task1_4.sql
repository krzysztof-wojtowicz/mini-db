-- 1. Widok: TOP 3 najczęściej wykorzystywane materiały dla każdej kategorii wózka
CREATE VIEW v_Top3MaterialyKategoria AS
WITH MaterialyWCaching AS (
    SELECT 
        w.kategoria, 
        c.material, 
        SUM(sw.liczba_sztuk) as zuzycie_materialu,
        ROW_NUMBER() OVER(PARTITION BY w.kategoria ORDER BY SUM(sw.liczba_sztuk) DESC) as pozycja
    FROM Wozki w
    JOIN SkladWozka sw ON w.id_wozka = sw.id_wozka
    JOIN Czesci c ON sw.id_czesci = c.id_czesci
    GROUP BY w.kategoria, c.material
)
SELECT kategoria, material, zuzycie_materialu 
FROM MaterialyWCaching 
WHERE pozycja <= 3;

-- 2. Widok: Wózki z najwyższym współczynnikiem złożoności w każdej kategorii
CREATE VIEW v_NajbardziejZlozoneWozkiKategoria AS
WITH ZlozonoscWozkow AS (
    SELECT 
        w.id_wozka, 
        w.model, 
        w.kategoria,
        COUNT(DISTINCT sw.id_czesci) * AVG(CAST(sw.liczba_sztuk AS DECIMAL(18,2))) * COUNT(DISTINCT c.material) AS wsp_zlozonosci
    FROM Wozki w
    JOIN SkladWozka sw ON w.id_wozka = sw.id_wozka
    JOIN Czesci c ON sw.id_czesci = c.id_czesci
    GROUP BY w.id_wozka, w.model, w.kategoria
), RankingZlozonosci AS (
    SELECT 
        id_wozka, model, kategoria, wsp_zlozonosci,
        ROW_NUMBER() OVER(PARTITION BY kategoria ORDER BY wsp_zlozonosci DESC) as rnk
    FROM ZlozonoscWozkow
)
SELECT id_wozka, model, kategoria, wsp_zlozonosci 
FROM RankingZlozonosci 
WHERE rnk = 1;
