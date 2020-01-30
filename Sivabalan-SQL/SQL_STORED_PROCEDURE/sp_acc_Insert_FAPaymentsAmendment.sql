CREATE procedure sp_acc_Insert_FAPaymentsAmendment(@documentdate datetime,@value decimal(18,6),
@balance decimal(18,6),@paymentmode int,@bankid int,@chequenumber int,@chequedate datetime,
@chequeid int,@bankcode nvarchar(50),@branchcode nvarchar(50),@others int,@expenseaccount int,
@denominations nvarchar(4000),@Narration nvarchar(4000),@DocRef nVarchar(100),@DocSerialType nvarchar(100),
@DocumentID Int,@DDMode Int = 0,@DDCharges Decimal(18,6) = 0,@DDChequeNumber Int = 0,
@DDChequeDate DateTime = NULL,@DDDetails nvarchar(128) = N'',@PayableTo nvarchar(255) = N'',@Bank_Txn_code nVarchar(400) = N'')
as
--Get the DocumentID from Previous Payment
Declare @DocID nVarchar(50)
Declare @DocumentType Int
Declare @DocumentDetailID Int
Declare @AdjustedAmount Float
Declare @Adjustment Float
Declare @DocPrefix nvarchar(50)
--Update Previous Payment First
Update Payments Set Balance = 0,
Status = (IsNull(Status,0) | 128) Where DocumentID = @DocumentID
--Update Collection Details
Declare UpdatePaymentDetail Cursor Static For
Select IsNull(DocumentID,0),IsNull(DocumentType,0),IsNull(AdjustedAmount,0),IsNull(Adjustment,0) from PaymentDetail Where PaymentID = @DocumentID
Open UpdatePaymentDetail
Fetch From UpdatePaymentDetail Into @DocumentDetailID,@DocumentType,@AdjustedAmount,@Adjustment
While @@Fetch_Status = 0
Begin
if  @DocumentType = 6
Begin
Update ARVAbstract set Balance = Balance + @AdjustedAmount + @Adjustment
Where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 2
Begin
Update CreditNote set Balance = Balance + @AdjustedAmount + @Adjustment
Where CreditID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 7
Begin
Update Collections set Balance = Balance + @AdjustedAmount + @Adjustment
Where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 5
Begin
Update DebitNote set Balance = Balance + @AdjustedAmount + @Adjustment
Where DebitID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if  @DocumentType = 4
Begin
update APVAbstract set Balance = Balance + @AdjustedAmount + @Adjustment
where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 3
Begin
update Payments set Balance = Balance + @AdjustedAmount + @Adjustment
where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 8 or @DocumentType = 9
Begin
Update ManualJournal Set Balance = Balance + @AdjustedAmount + @Adjustment
Where NewRefID = @DocumentDetailID And (Balance + @AdjustedAmount + @Adjustment) >= 0
End
Else if @DocumentType = 151
Begin
Update ServiceAbstract Set Balance = Balance + @AdjustedAmount + @Adjustment
Where InvoiceID = @DocumentDetailID And (Balance + @AdjustedAmount + @Adjustment) >= 0
End

Fetch Next From UpdatePaymentDetail Into @DocumentDetailID,@DocumentType,@AdjustedAmount,@Adjustment
End
Close UpdatePaymentDetail
DeAllocate UpdatePaymentDetail
--Insert New Row in the Collection Table
Select @DocPrefix = Prefix from VoucherPrefix where TranID = N'FA PAYMENTS'

Select @DocID = IsNull(FullDocID,N'') from Payments Where DocumentID = @DocumentID
If @DocID = N''
Begin
Begin Tran
update DocumentNumbers set DocumentID=DocumentID+1 where DocType=56
Select @DocID=DocumentID - 1 from DocumentNumbers where DocType=56
Commit Tran
SET @DocID = @DocPrefix + @DocID
End

--Revert Used cheque details in cheques table
If Exists(Select Paymentmode From Payments Where DocumentID = @DocumentID and
((PaymentMode = 1 and Cheque_ID <> 0) or (PaymentMode = 2 and DDMode = 1
and Cheque_ID <> 0)))
Begin
Update Cheques Set UsedCheques = UsedCheques - 1 Where ChequeID = (Select Cheque_ID From Payments Where DocumentID =@DocumentID)
End

if @PaymentMode = 1 and @ChequeID <> 0
begin
update Cheques set LastIssued = @ChequeNumber,UsedCheques = Isnull(UsedCheques, 0) + 1
where ChequeID = @chequeid
end
else if @PaymentMode = 2 and @DDMode = 1 and @ChequeID <> 0
begin
update Cheques set LastIssued = @DDChequeNumber,UsedCheques = Isnull(UsedCheques, 0) + 1
where ChequeID = @chequeid
end

insert Payments (DocumentDate,Value,Balance,PaymentMode,BankID,Cheque_Number,Cheque_Date,
Cheque_ID,BankCode,BranchCode,CreationTime,Others,ExpenseAccount,Denominations,
Narration,FullDocID,DDMode,DDCharges,DDChequeNumber,DDChequeDate,DDDetails,
PayableTo,DocRef,DocSerialType,RefDocID,Memo)
values (@documentdate,@value,@balance,@paymentmode,@bankid,@chequenumber,@chequedate,
@chequeid,@bankcode,@branchcode,getdate(),@others,@expenseaccount,@denominations,
@Narration,@DocID,@DDMode,@DDCharges,@DDChequeNumber,@DDChequeDate,@DDDetails,
@PayableTo,@DocRef,@DocSerialType,@DocumentID,@Bank_Txn_code)
Select @@identity,@DocID

