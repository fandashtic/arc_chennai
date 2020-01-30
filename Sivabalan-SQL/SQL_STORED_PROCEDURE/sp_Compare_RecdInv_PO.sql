CREATE Procedure sp_Compare_RecdInv_PO (@InvoiceID Int,
					@POID nvarchar(255))
As

If Exists(Select Product_Code From InvoiceDetailReceived Where InvoiceID = @InvoiceID And
Product_Code Not In (Select Product_Code From PODetail Where PONumber In (Select * From dbo.GetDocumentNumber(@POID))))
Begin
	Select 1
End
Else
Begin
	If Exists(Select Product_Code From PODetail Where PONumber In (Select * From dbo.GetDocumentNumber(@POID)) And
	Product_Code Not In (Select Product_Code From InvoiceDetailReceived 
	Where InvoiceID = @InvoiceID))
	Begin
		Select 1
	End
	Else
	Begin
		Select Count(PODetail.Product_Code)
		From InvoiceDetailReceived, PODetail
		Where 	InvoiceDetailReceived.InvoiceID = @InvoiceID And
			PODetail.PONumber In (Select * From  dbo.GetDocumentNumber(@POID)) And
			InvoiceDetailReceived.Product_Code = PODetail.Product_Code
		Group By InvoiceDetailReceived.Product_Code, PODetail.Product_Code
		Having Sum(PODetail.Quantity)-Sum(InvoiceDetailReceived.Quantity) <> 0
	End
End
