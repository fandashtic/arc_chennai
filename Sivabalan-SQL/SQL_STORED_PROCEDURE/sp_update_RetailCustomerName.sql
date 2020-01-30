CREATE Procedure sp_update_RetailCustomerName (@ID nvarchar(10),@NewName nvarchar(128))    
As    
--Retail Customer is merged into Customer Table.  
--If End Customer Name is Changed, we will treat it as a First Name and Second Name is empty.  
Update Customer Set Company_Name = @NewName + N' ', First_Name = @NewName,   
Second_Name = N'' Where CustomerID = @ID   
  


