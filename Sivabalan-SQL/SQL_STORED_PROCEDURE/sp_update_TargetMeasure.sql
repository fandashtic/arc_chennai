
CREATE PROCEDURE [sp_update_TargetMeasure]  
 (@MeasureID_1  [int],  
  @MeasureID_2  [int],  
  @Description_3  [nvarchar](128),  
  @Active_4  [int])  
  
AS UPDATE [TargetMeasure]   
  
SET  [Description]  = @Description_3,  
  [Active]  = @Active_4   
  
WHERE   
 ( [MeasureID]  = @MeasureID_1)

