CREATE procedure [dbo].[sp_print_InvAbstract_Template](@INVNO INT)          
AS          
DECLARE @TotalTax Decimal(18,6)          
Declare @TotalQty Decimal(18,6)          
Declare @FirstSales Decimal(18, 6)          
Declare @SecondSales Decimal(18, 6)          
Declare @Savings Decimal(18,6)          
Declare @GoodsValue Decimal(18,6)          
Declare @ProductDiscountValue Decimal(18,6)          
Declare @AvgProductDiscountPercentage Decimal(18,6)          
Declare @TaxApplicable Decimal(18,6)          
Declare @TaxSuffered Decimal(18,6)          
Declare @ItemCount int  
Declare @ItemCountWithoutFree int         
Declare @AdjustedValue Decimal(18, 6)  
Declare @SalesTaxwithcess Decimal(18, 6)        
Declare @salestaxwithoutCESS Decimal(18, 6)            
Declare @DispRef nvarchar(50)    
Declare @SCRef nvarchar(50)    
Declare @SCID nvarchar(50)    
Declare @bRefSC Int    
Declare @TotTaxableSaleVal Decimal(18, 6)    
Declare @TotNonTaxableSaleVal Decimal(18, 6)    
Declare @TotTaxableGV Decimal(18, 6)    
Declare @TotNonTaxableGV Decimal(18, 6)    
Declare @TotTaxSuffSaleVal Decimal(18, 6)    
Declare @TotNonTaxSuffSaleVal Decimal(18, 6)    
Declare @TotTaxSuffGV Decimal(18, 6)    
Declare @TotNonTaxSuffGV Decimal(18, 6)    
Declare @TotFirstSaleGV Decimal(18, 6)    
Declare @TotSecondSaleGV Decimal(18, 6)    
Declare @TotFirstSaleValue Decimal(18, 6)    
Declare @TotSecondSaleValue Decimal(18, 6)    
Declare @TotFirstSaleTaxApplicable Decimal(18, 6)    
Declare @TotSecondSaleTaxApplicable Decimal(18, 6)    
Declare @AddnDiscount Decimal(18, 6)    
Declare @TradeDiscount Decimal(18, 6)    
Declare @ChequeNo nvarchar(50)    
Declare @ChequeDate Datetime    
Declare @BankCode nvarchar(50)    
Declare @BankName nvarchar(100)    
Declare @BranchCode nvarchar(50)    
Declare @BranchName nvarchar(100)    
Declare @CollectionID Int    
      
Declare @SCRefNo nvarchar(50)     
Declare @DispRefNo nvarchar(50)    
Declare @DispRefNumber nvarchar(50)    
Declare @SCRefNumber nvarchar(50)    
    
Declare @CANCELLEDSALESRETURNDAMAGES As NVarchar(50)  
Declare @CANCELLEDSALESRETURNSALEABLE As NVarchar(50)  
Declare @SALESRETURNDAMAGES As NVarchar(50)  
Declare @SALESRETURNSALEABLE As NVarchar(50)  
Declare @CANCELLED As NVarchar(50)  
Declare @AMENDED As NVarchar(50)  
Declare @INVOICEFROMVAN As NVarchar(50)  
Declare @INVOICE As NVarchar(50)  
Declare @CREDIT As NVarchar(50)  
Declare @CASH As NVarchar(50)  
Declare @CHEQUE As NVarchar(50)  
Declare @DD As NVarchar(50)  
Declare @SC As NVarchar(50)  
Declare @DISPATCH As NVarchar(50)  
  
Set @CANCELLEDSALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'CANCELLED SALES RETURN DAMAGES', Default)  
Set @CANCELLEDSALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'CANCELLED SALES RETURN SALEABLE', Default)  
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'SALES RETURN DAMAGES', Default)  
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'SALES RETURN SALEABLE', Default)  
Set @CANCELLED = dbo.LookupDictionaryItem(N'CANCELLED', Default)  
Set @AMENDED = dbo.LookupDictionaryItem(N'AMENDED', Default)  
Set @INVOICEFROMVAN = dbo.LookupDictionaryItem(N'INVOICE FROM VAN', Default)  
Set @INVOICE = dbo.LookupDictionaryItem(N'INVOICE', Default)  
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default)  
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)  
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)  
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)  
Set @SC = dbo.LookupDictionaryItem(N'SC', Default)  
Set @DISPATCH = dbo.LookupDictionaryItem(N'DISPATCH', Default)  
  
Select @AddnDiscount = AdditionalDiscount, @TradeDiscount = DiscountPercentage,    
@CollectionID = Cast(PaymentDetails As Int)    
From InvoiceAbstract Where InvoiceID = @INVNO    
select @TotalTax = SUM(ISNULL(STPayable, 0)), @TotalQty = ISNULL(SUM(Quantity), 0),          
@FirstSales = (Select IsNull(Sum(STPayable + CSTPayable), 0)          
From InvoiceDetail          
Where InvoiceID = @InvNo And SaleID = 1),          
@SecondSales = (Select IsNull(Sum(STPayable + CSTPayable), 0) From InvoiceDetail          
Where InvoiceID = @InvNo And SaleID = 2),          
@Savings = Sum(MRP * Quantity) - Sum(SalePrice * Quantity),          
@GoodsValue = SUM(Quantity * SalePrice),          
@ProductDiscountValue = Sum(DiscountValue),          
@AvgProductDiscountPercentage = Avg(DiscountPercentage),          
@TaxApplicable = Sum(IsNull(CSTPayable , 0) + IsNull(STPayable, 0)),    
@TotTaxableSaleVal =     
Sum(Case     
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then    
0    
Else    
Amount    
End),    
@TotNonTaxableSaleVal =     
Sum(Case     
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then    
Amount    
Else    
0    
End),    
@TotTaxableGV =     
Sum(Case     
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then    
0    
Else    
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))    
End),    
  
/*  
@TotNonTaxableGV =     
Sum(Case     
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then    
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))    
Else    
0    
End),    
*/  
@TotNonTaxableGV = (Select Sum(InvDetail.TotNonTaxableGV) from        
  (Select Sum(((InvDet.Quantity * InvDet.SalePrice) -   
               InvDet.DiscountValue +   
               (InvDet.Quantity * InvDet.SalePrice * InvDet.TaxSuffered /100)  
               )) "TotNonTaxableGV"    
  from InvoiceDetail InvDet             
  where InvDet.InvoiceID = @INVNO                
  Group by InvDet.serial  
  having Sum(IsNull(CSTPayable, 0)) = 0 And Sum(IsNull(STPayable, 0)) = 0  
  )  InvDetail),     
  
@TotTaxSuffSaleVal =     
Sum(Case     
When IsNull(TaxSuffered, 0) = 0 Then    
0    
Else    
Amount    
End),    
@TotNonTaxSuffSaleVal =     
Sum(Case    
When IsNull(TaxSuffered, 0) = 0 Then    
Amount    
Else    
0    
End),    
@TotTaxSuffGV =     
Sum(Case    
When IsNull(TaxSuffered, 0) = 0 Then    
0    
Else    
((Quantity * SalePrice) - DiscountValue)    
End),    
@TotNonTaxSuffGV =     
Sum(Case    
When IsNull(TaxSuffered, 0) = 0 Then    
((Quantity * SalePrice) - DiscountValue)    
Else    
0    
End),   
@TotFirstSaleGV =     
Sum(Case SaleID    
When 1 Then    
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))    
Else    
0    
End),    
@TotSecondSaleGV =     
Sum(Case SaleID    
When 1 Then    
0    
Else    
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))    
End),    
@TotFirstSaleValue =     
Sum(Case SaleID    
When 1 Then    
Amount    
Else    
0    
End),    
@TotSecondSaleValue =     
Sum(Case SaleID    
When 1 Then    
0    
Else    
Amount    
End),    
@TotFirstSaleTaxApplicable =     
Sum(Case SaleID    
When 1 Then    
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) -     
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * (@AddnDiscount + @TradeDiscount) / 100))    
Else    
0    
End),    
@TotSecondSaleTaxApplicable =     
Sum(Case SaleID    
When 1 Then    
0    
Else    
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) -    
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * (@AddnDiscount + @TradeDiscount) /100))    
End)    
from InvoiceDetail          
where InvoiceID = @INVNO          
        
create table #temp(taxsuffered Decimal(18, 6), ItemCount int, ItemCountWithoutFree int)          
insert #temp          
Select isnull(sum(invoicedetail.taxsuffamount),  0),1,   
case InvoiceDetail.FlagWord   
 When 1 Then 0   
 Else   
  Case batch_products.Free   
   When 1 Then 0 Else 1 End   
 End  
From InvoiceDetail, Batch_Products,InvoiceAbstract  
Where InvoiceDetail.InvoiceID = @INVNO  
And InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID And  
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code        
Group By InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,         
InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'         
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),        
InvoiceDetail.MRP, InvoiceDetail.SaleID,InvoiceAbstract.TaxOnMRP,  
InvoiceDetail.Flagword,Batch_Products.[Free]       
          
Select @TaxSuffered = Sum(TaxSuffered),  @ItemCount = Sum(ItemCount), @ItemCountWithoutFree = Sum(ItemCountWithoutFree) From #temp          
drop table #temp          
--Select @ItemCount = Count(Distinct Product_Code) From InvoiceDetail    
--Where InvoiceID = @INVNO      
--Select @ItemCount = Count(*) From InvoiceDetail, Batch_Products          
--Where InvoiceID = @INVNO And          
--InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code          
--Group By InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,           
--InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'           
--+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),          
--InvoiceDetail.MRP, InvoiceDetail.SaleID          
          
-- Select @AdjustedValue = IsNull(Sum(CollectionDetail.AdjustedAmount), 0) From CollectionDetail, InvoiceAbstract          
-- Where CollectionID = Cast(PaymentDetails as int) And           
-- CollectionDetail.DocumentID <> @InvNo And          
-- InvoiceAbstract.InvoiceID = @InvNo          
  
Select @AdjustedValue =   
Sum ( Case  
      When InvoiceAbstract.InvoiceType=4 then  
 /*For Sales Return Adjustment*/  
  (Case Collectiondetail.DocumentType   
   When 4 Then   
    Isnull(CollectionDetail.AdjustedAmount,0)   
   When 5 Then   
    Isnull(CollectionDetail.AdjustedAmount,0)   
    Else    
     0   
  End)      
      Else  
 /* For Invoice Adjustment */  
  Case   
   When CollectionDetail.DocumentID <> @InvNo then   
    (Case Collectiondetail.DocumentType   
    When 5 Then -1   
    Else 1 End) * Isnull(CollectionDetail.AdjustedAmount,0)   
   Else   
    Case   
    When CollectionDetail.DocumentType <>4 then   
     (Case Collectiondetail.DocumentType   
     When 5 Then -1   
     Else 1 End) * Isnull(CollectionDetail.AdjustedAmount,0)   
    Else    
     0   
    END   
  END  
      End  
)  
    
From CollectionDetail, InvoiceAbstract        
Where CollectionID = Cast(ISnull(PaymentDetails,0) as int)   
And InvoiceAbstract.InvoiceID = @InvNo   
  
  
        
Select @SalesTaxwithcess = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode, 0) >= 5.00         
Select @salestaxwithoutCESS = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode,0) < 5.00        
  
Select @DispRefNumber = case when PatIndex(N'%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else null end From InvoiceAbstract Where InvoiceID = @INVNO And Status & 1 <> 0    
Select @SCRefNumber = case when PatIndex(N'%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else null end From InvoiceAbstract Where InvoiceID = @INVNO And Status & 4 <> 0    
  
DECLARE DispInfo CURSOR FOR      
Select RefNumber, NewRefNumber, Case When (Status & 6 <> 0) Then 0 Else 1 End    
From DispatchAbstract     
Where DispatchID in (Select * From dbo.sp_SplitIn2Rows(@DispRefNumber, N','))    
  
Set @DispRef = N''    
Set @SCRef = N''    
OPEN DispInfo    
FETCH FROM DispInfo Into @SCID, @DispRefNo, @bRefSC      
If @@fetch_status <> 0               
Begin  
 DECLARE SCInfo CURSOR FOR       
 Select PODocReference From SOAbstract Where SONumber in     
 (Select * From dbo.sp_SplitIn2Rows(@SCRefNumber, N','))    
 OPEN SCInfo    
 FETCH FROM SCInfo Into @SCRefNo  
 While @@fetch_status = 0               
 BEGIN      
  Set @SCRef = @SCRef + N',' + @SCRefNo    
  FETCH NEXT FROM SCInfo Into @SCRefNo  
 End  
 Close SCInfo         
 DeAllocate SCInfo    
End   
  
While @@fetch_status = 0               
BEGIN      
  If LTrim(@DispRefNo) <> N''    
   Set @DispRef = @DispRef + N',' + LTrim(@DispRefNo)    
    
  If @bRefSC = 1  
 Begin    
   --Select @SCRefNo = PODocReference From SOAbstract Where SONumber in (@SCID)    
  DECLARE SCInfo CURSOR FOR        
  Select PODocReference From SOAbstract Where SONumber in     
  (Select * From dbo.sp_SplitIn2Rows(@SCID, N','))    
  OPEN SCInfo    
  FETCH FROM SCInfo Into @SCRefNo  
  While @@fetch_status = 0               
  BEGIN      
   Set @SCRef = @SCRef + N',' + @SCRefNo    
   FETCH NEXT FROM SCInfo Into @SCRefNo  
  End   
  Close SCInfo              
  DeAllocate SCInfo   
 End  
  Else    
  Begin    
--     Select @SCRefNo = PODocReference From SOAbstract Where SONumber in     
--     (Select * From dbo.sp_SplitIn2Rows(@DispRefNumber, N','))    
  DECLARE SCInfo CURSOR FOR        
  Select PODocReference From SOAbstract Where SONumber in     
  (Select * From dbo.sp_SplitIn2Rows(@DispRefNumber, N','))    
  OPEN SCInfo    
  FETCH FROM SCInfo Into @SCRefNo  
  While @@fetch_status = 0               
  BEGIN      
   Set @SCRef = @SCRef + N',' + @SCRefNo    
   FETCH NEXT FROM SCInfo Into @SCRefNo  
  End   
  Close SCInfo              
  DeAllocate SCInfo   
  End    
  FETCH NEXT FROM DispInfo Into @SCID, @DispRefNo, @bRefSC      
END    
    
Close DispInfo              
DeAllocate DispInfo     
  
If Len(@DispRef) > 1     
 Set @DispRef = SubString(@DispRef, 2, Len(@DispRef) - 1)    
Else    
 Set @DispRef = N''    
If Len(@SCRef) > 1     
 Set @SCRef = SubString( @SCRef, 2, Len(@SCRef) - 1)    
Else    
 Set @SCRef = N''    
    
Select @ChequeNo = ChequeNumber, @ChequeDate = ChequeDate,    
@BankCode = BankMaster.BankCode, @BankName = BankMaster.BankName,    
@BranchCode = BranchMaster.BranchCode, @BranchName  = BranchMaster.BranchName    
From Collections, BranchMaster, BankMaster     
Where DocumentID = @CollectionID And    
Collections.BankCode = BankMaster.BankCode And    
Collections.BranchCode = BranchMaster.BranchCode And    
Collections.BankCode = BranchMaster.BankCode    
    
SELECT "Invoice Date" = InvoiceDate, "Company Name" = Company_Name,           
"Billing Address" = InvoiceAbstract.BillingAddress, "Gross Value" = GrossValue,           
"Discount%" = DiscountPercentage, "Discount Value" = DiscountValue,           
"Net Value" = Case InvoiceAbstract.InvoiceType          
When 4 Then          
0 - NetValue          
Else          
NetValue          
End, "Shipping Address" = InvoiceAbstract.ShippingAddress,          
"Addn Discount%" = AdditionalDiscount, "Freight" = Freight,           
--"Invoice Type" = InvoiceType,           
"Invoice No" =           
CASE InvoiceType          
WHEN 1 THEN          
Inv.Prefix          
WHEN 3 THEN          
InvA.Prefix          
WHEN 4 THEN          
SR.Prefix          
WHEN 5 THEN          
SR.Prefix          
END +          
CAST(DocumentID AS nvarchar),          
"Serial No" = InvoiceID, "Payment Date" = PaymentDate, "CreditTerm" = CreditTerm.Description,          
"MemoLabel1" =  MemoLabel1, "MemoLabel2" = MemoLabel2,           
"MemoLabel3" = Memolabel3, "Memo1" = Memo1, "Memo2" = Memo2,           
"Memo3" = Memo3, "DLNumber20" = DLNumber, "TNGST" = TNGST, "CST" = CST,           
"DLNumber21" = DLNumber21,           
"Total Tax" = @TotalTax, "User Name" = UserName,           
"Adjustments" = dbo.GetAdjustments(cast(InvoiceAbstract.PaymentDetails as int), @INVNO),          
"Adjusted Value" = @AdjustedValue,          
"Salesman" = Salesman.Salesman_Name, "Sales Officer" = Salesman2.SalesmanName,           
"User Name" = InvoiceAbstract.UserName,           
"Total Qty" = @TotalQty,          
"First Sales Total" = @FirstSales, "Second Sales Total" = @SecondSales,           
"Balance" = Case InvoiceAbstract.PaymentMode          
When 0 Then          
 Case InvoiceAbstract.InvoiceType          
 When 4 Then          
--   0 - ((NetValue + RoundOffAmount + AdjustmentValue) - @AdjustedValue)         
  0 - ((NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0))         
 Else          
--  (NetValue + RoundOffAmount + AdjustmentValue) - @AdjustedValue          
 (NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0)          
 End          
Else          
InvoiceAbstract.Balance          
End, "Doc Ref" = InvoiceAbstract.DocReference,          
"Invoice Reference" = InvoiceAbstract.NewInvoiceReference,          
"Ref No" = InvoiceAbstract.NewReference,          
"Savings" = @Savings, "CustomerID" = InvoiceAbstract.CustomerID,          
"Goods Value" = @GoodsValue, "Product Discount Value" = @ProductDiscountValue,          
"Resale Tax" = @TaxApplicable,    
"Gross Value (GoodsValue+ResaleTax+TaxSuffered)" = @GoodsValue + @TaxApplicable + @Taxsuffered,          
"Outstanding" = dbo.CustomerOutStanding(InvoiceAbstract.CustomerID),          
"OverAll Discount Value" = ((@GoodsValue - @ProductDiscountValue) * (AdditionalDiscount + DiscountPercentage) /100),          
"OverAll Discount%" = AdditionalDiscount + DiscountPercentage,          
"Item Count" = @ItemCount,          
"Item Count without Free" = @ItemCountWithoutFree,  
"Invoice Type" = Case           
When (InvoiceAbstract.Status & 32) <> 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 64 then          
@CANCELLEDSALESRETURNDAMAGES         
When (InvoiceAbstract.Status & 32) = 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 64 then          
@CANCELLEDSALESRETURNSALEABLE  
When (InvoiceAbstract.Status & 32) <> 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 0 then          
@SALESRETURNDAMAGES  
When (InvoiceAbstract.Status & 32) = 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 0 then          
@SALESRETURNSALEABLE  
When (InvoiceAbstract.Status & 64) = 64 then          
@CANCELLED  
When (InvoiceAbstract.Status & 128) = 128 then          
@AMENDED  
When (InvoiceAbstract.Status & 16) = 16 then          
@INVOICEFROMVAN  
Else          
@INVOICE   
End, "Adjustment Value" = InvoiceAbstract.AdjustmentValue,          
"Rounded Net Value" = Case InvoiceAbstract.InvoiceType          
When 4 Then          
0 - (NetValue + RoundOffAmount)          
Else          
NetValue + RoundOffAmount          
End,          
"Average Product Discount Percentage" = @AvgProductDiscountPercentage,          
"Sales Tax" = (@TotalTax / 1.05),          
"Surcharge" = ((@TotalTax / 1.05) * 0.05),          
        
"Total Sales Tax minus CESS" = cast((Isnull(@SalesTaxwithcess,0)/1.15) + (Isnull(@SalesTaxwithoutcess,0)) as Decimal(18, 6)),        
"CESS" = cast(((Isnull(@SalesTaxwithcess,0) / 1.15) * 0.15)as Decimal(18, 6)),         
        
"Total Amount Before Tax" = Case InvoiceAbstract.InvoiceType          
When 4 Then          
0 - (NetValue - @TaxApplicable)          
Else          
NetValue - @TaxApplicable          
End,    
"Rounded Off Amount Diff" = RoundOffAmount,    
"Ref In Dispatch" = @DispRef,    
"Ref In SC" = @SCRef,    
"Total Taxable Sale Value" = @TotTaxableSaleVal,    
"Total Non Taxable Sale Value" = @TotNonTaxableSaleVal,    
"Total Taxable GV" = @TotTaxableGV,    
"Total Non Taxable GV" = @TotNonTaxableGV,    
"Total TaxSuff Sale Value" = @TotTaxSuffSaleVal,    
"Total Non TaxSuff Sale Value" = @TotNonTaxSuffSaleVal,    
"Total TaxSuff GV" = @TotTaxSuffGV,    
"Total Non TaxSuff GV" = @TotNonTaxSuffGV,    
"Total First Sale GV" = @TotFirstSaleGV,    
"Total Second Sale GV" = @TotSecondSaleGV,    
"Total First Sale Value" = @TotFirstSaleValue,    
"Total Second Sale Value" = @TotSecondSaleValue,    
"Total First Sale Tax Applicable" = @TotFirstSaleTaxApplicable,    
"Total Second Sale Tax Applicable" = @TotSecondSaleTaxApplicable,    
"Creation Date" = InvoiceAbstract.CreationTime,    
"Payment Mode" = Case PaymentMode    
When 0 Then @CREDIT  
When 1 Then @CASH    
When 2 Then @CHEQUE  
When 3 Then @DD End,    
"Cheque/DD Number" = @ChequeNo,    
"Cheque/DD Date" = @ChequeDate,    
"Bank Code" = @BankCode,    
"Bank Name" = @BankName,    
"Branch Code" = @BranchCode,    
"Branch Name" = @BranchName,    
"Amount Received" = AmountRecd ,    
"SC Date" = dbo.GetSCAndDispatchDate(@INVNO, @SC),    
"Dispatch Date" = dbo.GetSCAndDispatchDate(@INVNO, @DISPATCH),   
"Addl Discount Value" = AddlDiscountValue,   
"Beat Name" = Beat.Description,   
"Invoice Balance" = (NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0),         
"Total Tax Suffered" = IsNull(@Taxsuffered,0),   
"TIN Number" = TIN_Number, "Alternate Name" = Alternate_Name, "Doc Type" = DocSerialType,  
"Sequence Number" = Customer.SequenceNo,   
--For ExciseDuty  
"Excise Duty" = InvoiceAbstract.ExciseDuty, 'TaxComponents', 'AdjustmentComponent',
"Customer Points" =Isnull(CustomerPoints,0)
FROM InvoiceAbstract, Customer, VoucherPrefix Inv, VoucherPrefix InvA, Salesman2, Salesman,  Beat,        
VoucherPrefix SR, CreditTerm          
WHERE InvoiceID = @INVNO           
AND InvoiceAbstract.CustomerID = Customer.CustomerID          
AND InvoiceAbstract.BeatID *= Beat.BeatID   
AND SR.TranID = N'SALES RETURN'          
AND InvA.TranID = N'INVOICE AMENDMENT'          
AND Inv.TranID = N'INVOICE'          
AND InvoiceAbstract.CreditTerm *= CreditTerm.CreditID           
AND InvoiceAbstract.SalesmanID *= Salesman.SalesmanID          
AND InvoiceAbstract.Salesman2 *= Salesman2.SalesmanID
