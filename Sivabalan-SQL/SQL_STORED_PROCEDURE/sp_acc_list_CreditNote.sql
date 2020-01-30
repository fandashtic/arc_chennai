create Procedure sp_acc_list_CreditNote(@FromDate datetime,  
         @ToDate datetime)  
as  
If Not Exists (Select * from ReportData Where Parent = 137)/*(Parent)137 = CreditNote Report*/  
select CreditID, "Credit ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),"Date" = DocumentDate,  
"Type"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then dbo.LookupDictionaryItem('Others',Default) Else   
(Case When CreditNote.CustomerID is Null Then dbo.LookupDictionaryItem('Vendor',Default) Else dbo.LookupDictionaryItem('Customer',Default) End) End,    
"Account Name"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then   
dbo.getaccountname(isnull(Others,0)) Else (Case When CreditNote.CustomerID is Null Then    
Vendors.Vendor_Name Else Customer.Company_Name End) End, "DocRef" = DocRef, "Value" = NoteValue,  
"Expense"=dbo.getaccountname(isnull(CreditNote.AccountID,0)),  
"Remarks" = Memo,  
/*Status column shows incorrect value is addressed. - CRM ID is 11299412 */
"Status" =   
case   
 when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default)   
 when isnull(status & 128,0 ) = 128 
-- and isnull(RefDocid,0) <> 0 
 then dbo.LookupDictionaryItem('Amended',Default)      
-- when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)      
-- when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)      
 When isnull(status,0) = 0 and Balance = 0 
--and isnull(RefDocid,0) = 0 
then dbo.LookupDictionaryItem('Closed',Default)  
 When isnull(status,0) = 0 and Balance > 0 
--and isnull(RefDocid,0) = 0 
then dbo.LookupDictionaryItem('Open',Default)  
end  
from CreditNote
Left Outer Join Customer On CreditNote.CustomerID = Customer.CustomerID
Left Outer Join Vendors  On CreditNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix On VoucherPrefix.TranID = N'CREDIT NOTE'  
where CreditNote.DocumentDate between @FromDate and @ToDate 
Else  
select CreditID, "Credit ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),"Date" = DocumentDate,  
"Type"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then dbo.LookupDictionaryItem('Others',Default) Else   
(Case When CreditNote.CustomerID is Null Then dbo.LookupDictionaryItem('Vendor',Default) Else dbo.LookupDictionaryItem('Customer',Default) End) End,    
"Account Name"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then   
dbo.getaccountname(isnull(Others,0)) Else (Case When CreditNote.CustomerID is Null Then    
Vendors.Vendor_Name Else Customer.Company_Name End) End, "DocRef" = DocRef, "Value" = NoteValue,  
"Remarks" = Memo,  
/*Status column shows incorrect value is addressed. - CRM ID is 11299412 */
"Status" =   
case   
 when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default)   
 when isnull(status & 128,0 ) = 128 
-- and isnull(RefDocid,0) <> 0 
 then dbo.LookupDictionaryItem('Amended',Default)      
-- when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)      
-- when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)      
 When isnull(status,0) = 0 and Balance = 0 
--and isnull(RefDocid,0) = 0 
then dbo.LookupDictionaryItem('Closed',Default)  
 When isnull(status,0) = 0 and Balance > 0 
--and isnull(RefDocid,0) = 0 
then dbo.LookupDictionaryItem('Open',Default)  
end  
from CreditNote
Left Outer Join Customer On CreditNote.CustomerID = Customer.CustomerID
Left Outer Join Vendors On CreditNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix On VoucherPrefix.TranID = N'CREDIT NOTE'  
where CreditNote.DocumentDate between @FromDate and @ToDate
