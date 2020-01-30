Create Procedure mERP_sp_CheckDocRef(@DocType nVarchar(255), @DocRef nVarchar(255))
As
Begin
	If @DocType = '' 
		Select 0
		--Select Count(*) 
		--	From InvoiceAbstract 
		--	Where DocReference = @DocRef  And DocSerialType = N''
	Else
		Select Count(*) 
			From InvoiceAbstract 
			Where DocSerialType = @DocType
			And DocReference = @DocRef 	
End	
