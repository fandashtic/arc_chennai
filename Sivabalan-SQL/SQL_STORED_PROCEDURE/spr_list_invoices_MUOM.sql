CREATE procedure [dbo].[spr_list_invoices_MUOM]( @FROMDATE datetime,            
       @TODATE datetime,            
       @DocType nvarchar(100), @UOMDesc nVarchar(30))            
AS            
DECLARE @INV AS NVARCHAR(50)            
DECLARE @CASH AS NVARCHAR(50)
DECLARE @CREDIT AS NVARCHAR(50)            
DECLARE @CHEQUE AS NVARCHAR(50)
DECLARE @DD AS NVARCHAR(50)
SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)
SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)
SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'            
            
SELECT  InvoiceID,             
 "InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR),             
 "Doc Ref" = InvoiceAbstract.DocReference,            
 "Date" = InvoiceDate,             
 "Payment Mode" = case IsNull(PaymentMode,0)            
 When 0 Then @Credit            
 When 1 Then @Cash            
 When 2 Then @Cheque            
 When 3 Then @DD            
 Else @Credit            
 End,            
 "Payment Date" = PaymentDate,            
 "Credit Term" = CreditTerm.Description,            
 "CustomerID" = Customer.CustomerID,             
 "Customer" = Customer.Company_Name,            
 "Forum Code" = Customer.AlternateCode,            
 "Goods Value" = GoodsValue,             
 "Product Discount" = ProductDiscount,            
 "Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',             
 "Trade Discount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),            
 "Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',            
 "Addl Discount" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),            
 Freight, "Net Value" = NetValue,            
 "Net Volume" = Cast((      
     Case       
     When @UOMdesc = N'UOM1' then       
     (Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)) from Items, InvoiceDetail       
     Where Items.Product_Code = InvoiceDetail.Product_Code and       
     InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)      
     When @UOMdesc = N'UOM2' then       
     (Select Sum(dbo.sp_Get_ReportingQty(Quantity,Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)) from Items, InvoiceDetail       
     Where Items.Product_Code = InvoiceDetail.Product_Code and       
      InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)      
     Else      
     (Select Sum(Quantity) from Items, InvoiceDetail       
     Where Items.Product_Code = InvoiceDetail.Product_Code and       
     InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID)      
    End) as nVarchar),       
 "Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),            
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
 "Round Off" = RoundOffAmount,            
 "Document Type" = DocSerialType,            
 "Total TaxSuffered Value" =  TotalTaxSuffered,            
 "Total SalesTax Value" = TotalTaxApplicable            
FROM InvoiceAbstract, Customer, CreditTerm, ClientInformation, Beat, Salesman             
WHERE   InvoiceType in (1,3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND            
 InvoiceAbstract.CustomerID = Customer.CustomerID AND            
 InvoiceAbstract.CreditTerm *= CreditTerm.CreditID AND             
 InvoiceAbstract.ClientID *= ClientInformation.ClientID And            
 InvoiceAbstract.BeatID *= Beat.BeatID And            
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And             
 (InvoiceAbstract.Status & 128) = 0 And            
 InvoiceAbstract.DocSerialType like @DocType         
Order By  DocumentID
