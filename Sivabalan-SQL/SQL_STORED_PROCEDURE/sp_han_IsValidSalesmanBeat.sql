Create Procedure [dbo].[sp_han_IsValidSalesmanBeat] (@BeatID Int,@SalesmanID Int)  
As    
If (IsNull((Select Count(*) from Beat_Salesman where SalesmanID = @SalesmanID and BeatID = @BeatID),0) = 0) 
Or @BeatID = 0 Or Not Exists (Select * from beat where beatID = @beatID)
	Select 0 'Count',   (Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName', 
		(Select Description from Beat Where BeatID = @BeatID) 'BeatName'
Else
	Select 1 'Count', (Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName', 
		(Select Description from Beat Where BeatID = @BeatID) 'BeatName'
