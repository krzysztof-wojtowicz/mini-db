set transaction isolation level read committed
begin transaction
update Customers set City='Berlin'
where CustomerID='ALFKI'
commit