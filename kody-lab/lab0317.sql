-- Query 1 (everything from Orders)
select * from dbo.Orders
go

-- Query 2.1 (Orders shipped to Mexico, Germany or Brazil with list)
select * from dbo.Orders
where ShipCountry in ('Mexico', 'Germany', 'Brazil')
go

-- Query 2.2 (Orders shipped to Mexico, Germany or Brazil with or)
select * from dbo.Orders
where ShipCountry = 'Mexico' or ShipCountry = 'Germany' or ShipCountry = 'Brazil'
go

-- Query 3.1 (All cities in Germany with distinct)
select distinct ShipCity
from dbo.Orders
where ShipCountry = 'Germany'
go

-- Query 3.2 (All cities in Germany with group by)
select ShipCity
from dbo.Orders
where ShipCountry = 'Germany'
group by ShipCity
go

-- Query 5 (First ten characters from company names with UPPER)
select distinct LEFT(UPPER(CompanyName),10)
from dbo.Customers
go

-- Query 8 (orders shipped to different country than customer country)
select o.*
from dbo.Orders o
         join dbo.Customers c
              on c.CustomerID = o.CustomerID
where c.Country != o.ShipCountry
go

-- Query 9.1 (customers than don't have any orders with left join)
select ContactName, OrderID
from dbo.Customers c
         left join dbo.Orders o
                   on o.CustomerID = c.CustomerID
where OrderID is null
go

-- Query 9.2 (customers than don't have any orders with where, not in)
select ContactName
from dbo.Customers c
where CustomerID not in (select CustomerID from dbo.Orders)
go

-- Query 11 (all clients that ordered Scottish Longbreads)
select distinct ContactName, ProductName
from dbo.Customers c
    join dbo.Orders o
        on c.CustomerID = o.CustomerID
    join dbo.[Order Details] od
        on od.OrderID = o.OrderID
    join dbo.Products p
        on p.ProductID = od.ProductID
where ProductName = 'Scottish Longbreads'
go

-- Query 15
-- with german_clients as (
--     select *
--     from dbo.Customers
--     where Country = 'German'
-- )
-- , cs_products as (
--         select *
--       from dbo.Products
--       where ProductName like '[c-s]%'
--       )
-- select *
-- from