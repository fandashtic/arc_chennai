CREATE procedure sp_acc_updatecustomername(@customerid nvarchar(50))
as 
Declare @accountid integer,@customername nvarchar(256)
select @accountid=AccountID,@customername = Company_Name from Customer where [CustomerID]=@customerid

update AccountsMaster Set AccountName = @customername
where AccountID = @accountid
