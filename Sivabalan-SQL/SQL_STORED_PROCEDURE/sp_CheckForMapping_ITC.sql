
CREATE Procedure sp_CheckForMapping_ITC(@SalesmanID as int, @BeatID as int, @CustID as nvarchar(30))
As
		Select Count(*) From Beat_Salesman 
			Where SalesmanID = @SalesmanID
			And BeatID = @BeatID
			And CustomerID = @CustID


