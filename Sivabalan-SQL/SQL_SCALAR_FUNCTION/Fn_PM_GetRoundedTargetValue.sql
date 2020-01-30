Create Function Fn_PM_GetRoundedTargetValue(@Target As Decimal(18,6))
Returns Int
As
Begin
	Declare @RoundedTarget as Int
	If ((Cast(@Target as Decimal(18,6))/100) - Round((Cast(@Target as Decimal(18,6))/100),0)) >  0
	Begin
		Set @RoundedTarget =  (Round((Cast(@Target as Decimal(18,6))/100),0) + 1) * 100 
	End
	Else
	Begin
		Set @RoundedTarget = (Round((Cast(@Target as Decimal(18,6))/100),0)) * 100 
	End

	Return @RoundedTarget 
End
