CREATE Procedure sp_Create_AdjClaim (@ClaimID Int,
							@ClaimDocID nvarchar(255),
							@AdjReasonID Int,
							@AdjustedAmount Decimal(18,6),
							@DiffAmount Decimal(18,6),
							@Serial int =0)
As
Declare @AdjRefID Int
Declare @Balance Decimal(18,6)
Declare @ClearingAmount Decimal(18,6)

Insert Into ClaimsDetail (ClaimID, AdjReasonID, AdjustedAmount,Serial)
Values (@ClaimID, @AdjReasonID, @AdjustedAmount,@Serial)

Update AdjustmentReference Set Balance = 0, 
ClaimID = IsNull(ClaimID, N'')+ N', ' + Cast(@ClaimID as nvarchar),
DocRef = IsNull(DocRef, N'') + N', ' + Cast(@ClaimDocID as nvarchar)
Where AdjustmentReasonID = @AdjReasonID And
DocumentType = 5 And
IsNull(Status, 0) & 128 = 0 And
IsNull(Balance, 0) > 0

Declare Adjustments Cursor Keyset For
Select AdjRefID, Balance From AdjustmentReference
Where IsNull(Balance, 0) > 0 And
AdjustmentReasonID = @AdjReasonID And
IsNull(Status, 0) & 128 = 0 And 
DocumentType = 2 Order By AdjRefID Desc

Open Adjustments

Fetch From Adjustments Into @AdjRefID, @Balance
Set @ClearingAmount = @DiffAmount
While @@Fetch_Status = 0
Begin
	If @Balance > @ClearingAmount And @ClearingAmount > 0
	Begin
		Update AdjustmentReference Set Balance = @ClearingAmount,
		ClaimID = IsNull(ClaimID, N'') + N', ' + Cast(@ClaimID as nvarchar),
		DocRef = IsNull(DocRef, N'') + N', ' + Cast(@ClaimDocID as nvarchar)
		Where AdjRefID = @AdjRefID
		Insert Into AdjClaimReference (ClaimID, AdjRefID, AdjustedValue)
		Values (@ClaimID, @AdjRefID, @Balance - @ClearingAmount)
		Set @ClearingAmount = 0
	End
	Else If @Balance <= @ClearingAmount And @ClearingAmount > 0
	Begin
-- 		Update AdjustmentReference Set Balance = 0,
-- 		ClaimID = IsNull(ClaimID, '') + ', ' + Cast(@ClaimID as nvarchar),
-- 		DocRef = IsNull(DocRef, '') + ', ' + Cast(@ClaimDocID as nvarchar)
-- 		Where AdjRefID = @AdjRefID
		Set @ClearingAmount = @ClearingAmount - @Balance
	End
	Else
	Begin
		Update AdjustmentReference Set Balance = 0,
		ClaimID = IsNull(ClaimID, N'') + N', ' + Cast(@ClaimID as nvarchar),
		DocRef = IsNull(DocRef, N'') + N', ' + Cast(@ClaimDocID as nvarchar)
		Where AdjRefID = @AdjRefID		
		Insert Into AdjClaimReference (ClaimID, AdjRefID, AdjustedValue)
		Values (@ClaimID, @AdjRefID, @Balance)
		Set @ClearingAmount = @ClearingAmount - @Balance		
	End
	Fetch Next From Adjustments Into @AdjRefID, @Balance
End
Close Adjustments
DeAllocate Adjustments

