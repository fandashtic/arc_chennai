Create Procedure sp_Save_DandD_Invoice(@DandDID Int,@OperatingYear nvarchar(50) = '',@BackDated int = 0 )
As
Begin
Declare @GSTDocID int
Declare @GSTFullDocID nvarchar(250)
Declare @GSTVoucherPrefix nvarchar(50)
Declare @Year as nvarchar(20)
Declare @DandDInvID Int

Set DateFormat DMY

Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

Declare @Prefix nVarchar(50)
Select @Prefix = Prefix  From VoucherPrefix Where TranID = 'CLAIMS NOTE'

Declare @DandDRFATaxFlag int
Select @DandDRFATaxFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'DandDRFATax'

Declare @CompaniesToUploadCode nVarchar(255)
Declare @WDCode nVarchar(255)
Declare @WDDest nVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  (NoLock)
Select Top 1 @WDCode = RegisteredOwner From Setup (NoLock)

If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Declare @ClaimID Int
Declare @ActivityCode nVarChar(255)
Declare @ActivityType nVarChar(255)

IF Not Exists(Select 'x' From DandDAbstract DDA (NoLock) Join ClaimsNote CN (NoLock)
On CN.ClaimID = DDA.ClaimID And CN.ClaimType In (2) And IsNull(CN.ClaimRFA,0) = 0
Where DDA.ID = @DandDID And DDA.ClaimStatus = 3 And DDA.Flag = 1)
GoTo Nothing

Select @ClaimID = DDA.ClaimID, @ActivityType = 'Damages',
@ActivityCode = @Prefix + Cast(CN.DocumentID as nVarchar) + '/' +
SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 1, 2) +
SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 4, 2) +
SUBSTRING(CONVERT(nVarchar(30), dda.ClaimDate, 103), 7, 4)
From DandDAbstract DDA (NoLock)
Join ClaimsNote CN (NoLock) On CN.ClaimID = DDA.ClaimID And CN.ClaimType In (2) And IsNull(CN.ClaimRFA,0) = 0
Where DDA.ID = @DandDID And DDA.ClaimStatus = 3 And DDA.Flag = 1

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

Create Table #RFAInfo(  SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50),
Division nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,
SubCategory nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6), SaleValue Decimal(18, 6),
PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6), FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
RebateQty Decimal(18, 6), RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6),
TaxPercentage Decimal(18,6), TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),
SchemeDetail nVarchar(1000), Serial Int, Flagword Int, Amount Decimal(18, 6),
SchemeID Int, SlabID Int, PTR Decimal(18,6), TaxCode Decimal(18,6), BudgetedValue Decimal(18,6),
FreeSKUSerial Int,SalePrice Decimal(18,6),  UOM1Conv Decimal(18,6), UOM2Conv Decimal(18,6),
InvoiceType Int, SchemeOutlet Int, SchemeSKU Int Default(0), SchemeGroup Int, TotalPoints Decimal(18,6),
PointsValue Decimal(18,6), ReferenceNumber nVarchar(255), LoyaltyID nVarchar(255), CSSchemeID int,[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
SalvageQty Decimal(18,6), SalvageValue Decimal(18,6), DamageDesc nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
DamageDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,
SchemeFromDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,
SchemeToDate nVarchar(20) collate SQL_Latin1_General_CP1_CI_AS,DamageOption int,TOQ int,DandDGreen Int
,TaxableValue Decimal(18,6) ,HSN nVarChar(15) collate SQL_Latin1_General_CP1_CI_AS, TaxID Int, TaxType Int)

Insert Into #RFAInfo(BillRef, Serial, SKUCode, SaleQty, SaleValue, SchemeID, SchemeDetail , SalvageQty, SalvageValue,
DamageDesc, DamageDate,SchemeFromDate,SchemeToDate,RebateValue,DamageOption,DandDGreen,TaxableValue , HSN ,TaxID,TaxType)
Select '' as BillRef,
CD.Serial as Serial,
CD.Product_Code,
CD.Quantity,
--CD.Quantity * (CD.Rate + CD.Rate * (CD.TaxSuffPercent/100)) as SaleValue ,
--(select Case When @DandDRFATaxFlag = 0 Then Max(ddd.UOMTotalAmount) - Max(ddd.UOMTaxAmount) Else Max(ddd.UOMTotalAmount) End
--		From DandDAbstract dda, DandDDetail ddd
--where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
(select Max(ddd.UOMTotalAmount) - Max(ddd.UOMTaxAmount) From DandDAbstract dda, DandDDetail ddd
where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
CN.ClaimType as SchemeID,
CD.Batch_Code as SchemeDetail,
0,0,
--				(Select SUM(IsNull(ddd.SalvageQuantity, 0)) From DandDAbstract dda, DandDDetail ddd
--					Where dda.ID = ddd.ID And dda.ClaimID = CN.ClaimID And ddd.Product_Code = cd.Product_Code),
--				(Select SUM(IsNull(ddd.SalvageValue, 0)) From DandDAbstract dda, DandDDetail ddd
--					Where dda.ID = ddd.ID And dda.ClaimID = CN.ClaimID And ddd.Product_Code = cd.Product_Code),
--				IsNull((Select 'Damages' + MAX(dda.Remarks) + ' From ' + MAX(IsNull(dda.FromMonth, '')) + ' To ' + MAX(IsNull(dda.ToMonth, ''))
--								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), ''),
IsNull((Select 'Damages' + MAX(dda.RemarksDescription)
From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), ''),
--				IsNull((Select CONVERT(nVarchar(30), MAX(dda.ClaimDate), 103)
--								From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
IsNull((Select CONVERT(nVarchar(30), MAX(dda.DestroyedDate), 103)
From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
IsNull((Select case Max(dda.OptSelection) when 1 then CONVERT(nVarchar(30), MAX(dda.DayCloseDate), 103) Else CONVERT(nVarchar(30), MAX(dda.FromDate), 103) End
From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
IsNull((Select case Max(dda.OptSelection) when 1 then CONVERT(nVarchar(30), MAX(dda.DayCloseDate), 103) Else CONVERT(nVarchar(30), MAX(dda.ToDate), 103) End
From DandDAbstract dda Where dda.ClaimID = CN.ClaimID), '') ,
--  (select Case When @DandDRFATaxFlag = 0 Then (Max(ddd.UOMTotalAmount) - Max(ddd.UOMTaxAmount))- Max(ddd.SalvageUOMValue) Else Max(ddd.UOMTotalAmount) - Max(ddd.SalvageUOMValue) End
--		From DandDAbstract dda, DandDDetail ddd
--where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
(select  Max(ddd.UOMTotalAmount) - Max(ddd.SalvageUOMValue) From DandDAbstract dda, DandDDetail ddd
where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code),
(select Max(dda.OptSelection) From DandDAbstract dda where dda.ClaimID=CN.ClaimID),
IsNull((Select DandDGreen From DandDAbstract DDA where DDA.ClaimID  = CN.ClaimID),0)
,(Select Sum(DDD.BatchTaxableAmount)  From DandDAbstract dda, DandDDetail ddd
where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code)
,(Select MAX(HSNNumber) from Items where Product_Code = cd.Product_Code)
,(Select Max(DDD.TaxID)  From DandDAbstract dda, DandDDetail ddd
where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code)
,(Select Max(DDD.TaxType)  From DandDAbstract dda, DandDDetail ddd
where dda.ID=ddd.ID and dda.ClaimID=CN.ClaimID and ddd.product_Code=cd.Product_Code)
From ClaimsNote CN (NoLock), ClaimsDetail CD (NoLock)
Where CN.ClaimID = @ClaimID
And CN.ClaimID = CD.ClaimID
And IsNull(CN.Status, 0) <= 1
And IsNull(CN.ClaimRFA, 0) = 0
And CN.ClaimType In(2) /*3 - Sampling, 1 - Expiry, 2 - Damages*/

Declare @BatchCode int
Declare @PCode nvarchar(256)
Declare @SalesValue Decimal(18,6)
Declare @SalesQty Decimal(18,6)
Declare @RebateVal Decimal(18,6)
Declare UpdateSalesValue Cursor For Select Distinct SKUCode,SchemeDetail,SaleValue,SaleQty,RebateValue from #RFAInfo
Open UpdateSalesValue
Fetch from UpdateSalesValue into @PCode,@BatchCode,@SalesValue,@SalesQty,@RebateVal
While @@fetch_status=0
BEGIN
update R set Salevalue=T.SalValue From
(Select (isnull(@SalesValue,0)/Sum(isnull(SaleQty,0)))*@SalesQty as SalValue,@BatchCode as BatchCode from #RFAInfo
where SKUCode=@PCode) T,#RFAInfo R
Where T.BatchCode=R.SchemeDetail

update R set RebateValue=T.RebateValue From
(Select (isnull(@RebateVal,0)/Sum(isnull(SaleQty,0)))*@SalesQty as RebateValue,@BatchCode as BatchCode from #RFAInfo
where SKUCode=@PCode) T,#RFAInfo R
Where T.BatchCode=R.SchemeDetail

Fetch Next from UpdateSalesValue into @PCode,@BatchCode,@SalesValue,@SalesQty,@RebateVal
END
Close UpdateSalesValue
Deallocate UpdateSalesValue

Declare @SKUCode nVarchar(255)
Declare @Divison nVarchar(255)
Declare @DivID Int
Declare @SubCategory nVarchar(255)
Declare @SubCatID Int
Declare @MarketSKU nVarchar(255)
Declare @MarketSKUID Int
Declare @UOMID Int
Declare @UOM nVarchar(255)
/*Update SKU Category Levels and UOM - Start*/
Declare UpdateLevelCur Cursor For
Select Distinct SKUCode From #RFAInfo
Open UpdateLevelCur
Fetch Next From UpdateLevelCur Into @SKUCode
While (@@Fetch_Status = 0)
Begin
Select  @MarketSKU = Category_Name, @MarketSKUID = CategoryID, @SubCatID = ParentID
From ItemCategories(NoLock) Where CategoryID = (Select CategoryID From Items (NoLock) Where Product_Code = @SKUCode )
Select @SubCategory = Category_Name, @DivID = ParentID From ItemCategories (NoLock) Where CategoryID = @SubCatID
Select @Divison = Category_Name From ItemCategories (NoLock) Where CategoryID = @DivID

Select @UOM = Description From UOM (NoLock) Where UOM = (Select UOM From Items (NoLock) Where Product_Code = @SKUCode)

Update #RFAInfo Set LineType = 'MAIN', Division = @Divison, SubCategory = @SubCategory, MarketSKU = @MarketSKU, UOM = @UOM
Where SKUCode = @SKUCode

Fetch Next From UpdateLevelCur Into @SKUCode
End
Close UpdateLevelCur
Deallocate UpdateLevelCur

Create Table #TmpSalvageDetails(Product_code nvarchar(256) collate SQL_Latin1_General_CP1_CI_AS,SalvageQty decimal(18,6),SalvageValue decimal(18,6),UOM int)
Insert into #TmpSalvageDetails(Product_code,SalvageQty,SalvageValue,UOM)
Select distinct DD.Product_code,max(DD.SalvageQuantity),Max(DD.SalvageValue),Max(SalvageUOM) from DandDDetail DD, DandDAbstract DA where
DA.ID=DD.ID and DA.ClaimID=@ClaimID
Group by DD.Product_code

Select  DandDID , Product_Code, Tax_Code ,Batch_Code ,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End),
CCESSPer = Max(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.Tax_Percentage Else 0 End),
CCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From DandDTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where ITC.DandDID = @DandDID
Group By DandDID, Product_Code, Tax_Code,Batch_Code

BEGIN TRAN
--UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 107
--Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 107
--Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'DAMAGE INVOICE'
--Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 107 and OperatingYear = @OperatingYear
Select @GSTDocID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = 107  and OperatingYear = @OperatingYear
Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'DAMAGE INVOICE'
Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
COMMIT TRAN

Insert Into DandDInvAbstract (DandDInvDate,CustomerID, GSTDocID, GSTFullDocID, DandDID,  ClaimID,  SubmissionDate,
[SchemeType], [ActivityCode], [Description] , [ActiveFrom], [ActiveTo] , [PayoutFrom] , [PayoutTo],
[DamageOption] , [UserName], [GreenDandD] ,[TaxAmount],  [ClaimAmount] , [Balance],GSTIN,FromStateCode ,ToStateCode)
Select DDA.DestroyedDate, DDA.CustomerID , @GSTDocID, @GSTFullDocID , @DandDID , @ClaimID, GETDATE(),
@ActivityType, @ActivityCode, DandDDesc='Damages' + DDA.RemarksDescription,
IsNull((case DDA.OptSelection when 1 then DDA.DayCloseDate Else  DDA.FromDate End), '') ,
IsNull((case DDA.OptSelection when 1 then DDA.DayCloseDate Else  DDA.ToDate End), '') ,
IsNull((DDA.DestroyedDate), ''), IsNull((DDA.DestroyedDate), ''),
--IsNull((case DDA.OptSelection when 1 then CONVERT(nVarchar(30), DDA.DayCloseDate, 103) Else CONVERT(nVarchar(30), DDA.FromDate, 103) End), '') ,
--IsNull((case DDA.OptSelection when 1 then CONVERT(nVarchar(30), DDA.DayCloseDate, 103) Else CONVERT(nVarchar(30), DDA.ToDate, 103) End), '') ,
--IsNull((CONVERT(nVarchar(30), DDA.DestroyedDate, 103)), ''), IsNull((CONVERT(nVarchar(30), DDA.DestroyedDate, 103)), ''),
Case DDA.OptSelection  when 1 then 'Day Close Date' Else 'Month Selection' End , DDa.UserName, DDA.DandDGreen,
(Select Sum(SGSTAmt + UTGSTAmt + CGSTAmt + IGSTAmt + CESSAmt + ADDLCESSAmt + IsNull(CCESSAmt,0))  From #TempTaxDet TTD),
DDA.ClaimValue, DDA.ClaimValue, DDA.GSTIN , DDA.FromStateCode, DDA.ToStateCode
From DandDAbstract DDA Where DDA.ID = @DandDID

Set @DandDInvID = @@IDENTITY

Insert Into DandDInvDetail (DandDInvID, [Division], [SubCategory], [MarketSKU], [SystemSKU], [UOM] , [SaleQty] , [SaleValue] ,[RebateValue] ,	[SalvageQty],[SalvageValue] ,
TaxableValue,HSN,TaxCode ,TaxType ,
[TotalTaxAmount] , [CGSTRate] ,	[CGSTAmount] ,	[SGSTRate] ,	[SGSTAmount] ,	[IGSTRate] ,	[IGSTAmount] ,	[CessRate] ,	[CessAmount] ,	[AddlCessRate] ,	[AddlCessAmount], [CCESSRate], [CCESSAmount])
Select  @DandDInvID,
--@WDCode as WDCode,  @WDDest as WDDest,
--Case @ActivityType When 'Expiry' Then 'Damages' Else 'Damages' End as SchemeType,
--@ActivityCode as ActivityCode,
--Case @ActivityType When 'Expiry' Then 'Damages' Else DamageDesc End as ActivityDesc,
--Case @ActivityType When 'Damages' Then SchemeFromDate End as ActiveFrom,
--Case @ActivityType When 'Damages' Then SchemeToDate End as ActiveTo,
--Case @ActivityType When 'Damages' Then DamageDate End as PayoutFrom,
--Case @ActivityType When 'Damages' Then DamageDate End as PayoutTo,
Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM,Sum(SaleQty) as SaleQty, Sum(SaleValue) as SaleValue,
sum(isnull(RebateValue,0)) as RebateValue,
max(IsNull(T.SalvageQty, 0)) As SalvageQty, max(IsNull(T.SalvageValue, 0)) As SalvageValue,
--Null as PromotedQty, Null as PromotedValue, Null as FreeBaseUOM, Null as RebateQty,
--sum(isnull(RebateValue,0)) as RebateValue,
--Null as BudgetedQty, Null as BudgetedValue, Null as AppOn,
--Case Max(DamageOption) when 1 then 'Day Close Date' Else 'Month Selection' End as DamageOption,
--Max(DandDGreen),
TaxableValue = Max(#RFAInfo.TaxableValue), HSN = Max(#RFAInfo.HSN),TaxCode=Max(#RFAInfo.TaxID) , TaxType = MAX(#RFAInfo.TaxType),
TotTaxamt =(Select Sum(SGSTAmt + UTGSTAmt + CGSTAmt + IGSTAmt + CESSAmt + ADDLCESSAmt + IsNull(CCESSAmt,0))  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
CGSTRate = (Select Max(CGSTPer)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
CGSTAmt = (Select Sum(CGSTAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
SGSTRate = (Select Max(SGSTPer + UTGSTPer)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
SGSTAmt = (Select Sum(SGSTAmt + UTGSTAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
IGSTRate = (Select Max(IGSTPer)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
IGSTAmt = (Select Sum(IGSTAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
CESSRate = (Select Max(CESSPer )  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
CESSAmt = (Select Sum(CESSAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
ADDLCESSRate = (Select Max(ADDLCESSPer)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode),
ADDLCESSAmt = (Select Sum(ADDLCESSAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),
CCESSRate = IsNull((Select Max(CCESSPer)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode),0),
CCESSAmt = IsNull((Select Sum(CCESSAmt)  From #TempTaxDet TTD where TTD.Product_Code = #RFAInfo.SKUCode ),0)
From #RFAInfo,#TmpSalvageDetails T
Where T.Product_code =#RFAInfo.SKUCode
Group By Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM, DamageDesc, DamageDate, SchemeFromDate,SchemeToDate
Order by Division, SubCategory, MarketSKU, SKUCode, #RFAInfo.UOM, DamageDesc, DamageDate, SchemeFromDate,SchemeToDate

Update DandDAbstract Set DandDInvoiceID = @DandDInvID Where ID = @DandDID

Update ClaimsNote Set ClaimRFA = 1 where ClaimID = @ClaimID

--Account Posting	Start

Declare @DocumentID Int
Declare @UniqueID Int
Declare @nClaimValue Decimal(18,6)
Declare @nDamageValue Decimal(18,6)
Declare @nTaxValue Decimal(18,6)
Declare @CustomerID nVarChar(30)
Declare @AccountID Int
Declare @ndoctype Int
Declare @dclaimdate DateTime

Set @ndoctype=155   /*constant to store document type Account*/

Select @CustomerID = DDIA.CustomerID , @dclaimdate = DDIA.DandDInvDate ,
@nClaimValue = ClaimAmount,  @nDamageValue= ClaimAmount-TaxAmount, @nTaxValue= TaxAmount
From DandDInvAbstract DDIA Where DDIA.DandDInvID = @DandDInvID

Select Top 1 @AccountID = AccountID From Customer Where CustomerID = @CustomerID

begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 24
commit tran
begin tran
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
commit tran

-- Account
IF @nclaimvalue <> 0 And @AccountID <> 0
Begin
Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
Values(@documentid,5,@dclaimdate,0,@nDamageValue,@DandDInvID,@ndoctype,'DandD Invoice',@uniqueid)

Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
Values(@documentid,@accountid,@dclaimdate,@nclaimvalue,0,@DandDInvID,@ndoctype,'DandD Invoice',@uniqueid)
End

Insert Into #TempBackdatedAccounts(AccountID) Values(5)   -- Sales Account
Insert Into #TempBackdatedAccounts(AccountID) Values(@accountid)

Create Table #GSTaxCalc(Id int identity(1,1),DandDID int,Tax_Component_Code int,Tax_Value Decimal(18,6), GST_Flag  int)

Insert Into #GSTaxCalc
(DandDID, Tax_Component_Code, Tax_Value, GST_Flag)
Select DandDID, Tax_Component_Code, SUM(Tax_Value), tx.GSTFlag
From DandDTaxComponents	bl(NOLOCK)
JOIN Tax tx(NOLOCK)	ON (tx.Tax_Code = bl.Tax_Code AND ISNULL(tx.GSTFlag,0)= 1)
Where DandDID = @DandDID
Group By Tax_Component_Code,DandDID,tx.GSTFlag

Declare @GSTCount Int
Declare @RowId Int
DECLARE	@GSTPayable INT
DECLARE	@GSTaxComponent INT
DECLARE	@nGSTaxAmt Decimal(18,6)

Select @GSTCount = MAX(ID) from #GSTaxCalc

IF (@GSTCount > 0)
Begin
Select @RowId = 1
While (@RowId <= @GSTCount)
Begin
Select @GSTaxComponent = Tax_Component_Code, @nGSTaxAmt	= Tax_Value	From #GSTaxCalc
Where ID = @RowId

IF @nGSTaxAmt <> 0
Begin
Select @GSTPayable = OutputAccID From TaxComponentDetail(nolock)
Where TaxComponent_Code = @GSTaxComponent

--Entry for GS Tax Accounts
IF ((isnull(@GSTPayable,0) > 0) And @nGSTaxAmt > 0 )
Begin
Insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
Values(@DocumentID,@GSTPayable,@dclaimdate,0,@nGSTaxAmt,@DandDInvID,@nDocType,'DandD Invoice',@UniqueID)

Insert Into #TempBackdatedAccounts(AccountID) Values(@GSTPayable)
End
End
Select @RowId = @RowId+1
End
End
--Account Posting	End

/* BackDated Operation */
IF isnull(@BackDated,0) > 0
Begin
Declare @TempAccountID Int

DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
Select Distinct AccountID From #TempBackdatedAccounts
OPEN scantempbackdatedaccounts
FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
WHILE @@FETCH_STATUS = 0
Begin
Exec sp_acc_backdatedaccountopeningbalance @dclaimdate,@TempAccountID
FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
End
CLOSE scantempbackdatedaccounts
DEALLOCATE scantempbackdatedaccounts
End

Drop Table #TempBackdatedAccounts
Drop Table #RFAInfo
Drop Table #TmpSalvageDetails
Drop Table #TempTaxDet
Drop Table #GSTaxCalc

Nothing:
End
