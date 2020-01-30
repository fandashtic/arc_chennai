CREATE function sp_acc_getdocumentid (@DocType Int,@DocID Int)
Returns nVarChar(50)
as
Begin
Declare @ReturnDescription nVarchar(50)
Declare @Status Int
Declare @BILLAMENDMENT Int
Set @BILLAMENDMENT = 9
If @DocType = @BILLAMENDMENT 
Begin
	Select @Status =  IsNull(Status,0)from BillAbstract
	Where BillID = @DocID
	If (@status & 128) <> 0
	Begin
		Set @ReturnDescription = dbo.LookupDictionaryItem('BILL',Default)
	End
	Else
	Begin
		Set @ReturnDescription = dbo.LookupDictionaryItem('BILL AMENDMENT',Default)
	End
End
Return @ReturnDescription
End




