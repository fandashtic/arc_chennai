create function sp_acc_getmanualjournalnewreference(@TransactionID Int,
@AccountID Int,@Mode Int)
returns nvarchar(255)
as 
begin
Declare @AdditionalInfo nVarchar(255)

If @Mode = 1 
Begin
	Select @AdditionalInfo = ReferenceNo from ManualJournal
	Where TransactionID = @TransactionID
	and AccountID = @AccountID
	and IsNull(Status,0) <> 192 
	and IsNull(Status,0) <> 128 
End
Else If @Mode = 2
Begin
	Select @AdditionalInfo = Remarks from ManualJournal
	Where TransactionID = @TransactionID
	and AccountID = @AccountID
	and IsNull(Status,0) <> 192 
	and IsNull(Status,0) <> 128 
End
Return @AdditionalInfo
End





