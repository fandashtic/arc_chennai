Create Function fn_ListDocType(@InvType nVarchar(50))
Returns @TransactionType Table(DocType Int)
As
Begin
	If @InvType = N'%' or @InvType = N'%%' or @InvType = N'All Invoices'
	Begin
		Insert Into @TransactionType Select 1
		Insert Into @TransactionType Select 3
	End
	Else If @InvType = N'Sales Invoices'
	Begin
		Insert Into @TransactionType Select 1
	End
	Else
		Insert Into @TransactionType Select 3
Return
End
