Create Function dbo.fnToSum(@list nVarchar(4000), @Delt nvarchar(5))
Returns Decimal(18, 6)
As
Begin
	Declare @VslSum Decimal(18, 6)

	Select @VslSum = Sum(Cast(ItemValue As Decimal(18, 6))) from dbo.sp_SplitIn2Rows(@list, @Delt)
	
	Return @VslSum 
End
