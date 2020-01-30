CREATE Procedure sp_Get_Beat_Customer @CustomerID nvarchar(30)   
as  
SELECT Beat.Description FROM Customer   
INNER JOIN Beat_Salesman ON   
 Customer.CustomerID = Beat_Salesman.CustomerID  
INNER JOIN Beat ON  
 Beat.BeatID = Beat_Salesman.BeatID  
Where Customer.CustomerID = @CustomerID  
  


