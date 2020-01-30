Create Function FN_Get_GST_InvoiceCustomerLocality(@InvNo int)
	Returns int
As
Begin
	Declare @CustomerLocality int

	IF Exists(Select 'x' From InvoiceAbstract Where InvoiceID = @InvNo and isnull(FromStateCode,0) = isnull(ToStateCode,0))
		Set @CustomerLocality = 1
	Else
		Set @CustomerLocality = 2
	
	Return @CustomerLocality
End
