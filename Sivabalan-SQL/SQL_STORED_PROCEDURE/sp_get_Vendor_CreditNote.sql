CREATE procedure sp_get_Vendor_CreditNote(@DocumentID int)  
as  
select Vendors.VendorID, Vendors.Vendor_Name, NoteValue, DocumentDate, Memo,   
DocumentID, DocRef,   
case   
When Status & 64 <> 0 Then dbo.LookupDictionaryItem(N'Cancelled', Default)
When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem(N'Amended', Default)
when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem(N'Amended', Default)
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem(N'Amendment', Default)
Else N''    
end, Cancel_Memo,DocumentReference,DocSerialType
from CreditNote, Vendors  
where CreditID = @DocumentID and  
Vendors.VendorID = CreditNote.VendorID



