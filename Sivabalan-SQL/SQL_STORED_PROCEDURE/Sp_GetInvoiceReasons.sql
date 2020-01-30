Create Procedure Sp_GetInvoiceReasons (@Type Nvarchar(255))  
As    
Begin
	Select Distinct ID,Reason From InvoiceReasons Where isnull(Active,0) = 1 And [Type] = @Type
End
