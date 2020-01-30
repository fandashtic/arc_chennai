




CREATE Procedure sp_acc_receiptdenomination(@Mode as Integer, @Title as nVarchar(25), @Count as Decimal(18,6))
As
Declare @ADD INT, @SUB INT, @REPLACE INT
Set @ADD=0
SET @SUB=1
Set @REPLACE=2

If not exists(Select Top 1 DenominationCount from Denominations where DenominationTitle=@Title)
Begin
	Insert Into Denominations(DenominationTitle,DenominationCount) values(@Title,@Count)
End
Else
Begin
	If @Mode=@ADD
	Begin
		Update Denominations Set DenominationCount = (DenominationCount + @Count) where DenominationTitle=@Title
	End
	Else If @Mode=@SUB
	Begin
		Update Denominations Set DenominationCount = (DenominationCount - @Count) where DenominationTitle=@Title
	End
	Else If @Mode=@REPLACE
	begin
		Update Denominations Set DenominationCount = @Count where DenominationTitle=@Title
	End
End





