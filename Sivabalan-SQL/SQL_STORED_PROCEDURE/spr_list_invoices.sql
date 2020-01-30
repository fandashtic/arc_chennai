CREATE procedure [dbo].[spr_list_invoices]( @FROMDATE datetime,  
       @TODATE datetime,  
       @DocType nvarchar(100))  
AS  
DECLARE @INV AS NVARCHAR(50)  

Declare @CREDIT As NVarchar(50)
Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
set @CREDIT = dbo.LookupDictionaryItem(N'Credit',Default)
Set @CASH = dbo.LookupDictionaryItem(N'Cash',Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque',Default)
Set @DD = dbo.LookupDictionaryItem(N'DD',Default)
  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'  
  
SELECT  InvoiceID,   
 "InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR),   
 "Doc Ref" = InvoiceAbstract.DocReference,  
 "Date" = InvoiceDate,   
 "Payment Mode" = case IsNull(PaymentMode,0)  
 When 0 Then @CREDIT  
 When 1 Then @CASH 
 When 2 Then @CHEQUE 
 When 3 Then @DD
 Else @CREDIT  
 End,  
 "Payment Date" = PaymentDate,  
 "Credit Term" = CreditTerm.Description,  
 "CustomerID" = Customer.CustomerID,   
 "Customer" = Customer.Company_Name,  
 "Forum Code" = Customer.AlternateCode,  
 "Goods Value" = GoodsValue,   
 "Product Discount (%c.)" = ProductDiscount,  
 "Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + '%',   
 "Trade Discount(%c.)" = DiscountValue,
 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + '%',  
 "Addl Discount(%c.)" = AddlDiscountValue,
 Freight, "Net Value" = NetValue,   
 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, ''),  
 "Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),  
 "Balance" = InvoiceAbstract.Balance,  
 "Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),  
 "Branch" = ClientInformation.Description,  
 "Beat" = Beat.Description,  
 "Salesman" = Salesman.Salesman_Name,  
 "Reference" =   
 CASE Status & 15  
 WHEN 1 THEN  
 ''  
 WHEN 2 THEN  
 ''  
 WHEN 4 THEN  
 ''  
 WHEN 8 THEN  
 ''  
 END  
 + CAST(NewReference AS nVARCHAR),  
 "Round Off (%c)" = RoundOffAmount,  
 "Document Type" = DocSerialType,  
 "Total TaxSuffered Value (%c)" =  TotalTaxSuffered,  
 "Total SalesTax Value (%c)" = TotalTaxApplicable  
FROM InvoiceAbstract, Customer, CreditTerm, ClientInformation, Beat, Salesman   
WHERE   InvoiceType in (1,3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
 InvoiceAbstract.BeatID *= Beat.BeatID And  
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And   
 (InvoiceAbstract.Status & 128) = 0 And  
 InvoiceAbstract.DocSerialType like @DocType  
Order By DocumentID
