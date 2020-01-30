CREATE Procedure sp_compare_TaxPercentage (     @LST Decimal(18,6),
						@CST Decimal(18,6),
						@LSTApplicableOn Int = 1,
						@LSTPartOff Decimal(18,6) = 100,
						@CSTApplicableOn Int = 1,
						@CSTPartOff Decimal(18,6) = 100)
As
If Exists(Select * From Tax Where IsNull(GSTFlag,0) = 0 And Percentage = @LST And CST_Percentage = @CST 
 And LSTApplicableOn = @LSTApplicableOn And LSTPartOff = @LSTPartOff 
 And CSTApplicableOn = @CSTApplicableOn And CSTPartOff = @CSTPartOff) 
	Select top 1 tax_code, active From Tax Where IsNull(GSTFlag,0) = 0 And Percentage = @LST And CST_Percentage = @CST 
	And LSTApplicableOn = @LSTApplicableOn And LSTPartOff = @LSTPartOff 
	And CSTApplicableOn = @CSTApplicableOn And CSTPartOff = @CSTPartOff order by active desc, tax_code desc  
Else
	Select 0, 0
