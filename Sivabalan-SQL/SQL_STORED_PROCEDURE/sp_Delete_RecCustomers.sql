Create Procedure sp_Delete_RecCustomers(@ID int)
As

	Update ReceivedCustomers Set Status=(Status |192)
	Where ID=@ID

