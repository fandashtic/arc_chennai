CREATE PROCEDURE spr_list_invoices_by_customer(@CUSTOMER nvarchar(15),
						        @FROMDATE datetime,
		  				        @TODATE datetime)
AS
DECLARE @DISPATCH AS nvarchar(50)
DECLARE @PO AS nvarchar(50)
DECLARE @SO AS nvarchar(50)

DECLARE @INVOICE AS NVarchar(50)
DECLARE @INVOICEAMENDMENT AS NVarchar(50)
DECLARE @UNPAID AS NVarchar(50)
DECLARE @PAID AS NVarchar(50)
DECLARE @PARTIALLYPAID AS NVarchar(50)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice',Default)
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment',Default)
Set @UNPAID = dbo.LookupDictionaryItem(N'UnPaid',Default)
Set @PAID = dbo.LookupDictionaryItem(N'Paid',Default)
Set @PARTIALLYPAID = dbo.LookupDictionaryItem(N'Partially Paid',Default)

SELECT @DISPATCH = Prefix FROM VoucherPrefix WHERE TranID = 'DISPATCH'
SELECT @PO = Prefix FROM VoucherPrefix WHERE TranID = 'PURCHASE ORDER'
SELECT @SO = Prefix FROM VoucherPrefix WHERE TranID = 'SALE CONFIRMATION'

SELECT  InvoiceID, "InvoiceID" = Case IsNull(GSTFlag,0) when 0 then VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar)else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, 
	"Doc Reference"=DocReference,
	"Invoice Type" = case InvoiceAbstract.InvoiceType
	when 1 then
	@INVOICE
	when 3 then
	@INVOICEAMENDMENT
	end,
	"Date" = InvoiceDate, "Credit Term" = CreditTerm.Description, 
	"Gross Value" = GrossValue, "Discount" = DiscountValue, "Additional Discount" = 
CAST(AdditionalDiscount AS nvarchar) + '%',
	"Freight" = Freight, "Net Value" = NetValue, 
	"Reference" = 
	CASE Status & 7
	WHEN 1 THEN
	@DISPATCH
	WHEN 2 THEN
	@PO
	WHEN 4 THEN
	@SO
	END
	+ CAST(ReferenceNumber AS nvarchar),
	"Status" = Case 
	WHEN isnull(InvoiceAbstract.NetValue,0) + isnull(InvoiceAbstract.RoundOffAmount,0) - 
		 isnull(InvoiceAbstract.Balance,0) - isnull(InvoiceAbstract.AdjustedAmount,0) = 0 
		 THEN @UNPAID
	WHEN isnull(InvoiceAbstract.NetValue,0) + isnull(InvoiceAbstract.RoundOffAmount,0) - 
		 isnull(InvoiceAbstract.Balance,0) - isnull(InvoiceAbstract.AdjustedAmount,0) = isnull(InvoiceAbstract.NetValue,0)
		 THEN @PAID
	ELSE @PARTIALLYPAID
	END,
	"Total Weight" = 	
	(
		select sum(It.ConversionFactor * IDt.Quantity) from Items It, InvoiceDetail IDt
		where 
		IDt.InvoiceID = InvoiceAbstract.InvoiceID and
		IDt.Product_Code = It.Product_Code
	)
FROM InvoiceAbstract
Inner Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join CreditTerm on InvoiceAbstract.CreditTerm = CreditTerm.CreditID
Inner Join VoucherPrefix on VoucherPrefix.TranID = 'INVOICE'
WHERE   InvoiceType IN (1, 3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	--InvoiceAbstract.CustomerID = Customer.CustomerID AND
	--InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND 
	InvoiceAbstract.CustomerID = @CUSTOMER AND
	--VoucherPrefix.TranID = 'INVOICE' AND
	InvoiceAbstract.Status & 128 = 0
ORDER BY InvoiceAbstract.InvoiceDate


