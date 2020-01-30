CREATE procedure sp_modify_Tax
(	@TAXCODE INT,
	@PERCENTAGE Decimal(18,6),
	@ACTIVE INT, 
	@CentralTax Decimal(18,6),
	@LSTApplicableOn Int = 1,
	@LSTPartOff Decimal(18,6) = 100,
	@CSTApplicableOn Int = 1,
	@CSTPartOff Decimal(18,6) = 100
)  
AS  
update Tax  set Percentage=@PERCENTAGE, CST_Percentage = @CentralTax,   
Active = @ACTIVE, LSTApplicableOn = @LSTApplicableOn,
LSTPartOff = @LSTPartOff, CSTApplicableOn = @CSTApplicableOn,
CSTPartOff = @CSTPartOff
Where Tax_Code = @TAXCODE  
  


