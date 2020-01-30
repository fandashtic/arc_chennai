Create PROCEDURE sp_Save_BeatSalesman(  
          @BeatID INT,  
          @SalesmanID INT,  
              @MON int = 0,   
          @TUE int = 0,  
          @WED int = 0,  
          @THU int = 0,  
          @FRI int = 0,  
          @SAT int = 0,  
          @SUN int = 0)            
AS  
Update Beat_Salesman SET SalesmanID = @SalesmanID,   
MON = @MON, TUE = @TUE, WED = @WED, THU = @THU, FRI = @FRI, SAT = @SAT, SUN = @SUN   
WHERE BeatID = @BeatID    


if Exists(Select * from Beat_Salesman Where SalesManID = @SalesmanID  and BeatID <> 0 and isnull(CustomerID,'') <> '')
Begin
	Update Salesman Set ModifiedDate = Getdate() Where SalesmanID  = @SalesmanID
	Update Customer Set ModifiedDate = GetDate() Where isnull(CustomerID,'') IN
	(Select ISNull(CustomerID,'') From Beat_Salesman Where SalesManID = @SalesmanID and BeatID <> 0)
	
End

