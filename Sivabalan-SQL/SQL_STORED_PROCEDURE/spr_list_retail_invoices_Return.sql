CREATE procedure [dbo].[spr_list_retail_invoices_Return](@FROMDATE datetime,            
       @TODATE datetime)            
AS

Declare @CREDIT As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @SALABLE As NVarchar(50)
Declare @DAMAGES As NVarchar(50)

Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @SALABLE = dbo.LookupDictionaryItem(N'Salable', Default)
Set @DAMAGES = dbo.LookupDictionaryItem(N'Damages', Default)
            
SELECT  InvoiceID,           
 "InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),           
 "Date" = InvoiceDate, "Customer" = Customer.Company_Name,          
 "Referred By" = Doctor.Name,"Return Type"= case InvoiceType when 5 then @SALABLE          
 WHEN 6 THEN @DAMAGES end,          
 "Gross Value" = GrossValue, "Discount" = DiscountValue,    
  "Net Value" = NetValue, "Status" = case Status & 128          
 WHEN 0 THEN N''          
 ELSE @CANCELLED  
 END,          
 "Invoice Reference" = NewInvoiceReference,          
 "Memo" = InvoiceAbstract.ShippingAddress, --Memo field for Retail Invoices          
 "Branch" = ClientInformation.Description,          
 "Payment Mode" = @CREDIT, "Payment Details" = @CREDIT +':'+ cast(NetValue as nvarchar),          
 "Amount Received" = 0.00,          
 "SalesStaff" = SalesMan.SalesMan_Name          
FROM InvoiceAbstract, Customer, VoucherPrefix, ClientInformation, Doctor, SalesMan            
WHERE InvoiceType in(5,6) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND            
 --(InvoiceAbstract.Status & 128) = 0 And          
 InvoiceAbstract.CustomerID *= Customer.CustomerID AND          
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND             
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND            
 InvoiceAbstract.ReferredBy *= Doctor.ID AND            
 InvoiceAbstract.SalesmanID *= SalesMan.SalesManID
