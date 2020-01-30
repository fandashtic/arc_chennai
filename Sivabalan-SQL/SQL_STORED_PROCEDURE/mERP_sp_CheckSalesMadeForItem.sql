Create Procedure mERP_sp_CheckSalesMadeForItem(@ItemCode nVarchar(255))
As
Begin
	Declare @ProdCode nVarchar(255)

	Select Top 1 @ProdCode = Product_Code From 
	InvoiceAbstract IA ,InvoiceDetail ID
	Where IA.InvoiceID = ID.InvoiceID And
	isNull(Status,0) & 128  = 0 And
	ID.Product_Code = @ItemCode

	If isNull(@ProdCode,'') <> ''
		Select 1
	Else
		Select 0

End

