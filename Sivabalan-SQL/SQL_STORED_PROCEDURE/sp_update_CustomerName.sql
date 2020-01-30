CREATE Procedure sp_update_CustomerName (@ID nvarchar(30),@NewName nvarchar(128))          
As          
If Exists(Select CustomerCategory from Customer Where CustomerID = @ID 
	And CustomerCategory In (4))
 Begin  
  --Retail Customer is merged into Customer Table.    
  --If End Customer Name is Changed, we will treat it as a First Name and Second Name is empty.    
  Update Customer Set Company_Name = @NewName + N' ', First_Name = @NewName,     
  Second_Name = N'' Where CustomerID = @ID     
 End  
Else  
 Begin  
  Update Customer Set Company_Name = @NewName        
  Where CustomerId = @ID       
 End  


