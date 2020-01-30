CREATE Function GetAmountCollected (@PaymentDetail nvarchar(255),
					@PaymentMode nvarchar(255))
Returns Decimal(18,6)
Begin
Declare @StartPos int
Declare @EndPos int
Declare @Value Decimal(18,6)
Declare @Len int
Declare @Digit int
Declare @Return Decimal(18,6)

Set @Len = Len(@PaymentDetail)
Set @StartPos = CharIndex(@PaymentMode, @PaymentDetail) 
If @StartPos = 0
Begin
	Return 0
End
Else
Begin
	Set @EndPos = @StartPos + Len(@PaymentMode)
	Set @StartPos = @EndPos
	While @EndPos <= @Len
	Begin
		Set @Digit = ascii(Substring(@PaymentDetail, @EndPos, 1))
		IF (@Digit < 48 or @Digit > 57) and (@Digit <> 46) Goto OuttaLoop
		Set @EndPos = @EndPos + 1
	End
OuttaLoop:
	Set @Value = Cast(SubString(@PaymentDetail, @StartPos, @EndPos - @StartPos) as Decimal(18,6))
	Set @StartPos = CharIndex(':', @PaymentDetail, @EndPos + 1)
	Set @EndPos = @StartPos + 1
	Set @StartPos = @EndPos
	While @EndPos <= @Len
	Begin
		Set @Digit = ascii(Substring(@PaymentDetail, @EndPos, 1))
		IF (@Digit < 48 or @Digit > 57) and (@Digit <> 46) Goto OuttaLoop2
		Set @EndPos = @EndPos + 1
	End
OuttaLoop2:
	Set @Return = Cast(SubString(@PaymentDetail, @StartPos, @EndPos - @StartPos) as Decimal(18,6))
	Return (@Value - @Return)
End
	Return 0
End
