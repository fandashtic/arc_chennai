Create Function mERP_fn_GetInvoiceDate(@InvoiceID Int,@mode int)
Returns datetime
As
Begin
	Declare @i Int
	declare @InvDate datetime
	Set @i = 1
	While @i <> 0
	Begin
		If (Select IsNull(InvoiceReference, 0) From InvoiceAbstract Where InvoiceID = @InvoiceID And InvoiceType = 1) = 0
		Begin
			Set @i = 0
			Select @InvDate = case when @mode = 1 then InvoiceDate else CreationTime end From InvoiceAbstract Where InvoiceID = @InvoiceID
		End
		Else
			Select @InvoiceID = InvoiceReference From InvoiceAbstract Where InvoiceID = @InvoiceID
	End

Return (@InvDate)
End
