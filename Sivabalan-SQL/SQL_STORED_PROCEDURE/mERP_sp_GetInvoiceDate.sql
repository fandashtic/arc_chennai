Create Procedure mERP_sp_GetInvoiceDate(@InvoiceID Int)
As
	Declare @i Int
	Set @i = 1
	While @i <> 0
	Begin
		If (Select IsNull(InvoiceReference, 0) From InvoiceAbstract Where InvoiceID = @InvoiceID And InvoiceType = 1) = 0
		Begin
			Set @i = 0
			Select InvoiceDate, CreationTime From InvoiceAbstract Where InvoiceID = @InvoiceID
		End
		Else
			Select @InvoiceID = InvoiceReference From InvoiceAbstract Where InvoiceID = @InvoiceID
	End

