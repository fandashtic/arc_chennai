





create procedure sp_acc_loadpendinginvoices(@accountid nvarchar(15))
as 
DECLARE @customerid nvarchar(15)
DECLARE @prefix nvarchar(10)

select @prefix =[Prefix] from [VoucherPrefix] where [TranID]=N'INVOICE'  
select 'DocumentID'=@prefix + cast(DocumentID as nvarchar),InvoiceID, dbo.stripdatefromtime(InvoiceDate),NetValue,Balance from InvoiceAbstract
where customerid in (select CustomerID from Customer where [AccountID]= @accountid) 
and isnull(Balance,0)>0 and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0  






