set transaction isolation level read committed
begin transaction
update Customers set City='Warsaw'
where CustomerID='ALFKI'
commit
