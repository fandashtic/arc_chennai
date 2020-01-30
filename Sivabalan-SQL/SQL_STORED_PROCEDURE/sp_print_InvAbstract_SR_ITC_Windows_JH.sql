
Create Procedure [dbo].[sp_print_InvAbstract_SR_ITC_Windows_JH](@INVNO INT)     
AS      
Set dateformat DMY    
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
Declare @WDPhoneNumber As NVarchar(20)
Declare @PointsEarned as int
Declare @TotPointsEarned as int
Declare @CustCode as nvarchar(255)

Declare @InvoiceDate as DateTime
Declare @ClosingPoints as Nvarchar(2000)
Declare @TargetVsAchievement as Nvarchar(2000)

Set @CustCode=''
Set @CustCode=(Select CustomerID from InvoiceAbstract where InvoiceID=@InvNo)

Set @InvoiceDate = (select  Top 1 dbo.stripTimeFromdate(InvoiceDate) From InvoiceAbstract Where InvoiceID = @INVNO)
set @ClosingPoints = isnull((select Dbo.Fn_Get_CurrentAchievementVal(@CustCode,@InvoiceDate)),'')
Set @TargetVsAchievement = isnull((select Dbo.Fn_Get_CurrentTarget_AchievementVal(@CustCode,@InvoiceDate)),'')

Set @PointsEarned=''
Set @PointsEarned=Cast(IsNull((Select Cast(Sum(IsNull(Points, 0)) as int) from tbl_mERP_OutletPoints op
                          Where op.InvoiceID = @INVNO And op.Status = 0), 0) as int)
Set @TotPointsEarned=''
Set @TotPointsEarned=Cast(IsNull((Select Cast(Sum(IsNull(Points, 0)) as int) from tbl_mERP_OutletPoints op
                          Where op.outletCode =@CustCode and op.InvoiceID <= @INVNO  And op.Status = 0), 0) as int)

Select @WDPhoneNumber=Telephone from Setup
  
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
        
create table #temp(taxsuffered Decimal(18, 6), ItemCountWithoutFree int)          
Create Table #tempItemCount(ItemCount Int)
insert #temp
Select isnull(sum(invoicedetail.taxsuffamount),  0),   
case InvoiceDetail.FlagWord   
 When 1 Then 0   
 Else   
  Case batch_products.Free   
   When 1 Then 0 Else 1 End   
 End  
From InvoiceDetail 
left outer join Batch_Products on InvoiceDetail.Batch_Code = Batch_Products.Batch_Code   
inner join InvoiceAbstract  on InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID    
Where InvoiceDetail.InvoiceID = @INVNO        
Group By InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,         
InvoiceDetail.SalePrice, 
--CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'         
--+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),        
InvoiceDetail.MRP, InvoiceDetail.SaleID,InvoiceAbstract.TaxOnMRP,  
InvoiceDetail.Flagword,Batch_Products.[Free]       


/*While counting the number of items in the invoice 
Same product free item will not be considered as a separate item as the free item will be
shown under the free column in the same row along with the saleable item */
insert #tempItemCount(ItemCount)
exec sp_print_RetInvItems_RespectiveUOM_SR_ITC_JH @INVNO,1

--Select  1
--From InvoiceDetail, Batch_Products,InvoiceAbstract  
--Where InvoiceDetail.InvoiceID = @INVNO  
--And InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID And  
--InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code And
--InvoiceDetail.Serial Not In(Select Serial From InvoiceDetail Where InvoiceID = @INVNO And SalePrice = 0 And Product_Code  In
--(Select Product_Code From InvoiceDetail Where InvoiceID = @INVNO and SalePrice <>0))
--Group By InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,         
--InvoiceDetail.SalePrice, 
----CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'         
----+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),        
--InvoiceDetail.MRP, InvoiceDetail.SaleID,InvoiceAbstract.TaxOnMRP


          
Select @TaxSuffered = Sum(TaxSuffered) From #temp   
--@ItemCountWithoutFree = Sum(ItemCountWithoutFree) From #temp          
Select @ItemCountWithoutFree=Count(Distinct Product_Code) from InvoiceDetail where InvoiceID=@InvNo and SalePrice<>0
Select @ItemCount = Max(ItemCount) From #tempItemCount


drop table #temp          
Drop Table #tempItemCount
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
    
SELECT 
"Invoice Date" = InvoiceDate, 
"Doc Ref" = InvoiceAbstract.DocReference ,
--"Invoice No"= CASE InvoiceType WHEN 1 THEN Inv.Prefix WHEN 3 THEN InvA.Prefix WHEN 4 THEN SR.Prefix WHEN 5 THEN SR.Prefix END + CAST(DocumentID AS nvarchar),
"WDPhoneNumber" = 'Phone: ' + @WDPhoneNumber,
"Customer Name" = Company_Name,           
"Billing Address" = InvoiceAbstract.BillingAddress, 
"Gross Value" = GoodsValue, --GrossValue,           
"Discount Value" = ProductDiscount, --DiscountValue,           
"Net Value" = Case InvoiceAbstract.InvoiceType When 4 Then 0 - GrossValue Else GrossValue End, 
"TaxPercentage" =  dbo.GetTaxDetails_windows(@INVNO,1),
"SalesValue" = dbo.GetTaxDetails_windows(@INVNO,2),
"TaxCompPercentage" =  dbo.GetTaxDetails_windows(@INVNO,3),
"TaxAmt" =  dbo.GetTaxDetails_windows(@INVNO,4),
"TotalTaxAmt" =  dbo.GetTaxDetails_windows(@INVNO,5),
"InvoiceOutstandingDetail" = dbo.GetCustomerOutStanding_Windows(@InvNo), 
"Adjusted Value" = @AdjustedValue,          
"Salesman" = Salesman.Salesman_Name, 
"Balance" = Case InvoiceAbstract.PaymentMode When 0 Then Case InvoiceAbstract.InvoiceType When 4 Then 0 - ((NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0)) Else (NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0) End Else InvoiceAbstract.Balance End,
"CustomerID" = InvoiceAbstract.CustomerID + case when dbo.Fn_Get_PANNumber(@InvNo,'INVOICE','CUSTOMER')='' Then '' 
else ' PAN No:' + dbo.Fn_Get_PANNumber(@InvNo,'INVOICE','CUSTOMER') end,
"Item Count without Free" = 'No.ofItems sold: ' + cast(@ItemCountWithoutFree as nvarchar(3)),  

"Rounded Net Value" = 
Cast(
Case InvoiceAbstract.InvoiceType When 4 
Then 0 - (NetValue + RoundOffAmount - isnull(@AdjustedValue,0)) 
Else NetValue + RoundOffAmount - isnull(@AdjustedValue,0) End
as Decimal(18,2)),
"Payment Mode" = Case PaymentMode When 0 Then @CREDIT When 1 Then @CASH When 2 Then @CHEQUE When 3 Then @DD End,
"Beat Name" = Beat.Description,   
"DeliveryDate" = DeliveryDate,

"CurrentInvoicePoints" = case when isnull(cast(@PointsEarned as int),0) > 0 then 'PtsEarned: ' + cAST(@PointsEarned AS NVARCHAR(40)) + ' Cum.Pts: ' + cast(@TotPointsEarned as NVARCHAR(40)) else '' End,
"InvSchemeDiscount%" = Cast(Cast(isnull(DiscountPercentage,0) as decimal(18,2)) as nvarchar(10)),
"InvSchemeDiscount" = Cast(cast(isnull(DiscountValue,0) as decimal(18,2)) as nvarchar(10)),
--'|Inv.Sch.Disc.@ ' + 									 
"InvTradeDiscount%" = Cast(cast(isnull(AdditionalDiscount,0) as decimal(18,2)) as nvarchar(10)), 
"InvTradeDiscount" = Cast(cast(isnull(AddlDiscountValue,0) as decimal(18,2)) as nvarchar(10)), 
--'|Trade Disc.@   ' 
"InvCreditAdjustment" = cast(cast(isnull(@AdjustedValue,0) as decimal(18,2)) as Nvarchar(10)), 
--'|Credit Adj.          :' 
"InvRoundOffAmount" = cast(cast(isnull(RoundOffAmount,0) as decimal(18,2)) as Nvarchar(10)), 
--'|Round off Amt.       :' 
"InvNetAmountPayable" = cast(cast(isnull(Case InvoiceAbstract.InvoiceType 
						When 4 Then 0 - ((NetValue + RoundOffAmount) - isnull(@AdjustedValue,0)) 
												Else (NetValue + RoundOffAmount) - isnull(@AdjustedValue,0) End ,0) 
												as decimal(18,2)) as Nvarchar(10)), 
"Cr.Note.Desc" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,1),
"Cr.Note.Val" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,2),
"Cr.Note.AdjVal" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,3),
"Cr.Note.BalVal" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,4),
"Cr.Note.Total" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,5),
"TIN Number" = TIN_Number,
"Item Count" = @ItemCount,
"TaxBrkUp" = dbo.GetTaxCompInfoForInv(@INVNO, 1, 1),
"CompBrkUp" = dbo.GetTaxCompInfoForInv(@INVNO, 2, 1),
"TotTax" = dbo.GetTaxCompInfoForInv(@INVNO, 1, 2),
"TIN/NON TIN" = (Select Case IsNull(TIN_Number, '') When '' Then 'R E T A I L  I N V O I C E' Else 
	'T A X   I N V O I C E' End From Customer cu Where cu.CustomerID = Customer.CustomerID),
"ClosingPoints as on Date" = @ClosingPoints,
"Target Vs Achievement" = @TargetVsAchievement
FROM InvoiceAbstract
inner join  Customer on  InvoiceAbstract.CustomerID = Customer.CustomerID  
inner join VoucherPrefix Inv on  Inv.TranID = N'INVOICE'   
inner join VoucherPrefix InvA on  InvA.TranID = N'INVOICE AMENDMENT'  
left outer join  Salesman2 on  InvoiceAbstract.Salesman2 = Salesman2.SalesmanID
left outer join  Salesman on   InvoiceAbstract.SalesmanID = Salesman.SalesmanID   
inner join  Beat      on    InvoiceAbstract.BeatID = Beat.BeatID   
inner join VoucherPrefix SR on  SR.TranID = N'SALES RETURN'   
left outer join   CreditTerm    on       InvoiceAbstract.CreditTerm = CreditTerm.CreditID 
WHERE InvoiceID = @INVNO    

