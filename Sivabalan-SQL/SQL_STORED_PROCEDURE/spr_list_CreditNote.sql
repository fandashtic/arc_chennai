CREATE procedure [dbo].[spr_list_CreditNote](@FromDate datetime,  
         @ToDate datetime)  
as  

Declare @OPEN NVarchar(50)
Declare @CANCELLED NVarchar(50)
Declare @CLOSED NVarchar(50)

Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default) 
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default) 
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default) 

select CreditID, "Credit ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),  
"Date" = DocumentDate, "Customer" = Customer.Company_Name,   
"Vendor" = Vendors.Vendor_Name, "DocRef" = DocRef, "Value" = NoteValue,   
"Remarks" = Memo,  
"Status" = case   
when Balance > 0 then  
@OPEN
When Status & 64 <> 0 Then  
@CANCELLED
else  
@CLOSED
end  
from CreditNote, VoucherPrefix, Customer, Vendors  
where CreditNote.CustomerID *= Customer.CustomerID and  
CreditNote.VendorID *= Vendors.VendorID and  
CreditNote.DocumentDate between @FromDate and @ToDate and  
VoucherPrefix.TranID = 'CREDIT NOTE'
