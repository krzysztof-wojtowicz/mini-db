-- Zadanie 2 (12p)

-- Query 1 - Wypisz informacje o produktach które zostały zamówione jednorazowo w ilości (quantity) poniżej 105%
-- średniej ilości tego produktu zamawianej we wszystkich zamówieniach. Wyniki przedstaw w kolejności rosnącej
-- liczby zamówień na produkt.
with pre_sql as (
    select p.ProductID, AVG(od.Quantity * 1.0) as AvgQuantity, COUNT(od.OrderID) as ProductOrdersCount
    from Products p
        join [Order Details] od
        on p.ProductID = od.ProductID
    group by p.ProductID
)

select ProductName, OrderID, Quantity, AvgQuantity, ProductOrdersCount
from Products p
join [Order Details] od
on od.ProductID = p.ProductID
join pre_sql ps
on ps.ProductID = p.ProductID
where  1.05*AvgQuantity > od.Quantity
order by ps.ProductOrdersCount;

-- Query 2 - Wypisz w porządku alfabetycznym nazwiska pracowników, którzy nie obsługiwali żadnego zamówienia wy-
-- słanego do Niemiec lub Brazylii i kiedykolwiek w ich nadzorowanym zamówieniu znajdował się produkt o nazwie
-- kończącej się na literę ’k’.

-- Pracownicy, którzy obsługiwali coś z Niemiec lub Brazylii
with pre_sql as (
    select e.EmployeeID
    from Employees e
             join Orders o
                  on e.EmployeeID = o.EmployeeID
    where o.ShipCountry = 'Brazil' or o.ShipCountry = 'Germany'
    group by e.EmployeeID
)
-- Pracownicy, którzy zamówili kiedykolwiek produkt kończący się na 'k'
, pre_sql2 as (
    select e.EmployeeID
    from Employees e
        join Orders o
            on e.EmployeeID = o.EmployeeID
        join [Order Details] od
            on od.OrderID = o.OrderID
        join Products p
            on p.ProductID = od.ProductID
    where p.ProductName like '%k'
    group by e.EmployeeID
    )

select e.LastName
from Employees e
where
    e.EmployeeID not in (select EmployeeID from pre_sql)
    and e.EmployeeID in (select EmployeeID from pre_sql2)
order by e.LastName;

-- Query 3 - Całkowita liczba sztuk sprzedanych produktów w 1996, wyliczona w okresie od poprzedzającego do następ-
-- nego miesiąca. Wynik: Month, TotalQuantityForYear, TotalQuantityForTheMonths. Do realizacji zapytania można
-- wykorzystać widok.

with pre_sql as (
    select MONTH(o.OrderDate) as Month, SUM(od.Quantity) as TotalQuantityForMonth
    from Orders o
        join [Order Details] od
            on o.OrderID = od.OrderID
    where YEAR(o.OrderDate) = 1996
    group by MONTH(o.OrderDate)
)

select
    Month,
    SUM(TotalQuantityForMonth) over (  ) as TotalQuantityForYear,
    SUM(TotalQuantityForMonth) over (
        order by Month
        rows between 1 preceding and 1 following
        ) as TotalQuantityForTheMonths
from pre_sql;

-- Query 4 - Wypisz 2 najstarszych pracowników, którzy sprzedali więcej różnych produktów (asortyment, nie sztuki) w 2
-- kwartale 1997 niż w 1 kwartale 1997 roku.

--
with pre_sql as (
    select
        e.EmployeeID,
        COUNT(DISTINCT od.ProductID) as DistinctProductsQ2
    from Employees e
        join Orders o
            on o.EmployeeID = e.EmployeeID
        join [Order Details] od
            on od.OrderID = o.OrderID
    where YEAR(o.OrderDate) = 1997 and DATEPART(quarter, o.OrderDate) = 2
    group by e.EmployeeID
)
, pre_sql2 as (
    select
        e.EmployeeID,
        COUNT(DISTINCT od.ProductID) as DistinctProductsQ1
    from Employees e
             join Orders o
                  on o.EmployeeID = e.EmployeeID
             join [Order Details] od
                  on od.OrderID = o.OrderID
    where YEAR(o.OrderDate) = 1997 and DATEPART(quarter, o.OrderDate) = 1
    group by e.EmployeeID
)

select top 2
    e.FirstName,
    e.LastName,
    e.BirthDate,
    ps2.DistinctProductsQ1,
    ps.DistinctProductsQ2
from Employees e
    join pre_sql ps
        on ps.EmployeeID = e.EmployeeID
    join pre_sql2 ps2
        on ps2.EmployeeID = e.EmployeeID
where ps.DistinctProductsQ2 > ps2.DistinctProductsQ1
order by e.BirthDate;