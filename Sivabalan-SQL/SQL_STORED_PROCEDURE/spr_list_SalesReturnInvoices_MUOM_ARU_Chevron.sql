CREATE procedure [dbo].[spr_list_SalesReturnInvoices_MUOM_ARU_Chevron](@FROMDATE datetime,
				              @TODATE datetime, @UOMDesc nvarchar(30))
AS

Declare @SALEABLE As NVarchar(50)
Declare @DAMAGES As NVarchar(50)
Declare @CANCELLED As NVarchar(50)

Set @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)
Set @DAMAGES = dbo.LookupDictionaryItem(N'Damages', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)

SELECT  InvoiceID, 
	"InvoiceID" = SRPrefix.Prefix + CAST(DocumentID AS nvarchar), 
	"Doc Reference"=DocReference,
	"Date" = InvoiceDate, 
	"Customer" = Customer.Company_Name,
	"Goods Value" = GoodsValue,
	"Product Discount" = ProductDiscount,
	"Discount%" = DiscountPercentage,
	"Discount" = DiscountValue, 
	"Addn. Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',
	"Addn. Discount" = AddlDiscountValue,
	"Tax Suffered" = TotalTaxSuffered,
	"Tax Applicable" = TotalTaxApplicable,
	"Freight" = Freight, 
	"Net Value" = Case Status & 128
	When 0 Then Cast(NetValue As nvarchar) Else N'' End, 
	"(Can)Net Value" = Case Status & 128
	When 0 Then N'' Else Cast(NetValue As nvarchar) End,
	"Adjusted Reference" = dbo.GetSalesReturnReference(InvoiceID),
	"Reference" = NewReference, 
	"Branch" = ClientInformation.Description,
	"Balance" = Balance,
	"Type" = case When (Status & 32) <> 0 Then @DAMAGES Else @SALEABLE End,
	"Status" = Case Status & 128 When 0 Then N'' Else @CANCELLED End,
	"Salesman" = SM.Salesman_Name
FROM 	InvoiceAbstract, Customer, VoucherPrefix SRPrefix, VoucherPrefix RefPrefix, 
	ClientInformation, Salesman SM
WHERE   InvoiceType = 4 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
--	(InvoiceAbstract.Status & 128) = 0 And
	InvoiceAbstract.CustomerID = Customer.CustomerID AND
	SRPrefix.TranID = N'SALES RETURN' AND
	RefPrefix.TranID = N'INVOICE' AND
	InvoiceAbstract.ClientID *= ClientInformation.ClientID and 
	InvoiceAbstract.SalesmanID *= SM.SalesmanID
