CREATE procedure [dbo].[spr_list_Retail_Invoices_Amendment_MUOM_pidilite](	@FROMDATE datetime,  
       							@TODATE datetime, @UOMDesc nvarchar(30))  
AS  
SELECT  InvoiceID, 
"InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar), 
"Date" = InvoiceDate, 
"Doc Reference" = DocReference,
"Customer" = customer.company_name,
"Referred By" = Doctor.Name,
"Gross Value" = GrossValue, 
"Discount" = DiscountValue, 
"Net Value" = NetValue, 
"Invoice Reference" = NewInvoiceReference,
"Memo" = InvoiceAbstract.BillingAddress,
"Branch" = ClientInformation.Description,

"Payment Mode" = Case PaymentMode When N'0' Then N'Credit' Else N'Others' End, 

"Payment Details" = Case When PaymentDetails = N'' Then N'' Else N'CL' + PaymentDetails End,

"Amount Received" = IsNull((Select Value From Collections Where DocumentID =  PaymentDetails), 0),

-- "Payment Mode" = Case When IsNull(paymentmode, 0) = 0 Then 'Cash' Else case Patindex('%;%',PaymentDetails)
-- 	when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else 'Multiple' end end,
--"Payment Details" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End,
--"Amount Received" = dbo.GetAmountReceived(Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End),
"SalesStaff" = SalesStaff.Staff_Name
FROM InvoiceAbstract, customer, VoucherPrefix, ClientInformation, Doctor, SalesStaff  
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 (InvoiceAbstract.Status & 128) = 0 And 
 Isnull(InvoiceReference,0) <> 0 AND
 InvoiceAbstract.CustomerID *= customer.CustomerID AND  
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND   
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND  
 InvoiceAbstract.ReferredBy *= Doctor.ID AND  
 InvoiceAbstract.SalesmanID *= SalesStaff.Staff_ID
