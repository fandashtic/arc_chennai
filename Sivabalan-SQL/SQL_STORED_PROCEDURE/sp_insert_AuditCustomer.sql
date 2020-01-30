create procedure sp_insert_AuditCustomer(@CustId as nvarchar(30))
as
update AuditMaster set customerID=@CustID where CustomerID=@CustID
if(@@RowCount=0)
insert into auditmaster values(@CustId)






