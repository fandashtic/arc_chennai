CREATE procedure sp_acc_Insert_DebitNote_ClaimSettlement(@PartyType int,
					@PartyID nvarchar(15),@Value float,@DocDate datetime,
					@Remarks nvarchar(255),@ClaimID Integer,@Flag int = 0,
					@DocRef nVarchar(50) = N'')			
As
DECLARE @DocumentID Int
DECLARE @SalesmanID Int

DECLARE @nClaimType Int
DECLARE @SecondarySchemeExpense Int
DECLARE @DiscountAccount Int
DECLARE @ClaimsReceivable Int
DECLARE @ExpenseAccountID Int
DECLARE @AdjReasonID Int

Set @SecondarySchemeExpense = 39		/*constant to store secondary scheme expenses Account*/ 
Set @ClaimsReceivable = 10 	/*constant to store claimsreceivable Account*/ 

Select @nClaimType = [ClaimType] from ClaimsNote where [ClaimID] = @ClaimID
If @nClaimType = 4 -- Secondary Scheme
	Begin
		Set @ExpenseAccountID = @SecondarySchemeExpense
	End
Else If @nClaimType=5 -- Adjustment Reason
	Begin
		Select Top 1 @AdjReasonID = AdjReasonID from ClaimsDetail Where ClaimID = @ClaimID
		Select @ExpenseAccountID = AccountID From AdjustmentReason Where AdjReasonID = @AdjReasonID
	End
Else
	Begin		
		Set @ExpenseAccountID = @ClaimsReceivable
	End
Select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)

Begin tran
	Update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11
	Select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11
Commit tran

If @PartyType = 0 
	Insert Into DebitNote (DocumentID,CustomerID,AccountID,NoteValue,DocumentDate,Balance,Memo,SalesmanID,Flag,DocRef)
						Values (@DocumentID,@PartyID,@ExpenseAccountID,@Value,@DocDate,@Value,@Remarks,@SalesmanID,@Flag,@DocRef)	
Else
	Insert Into DebitNote (DocumentID,VendorID,AccountID,NoteValue,DocumentDate,Balance,Memo,SalesmanID,Flag,DocRef)
						Values (@DocumentID,@PartyID,@ExpenseAccountID,@Value,@DocDate,@Value,@Remarks,@SalesmanID,@Flag,@DocRef)	
Select @DocumentID, @@Identity
