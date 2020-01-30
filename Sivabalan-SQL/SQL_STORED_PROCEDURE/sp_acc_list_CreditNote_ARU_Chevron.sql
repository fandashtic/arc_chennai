Create Procedure [dbo].[sp_acc_list_CreditNote_ARU_Chevron](@FromDate datetime,
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
"Status" = 
case 
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end
from CreditNote
Left Join Customer on CreditNote.CustomerID = Customer.CustomerID
Left Join Vendors on CreditNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix on VoucherPrefix.TranID = N'CREDIT NOTE'
--CreditNote, VoucherPrefix, Customer, Vendors
where 
--CreditNote.CustomerID *= Customer.CustomerID and
--CreditNote.VendorID *= Vendors.VendorID and
CreditNote.DocumentDate between @FromDate and @ToDate 
--and VoucherPrefix.TranID = N'CREDIT NOTE'
Else
select CreditID, "Credit ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),"Date" = DocumentDate,
"Type"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then dbo.LookupDictionaryItem('Others',Default) Else 
(Case When CreditNote.CustomerID is Null Then dbo.LookupDictionaryItem('Vendor',Default) Else dbo.LookupDictionaryItem('Customer',Default) End) End,  
"Account Name"=Case When (CreditNote.CustomerID is Null and CreditNote.VendorID is Null) Then 
dbo.getaccountname(isnull(Others,0)) Else (Case When CreditNote.CustomerID is Null Then  
Vendors.Vendor_Name Else Customer.Company_Name End) End, "DocRef" = DocRef, "Value" = NoteValue,
"Remarks" = Memo,
"Status" = 
case 
	when IsNull(Status,0) & 64 <> 0 then dbo.LookupDictionaryItem('Cancelled',Default) 
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) = 0  then dbo.LookupDictionaryItem('Amended',Default)    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Open',Default)    
	When isnull(status,0) = 0 and Balance = 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Closed',Default)
	When isnull(status,0) = 0 and Balance > 0 and isnull(RefDocid,0) = 0 then dbo.LookupDictionaryItem('Open',Default)
end
from CreditNote
Left Join Customer on CreditNote.CustomerID = Customer.CustomerID
Left Join Vendors on CreditNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix on VoucherPrefix.TranID = N'CREDIT NOTE'
--CreditNote, VoucherPrefix, Customer, Vendors
where 
--CreditNote.CustomerID *= Customer.CustomerID and
--CreditNote.VendorID *= Vendors.VendorID and
CreditNote.DocumentDate between @FromDate and @ToDate 
--and VoucherPrefix.TranID = N'CREDIT NOTE'
