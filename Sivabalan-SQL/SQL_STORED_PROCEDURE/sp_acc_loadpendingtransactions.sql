Create procedure sp_acc_loadpendingtransactions(@accountid nvarchar(15),@TransactionID Int = 0,
@Mode Int=0)
as
DECLARE @invoiceprefix nvarchar(10)
DECLARE @billprefix nvarchar(10)
DECLARE @BILL integer
DECLARE @INVOICE integer
DECLARE @transactionmode integer
DECLARE @vendorid nvarchar(15),@vendorcount integer,@customercount integer
DECLARE @customerid nvarchar(15)
DECLARE @debitnoteprefix nvarchar(10)
DECLARE @creditnoteprefix nvarchar(10)
DECLARE @GVprefix nvarchar(10)
DECLARE @purchasereturnprefix nvarchar(10)
DECLARE @totaldebit decimal(18,6)
DECLARE @totalcredit decimal(18,6)
DECLARE @debitcount integer
DECLARE @creditcount integer
DECLARE @apvprefix nvarchar(10)
DECLARE @arvprefix nvarchar(10)
DECLARE @otherpaymentprefix nvarchar(10)
DECLARE @otherreceiptprefix nvarchar(10)
DECLARE @manualjournalprefix nvarchar(10)
DECLARE @claimsprefix nvarchar(10)

DECLARE @COLLECTIONS integer
DECLARE @DEBITNOTE integer
DECLARE @CREDITNOTE integer
DECLARE @SALESRETURN integer
DECLARE @PURCHASERETURN integer
DECLARE @PAYMENTS integer

DECLARE @APV integer
DECLARE @ARV integer
DECLARE @OTHERPAYMENTS integer
DECLARE @OTHERRECEIPTS integer
DECLARE @OTHERDEBITNOTE integer
DECLARE @OTHERCREDITNOTE integer
DECLARE @MANUALJOURNAL_NEWREFERENCE integer
DECLARE @CLAIMS Integer
Declare @SERVICEINWARD Integer
Declare @SERVICEOUTWARD Integer
Declare @DAMAGE_INVOICE Integer

DECLARE @COLLECTIONDESC nvarchar(30)
DECLARE @INVOICEDESC nvarchar(30)
DECLARE @DEBITNOTEDESC nvarchar(30)
DECLARE @CREDITNOTEDESC nvarchar(30)
DECLARE @SALESRETURNDESC nvarchar(30)
DECLARE @BILLDESC nvarchar(30)
DECLARE @PURCHASERETURNDESC nvarchar(30)
DECLARE @PAYMENTSDESC nvarchar(30)

DECLARE @APVDESC nvarchar(30)
DECLARE @ARVDESC nvarchar(30)
DECLARE @OTHERPAYMENTSDESC nvarchar(30)
DECLARE @OTHERRECEIPTSDESC nvarchar(30)
DECLARE @MANUALJOURNAL_NEWREFDESC nvarchar(30)
DECLARE @CLAIMSDESC nvarchar(30)
Declare @SERVICEINWARDDESC nvarchar(30)
Declare @SERVICEOUTWARDDESC nvarchar(30)
Declare @DAMAGE_INVOICEDESC   nvarchar(30)

SET @COLLECTIONS =32
SET @INVOICE =28
SET @DEBITNOTE =34
SET @CREDITNOTE =35
SET @SALESRETURN =29
SET @BILL =30
SET @PURCHASERETURN =31
SET @PAYMENTS=33

Set @APV = 60
Set @ARV  = 61
Set @OTHERPAYMENTS = 62
Set @OTHERRECEIPTS = 63
Set @OTHERDEBITNOTE = 79
Set @OTHERCREDITNOTE = 80
Set @MANUALJOURNAL_NEWREFERENCE = 81
Set @CLAIMS = 82
Set @SERVICEINWARD = 156
Set @SERVICEOUTWARD = 157
Set @DAMAGE_INVOICE = 158

SET @COLLECTIONDESC = dbo.LookupDictionaryItem('Collections',Default)
SET @INVOICEDESC = dbo.LookupDictionaryItem('Invoice',Default)
SET @DEBITNOTEDESC = dbo.LookupDictionaryItem('Debit Note',Default)
SET @CREDITNOTEDESC = dbo.LookupDictionaryItem('Credit Note',Default)
SET @SALESRETURNDESC = dbo.LookupDictionaryItem('Sales Return',Default)
SET @BILLDESC = dbo.LookupDictionaryItem('Bill',Default)
SET @PURCHASERETURNDESC = dbo.LookupDictionaryItem('Purchase Return',Default)
SET @PAYMENTSDESC = dbo.LookupDictionaryItem('Payments',Default)

SET @APVDESC =dbo.LookupDictionaryItem('APV',Default)
SET @ARVDESC =dbo.LookupDictionaryItem('ARV',Default)
SET @OTHERPAYMENTSDESC = dbo.LookupDictionaryItem('Other Payments',Default)
SET @OTHERRECEIPTSDESC =dbo.LookupDictionaryItem('Other Receipts',Default)
Set @MANUALJOURNAL_NEWREFDESC = dbo.LookupDictionaryItem('Manual Journal New Reference',Default)
Set @CLAIMSDESC = dbo.LookupDictionaryItem('Claims Note',Default)
Set @SERVICEINWARDDESC = dbo.LookupDictionaryItem('Service Inward',Default)
Set @SERVICEOUTWARDDESC = dbo.LookupDictionaryItem('Service Outward',Default)
Set @DAMAGE_INVOICEDESC =  dbo.LookupDictionaryItem('Damage Invoice',Default)

create table #pendingtransactions(DocumentID nvarchar(255),[Document Date] datetime,
[Description] nvarchar(30),Debit decimal(18,6),Credit decimal(18,6),
ActualID integer,DocType integer,NewReference nvarchar(50),Remarks nvarchar(255))

select @billprefix = [Prefix] from [VoucherPrefix] where [TranID]=N'BILL'
select @invoiceprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'INVOICE'
select @debitnoteprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'DEBIT NOTE'
select @creditnoteprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'CREDIT NOTE'
select @GVprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'GIFT VOUCHER'
select @purchasereturnprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'STOCK ADJUSTMENT PURCHASE RETURN'

select @apvprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'ACCOUNTS PAYABLE VOUCHER'
select @arvprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'ACCOUNTS RECEIVABLE VOUCHER'
select @otherpaymentprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'FA PAYMENTS'
select @otherreceiptprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'FA COLLECTIONS'
select @manualjournalprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'MANUAL JOURNAL'
select @claimsprefix =[Prefix] from [VoucherPrefix] where [TranID]=N'CLAIMS NOTE'

select @vendorcount = count(vendorid),@vendorid = max(VendorID) from vendors where [AccountID]=@accountid
select @customercount =count(customerid),@customerid=max(CustomerID) from customer where [AccountID]=@accountid

set dateformat dmy

if @vendorcount =1
begin
insert into #pendingtransactions
select @billprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(BillDate),
@BILLDESC,0,Balance,BillID,@BILL,'','' from BillAbstract
where VendorID = @vendorid and isnull(Balance,0)>0
and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select "DocumentID" =
Case IsNULL(GSTFullDocID,'')
When '' then @purchasereturnprefix + cast(DocumentID as nvarchar)
Else
IsNULL(GSTFullDocID,'')
End,
dbo.stripdatefromtime(AdjustmentDate),
@PURCHASERETURNDESC,Balance,0,AdjustmentID,@PURCHASERETURN,'',''
from AdjustmentReturnabstract where VendorID = @vendorid
and isnull(Balance,0) > 0 and (isnull(Status,0) & 128) = 0
and (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@PAYMENTSDESC,Balance,0,
DocumentID,@PAYMENTS,'','' from Payments where VendorID =@vendorid
and isnull(balance,0) > 0 and (isnull(Status,0) & 128) = 0
and (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select @debitnoteprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(DocumentDate),
@DEBITNOTEDESC,Balance,0,DebitID,@DEBITNOTE,'','' from DebitNote
where VendorID =@vendorid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select @creditnoteprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(DocumentDate),
@CREDITNOTEDESC,0,Balance,CreditID,@CREDITNOTE,'','' from CreditNote
where VendorID =@vendorid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0
-- and IsNull(Flag,0) = 0

insert into #pendingtransactions
select @claimsprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(ClaimDate),
@CLAIMSDESC,Balance,0,ClaimID,@CLAIMS,'',''
from ClaimsNote where VendorID = @vendorid
and isnull(Balance,0)>0 and (isnull(Status,0) & 64)= 0

--Service Invoice - Inward (Receivables)
Insert Into #pendingtransactions
Select DocumentID, ServiceInvoiceDate,@SERVICEINWARDDESC,0, Balance,InvoiceID, @SERVICEINWARD, DocumentRef, ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Inward'
and ((ServiceFor = 1 and Code = @vendorid) OR (ServiceFor = 2 and Code = @vendorid))

--Service Invoice - Ouward (Payable)
Insert Into #pendingtransactions
Select DocumentID, ServiceInvoiceDate,@SERVICEOUTWARDDESC,Balance, 0,InvoiceID, @SERVICEOUTWARD, DocumentRef, ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Outward'
and ((ServiceFor = 1 and Code = @vendorid) OR (ServiceFor = 2 and Code = @vendorid))

end

if @customercount =1
begin
insert into #pendingtransactions
select "DocumentID" =
Case IsNULL(GSTFlag ,0)
When 0 then @invoiceprefix + cast(DocumentID as nvarchar)
Else
IsNULL(GSTFullDocID,'')
End,
dbo.stripdatefromtime(InvoiceDate),
@INVOICEDESC,Balance,0,InvoiceID,@INVOICE,'','' from InvoiceAbstract
where customerid =@customerid and isnull(Balance,0)>0
and (isnull(Status,0) & 128) = 0 AND (isnull(Status,0) & 64)= 0 and
InvoiceType not in (4 ,5)

insert into #pendingtransactions
select "DocumentID" =
Case IsNULL(GSTFlag ,0)
When 0 then @invoiceprefix + cast(DocumentID as nvarchar)
Else
IsNULL(GSTFullDocID,'')
End,
dbo.stripdatefromtime(InvoiceDate),
@SALESRETURNDESC,0,Balance,InvoiceID,@SALESRETURN,'','' from InvoiceAbstract
where customerid =@customerid and isnull(Balance,0)>0 and (isnull(Status,0) & 128) = 0
AND (isnull(Status,0) & 64)= 0 and InvoiceType in (4 ,5)

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@COLLECTIONDESC,0,Balance,
DocumentID,@COLLECTIONS,'','' from collections where customerid =@customerid
and isnull(balance,0) > 0 and (isnull(Status,0) & 128) = 0
and (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select @debitnoteprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(DocumentDate),
@DEBITNOTEDESC,Balance,0,DebitID,@DEBITNOTE,'','' from DebitNote
where customerid =@customerid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0

insert into #pendingtransactions
select @creditnoteprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(DocumentDate),
@CREDITNOTEDESC,0,Balance,CreditID,@CREDITNOTE,'','' from CreditNote
where customerid =@customerid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0
and IsNull(Flag,0) In (0,1) and Creditid not in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)
union
select @GVprefix + cast(DocumentID as nvarchar),dbo.stripdatefromtime(DocumentDate),
@CREDITNOTEDESC,0,Balance,CreditID,@CREDITNOTE,'','' from CreditNote
where customerid =@customerid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0
and IsNull(Flag,0) =1
and Creditid in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)

--Service Invoice - Inward (Receivables)
Insert Into #pendingtransactions
Select DocumentID, ServiceInvoiceDate,@SERVICEINWARDDESC,0, Balance,InvoiceID, @SERVICEINWARD, DocumentRef, ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Inward'
and ((ServiceFor = 1 and Code = @customerid) OR (ServiceFor = 2 and Code = @customerid))

--Service Invoice - Ouward (Payable)
Insert Into #pendingtransactions
Select DocumentID, ServiceInvoiceDate,@SERVICEOUTWARDDESC,Balance, 0,InvoiceID, @SERVICEOUTWARD, DocumentRef, ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Outward'
and ((ServiceFor = 1 and Code = @customerid) OR (ServiceFor = 2 and Code = @customerid))

-- Damage Invoice
Insert Into #pendingtransactions
Select GSTDocId, DandDInvDate ,@DAMAGE_INVOICEDESC ,Balance,0, DandDInvID , @DAMAGE_INVOICE,DDIA.GSTFullDocID , DDIA.Description
From DandDInvAbstract DDIA Where Balance > 0 And DDIA.CustomerID =  @customerid

end

insert into #pendingtransactions
select @apvprefix + cast(APVID as nvarchar),dbo.stripdatefromtime(APVDate),@APVDESC,0,
isnull(Balance,0),DocumentID,@APV,'','' from APVAbstract
where PartyAccountID = @accountid and isnull(Balance,0)>0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 192

insert into #pendingtransactions
select @arvprefix + cast(ARVID as nvarchar),dbo.stripdatefromtime(ARVDate),@ARVDESC,
isnull(Balance,0),0,DocumentID,@ARV,'','' from ARVAbstract
where PartyAccountID =@accountid and isnull(Balance,0)>0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERPAYMENTSDESC,
isnull(Balance,0),0,DocumentID,@OTHERPAYMENTS,'','' from Payments
where isnull(Others,0) =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(Others,0)<> 0 and isnull(ExpenseAccount,0)=0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERPAYMENTSDESC,
isnull(Balance,0),0,DocumentID,@OTHERPAYMENTS,'','' from Payments
where isnull(ExpenseAccount,0) =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)=0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERPAYMENTSDESC,
isnull(Balance,0),0,DocumentID,@OTHERPAYMENTS,'','' from Payments
where isnull(Others,0) =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)<>0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERRECEIPTSDESC,0,
isnull(Balance,0),DocumentID,@OTHERRECEIPTS,'','' from collections
where Others =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(Others,0)<> 0 and isnull(ExpenseAccount,0)=0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERRECEIPTSDESC,0,
isnull(Balance,0),DocumentID,@OTHERRECEIPTS,'','' from collections
where ExpenseAccount =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)=0

insert into #pendingtransactions
select FullDocID,dbo.stripdatefromtime(DocumentDate),@OTHERRECEIPTSDESC,0,
isnull(Balance,0),DocumentID,@OTHERRECEIPTS,'','' from collections
where Others =@accountid and isnull(balance,0) > 0
and (IsNull(Status,0) & 128) = 0 And (IsNull(Status,0) & 64) = 0
and isnull(Others,0)<> 0 and isnull(ExpenseAccount,0)<>0

insert into #pendingtransactions
select @debitnoteprefix + cast(DocumentID as nvarchar),
dbo.stripdatefromtime(DocumentDate),@DEBITNOTEDESC,
Balance,0,DebitID,@OTHERDEBITNOTE,'','' from DebitNote
where IsNull(Others,0) = @accountid
and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0

-- and IsNull(CustomerID,0)=0
-- and IsNull(VendorID,0)=0

insert into #pendingtransactions
select @creditnoteprefix + cast(DocumentID as nvarchar),
dbo.stripdatefromtime(DocumentDate),@CREDITNOTEDESC,
0,Balance,CreditID,@OTHERCREDITNOTE,'','' from CreditNote
where IsNull(Others,0) = @accountid and isnull(balance,0) > 0
and (isnull(Status,0) & 64)= 0  and IsNull(Flag,0) In (0,1)
-- and IsNull(CustomerID,0)=0 and IsNull(VendorID,0)=0

If @Mode = 0
Begin
insert into #pendingtransactions
select @manualjournalprefix + cast(DocumentID as nvarchar),
dbo.stripdatefromtime(DocumentDate),@MANUALJOURNAL_NEWREFDESC,
case when PrefixType = 1 then IsNull(Balance,0) else
0 end ,case when PrefixType = 2 then IsNull(Balance,0) else
0 end,NewRefID,@MANUALJOURNAL_NEWREFERENCE,ReferenceNo,Remarks
from ManualJournal where AccountID = @accountid and isnull(Balance,0) > 0
and isnull(Status,0)<> 192 and isnull(Status,0)<> 128
End
Else If @Mode =1
Begin
insert into #pendingtransactions
select @manualjournalprefix + cast(DocumentID as nvarchar),
dbo.stripdatefromtime(DocumentDate),@MANUALJOURNAL_NEWREFDESC,
case when PrefixType = 1 then IsNull(Balance,0) else
0 end ,case when PrefixType = 2 then IsNull(Balance,0) else
0 end,NewRefID,@MANUALJOURNAL_NEWREFERENCE,ReferenceNo,Remarks
from ManualJournal where AccountID = @accountid
and (isnull(Balance,0) > 0) and (TransactionID <> @TransactionID)
and (isnull(Status,0)<> 192 and isnull(Status,0)<> 128)
End

select @debitcount =count(debit),@creditcount =count(credit), @totaldebit =sum(isnull(debit,0)),
@totalcredit = sum(isnull(credit,0)) from #pendingtransactions

if @debitcount > 0 or @creditcount >0
begin
insert into #pendingtransactions
select '',null,dbo.LookupDictionaryItem('Net Total',Default),case when (@totaldebit - @totalcredit) > 0 then (@totaldebit - @totalcredit) else 0 end,case when (@totaldebit - @totalcredit) < 0 then  abs(@totaldebit - @totalcredit) else 0 end,0,0,'',''

end
select * from #pendingtransactions
drop table #pendingtransactions
