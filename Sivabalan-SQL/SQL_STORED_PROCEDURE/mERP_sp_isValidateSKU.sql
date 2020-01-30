Create Procedure mERP_sp_isValidateSKU(@ItemCode nVarchar(50))
As
Begin
	If Not Exists(Select * From Items Where Product_Code = @ItemCode)
		Select -1 /*Product Not exists */
	Else If Not Exists(Select * From Items Where Product_Code = @ItemCode And Active = 1)
		Select 0
	Else 
		Select 1
	
End
