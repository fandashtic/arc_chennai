CREATE Procedure sp_Cancel_Payment (@PaymentID int)
As
Declare @DocID int
Declare @Amount Decimal(18,6)
Declare @DocType int
Declare @Adjustment Decimal(18,6)
Declare @OriginalID nvarchar(50)
Declare @DocumentDate Datetime
Declare @DocumentValue Decimal(18,6)
Declare @CreateNew Int
Declare @Vendor nvarchar(20)
Declare @Value Decimal(18,6)
Declare @Ref nvarchar(255)
Declare @PartyType Int
Declare @GetDate Datetime

Set @PartyType = 1
Select @Vendor = VendorID From Payments Where DocumentID = @PaymentID
Declare GetAdjustedDocs Cursor Static For
Select DocumentID, AdjustedAmount, DocumentType, Adjustment, DocumentDate, 
OriginalID, DocumentValue
From PaymentDetail 
Where PaymentID = @PaymentID
Open GetAdjustedDocs
Fetch From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment, @DocumentDate,
@OriginalID, @DocumentValue
While @@Fetch_Status = 0
Begin
	Set @CreateNew  = 0
	If @DocType = 1
	Begin
		If exists (Select AdjustmentID From AdjustmentReturnAbstract 
		Where AdjustmentID = @DocID)
		Begin
			Update AdjustmentReturnAbstract Set Balance = Balance + @Amount + @Adjustment
			Where AdjustmentID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = 2
	Begin
		If exists (Select DebitID From DebitNote Where DebitID = @DocID)
		Begin
			Update DebitNote Set Balance = Balance + @Amount + @Adjustment
			Where DebitID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = 3
	Begin
		If exists (Select DocumentID From Payments Where DocumentID = @DocID)
		Begin
			Update Payments Set Balance = Balance + @Amount + @Adjustment
			Where DocumentID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 1
		End
	End
	Else If @DocType = 4
	Begin
		If exists (Select BillID From BillAbstract Where BillID = @DocID)
		Begin
			Update BillAbstract Set Balance = Balance + @Amount + @Adjustment
			Where BillID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 2
		End
	End
	Else If @DocType = 5
	Begin
		If exists (Select CreditID From CreditNote Where CreditID = @DocID)
		Begin
			Update CreditNote Set Balance = Balance + @Amount + @Adjustment
			Where CreditID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 2
		End
	End
	Else If @DocType = 6
	Begin
		If exists (Select ClaimID From ClaimsNote Where ClaimID = @DocID)
		Begin
			Update ClaimsNote Set Balance = Balance + @Amount + @Adjustment
			Where ClaimID = @DocID
		End
		Else
		Begin
			Set @CreateNew = 2
		End
	End
	Set @Value = @Amount + @Adjustment
	Set @Ref = @OriginalID + ',' + Cast(@DocumentDate As nvarchar) + ',' + Cast(@DocumentValue As nvarchar)
	Set @GetDate = GetDate()
	If @CreateNew = 1
	Begin
 		exec sp_insert_DebitNote @PartyType, @Vendor, @Value, @GetDate, @Ref, 0, @OriginalID
	End
	Else If @CreateNew = 2
	Begin
 		exec sp_insert_CreditNote @PartyType, @Vendor, @Value, @GetDate, @Ref, @OriginalID
	End
	Fetch Next From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment, 
	@DocumentDate, @OriginalID, @DocumentValue
End
Update Payments Set Status = IsNull(Status, 0) | 192, Balance = 0 
Where DocumentID = @PaymentID
Close GetAdjustedDocs
DeAllocate GetAdjustedDocs
--Revert Used cheque details in cheques table
If Exists(Select Paymentmode From Payments Where DocumentID = @PaymentID and (IsNull(PaymentMode,0) = 1 or (IsNull(PaymentMode,0) = 2 and DDMode = 1)))
	Update Cheques Set UsedCheques = UsedCheques - 1 Where ChequeID = (Select ChequeID From Payments Where DocumentID = @PaymentID)


