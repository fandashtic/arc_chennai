CREATE procedure [dbo].[spr_list_Retail_Invoices_Amendment]( @FROMDATE datetime,      
              @TODATE datetime)      
AS   

Declare @OTHERS As NVarchar(50)
Declare @CREDIT As NVarchar(50)
Declare @CL As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)
Set @CL = dbo.LookupDictionaryItem(N'CL', Default)
 
SELECT  InvoiceID,     
"InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS NVARCHAR),     
"Date" = InvoiceDate,     
"Customer" = Customer.Company_Name,    
"Referred By" = Doctor.Name,    
"Gross Value" = GrossValue,     
"Discount" = DiscountValue,     
"Net Value" = NetValue,     
"Invoice Reference" = NewInvoiceReference,    
"Memo" = InvoiceAbstract.ShippingAddress,    
"Branch" = ClientInformation.Description,    
"Payment Mode" = Case PaymentMode When N'0' Then @CREDIT Else @OTHERS End,     
--Case When IsNull(PaymentDetails,'') = '' Then 'Cash' Else case Patindex('%;%',PaymentDetails)    
-- when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else 'Multiple' end end,    
"Payment Details" = Case When PaymentDetails = N'' Then N'' Else @CL + PaymentDetails End,    
--Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as varchar) + '::0' Else PaymentDetails End,    
"Amount Received" = dbo.Fn_AmountReceived(InvoiceAbstract.InvoiceID),
--dbo.GetAmountReceived(Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as varchar) + '::0' Else PaymentDetails End),    
"SalesStaff" = Isnull(Salesman.Salesman_name,'')    
FROM InvoiceAbstract, Customer, VoucherPrefix, ClientInformation, Doctor, Salesman      
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND      
 (InvoiceAbstract.Status & 128) = 0 And     
 Isnull(InvoiceReference,0) <> 0 AND    
 InvoiceAbstract.CustomerID *= Customer.CustomerID AND      
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND       
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND      
 InvoiceAbstract.ReferredBy *= Doctor.ID AND      
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
