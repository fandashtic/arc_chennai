CREATE FUNCTION GetInvoiceGrossValueFromSC(@SONumber INT, @ProductCode nvarchar(100))
RETURNS decimal(18,6)
As
BEGIN
DECLARE @DispatchPrefix nvarchar(100)
DECLARE @SCPrefix nvarchar(100)
DECLARE @DispatchCount INT
DECLARE @DispatchID INT
DECLARE @SCCount INT
DECLARE @GrossValue decimal(18,6)
SET @SCPrefix = dbo.GetVoucherPrefix('SALE CONFIRMATION') + CAST(@SONumber As nvarchar)


SELECT @DispatchID = DocumentID FROM DispatchAbstract WHERE NewRefNumber = @SCPrefix
AND (Status & 64) = 0 

IF @DispatchID > 0 
BEGIN
	SET @DispatchPrefix = dbo.GetVoucherPrefix('DISPATCH') + CAST(@DispatchID As nvarchar)
	SELECT @GrossValue = (InvoiceDetail.Quantity * InvoiceDetail.SalePrice) FROM InvoiceAbstract, InvoiceDetail
	WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And 
	InvoiceDetail.Product_Code = @ProductCode And
	InvoiceAbstract.NewReference = @DispatchPrefix And (InvoiceAbstract.Status & 128) = 0
END
ELSE
BEGIN
	SELECT @GrossValue = (InvoiceDetail.Quantity * InvoiceDetail.SalePrice) FROM InvoiceAbstract, InvoiceDetail
	WHERE InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And 
	InvoiceDetail.Product_Code = @ProductCode And
	InvoiceAbstract.NewReference = @SCPrefix And (InvoiceAbstract.Status & 128) = 0
END

RETURN(@GrossValue)
END




