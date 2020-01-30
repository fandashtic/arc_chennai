CREATE procedure [dbo].[sp_print_InvAbstract_Windows_CIG_IGST_ITC_GST_1](@INVNO INT)
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
Declare @CompanyGSTIN as Nvarchar(30)
Declare @CompanyPAN as Nvarchar(200)
Declare @CIN as Nvarchar(50)
Declare @CompanyState Nvarchar(200)
Declare @CompanySC	Nvarchar(50)
Declare @UTGST_flag  int

select @UTGST_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

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
Select @CompanyGSTIN=GSTIN from Setup
Select @CompanyPAN =PANNumber from Setup
Select @CIN=CIN from Setup
Select TOP 1 @CompanyState=StateName,@CompanySC=ForumStateCode from StateCode
inner join Setup on Setup.ShippingStateID=StateCode.StateID

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
From InvoiceDetail, Batch_Products,InvoiceAbstract
Where InvoiceDetail.InvoiceID = @INVNO
And InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID And
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
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
exec sp_print_RetInvItems_RespectiveUOM_CIG_IGST_ITC_GST @INVNO,1
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
Select @ItemCount = max(ItemCount)*2 From #tempItemCount


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

-------------------------Temp Tax Details
Select  InvoiceID, Product_Code, Tax_Code ,SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.NetTaxAmount Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.NetTaxAmount Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.NetTaxAmount Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.NetTaxAmount Else 0 End),
--CESSPer = Max(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.Tax_Percentage Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
--CESSAmt = Sum(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.NetTaxAmount Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.NetTaxAmount Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.NetTaxAmount Else 0 End) Into #TempTaxDet
From GSTInvoiceTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where InvoiceId = @INVNo
Group By InvoiceID, Product_Code, Tax_Code,SerialNo

--Temp Invoice Detail
Select Serial=ID.Serial , TaxID=ID.TaxID,
TaxableValue = Case When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then 0 Else ((UOMQty  * UOMPrice) - DiscountValue) - (((UOMQty  * UOMPrice) - DiscountValue)*@AddnDiscount /100) End ,
SGSTPer=Case GSTFlag
When 1 then (Select SGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0)
When 0 then isnull(ID.TaxCode,0) + isnull(ID.TaxCode2,0)
End ,
SGSTAmt=Case GSTFlag
When 1 then (Select Sum(SGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0)
When 0 then isnull(ID.stpayable,0)+ isnull(ID.cstpayable,0)
End,
CGSTPer=(Select CGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CGSTAmt=(Select Sum(CGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
IGSTPer=(Select IGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
IGSTAmt=(Select Sum(IGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
UTGSTPer=(Select UTGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
UTGSTAmt=(Select Sum(UTGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CESSPer=(Select CESSPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CESSAmt=(Select Sum(CESSAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0),
ADDLCESSPer=(Select ADDLCESSPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0)
into #TempInvDet2
from InvoiceDetail ID
Where InvoiceId = @INVNo
and UOMQty > 0
--Group by ID.Serial

--Select * from #TempTaxDet

--Select Tax_Code,MAX(SGSTPer)+MAX(CGSTPer),SGSTAmt=Sum(SGSTAmt),CGSTAmt=SUM(CGSTAmt) from #TempTaxDet Group By Tax_Code

--Select Serial,TaxID,TaxableValue,SGSTPer,SGSTAmt , CGSTPer, CGSTAmt, IGSTPer, IGSTAmt,UTGSTPer,UTGSTAmt,CESSPer,CESSAmt,ADDLCESSPer,ADDLCESSAmt
--From #TempInvDet2

Select TaxableValue=Sum(TaxableValue),SGSTPer=Max(SGSTPer),SGSTAmt =Sum(SGSTAmt ), CGSTPer=Max(CGSTPer),CGSTAmt=SUM(CGSTAmt),
IGSTPer=MaX(IGSTPer), IGSTAmt=Sum(IGSTAmt), UTGSTPer=Max(UTGSTPer),UTGSTAmt=Sum(UTGSTAmt),
CESSPer=Max(CESSPer),CESSAmt=Sum(CESSAmt), ADDLCESSPer=Max(ADDLCESSPer),ADDLCESSAmt=Sum(ADDLCESSAmt),
Total= SUM(IGSTAmt +CESSAmt+ADDLCESSAmt)
Into #GSTaxSummary
From #TempInvDet2
Group By TaxID

Select TaxableValue=Sum(TaxableValue),Rate =Convert(Decimal(5,2),Case when @UTGST_flag = 1 then UTGSTPer Else  SGSTPer End )+Convert(Decimal(5,2) , CGSTPer) ,
SGSTAmt =Sum(Case when @UTGST_flag = 1 then UTGSTAmt Else  SGSTAmt End ), CGSTAmt=Sum(CGSTAmt) , Total=Sum(IsNull(convert(Decimal(18,6),CGSTAmt),0)+IsNull(Convert(Decimal(18,6),Case when @UTGST_flag = 1 then UTGSTAmt Else  SGSTAmt End),0))
Into #GSTTaxCompDet
--, IGSTPer=Max(IGSTPer),IGSTAmt=SUM(IGSTAmt)
From #TempInvDet2 --where Convert(Decimal(5,2),Case when @UTGST_flag = 1 then UTGSTPer Else  SGSTPer End )+Convert(Decimal(5,2) , CGSTPer) > 0
Group By Case when @UTGST_flag = 1 then UTGSTPer Else  SGSTPer End, CGSTPer

Declare @GSTTaxSumText nVarChar(25)
Declare @GSTTaxComp nVarChar(Max)
Declare @GSTTaxComp_DOS nVarChar(Max)
Declare @GSTTaxCompText nVarChar(200)
Declare @GSTTaxCompText_DOS nVarChar(200)
Set @GSTTaxSumText = 'Tax Summary :'
Set @GSTTaxCompText =  'Rate'+ Space(8) +'TaxableVal' + SPACE(12) + 'CGST' + SPACE(8) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + SPACE(6) + '  Total Tax'
--Set @GSTaxCompHead = 'Rate'+ Space(8) +'TaxableVal' + SPACE(12) + 'CGST' + SPACE(8) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + SPACE(6) + '  Total Tax'
--Set @GSTTaxCompText =  'Tax Summary/GST  Component' + space(32) + 'TaxableVal' + Space(14) + 'IGST' + Space(10) + 'Cess' +  Space(6) + 'AddlCess'+ + Space(4) + 'Total Tax'
Set @GSTTaxCompText_DOS=  'Tax Summary/GST  Component' + space(32) + 'TaxableVal' + Space(14) + 'CGST' + Space(10) + 'SGST' +  Space(6) + 'Total Tax'
--Set @GSTTaxCompText_DOS=  'Tax Summary/GST  Component' + space(19) + 'TaxableVal ' + Space(6) + 'IGST ' + Space(6) + 'Cess ' +  Space(2) + 'AddlCess '+ + Space(1) + 'Total Tax'
--Set @GSTTaxComp = '  '+ + Char(13) + Char(10) + '  |  Tax Summary/GST  Component' + space(32) + 'TaxableVal' + Space(14) + 'IGST' + Space(10) + 'Cess' +  Space(6) + 'AddlCess'+ + Space(4) + 'Total Tax' + Char(13) + Char(10)
Set @GSTTaxComp = ''--'Rate'+ Space(3) +'TaxableVal' + SPACE(7) + 'CGST' + SPACE(6) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + SPACE(2) + '  Total Tax' 
--Set @GSTaxCompHead_DOS = 'Rate'+ SPACE(3)+'TaxableVal' + SPACE(7) + 'CGST' + SPACE(6) + Case when @UTGST_flag = 1 then 'UTGST' Else  ' SGST' End + SPACE(2) + 'Total Tax'
--Set @GSTaxCompHead = 'Rate'+ Space(8) +'TaxableVal' + SPACE(12) + 'CGST' + SPACE(8) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + SPACE(6) + '  Total Tax'

--Select @GSTTaxComp = @GSTTaxComp
--+ '  |  IGST' + Replicate('  ',5-LEN(Cast(Cast(IGSTPer   As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5))
----+ '%+SGST' + Replicate('  ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
--+ '% + Cess' + Replicate('  ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
--+ '% + AddlCess ' +Replicate('  ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
--+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
----+ ' ' + Replicate('  ',10-LEN(Cast(SGSTAmt as Decimal(10,2)))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate('  ',10-LEN(Cast(CESSAmt as Decimal(10,2)))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate('  ',10-LEN(Cast(ADDLCESSAmt as Decimal(10,2)))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + Char(13) + Char(10)--+ SPACE(2)
--From #GSTaxSummary

Set @GSTTaxComp_DOS  = ''
--Select @GSTTaxComp_DOS  = @GSTTaxComp_DOS
--+ 'IGST' + Replicate(' ',5-LEN(Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5))
----+ '%+SGST' + Replicate(' ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
--+ '% + Cess' + Replicate(' ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
--+ '% + AddlCess ' +Replicate(' ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
--+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
----+ ' ' + Replicate(' ',10-LEN(Cast(SGSTAmt as Decimal(10,2)))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate(' ',10-LEN(Cast(CESSAmt as Decimal(10,2)))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate(' ',10-LEN(Cast(ADDLCESSAmt as Decimal(10,2)))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + SPACE(2)
--From #GSTaxSummary

--Select @GSTTaxComp = @GSTTaxComp
--+ '' + Replicate('0',5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))))
----Space(5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5)))) + Space(5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))))
--+  Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))  + '%'
--+ '  ' + SPACE(10-LEN(Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10)))) +SPACE(10-LEN(Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10))
--+ '  ' + SPACE(10-LEN(Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10)))) + SPACE(10-LEN(Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10))
--+ '  ' + SPACE(10-LEN(Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10)))) + SPACE(10-LEN(Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10))))+ Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10))
--+ '  ' + SPACE(10-LEN(Cast(Cast(Total As Decimal(10,2)) As nVarChar(10))))+ SPACE(10-LEN(Cast(Cast(Total As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(Total As Decimal(10,2)) As nVarChar(10))
--From #GSTaxSummary

Select @GSTTaxComp = @GSTTaxComp
+ '' + Replicate('0',5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))))
--+  Space(5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5)))) + Space(5-LEN(Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))))
+  Cast(Cast(Rate As Decimal(5,2))As nVarChar(5))  + '%'
+ ' ' + SPACE(10-LEN(Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10)))) +SPACE(10-LEN(Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(TaxableValue As Decimal(10,2)) As nVarChar(10))
+ ' ' + SPACE(10-LEN(Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10)))) + SPACE(10-LEN(Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(CGSTAmt As Decimal(10,2)) As nVarChar(10))
+ ' ' + SPACE(10-LEN(Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10)))) + SPACE(10-LEN(Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10))))+ Cast(Cast(SGSTAmt As Decimal(10,2)) As nVarChar(10))
+ ' ' + SPACE(10-LEN(Cast(Cast(Total As Decimal(10,2)) As nVarChar(10))))+ SPACE(10-LEN(Cast(Cast(Total As Decimal(10,2)) As nVarChar(10)))) + Cast(Cast(Total As Decimal(10,2)) As nVarChar(10)) 
+' '
--+ (case when isnull(@GSTTaxComp,'') = '' then  ' ' else '' end)
From #GSTTaxCompDet

--Select @GSTTaxComp = @GSTTaxComp
----+ 'CGST' + Space(5-LEN(Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5))
----+ '%+SGST' + Space(5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
----+ '%+Cess' + Space(5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
----+ '%+AddlCess ' +Space(5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(4)
--+ ' ' + Space(12-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar)))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Space(12-LEN(LTrim(Cast(Cast(CGSTAmt as Decimal(10,2))  As nVarChar)))) + Cast(Cast(CGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Space(12-LEN(Cast(CGSTAmt as Decimal(10,2))  )) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
--+ ' ' + Cast((Cast(CGSTAmt as Decimal(10,2)) + Cast(SGSTAmt as Decimal(10,2)) )  as nVarChar)
----+ ' ' + Space(12-LEN(Cast(CGSTAmt as Decimal(10,2)))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
----+ ' ' + Replicate(' ',12-LEN(Cast(CGSTAmt as Decimal(10,2)))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))  + SPACE(1)
--From #GSTaxSummary

--Select @GSTTaxComp

--Select SUM(TaxableValue) from #TempInvDet2

--Set @GSTTaxComp = ''

--Select @GSTTaxComp = @GSTTaxComp
--+ Space(10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar)))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
--From #GSTaxSummary

--Select @GSTTaxComp

Drop Table #TempTaxDet
Drop Table #TempInvDet2
----------------------------------------------------------------

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
"Invoice Date" = convert(varchar(10),InvoiceDate,103),
"Doc Ref" = InvoiceAbstract.DocReference ,
"Serial No" = CASE Isnull(GSTFlag,0) when 1 then isnull(GSTFullDocID,'') else case InvoiceType WHEN 1 THEN Inv.Prefix WHEN 3 THEN InvA.Prefix WHEN 4 THEN SR.Prefix WHEN 5 THEN SR.Prefix END + CAST(DocumentID AS nvarchar) end,
"WDPhoneNumber" = 'Phone: ' + @WDPhoneNumber,
"Customer Name" = Company_Name,
"Billing Address" = InvoiceAbstract.BillingAddress,
"Shipping Address" =InvoiceAbstract.ShippingAddress,
"Gross Value" = GoodsValue, --GrossValue,
"Discount Value" = ProductDiscount, --DiscountValue,
"Net Value" = Case InvoiceAbstract.InvoiceType When 4 Then NetValue Else NetValue End,
"TaxPercentage" = 0 ,--=  dbo.GetTaxDetails_windows(@INVNO,1),
"SalesValue" =0,--= dbo.GetTaxDetails_windows(@INVNO,2),
"TaxCompPercentage"=0,-- =  dbo.GetTaxDetails_windows(@INVNO,3),
"TotalTaxAmt"=0,-- =  dbo.GetTaxDetails_windows(@INVNO,5),
"InvoiceOutstandingDetail" = dbo.GetCustomerOutStanding_Windows(@InvNo),
"Adjusted Value" = @AdjustedValue,
"Salesman" = Salesman.Salesman_Name,
"Balance" = Case InvoiceAbstract.PaymentMode When 0 Then Case InvoiceAbstract.InvoiceType When 4 Then  ((NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0)) Else (NetValue + RoundOffAmount) - Isnull(@AdjustedValue,0) End Else InvoiceAbstract.Balance End,
"CustomerID" = InvoiceAbstract.CustomerID + case when dbo.Fn_Get_PANNumber(@InvNo,'INVOICE','CUSTOMER')='' Then ''
else ' PAN No:' + dbo.Fn_Get_PANNumber(@InvNo,'INVOICE','CUSTOMER') end,
"Item Count without Free" = 'No.ofItems sold: ' + cast(@ItemCountWithoutFree as nvarchar(3)),
"TotTaxableGV" = Cast(IsNull(@TotTaxableGV,0) As Decimal(18,2)),
"Rounded Net Value" =
Cast(
Case InvoiceAbstract.InvoiceType When 4
Then  (NetValue + RoundOffAmount - isnull(@AdjustedValue,0))
Else NetValue + RoundOffAmount - isnull(@AdjustedValue,0) End
as Decimal(18,2)),
"Payment Mode" = Case PaymentMode When 0 Then @CREDIT When 1 Then @CASH When 2 Then @CHEQUE When 3 Then @DD End,
"Beat Name" = Beat.Description,
"DeliveryDate" = convert(varchar(10),DeliveryDate,103),
"Doc Type" = DocSerialType,
"CurrentInvoicePoints" = case when isnull(cast(@PointsEarned as int),0) > 0 then 'PtsEarned: ' + cAST(@PointsEarned AS NVARCHAR(40)) + ' Cum.Pts: ' + cast(@TotPointsEarned as NVARCHAR(40)) else '' End,
"InvSchemeDiscount%" = Cast(Cast(isnull(DiscountPercentage,0) as decimal(18,2)) as nvarchar(12)),
"InvSchemeDiscount" = Cast(cast(isnull(DiscountValue,0) as decimal(18,2)) as nvarchar(12)),
--'|Inv.Sch.Disc.@ ' +
"InvTradeDiscount%" = Cast(cast(isnull(AdditionalDiscount,0) as decimal(18,2)) as nvarchar(12)),
"InvTradeDiscount" = Cast(cast(isnull(AddlDiscountValue,0) as decimal(18,2)) as nvarchar(12)),
--'|Trade Disc.@   '
"InvCreditAdjustment" = cast(cast(isnull(@AdjustedValue,0) as decimal(18,2)) as nvarchar(12)),
--'|Credit Adj.          :'
"InvRoundOffAmount" = cast(cast(isnull(RoundOffAmount,0) as decimal(18,2)) as nvarchar(12)),
--'|Round off Amt.       :'
"InvNetAmountPayable" = cast(cast(isnull(Case InvoiceAbstract.InvoiceType
When 4 Then  ((NetValue + RoundOffAmount) - isnull(@AdjustedValue,0))
Else (NetValue + RoundOffAmount) - isnull(@AdjustedValue,0) End ,0)
as decimal(18,2)) as nvarchar(12)),
"Cr.Note.Desc" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,1),
"Cr.Note.Val" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,2),
"Cr.Note.AdjVal" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,3),
"Cr.Note.BalVal" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,4),
"Cr.Note.Total" = dbo.MERP_FN_GetCreditNoteDetails_Windows(@INVNO,5),
"Item Count" = @ItemCount,
"TaxBrkUp" = dbo.GetTaxCompInfoForInv(@INVNO, 1, 1),
"CompBrkUp" = dbo.GetTaxCompInfoForInv(@INVNO, 2, 1),
"TotTax" = InvoiceAbstract.VatTaxAmount,
"TIN/NON TIN" = (Select Case IsNull(TIN_Number, '') When '' Then 'R E T A I L  I N V O I C E' Else
'T A X   I N V O I C E' End From Customer cu Where cu.CustomerID = Customer.CustomerID),

"ClosingPoints as on Date" = @ClosingPoints,
"Target Vs Achievement" = @TargetVsAchievement,
"CompanyGSTIN" = @CompanyGSTIN,
"CompanyPAN" = @CompanyPAN,
"CustomerPAN" = Customer.PANNumber,
"CustomerGSTIN" = InvoiceAbstract.GSTIN,
"CIN" = @CIN,
"SCBilling" = SCBilling.ForumStateCode,
"SCShipping" = SCShipping.ForumStateCode,
"BillingState" = SCBilling.StateName,
"ShippingState" = SCShipping.StateName,
"CompanyState" = @CompanyState,
"CompanySC" = @CompanySC ,
"SGST/UTGST Rate" = case @UTGST_flag when 1 then 'UTGST Rate'  else 'SGST Rate' end,
"SGST/UTGST Amt" = case @UTGST_flag when 1 then 'UTGST Amt'  else 'SGST Amt' end,
"S/UT GST" = case @UTGST_flag when 1 then 'UTGST'  else 'SGST' end,
"TaxDetails" = Replace(dbo.GetTaxDetails_DOS (@INVNO),';',Char(13)),
"InvoiceTotals" =
'|Credit Adj.          :' + Space(12-len(cast(cast(isnull(@AdjustedValue,0) as decimal(18,2)) as nvarchar(12))))
+ cast(cast(isnull(@AdjustedValue,0) as decimal(18,2)) as nvarchar(12)) + Char(13) + Char(10) +
'|Round off Amt.       :' + Space(12-len(cast(cast(isnull(RoundOffAmount,0) as decimal(18,2)) as nvarchar(12))))
+ cast(cast(isnull(RoundOffAmount,0) as decimal(18,2)) as nvarchar(12)) + Char(13) + Char(10) +
'|Net Amt. Payable     :' + Space(14-Len(cast(cast(isnull(Case InvoiceAbstract.InvoiceType When 4 Then  ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) Else ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) End ,0) as decimal(18,2)) as nvarchar(12)) + Char(13) + Char(10)))
+ cast(cast(isnull(Case InvoiceAbstract.InvoiceType When 4 Then  ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) Else ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) End ,0) as decimal(18,2)) as nvarchar(12)) + Char(13) + Char(10),
"CreditNoteDetails" = dbo.MERP_FN_GetCreditNoteDetails_DOS(@INVNO),
"CreditNoteDetails_GST" = dbo.MERP_FN_GetCreditNoteDetails_GST(@INVNO),
"Invoice Ref" = InvoiceAbstract.ReferenceNumber,
"Net Amount Payable" = cast(cast(isnull(Case InvoiceAbstract.InvoiceType
When 4 Then  ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) Else ((NetValue + RoundOffAmount) - (isnull(@AdjustedValue,0))) End ,0) as decimal(18,2)) as Nvarchar(12)) ,
"Total Tax Text" ='Total Tax Amount:' ,
"Tax Summary Text" = @GSTTaxSumText  ,
"TaxComp Text" = @GSTTaxCompText  ,
"GSTTaxComp" = @GSTTaxComp
--,"Tax Summary Text_DOS" = @GSTTaxCompText_DOS
--,"GSTTaxComp_DOS" = @GSTTaxComp_DOS
FROM InvoiceAbstract, Customer, VoucherPrefix Inv, VoucherPrefix InvA, Salesman2, Salesman,  Beat,
VoucherPrefix SR, CreditTerm,StateCode SCBilling ,StateCode SCShipping
WHERE InvoiceID = @INVNO
AND InvoiceAbstract.CustomerID = Customer.CustomerID
AND InvoiceAbstract.BeatID *= Beat.BeatID
AND SR.TranID = N'SALES RETURN'
AND InvA.TranID = N'INVOICE AMENDMENT'
AND Inv.TranID = N'INVOICE'
AND InvoiceAbstract.CreditTerm *= CreditTerm.CreditID
AND InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
AND InvoiceAbstract.Salesman2 *= Salesman2.SalesmanID
AND InvoiceAbstract.ToStateCode  *= SCBilling.StateID
AND customer.ShippingStateID *= SCShipping.StateID
