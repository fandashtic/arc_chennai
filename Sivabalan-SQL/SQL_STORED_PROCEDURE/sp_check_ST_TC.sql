Create Procedure sp_check_ST_TC(@LST Decimal(18, 6), @CST Decimal(18, 6), 
                                @LApl Decimal(18, 6), @LPrt Decimal(18, 6),
                                @CApl Decimal(18, 6), @CPrt Decimal(18, 6))
As

Select Tax_Code From Tax Where Percentage = @LST And CST_Percentage = @CST And
    LSTApplicableOn = @LApl And LSTPartOff = @LPrt And CSTApplicableOn = @CApl And
    CSTPartOff = @CPrt


