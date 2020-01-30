Create Procedure [dbo].[sp_han_IsValidBeat_Salesman] (@BeatID Int,@SalesmanID Int, @CustID nvarchar(100))
As  

If (Isnull((Select Count(*) from Beat_SalesMan 
	where SalesmanID = @SalesmanID and CustomerID = @CustID), 0) = 0) or @BeatID = 0 
	or not exists (Select * from Beat where BeatID = @BeatID)

		Select @BeatID 'BeatID', '' 'BeatName', '' 'Beat_SalesMan',
		(Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName',
		'' 'Beat_Cust',
		(Select Company_Name from Customer where CustomerID = @CustID) 'CustomerName'
else
	Select B.BeatID 'BeatID', B.[Description] 'BeatName', BS.SalesmanId 'Beat_SalesMan',       
	(Select SalesMan_Name from SalesMan where SalesManID = @SalesmanID) 'SalesManName',       
	BC.CustomerID 'Beat_Cust',  
	(Select Company_Name from Customer where CustomerID = @CustID) 'CustomerName'       
	from Beat B      
	Left Outer join Beat_SalesMan BS On BS.BeatId = @BeatID and BS.SalesManID = @SalesManID       
	Left Outer join Beat_SalesMan BC On BC.BeatId = @BeatID and BC.CustomerID = @CustID      
	Where B.BeatID = @BeatID      
