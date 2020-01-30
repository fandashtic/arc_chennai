CREATE Procedure sp_update_ItemName (@ItemCode nvarchar(20),  @NewName nvarchar(250))  
As  
Update Items Set ProductName = @NewName, ModifiedDate = GetDate()   
Where Product_Code = @ItemCode  

