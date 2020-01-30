CREATE Procedure [dbo].[sp_acc_list_DebitNote](@FromDate datetime,
				    @ToDate datetime)
as
If Not Exists (Select * from ReportData Where Parent = 138)/*(Parent)138 = DebitNote Report*/
Select DebitID, "Note Number" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),"Date" = DocumentDate,
"Type"=Case When (DebitNote.CustomerID is Null and DebitNote.VendorID is Null) Then dbo.LookupDictionaryItem('Others',Default) Else 
(Case When DebitNote.CustomerID is Null Then dbo.LookupDictionaryItem('Vendor',Default) Else dbo.LookupDictionaryItem('Customer',Default) End) End,  
"Account Name"=Case When (DebitNote.CustomerID is Null and DebitNote.VendorID is Null) Then 
dbo.getaccountname(isnull(Others,0)) Else (Case When DebitNote.CustomerID is Null Then  
Vendors.Vendor_Name Else Customer.Company_Name End) End, "Doc Reference" = DocRef, "Note Value" = NoteValue, 
"Expense"=dbo.getaccountname(isnull(DebitNote.AccountID,0)),
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
from DebitNote
Left Join Customer on DebitNote.CustomerID = Customer.CustomerID
Left Join Vendors on DebitNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix on VoucherPrefix.TranID = N'DEBIT NOTE'
--DebitNote, VoucherPrefix, Customer, Vendors
where 
--DebitNote.CustomerID *= Customer.CustomerID and
--DebitNote.VendorID *= Vendors.VendorID and
DebitNote.DocumentDate between @FromDate and @ToDate 
--and VoucherPrefix.TranID = N'DEBIT NOTE'
Else
Select DebitID, "Note Number" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),"Date" = DocumentDate,
"Type"=Case When (DebitNote.CustomerID is Null and DebitNote.VendorID is Null) Then dbo.LookupDictionaryItem('Others',Default) Else 
(Case When DebitNote.CustomerID is Null Then dbo.LookupDictionaryItem('Vendor',Default) Else dbo.LookupDictionaryItem('Customer',Default) End) End,  
"Account Name"=Case When (DebitNote.CustomerID is Null and DebitNote.VendorID is Null) Then 
dbo.getaccountname(isnull(Others,0)) Else (Case When DebitNote.CustomerID is Null Then  
Vendors.Vendor_Name Else Customer.Company_Name End) End, "Doc Reference" = DocRef, "Note Value" = NoteValue, 
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
from 
DebitNote
Left Join Customer on DebitNote.CustomerID = Customer.CustomerID
Left Join Vendors on DebitNote.VendorID = Vendors.VendorID
Inner Join VoucherPrefix on VoucherPrefix.TranID = N'DEBIT NOTE'
--DebitNote, VoucherPrefix, Customer, Vendors
where 
--DebitNote.CustomerID *= Customer.CustomerID and
--DebitNote.VendorID *= Vendors.VendorID and
DebitNote.DocumentDate between @FromDate and @ToDate 
--and VoucherPrefix.TranID = N'DEBIT NOTE'
