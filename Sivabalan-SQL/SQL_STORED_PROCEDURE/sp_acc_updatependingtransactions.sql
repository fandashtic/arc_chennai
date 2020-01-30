CREATE procedure sp_acc_updatependingtransactions(@mode integer,@value decimal(18,6),@docreference integer)
as
DECLARE @INVOICE integer
DECLARE @BILL integer
DECLARE @COLLECTIONS integer
DECLARE @PAYMENTS integer
DECLARE @PURCHASERETURN integer
DECLARE @SALESRETURN integer
DECLARE @DEBITNOTE integer
DECLARE @CREDITNOTE integer

DECLARE @APV integer
DECLARE @ARV integer
DECLARE @OTHERPAYMENTS integer
DECLARE @OTHERRECEIPTS integer
DECLARE @OTHERDEBITNOTE integer
DECLARE @OTHERCREDITNOTE integer
DECLARE @MANUALJOURNAL_NEWREFERENCE integer
DECLARE @CLAIMS integer

DECLARE @INWARD_SERVICE integer
DECLARE @OUTWARD_SERVICE integer
DECLARE @DAMAGE_INVOICE integer

SET @INVOICE =28
SET @BILL =30
SET @COLLECTIONS =32
SET @PAYMENTS=33
SET @PURCHASERETURN =31
SET @SALESRETURN =29
SET @DEBITNOTE =34
SET @CREDITNOTE =35

SET @APV = 60
SET @ARV = 61
SET @OTHERPAYMENTS = 62
SET @OTHERRECEIPTS = 63
SET @OTHERDEBITNOTE = 79
SET @OTHERCREDITNOTE = 80
SET @MANUALJOURNAL_NEWREFERENCE = 81
SET @CLAIMS = 82
SET @INWARD_SERVICE = 156
SET @OUTWARD_SERVICE = 157
SET @DAMAGE_INVOICE = 158

DECLARE @invoiceprefix nvarchar(10)
DECLARE @billprefix nvarchar(10)
DECLARE @debitnoteprefix nvarchar(10)
DECLARE @creditnoteprefix nvarchar(10)
DECLARE @GVprefix nvarchar(10)
DECLARE @purchasereturnprefix nvarchar(10)
DECLARE @apvprefix nvarchar(10)
DECLARE @arvprefix nvarchar(10)
DECLARE @otherpaymentprefix nvarchar(10)
DECLARE @otherreceiptprefix nvarchar(10)
DECLARE @manualjournalprefix nvarchar(10)
DECLARE @claimsprefix nvarchar(10)
Declare @GRDoc nvarchar(255)

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

Declare @CollectionPrefix nVarchar(100)
Declare @PaymentPrefix nVarchar(100)
--Declare @PurchaseReturnPrefix nVarchar(100)
DECLARE @MANUALJOURNAL_NEWREFDESC nvarchar(30)
DECLARE @OTHERPAYMENTSDESC nvarchar(30)
DECLARE @OTHERRECEIPTSDESC nvarchar(30)
DECLARE @DAndDPrefix nvarchar(30)

select @CollectionPrefix =[Prefix] from [VoucherPrefix] where [TranID]=N'COLLECTIONS'
select @PaymentPrefix =[Prefix] from [VoucherPrefix] where [TranID]=N'PAYMENTS'
select @PurchaseReturnPrefix =[Prefix] from [VoucherPrefix] where [TranID]=N'PURCHASE RETURN'

Set @MANUALJOURNAL_NEWREFDESC = dbo.LookupDictionaryItem('Manual Journal New Reference',Default)
SET @OTHERPAYMENTSDESC = dbo.LookupDictionaryItem('Other Payments',Default)
SET @OTHERRECEIPTSDESC =dbo.LookupDictionaryItem('Other Receipts',Default)
select @DAndDPrefix =[Prefix] from [VoucherPrefix] where [TranID]=N'DAMAGE INVOICE'


Declare @BalanceAdjustement As Decimal(18,6)
Declare @BalanceAmt As Decimal(18,6)

Set @BalanceAdjustement = 0
Set @BalanceAmt = 0

If @mode = @INVOICE or @mode = @SALESRETURN
Begin
Select @BalanceAmt = [Balance] from InvoiceAbstract where [InvoiceID]= @docreference
Select @BalanceAdjustement = [Balance] - @value  , @GRDoc = GSTFullDocID from InvoiceAbstract where [InvoiceID]= @docreference

If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Invoice No : '+ Cast(cast(@invoiceprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) As nVarchar(100))
End
Else
Begin
Update InvoiceAbstract set [Balance]= [Balance] - @value where [InvoiceID]= @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Invoice with No :' + cast(@invoiceprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End

End
Else If @mode = @BILL
Begin
Select @BalanceAdjustement = [Balance] - @value  from BillAbstract where [BillID]=@docreference
Select @BalanceAmt = [Balance], @GRDoc = DocumentID from BillAbstract where [BillID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for CreditNote No : '+ cast(@billprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update BillAbstract set [Balance]=([Balance]- @value) where [BillID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Bill with No :' + cast(@billprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @COLLECTIONS
Begin
Select @BalanceAdjustement = [Balance] - @value  from Collections where [DocumentID]=@docreference
Select @BalanceAmt = [Balance] ,@GRDoc = FullDocID from Collections where [DocumentID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Collection No : '+ cast(@CollectionPrefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update Collections set [Balance]=[Balance]- @value where [DocumentID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Collection with No :' + cast(@CollectionPrefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @PAYMENTS
Begin
Select @BalanceAdjustement = [Balance] - @value from Payments where [DocumentID]=@docreference
Select @BalanceAmt = [Balance] ,@GRDoc = FullDocID from Payments where [DocumentID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Payment No : '+ cast(@billprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update Payments set [Balance]=[Balance]- @value where [DocumentID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Payment with No :' + cast(@PaymentPrefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @PURCHASERETURN
Begin
Select @BalanceAdjustement = [Balance] - @value from AdjustmentReturnabstract where [AdjustmentID]=@docreference
Select @BalanceAmt = [Balance],
@GRDoc = Case IsNULL(GSTFullDocID,'') When '' then @purchasereturnprefix + cast(DocumentID as nvarchar)
Else
IsNULL(GSTFullDocID,'')
End
from AdjustmentReturnabstract where [AdjustmentID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Purchase Return No : '+ cast(@purchasereturnprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update Payments set [Balance]=[Balance]- @value where [DocumentID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Purchase Return with No :' + cast(@purchasereturnprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @DEBITNOTE
Begin
Select @BalanceAdjustement = [Balance] - @value from DebitNote where [DebitID]=@docreference
Select @BalanceAmt = [Balance] ,@GRDoc = DocumentID from DebitNote where [DebitID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for DebitNote No : '+ cast(@debitnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update DebitNote set [Balance]=[Balance]-@value where [DebitID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'DebitNote with No :' + cast(@debitnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @CREDITNOTE
Begin
Select @BalanceAdjustement = [Balance] - @value from CreditNote where [CreditID]=@docreference
Select @BalanceAmt = [Balance] , @GRDoc = DocumentID  from CreditNote where [CreditID]=@docreference

If Exists (Select 'x' from clocrnote where isnull(creditID,0) = @docreference  and isnull(isgenerated,0)=1)
Begin
Set @creditnoteprefix = @GVprefix
End
Else
Begin
Set @creditnoteprefix = @creditnoteprefix
End


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for CreditNote No : '+ cast(@creditnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update CreditNote set [Balance]=[Balance]-@value where [CreditID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'CreditNote with No :' + cast(@creditnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @APV
Begin
Select @BalanceAdjustement = [Balance] - @value from APVAbstract where DocumentID = @docreference
Select @BalanceAmt = [Balance] , @GRDoc = APVID from APVAbstract where DocumentID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for APV No : '+ cast(@apvprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update APVAbstract set Balance = Balance - @value where DocumentID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'APV with No :' + cast(@apvprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
--Suresh
Else If @mode = @ARV
Begin
Select @BalanceAdjustement = [Balance] - @value from ARVAbstract where DocumentID = @docreference
Select @BalanceAmt = [Balance] ,  @GRDoc = ARVID from ARVAbstract where DocumentID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for ARV No : '+ cast(@apvprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update ARVAbstract set Balance = Balance - @value where DocumentID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'ARV with No :' + cast(@apvprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @OTHERPAYMENTS
Begin
Select @BalanceAdjustement = [Balance] - @value from Payments where DocumentID = @docreference
Select @BalanceAmt = [Balance] , @GRDoc = FullDocID from Payments where DocumentID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other Payment No : '+ cast(@OTHERPAYMENTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update Payments set Balance = Balance - @value where DocumentID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other Payment with No :' + cast(@OTHERPAYMENTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @OTHERRECEIPTS
Begin
Select @BalanceAdjustement = [Balance] - @value from Collections where DocumentID = @docreference
Select @BalanceAmt = [Balance] ,@GRDoc = FullDocID from Collections where DocumentID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other Receipt No : '+ cast(@OTHERRECEIPTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update Collections set Balance = Balance - @value where DocumentID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other Receipt with No :' + cast(@OTHERRECEIPTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @OTHERDEBITNOTE
Begin
Select @BalanceAdjustement = [Balance] - @value from DebitNote where [DebitID]=@docreference
Select @BalanceAmt = [Balance] , @GRDoc = DocumentID from DebitNote where [DebitID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other DebitNote No : '+ cast(@debitnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update DebitNote set [Balance]=[Balance]-@value where [DebitID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other DebitNote with No :' + cast(@debitnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @OTHERCREDITNOTE
Begin
Select @BalanceAdjustement = [Balance] - @value from CreditNote where [CreditID]=@docreference
Select @BalanceAmt = [Balance] , @GRDoc = DocumentID from CreditNote where [CreditID]=@docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other CreditNote No : '+ cast(@creditnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update CreditNote set [Balance]=[Balance]-@value where [CreditID]=@docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other CreditNote with No :' + cast(@creditnoteprefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @MANUALJOURNAL_NEWREFERENCE
Begin
Select @BalanceAdjustement = [Balance] - @value from ManualJournal where [NewRefID]= @docreference
Select @BalanceAmt = [Balance],@GRDoc = DocumentID from ManualJournal where [NewRefID]= @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other ManualJournal No : '+ cast(@MANUALJOURNAL_NEWREFDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update ManualJournal Set [Balance]= [Balance] - @value where [NewRefID]= @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other ManualJournal with No :' + cast(@MANUALJOURNAL_NEWREFDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
Else If @mode = @CLAIMS
Begin
Select @BalanceAdjustement = [Balance] - @value from ClaimsNote where [ClaimID]= @docreference
Select @BalanceAmt = [Balance] ,@GRDoc = DocumentID from ClaimsNote where [ClaimID]= @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Other Claims No : '+ cast(@OTHERRECEIPTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update ClaimsNote Set [Balance]= [Balance] - @value where [ClaimID]= @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Other Claims with No :' + cast(@OTHERRECEIPTSDESC + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
-- Service Invoice - Inward (Receivables)
Else if @mode = @INWARD_SERVICE
Begin
--Update ServiceAbstract Set Balance = [Balance] - @value	Where InvoiceID = @docreference

Select @BalanceAdjustement = [Balance] - @value from ServiceAbstract Where InvoiceID = @docreference
Select @BalanceAmt = [Balance] , @GRDoc = DocumentId from ServiceAbstract Where InvoiceID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Service Inward Invoice No : ' + @GRDoc
End
Else
Begin
Update ServiceAbstract Set Balance = [Balance] - @value	Where InvoiceID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Service Inward Invoice with No :' + @GRDoc + '  has been already adjusted.'
End
End
-- Service Invoice - Ouward (Payable)
Else if @mode = @OUTWARD_SERVICE
Begin
--Update ServiceAbstract Set Balance = [Balance] - @value	Where InvoiceID = @docreference

Select @BalanceAdjustement = [Balance] - @value from ServiceAbstract Where InvoiceID = @docreference
Select @BalanceAmt = [Balance] , @GRDoc = DocumentId from ServiceAbstract Where InvoiceID = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Service Outward Invoice No : ' + @GRDoc
End
Else
Begin
Update ServiceAbstract Set Balance = [Balance] - @value	Where InvoiceID = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Service Outward Invoice with No :' + @GRDoc + '  has been already adjusted.'
End
End
Else If @mode = @DAMAGE_INVOICE
Begin
Select @BalanceAdjustement = [Balance] - @value from DandDInvAbstract where DandDInvID  = @docreference
Select @BalanceAmt = [Balance] , @GRDoc = GSTDocId from DandDInvAbstract where DandDInvID  = @docreference


If Isnull(@BalanceAmt,0) > 0
Begin
If Isnull(@BalanceAmt,0) < Isnull(@value,0)
Begin
Select 2,'Adjusted Amt :' + Cast(@value As nVarchar(25)) + '  is greather than available Amt : '+ Cast(@BalanceAmt As nVarchar(25)) + '  for Damage Invoice No : '+ cast(@DAndDPrefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100))
End
Else
Begin
Update DandDInvAbstract Set Balance = [Balance] - @value	Where DandDInvID  = @docreference
Select 0,0
End
End
Else
Begin
Select 1,'Damage Invoice with No :' + cast(@DAndDPrefix + CAST(@GRDoc as nVarchar(50)) As nVarchar(100)) + '  has been already adjusted.'
End
End
