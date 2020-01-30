CREATE Procedure sp_CheckForMappedCustomer_ITC(@SalesmanID as int, @BeatID as int, @CustID as nvarchar(30))  
As
Begin  
	Declare @Exists as int
if( Select Count(*) From Beat_Salesman Where SalesmanID = @SalesmanID  And BeatID = @BeatID And CustomerID = @CustID) > 0 
	set @Exists = 1
else
Begin
	if(Select Count(*) From Beat_Salesman  where SalesmanID = @SalesmanID  And CustomerID = @CustID) > 0 
	set @Exists = 1
End
	Select @Exists
End

