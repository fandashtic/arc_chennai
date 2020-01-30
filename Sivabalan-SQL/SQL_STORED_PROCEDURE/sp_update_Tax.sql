
CREATE PROCEDURE [sp_update_Tax]  
 (@Tax_Code_1  [int],  
  @Tax_Code_2  [int],  
  @Tax_Description_3  [nvarchar](255),  
  @Percentage_4  Decimal(18,6),  
  @CreationDate_5  [datetime],  
  @Active_6  [int])  
  
AS UPDATE [Tax]   
  
SET  [Tax_Description]  = @Tax_Description_3,  
  [Percentage]  = @Percentage_4,  
  [CreationDate]  = @CreationDate_5,  
  [Active]  = @Active_6   
  
WHERE   
 ( [Tax_Code]  = @Tax_Code_1)

