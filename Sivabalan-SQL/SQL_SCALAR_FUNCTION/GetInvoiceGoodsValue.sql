CREATE FUNCTION GetInvoiceGoodsValue(@InvoiceID int)
RETURNS Decimal(18, 6)
AS
BEGIN
	return (Select Sum(SalePrice * Quantity) From InvoiceDetail Where InvoiceID = @InvoiceID)
END


