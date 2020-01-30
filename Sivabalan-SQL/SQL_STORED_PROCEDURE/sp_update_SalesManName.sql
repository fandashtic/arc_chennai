
CREATE Procedure sp_update_SalesManName (@ID nvarchar(10),@NewName nvarchar(128))      
As      
Update SalesMan Set salesman_Name = @NewName, ModifiedDate = GetDate()    
Where SalesmanId = @ID      

