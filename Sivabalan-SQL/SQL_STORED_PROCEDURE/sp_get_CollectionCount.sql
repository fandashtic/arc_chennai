
CREATE PROCEDURE sp_get_CollectionCount
AS
Declare @SICount as Int
--Begin: Changes has been made for Over Due Collections of service Invoice
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') 
and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	SELECT @SICount = Count(*) FROM ServiceInvoiceAbstract
	WHERE PaymentDate <= Getdate() and
	isNull(Balance,0) <> 0 and
	isNull(ServiceInvoiceType,0) in (1) and
	isNull(Status,0) & 192 = 0
End
--End: Over Due Collections of service Invoice

SELECT Count(*) + isNull(@SICount,0) FROM InvoiceAbstract
WHERE PaymentDate <= Getdate() and
Balance <> 0 and
InvoiceType in (1, 3) and
Status & 128 = 0

