
CREATE FUNCTION GetTotalFreeIssues(@ITEMCODE nvarchar(15), @FROMDATE datetime, @TODATE datetime)
RETURNS decimal(18,6)
AS
BEGIN
	RETURN ISNULL((SELECT SUM(Quantity) 
	FROM InvoiceDetail, InvoiceAbstract 
	WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	AND (InvoiceAbstract.InvoiceType = 2) 
	AND (InvoiceAbstract.Status & 128) = 0 
	AND InvoiceDetail.Product_Code = @ITEMCODE
	AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
	And InvoiceDetail.SalePrice = 0), 0) 
	+ ISNULL((SELECT SUM(Quantity) 
	FROM DispatchDetail, DispatchAbstract 
	WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID 
	AND (DispatchAbstract.Status & 64) = 0 
	AND DispatchDetail.Product_Code = @ITEMCODE
	AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE
	And DispatchDetail.SalePrice = 0), 0)
END

