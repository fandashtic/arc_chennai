
CREATE PROCEDURE sp_count_open_invoices(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT Count(*) FROM InvoiceAbstract
WHERE InvoiceDate BETWEEN @START_DATE AND @END_DATE

