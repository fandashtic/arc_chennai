CREATE Function Fn_Get_WriteoffAmt_Decimal(@BalanceAmt Decimal(18, 6))
--Returns Decimal(18, 6)
Returns nvarchar(30)
As
Begin
Declare @WritoffAmt Decimal(18,6)
Declare @Pos int
Declare @First nvarchar(30)
Declare @Second nvarchar(30)
Declare @Bal nvarchar(30)
Declare @DigitsReqd int
Declare @ReqdDigits nvarchar(30)
Declare @Result1 nvarchar(30)
Declare @Result2 nvarchar(30)

Set @Bal = Cast(@BalanceAmt as nvarchar(30))
Set @DigitsReqd = 2

IF Cast(@Bal as Decimal(18,6)) <= 0
BEGIN
	Set @WritoffAmt = 0
	GOTO OUT1
END
Set @Pos = CharIndex('.', @Bal, 1)
Set @First = Left(@Bal, @Pos - 1)
Set @Second = Substring(@Bal, @Pos, 7)

Set @ReqdDigits = Left(@Second, @DigitsReqd + 1)
Set @Result1 = @First + @ReqdDigits
Set @Result2 = '.00' + Substring(@Second, @DigitsReqd + 2, 4)
Set @WritoffAmt = Cast(@Result2 as Decimal(18, 6))

OUT1:
Return @WritoffAmt
End
