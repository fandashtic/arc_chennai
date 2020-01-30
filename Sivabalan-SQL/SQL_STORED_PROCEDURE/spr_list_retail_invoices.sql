CREATE procedure [dbo].[spr_list_retail_invoices](@FROMDATE datetime,  
       @TODATE datetime)  
AS  

Declare @AMENDED As NVarchar(50)
Declare @CREDIT As NVarchar(50)
Declare @OTHERS As NVarchar(50)

Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)


SELECT  InvoiceID, 
	"InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS NVARCHAR), 
	"Date" = InvoiceDate, "Customer" = Customer.Company_Name,
	"Referred By" = Doctor.Name,
	"Gross Value" = GrossValue, "Discount" = DiscountValue, 
	"Net Value" = NetValue, "Status" = case Status & 128
	WHEN 0 THEN N''
	ELSE @AMENDED
	END,
	"Invoice Reference" = NewInvoiceReference,
	"Memo" = InvoiceAbstract.ShippingAddress, --Memo field for Retail Invoices
	"Branch" = ClientInformation.Description,
	"Payment Mode" = Case PaymentMode When N'0' Then @CREDIT Else @OTHERS End,
	"Payment Details" = dbo.fn_RetailPaymentDetailproc(InvoiceID,1),
	--Case When PaymentDetails = '' Then '' Else 'CL' + PaymentDetails End,
	"Amount Received" = dbo.fn_RetailPaymentDetailproc(InvoiceID,3),
	--IsNull((Select Value From Collections Where DocumentID = PaymentDetails), 0),
	"SalesStaff" = Salesman.Salesman_Name
FROM InvoiceAbstract, Customer, VoucherPrefix, ClientInformation, Doctor, Salesman
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 (InvoiceAbstract.Status & 128) = 0 And  
 InvoiceAbstract.CustomerID *= Customer.CustomerID AND  
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND   
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND  
 InvoiceAbstract.ReferredBy *= Doctor.ID AND  
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
