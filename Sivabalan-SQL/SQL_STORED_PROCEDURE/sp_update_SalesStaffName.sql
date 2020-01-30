CREATE Procedure sp_update_SalesStaffName (@ID nvarchar(10),@NewName nvarchar(128))    
As    
Update Salesman Set Salesman_Name = @NewName  
Where SalesmanID = @ID    




