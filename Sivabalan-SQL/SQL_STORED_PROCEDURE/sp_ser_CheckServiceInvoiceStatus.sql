CREATE Procedure sp_ser_CheckServiceInvoiceStatus(@InvoiceID as int)
as  
	
		Select "Status" = 'cancelled' from ServiceInvoiceAbstract where 
		ServiceInvoiceID = @InvoiceID and (isNull(Status,0) & 192) = 192
