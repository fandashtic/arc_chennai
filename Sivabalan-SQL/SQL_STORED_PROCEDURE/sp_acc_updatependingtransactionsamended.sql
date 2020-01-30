CREATE procedure sp_acc_updatependingtransactionsamended(@mode integer,@value decimal(18,6),@docreference integer)
as
DECLARE @INVOICE integer
DECLARE @BILL integer
DECLARE @COLLECTIONS integer
DECLARE @PAYMENTS integer
DECLARE @PURCHASERETURN integer
DECLARE @SALESRETURN integer
DECLARE @DEBITNOTE integer
DECLARE @CREDITNOTE integer

DECLARE @INWARD_SERVICE integer
DECLARE @OUTWARD_SERVICE integer
DECLARE @DAMAGA_INVOICE integer

DECLARE @APV integer
DECLARE @ARV integer
DECLARE @OTHERPAYMENTS integer
DECLARE @OTHERRECEIPTS integer
DECLARE @OTHERDEBITNOTE integer
DECLARE @OTHERCREDITNOTE integer
DECLARE @MANUALJOURNAL_NEWREFERENCE Int
DECLARE @CLAIMSNOTE Int

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
SET @CLAIMSNOTE = 82

SET @INWARD_SERVICE = 156
SET @OUTWARD_SERVICE = 157
Set @DAMAGA_INVOICE = 158

if @mode = @INVOICE or @mode = @SALESRETURN
begin
update InvoiceAbstract
set [Balance]= [Balance] + @value where [InvoiceID]= @docreference
end
else if @mode = @BILL
begin
update BillAbstract
set [Balance]=([Balance]+ @value) where [BillID]=@docreference
end
else if @mode = @COLLECTIONS
begin
update Collections
set [Balance]=[Balance]+ @value where [DocumentID]=@docreference
end
else if @mode = @PAYMENTS
begin
update Payments
set [Balance]=[Balance]+ @value where [DocumentID]=@docreference
end
else if @mode = @PURCHASERETURN
begin
update AdjustmentReturnabstract
set [Balance]=[Balance] + @value where [AdjustmentID]=@docreference
end
else if @mode = @DEBITNOTE
begin
update DebitNote
set [Balance]=[Balance]+ @value where [DebitID]=@docreference
end
else if @mode = @CREDITNOTE
begin
update CreditNote
set [Balance]=[Balance] + @value where [CreditID]=@docreference
end
else if @mode = @APV
begin
update APVAbstract
set Balance = Balance + @value where DocumentID = @docreference
end
else if @mode = @ARV
begin
update ARVAbstract
set Balance = Balance + @value where DocumentID = @docreference
end
else if @mode = @OTHERPAYMENTS
begin
update Payments
set Balance = Balance + @value where DocumentID = @docreference
end
else if @mode = @OTHERRECEIPTS
begin
update Collections
set Balance = Balance + @value where DocumentID = @docreference
end
else if @mode = @OTHERDEBITNOTE
begin
update DebitNote
set [Balance]=[Balance]+ @value where [DebitID]=@docreference
end
else if @mode = @OTHERCREDITNOTE
begin
update CreditNote
set [Balance]=[Balance] + @value where [CreditID]=@docreference
end
else if @mode = @MANUALJOURNAL_NEWREFERENCE
begin
update ManualJournal
set [Balance]=[Balance] + @value where [NewRefID]= @docreference
end
else if @mode = @CLAIMSNOTE
begin
update ClaimsNote
set [Balance]=[Balance] + @value where [ClaimID]= @docreference
end

-- Service Invoice - Inward (Receivables)
Else if @mode = @INWARD_SERVICE
Begin
Update ServiceAbstract Set Balance = [Balance] + @value	Where InvoiceID = @docreference
End
-- Service Invoice - Ouward (Payable)
Else if @mode = @OUTWARD_SERVICE
Begin
Update ServiceAbstract Set Balance = [Balance] + @value	Where InvoiceID = @docreference
End
Else If @mode = @DAMAGA_INVOICE
Begin
Update DandDInvAbstract  Set Balance = [Balance] + @value	Where DandDInvID  = @docreference
End

