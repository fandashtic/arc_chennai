CREATE PROCEDURE spr_list_retail_invoices_MUOM(@FROMDATE datetime,        
       @TODATE datetime, @UOMDesc nVarchar(30))        
AS        
    
Declare @OTHERS As NVarchar(50)    
Declare @CREDIT As NVarchar(50)    
Declare @AMENDED As NVarchar(50)    
Declare @CANCELLED As NVarchar(50)    
Declare @OPEN As NVarchar(50)    
Declare @CASH As NVarchar(50)    
Declare @CL As NVarchar(50)    
    
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)    
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)    
Set @AMENDED = dbo.LookupDictionaryItem(N'Amendment', Default)    
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)    
Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)    
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)    
Set @CL = dbo.LookupDictionaryItem(N'CL', Default)    
    
SELECT  InvoiceID,       
 "InvoiceID" =  Case ISNULL(GSTFlag,0) when 0 then  VoucherPrefix.Prefix + CAST(DocumentID AS NVARCHAR) else ISNULL(GSTFullDocID,'') end,       
 "Date" = InvoiceDate, "Customer" = Customer.Company_Name,      
 "Referred By" = Doctor.Name,      
 "Gross Value" = GrossValue, "Discount" = DiscountValue,       
 "Net Value" = NetValue,     
 "Status" = Case IsNull(Invoicereference,0)  
 WHEN 0 Then ''  
 ELSE @AMENDED    
 END,    
 "Original Invoice Reference" = NewInvoiceReference,      
 "Memo" = InvoiceAbstract.ShippingAddress, --Memo field for Retail Invoices      
 "Branch" = ClientInformation.Description,      
    
"Payment Mode" = Case PaymentMode When N'0' Then @CREDIT Else @OTHERS End,     
"Payment Details" = Case When PaymentDetails = N'' Then N'' Else @CL + PaymentDetails  End,    
"Amount Received" = dbo.fn_RetailPaymentDetailproc(InvoiceID,3),      
-- Case When ( SubString(paymentdetails,1,1) not like N'%[0-9]' )  then     
-- dbo.GetAmountReceived(Case When IsNull(PaymentDetails,N'') = N'' Then @CASH + ':' + cast(NetValue as nvarchar) + N'::0' Else PaymentDetails End)    
-- Else     
-- IsNull((Select Value From Collections Where DocumentID =  PaymentDetails), 0) End ,    
    
--  "Payment Mode" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash' Else case Patindex('%;%',PaymentDetails)      
--   when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else 'Multiple' end end,      
--  "Payment Details" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End,      
--  "Amount Received" = dbo.GetAmountReceived(Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End),      
 "SalesStaff" = Salesman.Salesman_Name    
--SalesStaff.Staff_Name      
FROM InvoiceAbstract
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Inner Join VoucherPrefix On VoucherPrefix.TranID = N'RETAIL INVOICE' 
Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID 
Left Outer Join Doctor On InvoiceAbstract.ReferredBy = Doctor.ID 
Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID         
--SalesStaff        
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND        
 (InvoiceAbstract.Status & 128) = 0 
 
--SalesStaff.Staff_ID 
