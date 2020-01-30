CREATE procedure [dbo].[spr_list_cancelled_invoices_MUOM_pidilite](@FROMDATE datetime,
		 			     @TODATE datetime, @UOMDesc nvarchar(30))
AS
DECLARE @INV AS nvarchar(50)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'

SELECT  InvoiceID, 
	"InvoiceID" = @INV
	+ CAST(DocumentID AS nvarchar), "Date" = InvoiceDate, 
	"Payment Date" = PaymentDate,
	"Credit Term" = CreditTerm.Description, 
	"Doc Reference" = DocReference,
	"CustomerID" = InvoiceAbstract.CustomerID,
	"Customer Name" = Customer.Company_Name,
	"Gross Value" = GrossValue, 
	"Trade Discount%" = CAST(DiscountPercentage AS nvarchar) + N'%', 
	"Trade Discount(Rs.)" = GrossValue * (DiscountPercentage /100),
	"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',
	"Addl Discount(Rs.)" = GrossValue * (AdditionalDiscount / 100),
	Freight, "Net Value" = NetValue, 
	"Reference" = 
	CASE Status & 15
	WHEN 1 THEN
	N''
	WHEN 2 THEN
	N''
	WHEN 4 THEN
	N''
	WHEN 8 THEN
	N''
	END
	+ CAST(NewReference AS nvarchar), 
	"Status" = Case 
	WHEN (Status & 64) <> 0 THEN N'Cancelled'
	WHEN (Status & 128) <> 0 Then N'Amended'
	ELSE N''
	END,
	"Balance" = InvoiceAbstract.Balance,
	"Branch" = ClientInformation.Description,
	"Beat" = Beat.Description,
	"Salesman" = Salesman.Salesman_Name,
	"Adj Ref" = dbo.GetAdjustments(Cast(InvoiceAbstract.PaymentDetails As Int), InvoiceAbstract.InvoiceID),
	"Adjusted Amount" = (Select Sum(AdjustedAmount) From CollectionDetail
	Where CollectionID = Cast(PaymentDetails As Int) And 
	DocumentID <> InvoiceAbstract.InvoiceID)
FROM InvoiceAbstract, Customer, CreditTerm, ClientInformation, Beat, Salesman
WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	InvoiceAbstract.CustomerID = Customer.CustomerID AND
	InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND 
	InvoiceAbstract.ClientID *= ClientInformation.ClientID And
	InvoiceAbstract.BeatID *= Beat.BeatID And
	InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And 
	(InvoiceAbstract.Status & 64) = 64

Union

SELECT  InvoiceID, 
	"InvoiceID" = @INV
	+ CAST(DocumentID AS nvarchar), "Date" = InvoiceDate, 
	"Payment Date" = PaymentDate,
	"Credit Term" = Null, 
	"Doc Reference" = DocReference,
	"CustomerID" = InvoiceAbstract.CustomerID,
	"Customer Name" = Cash_Customer.CustomerName,
	"Gross Value" = GrossValue, 
	"Trade Discount%" = CAST(DiscountPercentage AS nvarchar) + N'%', 
	"Trade Discount(Rs.)" = GrossValue * (DiscountPercentage /100),
	"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',
	"Addl Discount(Rs.)" = GrossValue * (AdditionalDiscount / 100),
	Freight, "Net Value" = NetValue, 
	"Reference" = CAST(NewReference AS nvarchar), 
	"Status" = Case 
	WHEN (Status & 64) <> 0 THEN N'Cancelled'
	WHEN (Status & 128) <> 0 Then N'Amended'
	ELSE N''
	END,
	"Balance" = InvoiceAbstract.Balance,
	"Branch" = ClientInformation.Description,
	"Beat" = Null,
	"Salesman" = Null,
	"Adj Ref" = Null,
	"Adjusted Amount" = Null
FROM InvoiceAbstract, Cash_Customer, ClientInformation
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	InvoiceAbstract.CustomerID *= Cash_Customer.CustomerID AND
	InvoiceAbstract.ClientID *= ClientInformation.ClientID And
	(InvoiceAbstract.Status & 64) = 64
Order By InvoiceID
