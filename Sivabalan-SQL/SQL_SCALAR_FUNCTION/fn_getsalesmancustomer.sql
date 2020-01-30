Create Function fn_getsalesmancustomer (@CustomerID nvarchar(100))        
Returns nvarchar(2100)        
As        
Begin  
Declare @Result nvarchar(2100)  
Declare @SalesmanName nvarchar(100)
Set @Result= '' 

Declare SalesmanList Cursor Keyset For
Select Distinct Salesman_name from Salesman , Beat_Salesman
Where Salesman.SalesmanID = Beat_Salesman.SalesmanID 
And Beat_Salesman.CustomerID = @CustomerID
Open SalesmanList        
Fetch From SalesmanList into @SalesmanName
While @@Fetch_Status = 0        
Begin
Set @Result= @Result + @SalesmanName + ' | '
Fetch Next From SalesmanList into @SalesmanName
End
  
Close SalesmanList      
Deallocate SalesmanList        
Return @Result        
End
