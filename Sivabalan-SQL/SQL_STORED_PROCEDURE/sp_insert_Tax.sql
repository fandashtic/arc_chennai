CREATE PROCEDURE [sp_insert_Tax]  
(	@Tax_Description_2  [nvarchar](255),  
  	@Percentage_3  Decimal(18,6),  
  	@CentralPercentage Decimal(18,6),  
  	@LSTApplicableOn Int = 1,
 	@LSTPartOff Decimal(18,6) = 100,
	@CSTApplicableOn Int = 1,
  	@CSTPartOff Decimal(18,6) = 100
)
AS 
INSERT INTO [Tax]   
( [Tax_Description],  
  [Percentage],  
  [CST_Percentage],
  [LSTApplicableOn],
  [LSTPartOff],
  [CSTApplicableOn],
  [CSTPartOff]
)   
VALUES   
( @Tax_Description_2,  
  @Percentage_3,  
  @CentralPercentage,
  @LSTApplicableOn,
  @LSTPartOff,
  @CSTApplicableOn,
  @CSTPartOff
)  
  
Select Tax_Code,Tax_Description,Percentage, CST_Percentage from Tax where Tax_Code=@@Identity  
  


