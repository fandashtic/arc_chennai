
CREATE PROCEDURE [sp_update_Country]  
 (@CountryID_1  [int],  
  @CountryID_2  [int],  
  @Country_3  [nvarchar](50),  
  @Active_4  [int])  
  
AS UPDATE [Country]   
  
SET  [Country]  = @Country_3,  
  [Active]  = @Active_4   
  
WHERE   
 ( [CountryID]  = @CountryID_1)

