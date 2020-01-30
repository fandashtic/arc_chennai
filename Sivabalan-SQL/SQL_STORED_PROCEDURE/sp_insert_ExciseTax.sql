CREATE PROCEDURE [sp_insert_ExciseTax]    
 (@Tax_Description_2  [nvarchar](255),    
  @Percentage_3 decimal(18,6)  
)    
    
AS INSERT INTO [ExciseTax]     
  ( [Tax_Description],    
  [Percentage]    
)     
VALUES     
 (@Tax_Description_2,    
  @Percentage_3)    
    
Select Tax_Code,Tax_Description,Percentage from ExciseTax where Tax_Code=@@Identity



