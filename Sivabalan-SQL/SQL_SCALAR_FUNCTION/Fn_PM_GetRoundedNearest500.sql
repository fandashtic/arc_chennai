Create Function Fn_PM_GetRoundedNearest500(@Target As Decimal(18,6))
Returns Int
As
Begin
	Declare @RoundedTarget as Int	
	set @RoundedTarget = (Round((Cast(@Target as Decimal(18,6))/500),0)) * 500 
	Return @RoundedTarget 
End
