CREATE Function Fn_Cheque_Expired(@ChequeDate Datetime, @CollectionDate Datetime)
Returns int
As
Begin

Declare @ChequeExpired int
Declare @ChqMM int
Declare @ChqYY int
Declare @ColMM int
Declare @ColYY int

Declare @ChqDate nvarchar(25)
Declare @ColDate nvarchar(25)

Set @ChequeExpired = 0

Set @ChqDate = convert(varchar(10), @ChequeDate, 103)
Set @ColDate = convert(varchar(10), @CollectionDate, 103)
Select @ChqMM = SubString(@ChqDate, 4, 2)
Select @ChqYY = SubString(@ChqDate, 7, 4)

Select @ColMM = SubString(@ColDate, 4, 2)
Select @ColYY = SubString(@ColDate, 7, 4)

IF (@ColMM - 6) < 0
BEGIN
	Set @ColMM = 12 + (@ColMM - 6)
	Set @ColYY = @ColYY - 1
END
ELSE
	Set @ColMM = @ColMM - 6

IF @ChqYY > @ColYY
BEGIN
	Set @ChequeExpired = 0
	GOTO OUT1
END

IF @ChqYY = @ColYY
BEGIN
	IF @ChqMM >= @ColMM
		Set @ChequeExpired = 0
	ELSE
		Set @ChequeExpired = 1
END
ELSE
	Set @ChequeExpired = 1

OUT1:
Return @ChequeExpired

End
