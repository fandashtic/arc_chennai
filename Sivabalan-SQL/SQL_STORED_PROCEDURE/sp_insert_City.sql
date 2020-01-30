CREATE PROCEDURE [sp_insert_City]    
 (  @CityName_2  [nvarchar](50),    
   @DistrictID Integer = 0,    
   @StateID Integer = 0,    
   @Active Integer = 0,  
   @STD nvarchar(50) = 0)    
    
AS INSERT INTO [City]     
  (   [CityName], [DistrictID], [StateID], [Active], [STDCode])      
     
VALUES     
 (@CityName_2, @DistrictID, @StateID, 1, @STD)    
select @@identity    



