CREATE PROCEDURE sp_Update_CityInfo(@CityID [nvarchar](50),    
   @DistrictID Integer,    
   @StateID Integer,    
   @Active Integer,  
   @STD nvarchar(50) = 0)    
    
As    
    
Update City Set DistrictID =  @DistrictID, StateID = @StateID, Active =  @Active, STDCode = @STD  
Where CityID = @CityID    
  
Update Customer Set District =  @DistrictID, StateID = @StateID Where CityID = @CityID  
  


