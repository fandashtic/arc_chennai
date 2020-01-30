CREATE procedure sp_acc_prn_cus_DebitNote(@DocumentID int)  
as  
DECLARE @CUSTOMERID NVARCHAR(50)  
DECLARE @VENDORID NVARCHAR(50)  
  
create table #Debitnote  
(  
 Party   nvarchar(50),  
 customerid   nvarchar(50),  
 company_name nvarchar(256),  
 NoteValue  decimal(18,6),  
 Document_date datetime,  
 Memo   nvarchar(510),  
 Documentid  int,  
 DocRef   nvarchar(50),  
 Status   nvarchar(510),  
 cancel_memo  nvarchar(510),  
 Account_Name nvarchar(500),  
 DocSerialType nvarchar(100),  
 DocumentReference nvarchar(1020),
 BillingAddress_Caption	nVarchar(510),
 ShippingAddress_Caption	nVarchar(510),
 BillingAddress	nVarchar(510),			
 ShippingAddress	nVarchar(510),
)  
  
  
select @CUSTOMERID = isnull(customerid,N''), @VENDORID = isnull(vendorid,N'')  
from debitnote where DebitID = @DocumentID   
  
if @customerid <> N'' and @vendorid = N''  
 begin  
  insert into #debitnote  
  select dbo.LookupDictionaryItem('Customer           :',Default), Customer.CustomerID, Customer.Company_Name, NoteValue, DocumentDate, Memo,   
  DocumentID, DocRef,  
  case     
   	When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)      
 	When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
   	Else ''      
  end, Cancel_Memo,  
  'Account'= dbo.getaccountname(isnull(DebitNote.AccountID,0)),  
  DocSerialType,DocumentReference,
  dbo.LookupDictionaryItem('Billing Address    :',Default),dbo.LookupDictionaryItem('Shipping Address   :',Default),
  Customer.BillingAddress,Customer.ShippingAddress
  from DebitNote, Customer   
  where DebitID = @DocumentID and  
  Customer.CustomerID = DebitNote.CustomerID  
 end  
else if @customerid = N'' and @vendorid <> N''  
 begin  
  insert into #debitnote  
  select dbo.LookupDictionaryItem('Vendor             :',Default),Vendors.VendorID, Vendors.Vendor_Name,   
  NoteValue, DocumentDate,   
  Memo, DocumentID,   
  DocRef,  
  case     
   	When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)      
 	When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
  Else ''  
  end, Cancel_Memo,  
  'AccountName'=dbo.getaccountname(isnull(DebitNote.AccountID,0)),  
  DocSerialType,DocumentReference,
  dbo.LookupDictionaryItem('Address            :',Default),'',
  Vendors.Address,''
  from DebitNote, Vendors  
  where DebitID = @DocumentID and  
  Vendors.VendorID = DebitNote.VendorID  
 end  
else  
 begin  
  insert into #debitnote  
  select dbo.LookupDictionaryItem('Others             :',Default),AccountsMaster.AccountID, AccountsMaster.AccountName,   
  NoteValue, DocumentDate, Memo,   
  DocumentID, DocRef,  
  case     
   	When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)      
 	When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
 	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
 	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
   	Else ''      
  end, Cancel_Memo,  
  'Account'= dbo.getaccountname(isnull(DebitNote.AccountID,0)),  
  DocSerialType,DocumentReference,'','','',''
  from DebitNote, AccountsMaster  
  where DebitID = @DocumentID and  
  AccountsMaster.AccountID = DebitNote.Others  
 end  
  
select   
"Debit Note Number" = ltrim(rtrim(dbo.GetVoucherPrefix('DEBIT NOTE'))) + ltrim(rtrim(cast(DocumentID as nvarchar(50)))),  
"Debit Note Date" = Document_date,  
"Party Category" = Party,  
"Value" = NoteValue,  
"Document Reference" = Docref,  
"Remarks" = Memo,  
"Party Name" = company_name,  
"Document Type" = DocSerialType,  
"Document ID" = DocumentReference,
"Billing Address Label" = BillingAddress_Caption,
"Shipping Address Label" = ShippingAddress_Caption,
"Billing Address" = BillingAddress,
"Shipping Address" = ShippingAddress
from #DebitNote  
  
Drop table #Debitnote  
  
  
  
  






