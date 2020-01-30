CREATE procedure [dbo].[spr_invoices_up_Bunge](@FROMDATE datetime,  
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
  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  

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
 "Goods Value" = Case InvoiceType When 4 Then (0 - GoodsValue) Else GoodsValue End,   
 "Product Discount (%c.)" = Case InvoiceType When 4 Then (0 - ProductDiscount) Else ProductDiscount End,  
 "Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + '%',   
 "Trade Discount(%c.)" = Case InvoiceType When 4 Then (0 - DiscountValue) Else DiscountValue End,
 "Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + '%',  
 "Addl Discount(%c.)" = Case InvoiceType When 4 Then (0 - AddlDiscountValue) Else AddlDiscountValue End,
 "Freight" =  Case InvoiceType When 4 Then (0 - Freight) Else Freight End, 
	"Net Value" = Case InvoiceType When 4 Then (0 - NetValue) Else NetValue End,   
 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, ''),  
 "Adjusted Amount" = Case InvoiceType When 4 Then (0 - IsNull(InvoiceAbstract.AdjustedAmount, 0)) Else
													IsNull(InvoiceAbstract.AdjustedAmount, 0) End,  
 "Balance" = Case InvoiceType When 4 Then (0 - InvoiceAbstract.Balance) Else InvoiceAbstract.Balance End,  
 "Collected Amount" = Case InvoiceType When 4 Then (0 - (NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0)))
													 Else	(NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0)) End,  
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
 "Round Off (%c)" = Case InvoiceType When 4 Then (0 - RoundOffAmount) Else RoundOffAmount End,  
 "Document Type" = DocSerialType,  
 "Total TaxSuffered Value (%c)" = Case InvoiceType When 4 Then (0 - TotalTaxSuffered) Else TotalTaxSuffered End,  
 "Total SalesTax Value (%c)" = 		Case InvoiceType When 4 Then (0 - TotalTaxApplicable) Else TotalTaxApplicable End,
 "City" = IsNull((Select CityName From City Where CityID = Customer.CityID), '')
FROM InvoiceAbstract, Customer, CreditTerm, ClientInformation, Beat, Salesman   
WHERE   InvoiceType in (1,3,4) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND   
 InvoiceAbstract.ClientID *= ClientInformation.ClientID And  
 InvoiceAbstract.BeatID *= Beat.BeatID And  
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And   
 (InvoiceAbstract.Status & 128) = 0 And  
 InvoiceAbstract.DocSerialType like @DocType  
Order By DocumentID
