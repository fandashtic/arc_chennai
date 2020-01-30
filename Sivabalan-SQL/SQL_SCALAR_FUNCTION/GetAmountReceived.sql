CREATE Function GetAmountReceived (@PaymentDetails as nvarchar(255))
Returns Decimal(18,6)
As
Begin
Declare @StartPos Int
Declare @EndPos Int
Declare @Continue Int
Declare @Temp nvarchar(255)
Declare @NextIndex Int
Declare @TotalAmount Decimal(18,6)
Declare @PaidAmount Decimal(18,6)
Declare @Len Int

Set @Continue = 1
Set @Temp = @PaymentDetails
Set @Len = Len(@PaymentDetails)
While @Continue = 1
Begin
	Set @StartPos = CharIndex(':', @Temp)
	Set @EndPos = CharIndex(':', @Temp, @StartPos + 1)
	Set @PaidAmount = Cast(SubString(@Temp, @StartPos + 1, @EndPos - @StartPos - 1) As Decimal(18,6))
	Set @NextIndex = CharIndex(';', @Temp)
	Set @TotalAmount = IsNull(@TotalAmount, 0) + @PaidAmount
	If @NextIndex = 0 
		Set @Continue = 0
	Else
	Begin
		Set @Continue = 1
		Set @Temp = SubString(@Temp, @NextIndex + 1, @Len - @NextIndex)
	End
End
Return @TotalAmount
End

