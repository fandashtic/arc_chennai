Create Procedure sp_check_taxtable (@TaxSuffered Decimal(18, 6), @ApplOn Decimal(18, 6), 
                                    @PartPer Decimal(18, 6), @Location Decimal(18, 6))
As
Declare @i Int
Set @i = 0
If @Location = 1
Begin
	if (select Count(*) from tax where percentage = @TaxSuffered And 
    LSTApplicableOn = @ApplOn And LSTPartOff = @PartPer) > 0
    Begin
		Set @i = 1
	End
	Else
	Begin
		Set @i = 0
	End
End
Else If @Location = 2
Begin
	if (select Count(*) from tax where CST_Percentage = @TaxSuffered And 
    CSTApplicableOn = @ApplOn And CSTPartOff = @PartPer) > 0
    Begin
		Set @i = 1
	End
	Else
	Begin
		Set @i = 0
	End
End
select @i


