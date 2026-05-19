-- Query 2
with pre_sql as (
    select
        o.EmployeeID, SUM(od.Quantity) as quantity_total
    from dbo.Orders o
    join dbo.[Order Details] od
        on od.OrderID = o.OrderID
    where YEAR(o.OrderDate) = '1998'
        and ProductID = (select
                             ProductID
                         from dbo.Products
                         where ProductName = 'Chocolade')
    group by o.EmployeeID
    having SUM(od.Quantity) >= 0
)

select
    e.FirstName, e.LastName, ps.quantity_total
from dbo.Employees e
join pre_sql ps
    on ps.EmployeeID = e.EmployeeID

-- Query 4
select
    c.ContactName, p.ProductName, o.OrderDate, od.Quantity
from dbo.Customers c
join dbo.Orders o
    on c.CustomerID = o.CustomerID
join dbo.[Order Details] od
    on od.OrderID = o.OrderID
join dbo.Products p
    on p.ProductID = od.ProductID
where c.City = 'Berlin'
order by c.ContactName, p.ProductName, o.OrderDate

-- Query 7
select
    c.CompanyName,
    o.OrderID,
    cast(count(distinct ProductID) as decimal(10,2)) as ProductCount
from dbo.Orders o
join dbo.[Order Details] od
    on o.OrderID = od.OrderID
join dbo.Customers c
    on c.CustomerID = o.CustomerID
where c.Country = 'France'
group by o.OrderID, c.CompanyName
having count(distinct ProductID) >= 4

-- Query 9
-- with pre_sql as (
--     select
--         p.ProductID,
--         p.ProductName,
--         MAX(Quantity) as MaxQuantity
--     from dbo.[Order Details] od
--     join dbo.Products p
--         on p.ProductID = od.ProductID
--     group by p.ProductID, p.ProductName
-- )

-- Query 11
select top 5
    o.OrderID,
    count(distinct od.ProductID) as ProductCount
from dbo.Orders o
join dbo.[Order Details] od
    on o.OrderID = od.OrderID
group by o.OrderID
order by count(distinct od.ProductID) desc

-- Query 10
with pre_sql1 as (
    select
        o.EmployeeID,
        count(distinct o.OrderID) as OrderCount
    from dbo.Orders o
    group by o.EmployeeID
    )
, pre_sql2 as (
    select
        AVG(OrderCount) as AvgOrderCount
    from pre_sql1
    )

select
    e.FirstName,
    e.LastName,
    ps1.OrderCount,
    (select AvgOrderCount from pre_sql2) as AvgOrderCount
from dbo.Employees e
join pre_sql1 ps1
    on e.EmployeeID = ps1.EmployeeID
where OrderCount > 1.2 * (select AvgOrderCount from pre_sql2)