set transaction isolation level repeatable read
begin transaction

select * from Customers
where CustomerID='ALFKI'

rollback

-- scenariusz #1 do domu