CREATE Procedure sp_update_scheme_invoice_cancel( @InvoiceID nvarchar(255))

As

Delete SchemeSale Where InvoiceID = @InvoiceID 
and Pending = Free and Claimed = 0 

