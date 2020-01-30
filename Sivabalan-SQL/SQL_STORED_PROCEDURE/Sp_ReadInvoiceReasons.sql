Create Procedure Sp_ReadInvoiceReasons (@InvoiceID Int)  
As    
Begin
	Declare @ReasonID as Int
	Set @ReasonID = (Select (Case When Isnull(CancelReasonID,0) <> 0 Then  Isnull(CancelReasonID,0) Else Isnull(AmendReasonID,0) End) From InvoiceAbstract Where InvoiceID = @InvoiceID)
	Select Top 1 Isnull(Reason,'') Reason From InvoiceReasons Where ID = @ReasonID
End
