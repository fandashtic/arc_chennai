Create Procedure mERP_sp_OrigSODate(@InvoiceID Int)
As
	Declare @SONumber as Int

	Select @SONumber = isNull(SONumber,0) From InvoiceAbstract Where InvoiceID = 
	(Select Min(InvoiceID) From InvoiceAbstract Where DocumentID = (Select DocumentID From InvoiceAbstract Where InvoiceID = @InvoiceID) And InvoiceType = 1 )
	
	If @SONumber > 0
	Begin
		Select 1, SODate From SOAbstract Where SONumber = @SONumber
	End
	Else
		Select 0,''
	
