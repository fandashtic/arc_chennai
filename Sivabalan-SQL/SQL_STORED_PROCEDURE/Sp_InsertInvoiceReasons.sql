Create Procedure Sp_InsertInvoiceReasons (@Type Nvarchar(255),@Reason Nvarchar(255),@Active Int)  
As    
Begin
	If Not Exists(Select 'x' From InvoiceReasons Where [Type] = @Type And Reason = @Reason)
	Begin
		Insert Into InvoiceReasons ([Type],Reason,Active,CreationDate,ModifiedDate)
		Select @Type,@Reason,@Active,Getdate(),Null
	End
	Else
	Begin
		Update InvoiceReasons Set Active = @Active,ModifiedDate = Getdate() Where [Type] = @Type And Reason = @Reason
	End
End
