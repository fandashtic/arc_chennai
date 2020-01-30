CREATE PROCEDURE mERPFYCP_get_countRecInv ( @yearenddate datetime )
AS
SELECT count(*) FROM InvoiceAbstractReceived WHERE Status = 0 and invoicedate <= @yearenddate 
