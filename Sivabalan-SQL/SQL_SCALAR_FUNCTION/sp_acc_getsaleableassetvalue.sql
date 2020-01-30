
CREATE Function sp_acc_getsaleableassetvalue(@AccountID Int)
Returns Decimal(18,6)
As
Begin
	Declare @Value Decimal(18,6)
	Select @Value=Sum(isNull(Rate,0)) from Batch_Assets where AccountID=@AccountID and Saleable=1
	Return @Value
End


