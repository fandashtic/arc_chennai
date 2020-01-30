
CREATE PROCEDURE [sp_update_UOM]  
 (@UOM_1  [int],  
  @UOM_2  [int],  
  @Description_3  [nvarchar](255),  
  @CreationDate_4  [datetime],  
  @Active_5  [int])  
  
AS UPDATE [UOM]   
  
SET  [Description]  = @Description_3,  
  [CreationDate]  = @CreationDate_4,  
  [Active]  = @Active_5   
  
WHERE   
 ( [UOM]  = @UOM_1)

