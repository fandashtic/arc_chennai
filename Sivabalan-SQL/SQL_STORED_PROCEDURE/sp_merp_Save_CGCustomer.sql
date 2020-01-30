Create Procedure sp_merp_Save_CGCustomer(@CGCustomer nvarchar(150), @CGCustomerAddress nvarchar(500))
As

	IF Exists(Select 'x' From tbl_Merp_CGCustomer Where CGCustomerName = @CGCustomer)
		Update tbl_Merp_CGCustomer Set CGCustomerAddress = @CGCustomerAddress, ModifiedDate = GetDate() Where CGCustomerName = @CGCustomer
	Else
		Insert Into tbl_Merp_CGCustomer(CGCustomerName,CGCustomerAddress) Values (@CGCustomer, @CGCustomerAddress)

