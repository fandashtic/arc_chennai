





CREATE procedure sp_acc_loadpendingbills(@accountid nvarchar(15))
as 
DECLARE @prefix nvarchar(10)

select @prefix = [Prefix] from [VoucherPrefix] where [TranID]=N'BILL' 
 
select 'DocumentID'=@prefix + cast(DocumentID as nvarchar),BillID, dbo.stripdatefromtime(BillDate),Value,Balance from BillAbstract
where VendorID in (select VendorID from Vendors where [AccountID]= @accountid) 
and isnull(Balance,0)>0 and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0






