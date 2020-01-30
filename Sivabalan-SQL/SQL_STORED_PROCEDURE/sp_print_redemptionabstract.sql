CREATE procedure sp_print_redemptionabstract @DocSerial int
as
begin
declare @ItemCount int
declare @DocPrefix nvarchar(20)
select @DocPrefix = Prefix from voucherprefix where tranid = 'CUSTOMER POINT REDEMPTION'

select @ItemCount = count(*) from redemptiondetail where DocSerial = @DocSerial 

select "DocumentID" = @DocPrefix + cast(documentid as nvarchar),
"DocumentReference" = DocumentReference,"DocumentDate" = DocumentDate,
"CustomerID" = redemptionabstract.CustomerID,"Customer Name" = company_Name,
"RedeemedPoints" = redemptionabstract.RedeemedPoints, "RedeemedAmount" = RedeemedAmount,"Item Count" = @ItemCount
from redemptionabstract,customer where customer.customerid=redemptionabstract.customerid 
and redemptionabstract.DocSerial = @DocSerial
end

