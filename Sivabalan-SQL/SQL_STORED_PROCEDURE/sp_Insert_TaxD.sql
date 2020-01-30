Create Procedure sp_Insert_TaxD(@Desc nvarchar(2000), @LST Decimal(18, 6),@CST Decimal(18, 6),
							   @LApl Decimal(18, 6), @LPrt Decimal(18, 6),
                               @CApl Decimal(18, 6), @CPrt Decimal(18, 6))
As
	Insert InTo Tax(Tax_Description, Percentage, CST_Percentage, LSTApplicableOn, LSTPartOff,
                    CSTApplicableOn, CSTPartOff) Values (@Desc, @LST, @CST, @LApl, @LPrt,
                    @CApl, @CPrt)

