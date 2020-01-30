
CREATE PROCEDURE [sp_update_Brand]  
 (@BrandID_1  [int],  
  @BrandID_2  [int],  
  @BrandName_3  [nvarchar](255),  
  @CreationDate_4  [datetime],  
  @ManufacturerID_5  [nvarchar](15))  
  
AS UPDATE [Brand]   
  
SET  [BrandName]  = @BrandName_3,  
  [CreationDate]  = @CreationDate_4,  
  [ManufacturerID]  = @ManufacturerID_5   
  
WHERE   
 ( [BrandID]  = @BrandID_1)

