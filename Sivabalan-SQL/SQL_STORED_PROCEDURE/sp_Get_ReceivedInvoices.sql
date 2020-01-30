Create Procedure sp_Get_ReceivedInvoices (@Vendor nvarchar(20), @ShowAll as int = 1)
As

Select IAR.InvoiceID, IAR.DocumentID + ' - ' + Convert(nvarchar, IAR.InvoiceDate, 103)
From InvoiceAbstractReceived IAR
Where IAR.VendorID = @Vendor And IAR.Status & 1 = 0 and 
((Isnull((Select Count(*) From InvoiceAbstractReceived IAR1 Where 
		IAR1.InvoiceID < IAR.InvoiceID and
		IAR1.DocumentID = IAR.DocumentID),0) = 0
and isnull((Select Count(*) from GrnAbstract, InvoiceAbstractReceived IAR1 Where 
GrnAbstract.RecdInvoiceID = IAR1.InvoiceID and
IAR1.DocumentID = IAR.DocumentId and GrnAbstract.GrnStatus & 224 = 0),0) = 0 and
Isnull((Select Count(*) from BillAbstract Where InvoiceReference = IAR.DocumentID),0) = 0) or @ShowAll = 1)




