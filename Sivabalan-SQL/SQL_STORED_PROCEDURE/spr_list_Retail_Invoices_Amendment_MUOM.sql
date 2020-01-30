CREATE PROCEDURE spr_list_Retail_Invoices_Amendment_MUOM( @FROMDATE datetime,    
              @TODATE datetime, @UOMDesc nvarchar(30))    
AS    
  
Declare @OTHERS As NVarchar(50)  
Declare @CREDIT As NVarchar(50)  
Declare @CL As NVarchar(50)  
  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)  
Set @CL = dbo.LookupDictionaryItem(N'CL', Default)  
  
SELECT  InvoiceID,   
"InvoiceID" = case ISNULL(GSTFlag,0) when 0 then  VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar) Else ISNULL(GSTFullDocID,'') End,   
"Date" = InvoiceDate,   
"Customer" = Customer.Company_Name,  
--"Customer" = Cash_Customer.CustomerName,
"Referred By" = Doctor.Name,  
"Gross Value" = GrossValue,   
"Discount" = DiscountValue,   
"Net Value" = NetValue,   
"Invoice Reference" = NewInvoiceReference,  
"Memo" = InvoiceAbstract.ShippingAddress,  
"Branch" = ClientInformation.Description,  
  
"Payment Mode" = Case PaymentMode When N'0' Then @CREDIT Else @OTHERS End,   
  
"Payment Details" = Case When PaymentDetails = N'' Then N'' Else @CL + PaymentDetails End,  
  
"Amount Received" = IsNull((Select Value From Collections Where DocumentID = PaymentDetails and (Isnull(Status,0) & 192) = 0), 0),  
  
-- "Payment Mode" = Case When IsNull(paymentmode, 0) = 0 Then 'Cash' Else case Patindex('%;%',PaymentDetails)  
--  when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else 'Multiple' end end,  
--"Payment Details" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End,  
--"Amount Received" = dbo.GetAmountReceived(Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End),  
"SalesStaff" = Salesman.Salesman_Name  
--SalesStaff.Staff_Name    

FROM InvoiceAbstract
Left Outer Join Customer On  InvoiceAbstract.CustomerID = Customer.CustomerID
Inner Join VoucherPrefix On VoucherPrefix.TranID = N'RETAIL INVOICE' 
Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID 
Left Outer Join Doctor On InvoiceAbstract.ReferredBy = Doctor.ID
Left Outer Join  Salesman  On  InvoiceAbstract.SalesmanID = Salesman.SalesmanID    
--Cash_Customer
--SalesStaff
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND    
 (InvoiceAbstract.Status & 128) = 0 And   
 Isnull(InvoiceReference,0) <> 0 
--Cash_Customer.CustomerID 
--SalesStaff.Staff_ID      
