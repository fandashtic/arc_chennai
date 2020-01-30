CREATE PROCEDURE sp_acc_ReceivePriceList_InsertTax
(  
   @Tax_Desc nVarChar(255),
   @LST Decimal(18,6),  
   @CST Decimal(18,6),  
   @LSTApplicableOn Int = 1,
 	@LSTPartOff Decimal(18,6) = 100,
	@CSTApplicableOn Int = 1,
  	@CSTPartOff Decimal(18,6) = 100
)
AS 
INSERT INTO [Tax]   
( 
  [Tax_Description],  
  [Percentage],  
  [CST_Percentage],
  [LSTApplicableOn],
  [LSTPartOff],
  [CSTApplicableOn],
  [CSTPartOff]
)   
VALUES   
( 
  @Tax_Desc,  
  @LST,  
  @CST,
  @LSTApplicableOn,
  @LSTPartOff,
  @CSTApplicableOn,
  @CSTPartOff
)  
Select @@Identity

