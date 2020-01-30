
CREATE PROCEDURE [sp_update_State]  
 (@StateID_1  [int],  
  @StateID_2  [int],  
  @State_3  [nvarchar](50),  
  @Active_4  [int])  
  
AS UPDATE [State]   
  
SET  [State]  = @State_3,  
  [Active]  = @Active_4   
  
WHERE   
 ( [StateID]  = @StateID_1)

