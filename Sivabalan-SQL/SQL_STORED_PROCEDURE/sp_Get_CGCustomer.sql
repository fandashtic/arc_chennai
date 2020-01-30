Create Procedure sp_Get_CGCustomer(@CGCustomer nvarchar(150))
As

Select ID, isnull(CGCustomerAddress,'') 'CGCustomerAddress' From tbl_Merp_CGCustomer Where CGCustomerName = @CGCustomer

