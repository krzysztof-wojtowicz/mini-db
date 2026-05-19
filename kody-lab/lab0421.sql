-- Task 7 - db lab6

-- 1.
-- select
--     SUM(Quantity)
-- from dbo.[Order Details] od
--     join dbo.Products p
--         on p.ProductID = od.ProductID
--     join dbo.Orders o
--         on o.OrderID = od.OrderID
-- where
--     p.ProductName = 'Chocolade'
--     and YEAR(o.OrderDate) = 1997
--
-- begin transaction
--
--     -- 2.
--     update od
--     set od.Quantity = 2 * od.Quantity
--     from dbo.[Order Details] od
--          join dbo.Products p
--               on p.ProductID = od.ProductID
--          join dbo.Orders o
--               on o.OrderID = od.OrderID
--     where
--         p.ProductName = 'Chocolade'
--         and YEAR(o.OrderDate) = 1997
--
--     -- 3.
--     select
--         SUM(Quantity)
--     from dbo.[Order Details] od
--              join dbo.Products p
--                   on p.ProductID = od.ProductID
--              join dbo.Orders o
--                   on o.OrderID = od.OrderID
--     where
--         p.ProductName = 'Chocolade'
--       and YEAR(o.OrderDate) = 1997
--
-- rollback

-- Scenariusz #1 (to do domu + scenariusz #3) - db lab6

-- begin transaction
--     -- Stworzyć ArchivedOrders z zamówieniami z 1996
--     select *
--         into dbo.ArchivedOrders
--     from dbo.Orders
--     where YEAR(OrderDate) = 1996;
--
--     -- Dodać klucze etc.
--
--     -- Dodać kolumnę ArchivedDate
--     alter table dbo.ArchivedOrders
--     add ArchivedDate datetime2;
--
--     -- Stworzyć ArchivedOrdersDetails z zamówieniami z 1996
--     select od.*
--         into dbo.ArchiveOrderDetails
--     from dbo.[Order Details] od
--         join dbo.Orders o
--             on o.OrderID = od.OrderID
--     where YEAR(OrderDate) = 1996;
--
-- commit

-- Task 1 - db lab 7
-- select *
-- from orders o
-- where
--     not exists (select * from [order details] od
--                     join products p
--                     on p.productid = od.productid
--                     where productname = 'Scottish Longbreads'
--                         and od.orderid = o.orderid)
--                         and exists (select *
--                                     from [order details] od
--                                         join products p
--                                         on p.productid = od.productid
--                                     where productname = 'Chocolade'
--                                         and od.orderid = o.orderid)
--

-- create view OrdersTotal as (
-- select
--     year(OrderDate) as OrderYear, datepart(month, OrderDate) as OrderMonth,
--     O.OrderId, O.CustomerID, Cust.CompanyName, Cust.Country as CustomerCountry, Cust.City AS
--         CustomerCity,
--     O.ShipCountry, O.ShipCity, OD.ProductID, P.ProductName, Cat.CategoryName, OD.UnitPrice,
--     OD.Quantity, OD.UnitPrice * OD.Quantity as ProductValue
-- from Orders O
--          JOIN [Customers] Cust ON O.CustomerID = Cust.CustomerID
--          JOIN [Order Details] OD ON OD.OrderID = O.OrderID
--          JOIN [Products] P ON P.ProductID = OD.ProductID
--          JOIN [Categories] Cat ON Cat.CategoryID = P.CategoryID
--     )


set statistics io, time on

SELECT OrderId,ProductName,CategoryName, ProductValue,
       SUM(ProductValue) OVER (PARTITION BY ProductName) as
           ProdTotalSale,
       SUM(ProductValue) OVER (PARTITION BY CategoryName) as
           CategoryTotalSale
FROM OrdersTotal order by ProductName