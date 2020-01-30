
CREATE PROCEDURE [sp_update_City]  
 (@CityID_1  [int],  
  @CityID_2  [int],  
  @CityName_3  [nvarchar](50),  
  @Active_4  [int])  
  
AS UPDATE [City]   
  
SET  [CityName]  = @CityName_3,  
  [Active]  = @Active_4   
  
WHERE   
 ( [CityID]  = @CityID_1)

