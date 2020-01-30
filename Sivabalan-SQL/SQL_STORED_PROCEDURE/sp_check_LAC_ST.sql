Create Procedure sp_check_LAC_ST(@LST Decimal(18, 6), @CST Decimal(18, 6), 
                                 @LApl Decimal(18, 6), @LPrt Decimal(18, 6),
                                 @CApl Decimal(18, 6), @CPrt Decimal(18, 6))
As
Declare @i Int
Set @i = 0
If (Select Count(*) From Tax Where Percentage = @LST And CST_Percentage = @CST And
    LSTApplicableOn = @LApl And LSTPartOff = @LPrt And CSTApplicableOn = @CApl And
    CSTPartOff = @CPrt) > 0
	Begin
		Set @i = 1
	End
Else
	Begin
		Set @i = 0
	End
Select @i


