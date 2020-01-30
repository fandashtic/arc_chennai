
CREATE PROCEDURE [sp_update_Cash_Customer]  
 (@CustomerID_1  [int],  
  @CustomerName_2  [nvarchar],  
  @Address_3  [nvarchar],  
  @CustomerID_4  [int],  
  @CustomerName_5  [nvarchar](50),  
  @Address_6  [nvarchar](255))  
  
AS UPDATE [Cash_Customer]   
  
SET  [CustomerName]  = @CustomerName_5,  
  [Address]  = @Address_6   
  
WHERE   
 ( [CustomerID]  = @CustomerID_1 AND  
  [CustomerName]  = @CustomerName_2 AND  
  [Address]  = @Address_3)

