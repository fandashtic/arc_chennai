CREATE Procedure SP_Get_GRNInvoice (@GRNID Int)
As
Select InvoiceAbstractReceived.DocumentID + ' - ' 
+ Cast(InvoiceAbstractReceived.InvoiceDate As nvarchar), 
InvoiceAbstractReceived.InvoiceID
From InvoiceAbstractReceived, GRNAbstract
Where InvoiceAbstractReceived.InvoiceID = GRNAbstract.RecdInvoiceID
And GRNAbstract.GRNID = @GRNID
