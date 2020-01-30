CREATE procedure sp_ser_listCollections(@CustomerID as varchar(15))
as
Declare @Prefix as varchar(10)

Select @Prefix = VoucherPrefix.Prefix from VoucherPrefix 
Where VoucherPrefix.TranID = 'SERVICEINVOICE'

select 
"DocumentID" =  IsNull(@Prefix, '') + CAST(DocumentID as nvarchar), 
"DocumentDate" = ServiceInvoiceDate, NetValue, Balance, ServiceInvoiceID, 
"Type" = 12, 'Service Invoice', AdditionalDiscountPercentage, DocReference 
from ServiceInvoiceAbstract 
where 
IsNull(Status, 0) & 192 = 0 and CustomerID = @CustomerID and ISNULL(Balance, 0) > 0 
Order by ServiceInvoiceDate

--InvoiceType in (1)

