CREATE procedure sp_acc_prn_cus_CreditNote(@DocumentID int)
as
DECLARE @CUSTOMERID NVARCHAR(50)
DECLARE @VENDORID	NVARCHAR(50)

create table #creditnote
(
	Party			nvarchar(50),
	customerid 		nvarchar(50),
	company_name	nvarchar(256),
	NoteValue		decimal(18,6),
	Document_date	datetime,
	Memo			nvarchar(510),
	Documentid		int,
	DocRef			nvarchar(50),
	Status			nvarchar(510),
	cancel_memo		nvarchar(510),
	Account_Name	nvarchar(500),
	DocSerialType	nVarchar(100),
	DocumentReference	nvarchar(2040),
	BillingAddress_Caption	nVarchar(510),
	ShippingAddress_Caption	nVarchar(510),
	BillingAddress	nVarchar(510),			
	ShippingAddress	nVarchar(510)
)


select @CUSTOMERID = isnull(customerid,N''), @VENDORID = isnull(vendorid,N'')
from creditnote where CreditID = @DocumentID 

if @customerid <> N'' and @vendorid = N''
	begin
		insert into #creditnote
		select 
		dbo.LookupDictionaryItem('Customer           :',Default) , Customer.CustomerID, 
		Customer.Company_Name, NoteValue, 
		DocumentDate, Memo, 
		DocumentID, DocRef,
		case   
			When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)            
			When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
			when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
			Else ''    
		end, 
		Cancel_Memo,'Account' = dbo.getaccountname(isnull(CreditNote.AccountID,0)),
		DocSerialType,DocumentReference,
		dbo.LookupDictionaryItem('Billing Address    :',Default),dbo.LookupDictionaryItem('Shipping Address   :',Default),
		Customer.BillingAddress,Customer.ShippingAddress
		from CreditNote, Customer
		where CreditID = @DocumentID and
		Customer.CustomerID = CreditNote.CustomerID
	end
else if @customerid = N'' and @vendorid <> N''
	begin
		insert into #creditnote
		select dbo.LookupDictionaryItem('Vendor             :',Default) ,Vendors.VendorID, 
		Vendors.Vendor_Name, NoteValue, 
		DocumentDate, Memo, 
		DocumentID, DocRef,
		case   
			When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)            
			When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
			when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
			Else ''    
		end, 
		Cancel_Memo,'Account'= dbo.getaccountname(isnull(CreditNote.AccountID,0)),
		DocSerialType,DocumentReference,
		dbo.LookupDictionaryItem('Address            :',Default),'',
		Vendors.Address,''
		from CreditNote, Vendors
		where CreditID = @DocumentID and
		Vendors.VendorID = CreditNote.VendorID
	end
else
	begin
		insert into #creditnote
		select dbo.LookupDictionaryItem('Others             :',Default) ,AccountsMaster.AccountID, 
		AccountsMaster.AccountName, NoteValue, 
		DocumentDate, Memo, 
		DocumentID, DocRef,
		case   
			When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)            
			When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
			when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
			when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
			Else ''    
		end, 
		Cancel_Memo,'Account' = dbo.getaccountname(isnull(CreditNote.AccountID,0)),
		DocSerialType,DocumentReference,'','','',''
		from CreditNote, AccountsMaster
		where CreditID = @DocumentID and
		AccountsMaster.AccountID = CreditNote.Others
	end


select 
"Credit Note Number" = ltrim(rtrim(dbo.GetVoucherPrefix('CREDIT NOTE'))) + ltrim(rtrim(cast(DocumentID as nvarchar(50)))),
"Credit Note Date" = Document_date,
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
from #creditnote

Drop table #creditnote







