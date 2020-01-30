CREATE procedure sp_list_Vendor_CreditNote(@VendorID nvarchar(15),    
        @FromDate datetime,    
        @ToDate datetime)    
as    

Declare @CANCELLED As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)

select DocumentID, DocumentDate, Vendors.VendorID, Vendors.Vendor_Name, NoteValue, CreditID,  
case   
When Status & 64 <> 0 Then @CANCELLED          
When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then @AMENDED 
when isnull(status & 128,0 ) = 128 and Balance = 0  then @AMENDED
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then @AMENDMENT
Else N''    
end,DocumentReference          
from CreditNote, Vendors    
where Vendors.VendorID like @VendorID and    
DocumentDate between @FromDate and @ToDate and    
Vendors.VendorID = CreditNote.VendorID    
order by Vendors.Vendor_Name, DocumentDate





