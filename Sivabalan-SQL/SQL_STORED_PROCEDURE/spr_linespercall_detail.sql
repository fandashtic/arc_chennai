CREATE PROCEDURE spr_linespercall_detail(@SALESMANID INT,
					@FROMDATE DATETIME,
					@TODATE DATETIME)
AS
SELECT  InvoiceAbstract.invoicedate, 
	"Invoice Date" = InvoiceAbstract.invoicedate, 
	"Invoice ID" = case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then VoucherPrefix.Prefix + CAST(InvoiceAbstract.DocumentID AS nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') end, 
	"Doc Reference"=DocReference,
	"Net Value (%c)" = Sum(Amount), 
	"Lines Per Call" = Count(Distinct Product_Code)  
FROM InvoiceAbstract
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID
Inner Join VoucherPrefix On 	VoucherPrefix.TranID = 'INVOICE'
WHERE   InvoiceType in (1, 3)  AND
	(InvoiceAbstract.Status & 128) = 0 AND
	IsNull(InvoiceAbstract.SalesmanID, 0) = @SALESMANID AND
--	Salesman.SalesmanID *= @SALESMANID AND
	InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE
GROUP BY invoicedate, InvoiceAbstract.InvoiceID,InvoiceAbstract.DocReference,
	InvoiceAbstract.DocumentID, VoucherPrefix.Prefix,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
