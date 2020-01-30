
CREATE PROCEDURE [sp_update_Beat]  
 (@BeatID_1  [int],  
  @Description_2  [nvarchar],  
  @CreationDate_3  [smalldatetime],  
  @BeatID_4  [int],  
  @Description_5  [nvarchar](255),  
  @CreationDate_6  [smalldatetime])  
  
AS UPDATE [Beat]   
  
SET  [Description]  = @Description_5,  
  [CreationDate]  = @CreationDate_6   
  
WHERE   
 ( [BeatID]  = @BeatID_1 AND  
  [Description]  = @Description_2 AND  
  [CreationDate]  = @CreationDate_3)

