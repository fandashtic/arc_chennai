CREATE Procedure sp_acc_CanAmendARV (@ARVDocumentID as Int)
AS
Declare @AmendedCount Int
Declare @CancelledCount Int
Declare @IsSameBalance Int
Declare @CANNOTAMEND Int
Declare @CANAMEND Int

Set @CANAMEND = 1
Set @CANNOTAMEND = 0

Select @AmendedCount = Count(*) from ARVAbstract Where DocumentID = @ARVDocumentID
And (IsNull(Status, 0) & 128) <> 0

Select @CancelledCount = Count(*) from ARVAbstract Where DocumentID = @ARVDocumentID
And (IsNull(Status, 0) & 192) <> 0

If @AmendedCount > 0 Or @CancelledCount > 0
	Begin
		Select @CANNOTAMEND
	End
Else
	Begin
		Select @IsSameBalance = Count(*) From ARVAbstract Where DocumentID = @ARVDocumentID
	   And Amount = balance + (Select sum(ServiceChargeAmount) from ARVDetail Where ARVDetail.DocumentID = @ARVDocumentID)
		If @IsSameBalance > 0
			Begin		
				Select @CANAMEND
			End
		Else
			Begin			
				Select @CANNOTAMEND
			End
	End

