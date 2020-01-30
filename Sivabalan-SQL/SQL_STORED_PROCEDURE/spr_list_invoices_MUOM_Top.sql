CREATE PROCEDURE [dbo].[spr_list_invoices_MUOM_Top]( @FROMDATE datetime,                        @TODATE datetime,                        @DocType nvarchar(100),     @Term Nvarchar(255) = '%')                                  AS                 Begin DECLARE @INV AS NVARCHAR(50)                 DECLARE @CASH AS NVARCHAR(50)     DECLARE @CREDIT AS NVARCHAR(50)                 DECLARE @CHEQUE AS NVARCHAR(50)     DECLARE @DD AS NVARCHAR(50)     SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)     SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)       SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)     SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)     SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'                 Declare @Payid as Int Create Table #Term(PaymentId Int) Truncate Table #Term   if @term = 'Credit'  Begin   Truncate Table #Term   Insert Into #Term Select 0  End  Else if @term  = 'Cash'  Begin   Truncate Table #Term   Insert Into #Term Select 1  End  Else if @term  = 'Cheque'   Begin   Truncate Table #Term   Insert Into #Term Select 2  End  Else if @term  = 'DD'   Begin   Truncate Table #Term   Insert Into #Term Select 3  End Else IF @term = '%'  Begin   Truncate Table #Term   Insert Into #Term Select 0   Insert Into #Term Select 1   Insert Into #Term Select 2   Insert Into #Term Select 3  End  SELECT  InvoiceID,                   "InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR),      "Date" = InvoiceDate,            "CustomerID" = Customer.CustomerID,                   "Customer" = Customer.Company_Name,                  "Goods Value" = GoodsValue,                   "Product Discount" = ProductDiscount,       "Total SalesTax Value" = TotalTaxApplicable,          
--"Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',                   
"Trade Discount" = Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),                  
--"Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',                  
"Addl Discount" = InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100),                  Freight,    "Net Value" = NetValue,     "Round Off" = RoundOffAmount,                  
--"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),                  
"Adjusted Amount" = IsNull(InvoiceAbstract.AdjustedAmount, 0),                  
"Balance" = InvoiceAbstract.Balance,                  
"Collected Amount" = NetValue - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0),
                  "Beat" = Beat.Description, 
                 "Salesman" = Salesman.Salesman_Name, 
   "Document Type" = DocSerialType, 
                     "Doc Ref" = InvoiceAbstract.DocReference, 
                  "Payment Mode" = case IsNull(PaymentMode,0)  
                When 0 Then @Credit                
  When 1 Then @Cash                  When 2 Then @Cheque   
       When 3 Then @DD                  Else @Credit         
         End        FROM InvoiceAbstract, Customer, 
Beat, Salesman                 
 WHERE  InvoiceType in (1,3)
 AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND
                  InvoiceAbstract.CustomerID = Customer.CustomerID AND   
               InvoiceAbstract.BeatID *= Beat.BeatID And               
   InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And              
     (InvoiceAbstract.Status & 128) = 0 And              
    InvoiceAbstract.DocSerialType like @DocType         
     and paymentMode  in (select Distinct PaymentId from #Term) 
Order By  DocumentID        Drop Table #Term  END
