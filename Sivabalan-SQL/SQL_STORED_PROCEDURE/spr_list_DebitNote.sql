CREATE procedure [dbo].[spr_list_DebitNote](@FromDate datetime,    
        @ToDate datetime)    
as    

Declare @OPEN As NVarchar(50)
Declare @CLOSED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)


select DebitID, "Note Number" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),    
"Date" = DocumentDate, "Customer" = Customer.Company_Name,    
"Vendor" = Vendors.Vendor_Name, "Doc Reference" = DocRef, "Note Value" = NoteValue,     
"Remarks" = Memo,     
"Status" = case    
when Balance > 0 then    
@OPEN 
When Status & 64 <> 0 Then  
@CANCELLED 
else    
@CLOSED  
end    
from DebitNote, VoucherPrefix, Customer, Vendors    
where DebitNote.CustomerID *= Customer.CustomerID and    
DebitNote.VendorID *= Vendors.VendorID and    
DebitNote.DocumentDate between @FromDate and @ToDate and    
VoucherPrefix.TranID = 'DEBIT NOTE'
