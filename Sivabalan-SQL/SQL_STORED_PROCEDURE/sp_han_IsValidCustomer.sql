Create Procedure sp_han_IsValidCustomer(@CustomerID nVarchar(15))
As
Declare @Status as nVarchar(50)
Select @Status  = Case  
		When IsNull(CustomerCategory ,0) >=4 then 'has invalid customer category for '
		else ''
		end
from Customer Where CustomerID = @CustomerID 
Select "ErrStatus" = IsNull(@Status,'has invalid ')
