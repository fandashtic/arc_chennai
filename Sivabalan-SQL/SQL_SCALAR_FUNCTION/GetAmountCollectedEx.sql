CREATE Function GetAmountCollectedEx (@PaymentDetail nvarchar(255),
				      @PaymentMode nvarchar(255))
Returns nvarchar(50)
Begin
Declare @StartPos int
Declare @EndPos int
Declare @Value Decimal(18,6)
Declare @Len int
Declare @Digit int
Declare @IsAvailable int

Set @Len = Len(@PaymentDetail)
Set @IsAvailable = 0
Set @StartPos = CharIndex(@PaymentMode, @PaymentDetail) 
If @StartPos = 0
Begin
	Return N''
End
Else
Begin
	Set @EndPos = @StartPos + Len(@PaymentMode)
	Set @StartPos = @EndPos
	While @EndPos <= @Len
	Begin
		Set @Digit = ascii(Substring(@PaymentDetail, @EndPos, 1))
		IF (@Digit < 32 or @Digit > 127) and @Digit <> 58 and @Digit <> 46 Goto OuttaLoop
		IF @Digit = 58 And @IsAvailable = 0
		Begin
			Set @StartPos = @EndPos + 1
			Set @IsAvailable = @IsAvailable + 1	
		End
		Else If @Digit = 58 And @IsAvailable = 1 Goto OuttaLoop
		Set @EndPos = @EndPos + 1
	End
OuttaLoop:
	RETURN Case @IsAvailable 
	When 1 Then 
	SubString(@PaymentDetail, @StartPos, @EndPos - @StartPos) 
	When 2 Then 
	SubString(@PaymentDetail, @StartPos, @EndPos - @StartPos)
	Else 
	N'' 
	End
End
	Return N''
End
