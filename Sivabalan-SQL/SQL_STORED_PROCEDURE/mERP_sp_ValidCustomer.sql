CREATE Procedure mERP_sp_ValidCustomer(
				 @CustomerID nVarchar(255),
				@CustomerName nVarchar(500))
As
Begin
	Declare @CustID nVarchar(255)
	Declare @Active Int
	Declare @ErrMsg nVarchar(50)

	Set @ErrMsg = ''

	Select @CustID = isNull(CustomerID,'') , @Active = Active From Customer 
	Where CustomerID = @CustomerID 	And Company_Name = @CustomerName
	

	If isNull(@CustID,'') = ''
		Set @ErrMsg = 'Invalid Customer'
--	Else 
--		if @Active = 0 
--		Set @ErrMsg = 'Inactive Customer'


	Select (Case When @ErrMsg = '' Then 1 Else 0  End),@ErrMsg
	

End
