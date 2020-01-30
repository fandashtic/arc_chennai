
CREATE PROCEDURE [sp_update_Manufacturer]  
 (@ManufacturerID_1  [nvarchar],  
  @ManufacturerID_2  [nvarchar](15),  
  @Manufacturer_Name_3  [nvarchar](255),  
  @CreationDate_4  [smalldatetime],  
  @Active_5  [int])  
  
AS UPDATE [Manufacturer]   
  
SET  [Manufacturer_Name]  = @Manufacturer_Name_3,  
  [CreationDate]  = @CreationDate_4,  
  [Active]  = @Active_5   
  
WHERE   
 ( [ManufacturerID]  = @ManufacturerID_1)

