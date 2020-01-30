CREATE PROCEDURE mERPFYCP_ResetStatus_InvoiceAbstractReceived ( @yearenddate datetime ) as
update InvoiceAbstractReceived set Status = Status | 128 where status = 0 and invoicedate <= @yearenddate 
