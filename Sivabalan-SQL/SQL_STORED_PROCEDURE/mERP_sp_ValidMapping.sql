Create Procedure mERP_sp_ValidMapping(@CustID nVarchar(255),@SalesmanName nVarchar(500),@BeatName nVarchar(500))
As
Begin
	Declare @ErrMsg as nVarchar(50)

	If Not Exists(Select * From Customer Where  CustomerID = @CustID)
		Set @ErrMsg = 'Invalid Customer'
	Else If Not Exists(Select * From Customer Where  CustomerID = @CustID And Active = 1)
		Set @ErrMsg = 'Inactive Customer'
	Else IF Not Exists(Select * From Salesman Where Salesman_Name = @SalesmanName)
		Set @ErrMsg = 'InValid Salesman'
	Else IF Not Exists(Select * From Salesman Where Salesman_Name = @SalesmanName And Active = 1)
		Set @ErrMsg = 'Inactive Salesman'
	Else IF Not Exists(Select * From Beat Where Description = @BeatName)
		Set @ErrMsg = 'InValid Beat'
	Else IF Not Exists(Select * From Beat Where Description = @BeatName And Active = 1)
		Set @ErrMsg = 'Inactive Beat'
	Else if Not Exists(Select * From Beat_salesman BS,Beat B,Salesman S 
					  Where CustomerID = @CustID And
					  BS.SalesmanID = S.SalesmanID And
					  S.Salesman_Name = @SalesmanName And
					  BS.BeatID = B.BeatID And	
					  B.Description = @BeatName)
		Set @ErrMsg = 'Inactive Beat'
		
	Select isNull(@ErrMsg,'1')

	
End

