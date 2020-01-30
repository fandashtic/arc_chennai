Create Function Sp_ReturnTaxColumn(@TaxPercentage as Decimal(18,6)) Returns nvarchar(100)
As
Begin
Declare @ColumnHeader as nvarchar(100)
Declare @continue as Int
Declare @TaxSuffered as nvarchar(100)
If @TaxPercentage = 0 
	Begin
		Set @ColumnHeader = N'0'
	End
Else
	Begin
    Set @ColumnHeader = Cast(@TaxPercentage as Nvarchar(100))
		Set @Continue = 1
		While @Continue = 1
		Begin
			If Right(@ColumnHeader, 1) = N'0'
				Set @ColumnHeader = Left(@ColumnHeader,(len(@ColumnHeader)-1))
			Else
			 Set @Continue = 0
	  End
		Set @ColumnHeader = Case(Len(@ColumnHeader)) When 2 Then Replace(@ColumnHeader,N'.',N'') Else @ColumnHeader End
	End
	Return @ColumnHeader
End
