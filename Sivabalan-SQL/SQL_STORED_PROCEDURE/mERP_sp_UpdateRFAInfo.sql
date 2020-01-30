Create Procedure mERP_sp_UpdateRFAInfo(@InvoiceDate DateTime)
As
Begin
Declare @SchemeID Int
Declare @InvPrefix nVarchar(10)
Declare @ApplicableOn nVarchar(255)
Declare @ItemGroup Int
Declare @Serial Int
Declare @FlagWord Int
Declare @Amount Decimal(18, 6)
Declare @InvoiceID Int
Declare @SchemeDetail nVarchar(1000)
Declare @SRSchemeDetail_Tax nVarchar(1000)
Declare @SchemeAmt Decimal(18, 6)
Declare @SchemePerc Decimal(18, 6)
Declare @SRSchemeAmt_Tax Decimal(18, 6)
Declare @SKUCode nVarchar(255)
Declare @UOMID Int
Declare @UOM nVarchar(255)
Declare @SaleQty Decimal(18,6)
Declare @FreeQty Decimal(18,6)
Declare @FreeValue Decimal(18,6)
Declare @FreeValue_Tax Decimal(18,6)
Declare @PTR Decimal(18,6)
Declare @SlabID Int
Declare @PromotedQty Decimal(18,6)
Declare @PromotedValue Decimal(18,6)
Declare @ClaimID Int
Declare @FreeSKUSerial Int
Declare @TaxCode Decimal(18,6)
Declare @CustomerID nVarchar(255)
Declare @RCSID nVarchar(255)
Declare @SRNo Int
Declare @PrevSKUCode nVarchar(255)
Declare @SaleValue Decimal(18,6)
Declare @FreeFlag Int
Declare @DocumentID Int
Declare @InvoiceType Int
Declare @RebateQty Decimal(18,6)
Declare @RebateValue Decimal(18,6)
Declare @Qty Decimal(18,6)
Declare @Value Decimal(18,6)
Declare @SchemeGroup Int
Declare @SchemeOutlet nVarchar(255)
Declare @BillRef nVarchar(255)
Declare @SR Int
Declare @InvRebateValue Decimal(18,6)
Declare @SRRebateValue Decimal(18,6)
Declare @OutletCode nVarchar(255)
Declare @InvSRID Int
Declare @MarginPTR Decimal(18,6)
Declare @QPS Int

Declare @TaxOnQty int
Declare @Scheme_TLCFlag int

/* New InvoiceID */
Declare @InvID Int


Set @FreeFlag = 0

Select @InvPrefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'

Create Table #RFAInfo(SR Int Identity , InvoiceID Int, BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS, LineType nVarchar(50),
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
RebateValue_Tax Decimal(18,6),SRSchemeDetail_Tax nVarchar(1000) collate SQL_Latin1_General_CP1_CI_AS,TaxOnQty int)

Create Table #RFADetail	(SR Int, Flagword Int, InvoiceID Int, SchemeID Int,
BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
OutletCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
ActiveInRCS nVarchar(100) collate SQL_Latin1_General_CP1_CI_AS,
LineType nVarchar(50) collate SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, SaleQty Decimal(18, 6),
SaleValue Decimal(18, 6),PromotedQty Decimal(18, 6), PromotedValue Decimal(18, 6),RebateQty Decimal(18, 6),
RebateValue Decimal(18, 6), PriceExclTax Decimal(18, 6), TaxPercentage Decimal(18,6),
TaxAmount Decimal(18, 6), PriceInclTax Decimal(18, 6),BudgetedQty Decimal(18,6),BudgetedValue Decimal(18,6),
InvoiceType Int,[Doc No]  nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
SlabID Int, FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, PrimarySerial Int, FreeSerial Int,RebateValue_Tax Decimal(18,6),TaxOnQty int)

/* Table Not required as SalesQty updation cannot be done here */

--	Create Table #tmpSKUWiseSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS ,SalesQty Decimal(18,6),SalesValue Decimal(18,6))
--
--	/* Table Used to store the Total Sales qty and Volume SKUWise Starts */
--	Create Table #tmpSales(SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
--					   SaleQty Decimal(18,6),SaleValue Decimal(18,6),
--						Flagword Int,InvoiceType Int)

Create Table #tmpRFADet(InvoiceID Int, InvoiceType Int,
SR Int,BillRef nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
OutletCode nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
RCSID nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
ActiveInRCS nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
LineType nVarchar(25) collate SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
UOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS,
SaleQty Decimal(18,6),SaleValue Decimal(18,6),
PromotedQty Decimal(18,6),PromotedValue Decimal(18,6),
RebateQty Decimal(18,6),RebateValue Decimal(18,6), RebateValue_Tax Decimal(18,6),
PriceExclTax Decimal(18,6),TaxPercentage Decimal(18,6),TaxAmount Decimal(18,6),
PriceInclTax Decimal(18,6),BudgetedQty Decimal(18,6),
BudgetedValue Decimal(18,6),OutletName nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
[Doc No] nVarchar(500) collate SQL_Latin1_General_CP1_CI_AS,
SlabID Int,FreeBaseUOM nVarchar(255) collate SQL_Latin1_General_CP1_CI_AS, PrimarySerial Int, FreeSerial Int,TaxOnQty int)

--	Create Table #tmpSerial(Serial Int)

Create Table #NonQPSData (InvoiceID Int,
CustomerID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
SchemeID Int,
BillRef	NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceType	Int,
Product_Code NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Type] Int,
SlabID Int,
InvoiceDate	Datetime,
SaleQty Decimal(18,6),
SaleValue	Decimal(18,6),
RebateQty Decimal(18,6),
RebateValue	Decimal(18,6),
RebateValue_Tax	Decimal(18,6),
PromotedQty	Decimal(18,6),
PromotedValue Decimal(18,6),
RebateUOM Int,
PromotedUOM	Int,
PriceExclTax Decimal(18, 6),
TaxPercent Decimal(18,6),
TaxAmount Decimal(18,6),
PriceInclTax Decimal(18, 6),
Serial Int,
PrimarySerial Int,
FreeSerial Int,
OriginalInvDate Datetime,
DayCloseDate Datetime,
CreationDate Datetime,TaxOnQty int
)

/*To get Schemes applied on the particular Date - Start*/
Declare @SchInfo nVarchar(4000)
Create Table #Scheme(InvoiceID Int,Scheme Int)
Create Table #SchInfo(InvoiceID Int,SchemeInfo nVarchar(4000))

Insert Into #SchInfo
Select ID.InvoiceID,ID.MultipleSchemeDetails
From InvoiceAbstract IA, InvoiceDetail ID
Where IA.InvoiceID = ID.InvoiceID
And IA.InvoiceType In (1,3,4)
And (IA.Status & 128) = 0
And dbo.StripTimeFromDate(IA.InvoiceDate) = dbo.StripTimeFromDate(@InvoiceDate)
And (IsNull(ID.MultipleSchemeDetails, '') <> '' )
Union
Select ID.InvoiceID,ID.MultipleSplCategorySchDetail
As SchemeID
From InvoiceAbstract IA, InvoiceDetail ID
Where IA.InvoiceID = ID.InvoiceID
And IA.InvoiceType In (1,3,4)
And (IA.Status & 128) = 0
And dbo.StripTimeFromDate(IA.InvoiceDate) = dbo.StripTimeFromDate(@InvoiceDate)
And IsNull(ID.MultipleSplCategorySchDetail, '') <> ''
Union
Select IA.InvoiceID,IA.MultipleSchemeDetails
From InvoiceAbstract IA
Where IA.InvoiceType In (1,3,4)
And (IA.Status & 128) = 0
And dbo.StripTimeFromDate(IA.InvoiceDate) = dbo.StripTimeFromDate(@InvoiceDate)
And IsNull(IA.MultipleSchemeDetails, '') <> ''

Declare SchIDCursor Cursor For
Select Distinct InvoiceID,SchemeInfo From #SchInfo Where IsNull(SchemeInfo, '') <> ''
Open SchIDCursor
Fetch Next From SchIDCursor Into @InvID,@SchInfo
While (@@Fetch_Status = 0)
Begin
Insert Into #Scheme	Select @InvID,SchemeID From dbo.mERP_fn_GetInvSchemeDetail(0, @SchInfo, 0, 0, 0)
Fetch Next From SchIDCursor Into @InvID,@SchInfo
End
Close SchIDCursor
Deallocate SchIDCursor

/*To get Schemes applied on the particular Date - End*/



Declare SchCursor Cursor For
Select Distinct [Scheme] From #Scheme
Open SchCursor
Fetch Next From SchCursor Into @SchemeID
While (@@Fetch_Status = 0)
Begin --SchCursor Begin
Select
@ApplicableOn = Case When SA.ApplicableOn =1 And SA.ItemGroup = 1 Then 'ITEM'
When SA.ApplicableOn =1 And SA.ItemGroup = 2 Then 'SPL_CAT'
When SA.ApplicableOn = 2 Then 'INVOICE'
End,
@ItemGroup = Itemgroup,
@Scheme_TLCFlag = isnull(TLCFlag,0)
From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeType ST
Where SA.SchemeID = @SchemeID
And SA.SchemeType = ST.ID

--Select @QPS = QPS From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID And QPS = 1
--Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) From tbl_mERP_SchemeSlabDetail Where SchemeID = @SchemeID

/*  Table Used to store the Total Sales qty and Volume SKUWise Ends*/
Select @QPS = isNull(QPS,0) From tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID And isNull(QPS,0) = 0

If @QPS = 0  /* Non QPS Scheme starts here */
Begin
If @ApplicableOn = 'ITEM' Or @ApplicableOn = 'SPL_CAT'
Begin/*Trade - Item based schemes - Start*/
/*Select scheme products*/

Insert Into #RFAInfo(InvoiceId, BillRef, OutletCode, RCSID, LineType,
SKUCode, UOM, SaleQty, SaleValue, PromotedQty, PromotedValue, FreeBaseUOM, RebateQty,
RebateValue, PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax, SchemeDetail,
Serial, Flagword, Amount, SchemeID, SlabID, PTR,  BudgetedValue, FreeSKUSerial,
SalePrice, InvoiceType, ReferenceNumber,[Doc No], TaxCode,SRSchemeDetail_Tax,TaxOnQty)
Select IA.InvoiceID,
--@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef,
Case IsNULL(IA.GSTFlag ,0)
When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
Else
IsNULL(IA.GSTFullDocID,'')
End  as BillRef,
C.CustomerID as OutletCode,
IsNull(C.RCSOutletID, '') as RCSID,
(Case When InvoiceType <> 4 Then
Case IsNull(ID.Flagword, 0)
When 1 then 'Free'
Else 'MAIN'
End
Else
Case When IA.Status & 32 <> 0 Then 'Sales Return - Damaged'
Else 'Sales Return - Saleable'
End
End)
as LineType,
ID.Product_Code as SKUCode,
'' as UOM,
Case ID.FlagWord
When 0 Then ID.Quantity
Else 0 End	as SaleQty,
Case ID.FlagWord
When 0 Then ID.SalePrice * ID.Quantity
Else 0 End	as SaleValue,
Null as PromotedQty,
Null as PromotedValue,
Null as FreeBaseUOM,
Case ID.FlagWord
When 1 Then ID.Quantity
Else 0 End as RebateQty,
Null as RebateValue,
Null as PriceExclTax,
ID.TaxCode as TaxPercentage,
Null as TaxAmount,
Null as PriceInclTax,
Case InvoiceType When 4 Then dbo.fn_Get_ItemSchemeDetail_SR(ID.InvoiceID,@SchemeID,ID.Product_Code,0,ID.Serial)
Else
Case @ItemGroup
When 1 Then IsNull(ID.MultipleSchemeDetails, '')
When 2 Then IsNull(ID.MultipleSplCategorySchDetail, '')
End
End as SchemeDetail,
ID.Serial,
ID.FlagWord,
Case ID.FlagWord
When 1 Then	ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID))
Else 0 End as Amount,
0 as SchemeID,
0 as SlabID,
Case ID.FlagWord
When 1 Then dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID)
Else ID.PTR End as PTR,
0 as BudgetedValue,
0 as FreeSKUSerial,
ID.SalePrice as SalePrice,
IA.InvoiceType,
IA.ReferenceNumber,
IA.DocReference,
ID.TaxCode,
Case InvoiceType When 4 Then dbo.fn_Get_ItemSchemeDetail_SR(ID.InvoiceID,@SchemeID,ID.Product_Code,1,ID.Serial)
Else
''
End,isnull(ID.TaxOnQty,0)
From InvoiceAbstract IA, Customer C,
(Select InvDt.InvoiceID, IsNull(InvDt.Flagword,0) Flagword, InvDt.Product_Code, InvDt.SalePrice, Max(InvDt.TaxCode) TaxCode, InvDt.Serial, Max(InvDt.PTR) PTR,
IsNull(InvDt.MultipleSchemeDetails, '') MultipleSchemeDetails, IsNull(InvDt.MultipleSplCategorySchDetail, '') MultipleSplCategorySchDetail, Sum(InvDt.Quantity) Quantity,InvDt.TaxOnQty
From InvoiceDetail InvDt, InvoiceAbstract InvAb
Where InvAb.InvoiceID = InvDt.InvoiceID
And InvAb.InvoiceType In (1,3,4)
And (InvAb.Status & 128) = 0
And dbo.StripTimeFromDate(InvAb.InvoiceDate) = @InvoiceDate
Group By InvDt.InvoiceID, IsNull(InvDt.Flagword,0), InvDt.Product_Code, InvDt.SalePrice, InvDt.Serial, IsNull(InvDt.MultipleSchemeDetails, ''), IsNull(InvDt.MultipleSplCategorySchDetail, ''),InvDt.TaxOnQty) ID
Where IA.InvoiceId = ID.InvoiceId
And IA.InvoiceType In (1,3,4)
And (IA.Status & 128) = 0
And IA.CustomerID = C.CustomerID
And dbo.StripTimeFromDate(IA.InvoiceDate) = @InvoiceDate
And IA.InvoiceID In(Select Distinct InvoiceID From #Scheme Where [Scheme] = @SchemeID)


Update R1 Set TaxCode = (Select Max(TaxCode) From #RFAInfo Where InvoiceID = R1.InvoiceID And Serial = R1.Serial)
From #RFAInfo R1

/*SchemeGoup Not used anywhere hence updation of schemegourp not required ,
ActiveInRCS will be updated in the mERP_sp_GetRFAData SP hence not required*/

--					Declare SchemeOutletCur Cursor For
--					Select Distinct OutletCode From #RFAInfo
--					Open SchemeOutletCur
--					Fetch Next From SchemeOutletCur Into @CustomerID
--					While (@@Fetch_Status = 0)
--					Begin
--						Select @SchemeOutlet = 0, @SchemeGroup = GroupID From dbo.mERP_fn_CheckTradeSchemeOutlet(@SchemeID, @CustomerID)
--						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup
--							Where OutletCode = @CustomerID
--						Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'')
--							From Cust_TMD_Master CTM, Cust_TMD_Details CTD
--							Where CTM.TMDID = CTD.TMDID
--							And CTD.CustomerID = @CustomerID
--							And OutletCode = @CustomerID
--						Fetch Next From SchemeOutletCur Into @CustomerID
--					End
--					Close SchemeOutletCur
--					Deallocate SchemeOutletCur




Update #RFAInfo Set SchemeOutlet = 0

/*Delete non scheme Outlet*/
Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2

/* Update UOM */
Update RFA Set UOM = U.Description
From #RFAInfo RFA,Items I , UOM U
Where RFA.SKUCode = I.Product_Code And
I.UOM = U.UOM

/*Update Rebate Value - Start*/
Declare UpdateRebateCur Cursor For
Select Distinct InvoiceID, IsNull(SchemeDetail, ''), Serial, FlagWord, Sum(Amount) ,isNull(SRSchemeDetail_Tax,''),TaxOnQty
From #RFAInfo
Where SchemeOutlet = 0
Group By InvoiceID, IsNull(SchemeDetail, ''), Serial, FlagWord,isNull(SRSchemeDetail_Tax,''),TaxOnQty
Open UpdateRebateCur
Fetch Next From UpdateRebateCur Into @InvoiceID, @SchemeDetail, @Serial, @FlagWord, @Amount,@SRSchemeDetail_Tax,@TaxOnQty
While (@@Fetch_Status = 0)
Begin
Set @SchemeAmt = 0
Set @SlabID = 0
If @FlagWord = 1
Begin
/*Update Scheme cost of Free Qty of given scheme*/
If ((Select Count(*) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0) Where SchemeID = @SchemeID) > 0)
Begin
If (Select Count(*) From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial) > 1
Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial
Else
Set @SR = 0

If @SR = 0
BEGIN
if @TaxOnQty = 0
BEGIN
/*Update Tax info only for Free qty schemes*/
Update #RFAInfo Set RebateValue = @Amount,RebateValue_Tax = @Amount + (@Amount * (TaxCode / 100)) ,  PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * (PTR * (TaxCode / 100)), PriceInclTax =  PTR + (PTR * (TaxCode / 100))
Where InvoiceID = @InvoiceID  And Serial = @Serial
END
ELSE
BEGIN
/*Update Tax info only for Free qty schemes*/
Update #RFAInfo Set RebateValue = @Amount,
RebateValue_Tax = @Amount+(RebateQty * TaxCode) ,
PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * TaxCode, PriceInclTax =  PTR + TaxCode
Where InvoiceID = @InvoiceID  And Serial = @Serial
END
END
Else
BEGIN
if @TaxOnQty = 0
Update #RFAInfo Set RebateValue = @Amount,RebateValue_Tax = @Amount + (@Amount * (TaxCode / 100)), PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * (PTR * (TaxCode / 100)), PriceInclTax =  PTR + (PTR * (TaxCode / 100))
Where InvoiceID = @InvoiceID  And Serial = @Serial And SR = @SR
ELSE

Update #RFAInfo Set RebateValue = @Amount,RebateValue_Tax = @Amount + (RebateQty * TaxCode), PriceExclTax = PTR, TaxPercentage = TaxCode, TaxAmount = RebateQty * (TaxCode), PriceInclTax =  PTR + ((TaxCode))
Where InvoiceID = @InvoiceID  And Serial = @Serial And SR = @SR
END
Update #RFAInfo Set SchemeID = @SchemeID Where InvoiceID = @InvoiceID  And Serial = @Serial
End
Else
Begin

Update #RFAInfo Set RebateValue = 0, RebateQty = 0,RebateValue_Tax = 0
Where InvoiceID = @InvoiceID  And Serial = @Serial

End
End
Else
Begin

/*Check for FreeQty slab*/
/*This is just to chk whehter given FreeQty scheme applied for this primary item*/
Set @SlabID = (Select dbo.mERP_fn_CheckPrimarySKU(@InvoiceID, @SchemeID, @Serial))
If (@SlabID > 0)
Begin
if @TaxOnQty =0
BEGIN
Update #RFAInfo Set SchemeID = @SchemeID, SlabID = @SlabID, PriceExclTax = PTR, TaxPercentage = TaxCode,
TaxAmount = (PTR * (TaxCode / 100)),
PriceInclTax =  PTR + (PTR * (TaxCode / 100))
Where InvoiceID = @InvoiceID And Serial = @Serial
END
ELSE
BEGIN
Update #RFAInfo Set SchemeID = @SchemeID, SlabID = @SlabID, PriceExclTax = PTR, TaxPercentage = TaxCode,
TaxAmount = TaxCode,
PriceInclTax =  PTR + TaxCode
Where InvoiceID = @InvoiceID And Serial = @Serial
END
End
If IsNull(@SchemeDetail, '') <> ''
Begin
/*Scheme Percentage taken for SalesReturn Invoices having Primary item value as Zero*/
Set @SchemePerc = 0
/*Scheme cost for Amt Or Per scheme*/
Select @SchemeAmt = SchAmt ,@SlabID = SlabID, @SchemePerc=SchPer From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0)
Where SchemeID = @SchemeID

Set @SRSchemeAmt_Tax = 0


/*To update the Rebatevalue with tax column in case of SR Invoice*/
/*Both for Item Based percentage and Amount scheme RebateValue and RebateValue_Tax
will be the same in case of Normal Invoice.
But in SalesReturn Scheme% for PrimaryItem will be calculated based on the RebateValue of the
Free Item if any given for the primary item in its corresponding invoice.Rebate Value for the
Free item will be based on the Taxconfig , Hence both the value with and without tax stored separately
*/
If isNull(@SRSchemeDetail_Tax,'') <> ''
Begin
Select @SRSchemeAmt_Tax = SchAmt From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SRSchemeDetail_Tax, @FlagWord, 0, 0)
Where SchemeID = @SchemeID
End


If @SchemeAmt > 0 Or @SlabID > 0
Begin
If (Select Count(*) From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial) > 1
Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial
Else
Set @SR = 0
If @SR = 0
Begin
Update #RFAInfo Set RebateValue = @SchemeAmt ,RebateValue_Tax = (Case When @SRSchemeAmt_Tax = 0 Then @SchemeAmt Else @SRSchemeAmt_Tax End) Where InvoiceID = @InvoiceID And Serial = @Serial
End
Else
Begin
Update #RFAInfo Set RebateValue = @SchemeAmt, SlabID = @SlabID,
RebateValue_Tax = (Case When @SRSchemeAmt_Tax = 0 Then @SchemeAmt Else @SRSchemeAmt_Tax End)
Where InvoiceID = @InvoiceID And Serial = @Serial And SR = @SR
End
--Update #RFAInfo Set SlabID = @SlabID Where InvoiceID = @InvoiceID And Serial = @Serial
Update #RFAInfo Set SchemeID = @SchemeID, SlabID = @SlabID  Where InvoiceID = @InvoiceID  And Serial = @Serial
End


IF @SchemePerc > 0
Begin
Update #RFAInfo Set SchemeID = @SchemeID Where InvoiceID = @InvoiceID  And Serial = @Serial
End
End
End
Fetch Next From UpdateRebateCur Into @InvoiceID, @SchemeDetail, @Serial, @FlagWord, @Amount,@SRSchemeDetail_Tax,@TaxOnQty
End
Close UpdateRebateCur
Deallocate UpdateRebateCur
/*Update Rebate Value - End*/

If @ItemGroup = 2 --And @FreeFlag = 1
Begin
Declare UpdateFreeInfoCur Cursor For
Select InvoiceID, Sum(SaleQty)  From #RFAInfo
Where SchemeID = @SchemeID
And IsNull(FlagWord, 0) = 0
And SchemeOutlet = 0
Group By InvoiceId
Open UpdateFreeInfoCur
Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SaleQty
While (@@Fetch_Status = 0)
Begin
Select @FreeQty = Sum(RebateQty), @FreeValue = Sum(RebateValue),@FreeValue_Tax = Sum(RebateValue_Tax) From #RFAInfo Where InvoiceID  = @InvoiceID And IsNull(Flagword, 0) = 1
If @FreeQty > 0
Begin
Set @FreeFlag = 1
Update #RFAInfo Set RebateQty =  (@FreeQty/@SaleQty) * SaleQty,
RebateValue = (@FreeValue/@SaleQty) * SaleQty ,
RebateValue_Tax = (@FreeValue_Tax/@SaleQty) * SaleQty
Where InvoiceID = @InvoiceID And IsNull(Flagword, 0) = 0
End
Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SaleQty
End
Close UpdateFreeInfoCur
Deallocate UpdateFreeInfoCur
Update #RFAInfo Set RebateQty = (-1) * RebateQty, RebateValue = (-1) * RebateValue,RebateValue_Tax = (-1) * RebateValue_Tax Where InvoiceType = 4
End
Else
Begin
/*Update FreeQty Info of a Primary SKU - Start*/
/*Done separately to get cumulative value of PrimarySKU*/
Declare UpdateFreeInfoCur Cursor For
Select InvoiceID, SKUCode, Min(Serial), Sum(SaleQty), Sum(SalePrice), Max(TaxCode) From #RFAInfo
Where SchemeID = @SchemeID
And IsNull(FlagWord, 0) = 0
And SchemeOutlet = 0
Group By InvoiceId, SKUCode, IsNull(FlagWord, 0)
Open UpdateFreeInfoCur
Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SKUCode, @Serial, @SaleQty, @SaleValue, @TaxCode
While (@@Fetch_Status = 0)
Begin
Select @FreeSKUSerial = FreeSKUSerial, @UOM = FreeUOM, @FreeQty = FreeQty, @FreeValue = FreeValue ,@FreeValue_Tax = FreeValue_Tax From dbo.mERP_fn_GetFreeSKUInfo(@InvoiceID, @SchemeID, @Serial,@ItemGroup,0)
If IsNull(@UOM, '') <> ''
Begin
Set @FreeFlag = 1
Select Top 1 @SR =  SR From #RFAInfo Where InvoiceID = @InvoiceID And Serial = @Serial

Update #RFAInfo Set FreeSKUSerial = @FreeSKUSerial, FreeBaseUOM = @UOM, RebateQty = @FreeQty,
RebateValue = (Case @FreeQty When 0 Then @FreeValue  Else @FreeQty * @FreeValue End),
RebateValue_Tax = (Case @FreeQty When 0 Then @FreeValue_Tax  Else @FreeQty * @FreeValue_Tax End)
Where InvoiceID = @InvoiceID And SR = @SR  And SchemeID = @SchemeID

End
Fetch Next From UpdateFreeInfoCur Into @InvoiceID, @SKUCode, @Serial, @SaleQty, @SaleValue, @TaxCode
End
Close UpdateFreeInfoCur
Deallocate UpdateFreeInfoCur
/*Update FreeQty Info of a Primary SKU - End*/
End

/*Promoted Value Update - Start */
/*Promoted Qty For SplCategory Scheme*/
If @ItemGroup = 2
Begin
Declare @PrimaryUOM Int
Declare @SKUList nVarchar(2000)
Declare @QTYList nVarchar(2000)
Declare @PriceList nVarchar(2000)
Declare @TotalQty Decimal(18, 6)
Declare @TotalValue Decimal(18, 6)

Declare InvoiceCur Cursor For
Select Distinct InvoiceID, Max(SlabID) From #RFAInfo
Where SchemeID = @SchemeID
And SchemeOutlet = 0
Group By InvoiceID
Open InvoiceCur
Fetch Next From InvoiceCur Into @invoiceID, @SlabID
While @@Fetch_Status = 0
Begin
Set @SKUList = ''
Set @QTYList = ''
Set @PriceList = ''
Set @TotalQty	= 0
Set @TotalValue	= 0
/*Get Promoted Qty*/
Declare SKUCur Cursor For
Select  SKUCode, SaleQty, SaleQty * SalePrice   From #RFAInfo  --SaleQty * (SalePrice + (SalePrice * (TaxCode /100)))  From #RFAInfo
Where InvoiceID = @invoiceID And SchemeId = @SchemeID And  IsNull(Flagword, 0) = 0
Open SKUCur
Fetch Next From SKUCur Into @SKUCode, @SaleQty, @SaleValue
While @@Fetch_Status = 0
Begin
If @SKUList = ''
Set @SKUList = @SKUCode
Else
Set @SKUList = @SKUList + '|' + @SKUCode

If @QTYList = ''
Set @QTYList = Cast(@SaleQty as nVarchar)
Else
Set @QTYList = @QTYList + '|' + Cast(@SaleQty as nVarchar)

If @PriceList = ''
Set @PriceList = Cast(@SaleValue as nVarchar)
Else
Set @PriceList = @PriceList + '|' + Cast(@SaleValue as nVarchar)


Set @TotalQty = @TotalQty + @SaleQty
Set @TotalValue = @TotalValue + @SaleValue

Fetch Next From SKUCur Into @SKUCode, @SaleQty, @SaleValue
End
Close SKUCur
Deallocate SKUCur

Select @PromotedQty = PromotedQty , @PromotedValue = PromotedValue, @UOMID = UOM From
dbo.mERP_fn_GetPromotedQty('', @SchemeId, @SlabID, 0, 0, @SKUList, @QTYList, @PriceList)

If IsNull(@SKUList, '') <> ''
Begin
/*SKU wise Promoted Qty*/
Declare SKUCur Cursor For
Select Distinct SKUCode From #RFAInfo
Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And IsNull(Flagword, 0) = 0
Open SKUCur
Fetch Next From SKUCur Into @SKUCode
While @@Fetch_Status = 0
Begin
If @UOMID = 4
Begin
Update #RFAInfo Set PromotedValue = (@PromotedValue/@TotalValue) * (SaleQty * SalePrice )
Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
End
--Else
Else If @UOMID < 4
Begin
Update #RFAInfo Set PromotedQty = (@PromotedQty/@TotalQty) * SaleQty, PromotedValue = SalePrice * ((@PromotedQty/@TotalQty) * SaleQty)
Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
End
Else If @UOMID = 5
Begin
Update #RFAInfo Set PromotedQty = Null, PromotedValue = (@PromotedValue/@TotalValue) * (SaleQty * SalePrice )
Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
End
Else
Begin
Update #RFAInfo Set PromotedQty = 0, PromotedValue = 0
Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode
End
Fetch Next From SKUCur Into @SKUCode
End
Close SKUCur
Deallocate SKUCur
End
Fetch Next From InvoiceCur Into @invoiceID, @SlabID
End
Close InvoiceCur
Deallocate InvoiceCur

IF @Scheme_TLCFlag = 0
Update #RFAInfo Set PromotedQty = SaleQty, PromotedValue = SaleQty * SalePrice Where InvoiceType = 4
Else
Update #RFAInfo Set PromotedQty = Null, PromotedValue = SaleQty * SalePrice Where InvoiceType = 4

End
Else /*Promoted Qty Other schemes*/
Begin
Declare PromotedQty Cursor For
Select InvoiceID, SKUCode, Min(Serial) ,Min(SR)
From #RFAInfo
Where SchemeID = @SchemeID
And IsNull(FlagWord,0) = 0
And SchemeOutlet = 0
Group By InvoiceId, SKUCode
Order By SKUCode
Open PromotedQty
Fetch Next From PromotedQty Into @invoiceID, @SKUCode, @Serial,@SR
While @@Fetch_Status = 0
Begin
Select @SlabId = Max(IsNull(SlabID,0)), @SaleQty = Sum(SaleQty),
@SaleValue = Sum(SalePrice * SaleQty )
--@SaleValue = Sum((SalePrice * SaleQty ) + ((SalePrice * SaleQty) * TaxCode/100))
From #RFAInfo
Where InvoiceID = @InvoiceId And SchemeID = @SchemeID And SKUCode = @SKUCode
If @ItemGroup = 1
Begin
Select @PromotedValue = PromotedValue, @PromotedQty = PromotedQty, @UOM = UOM From dbo.mERP_fn_GetPromotedQty(@SKUCode, @SchemeId, @SlabID, @SaleQty, @SaleValue, '', '', '')
If IsNull(@PromotedQty,0) = 0
Update #RFAInfo Set PromotedValue = @PromotedValue, PromotedQty = @PromotedQty Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode And Serial =  @Serial And SR = @SR
Else
Begin
Update #RFAInfo Set PromotedValue = (@PromotedQty * SalePrice), PromotedQty = @PromotedQty Where InvoiceID = @InvoiceID And SchemeID = @SchemeID And SKUCode = @SKUCode And Serial = @Serial And  SR = @SR
End
End
Fetch Next From PromotedQty Into @invoiceID, @SKUCode, @Serial,@SR
End
Close PromotedQty
Deallocate PromotedQty
/*Update for SalesReturn*/

Update #RFAInfo Set PromotedQty = SaleQty, PromotedValue = SaleQty * SalePrice,
RebateQty = (-1) * RebateQty, RebateValue = (-1) * RebateValue ,
RebateValue_Tax = (-1) * RebateValue_Tax
Where InvoiceType = 4
End
/*Promoted Value Update - End */

/*Remove entry if Rebate value comes in (-)ve*/
Declare SRCursor Cursor For
Select Distinct InvoiceID, BillRef From #RFAInfo Where InvoiceType = 1 And FlagWord = 0
Open SRCursor
Fetch Next From SRCursor Into @InvoiceID, @BillRef
While (@@Fetch_Status = 0)
Begin
Set @InvRebateValue = 0
Set @SRRebateValue = 0

/*Invoice Rebate value*/
Select @InvRebateValue = Sum(RebateValue) From #RFAInfo Where InvoiceID = @InvoiceID
/*Sales Return Rebate value against the invoice*/
Select @SRRebateValue = Sum(RebateValue) From #RFAInfo Where ReferenceNumber = @BillRef

If (@InvRebateValue + @SRRebateValue) < = 0
Begin
Delete From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
--Select * From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
End
Fetch Next From SRCursor Into @InvoiceID, @BillRef
End
Close SRCursor
Deallocate SRCursor

Update #RFAInfo Set SaleQty = (-1) * SaleQty, SaleValue = (-1) * SaleValue,
PromotedQty = (-1) * PromotedQty, PromotedValue = (-1) * PromotedValue
Where InvoiceType = 4

Insert Into #RFADetail
Select  0, IsNull(FlagWord, 0), InvoiceID, SchemeId, BillRef , OutletCode ,
RCSID , ActiveInRCS, LineType , SKUCode ,
UOM , Sum(SaleQty) ,Sum(SaleValue) ,
Sum(PromotedQty) , Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax),
Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 , Sum(BudgetedValue), InvoiceType,[Doc No],
SlabID, FreeBaseUOM, Max(Serial), Max(FreeSKUSerial),Sum(RebateValue_Tax),isnull(TaxOnQty,0)
From #RFAInfo
Where SchemeID = @SchemeID
Group By InvoiceID, SchemeId, BillRef , OutletCode ,
RCSID , ActiveInRCS, LineType , SKUCode ,
UOM, InvoiceType,[Doc No], SlabID,FreeBaseUOM,IsNull(FlagWord, 0),isnull(TaxOnQty,0)



--/*For FreeQty schemes RebateValue and RebateQty should not be shown in bottom frame*/
If @FreeFlag = 1
--Update #RFADetail Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,TaxAmount =0, PriceInclTax = 0
Update #RFADetail Set PriceExclTax =0,TaxAmount = 0, PriceInclTax = 0
Where IsNull(Flagword, 0) = 0
And InvoiceType <> 4


If (Select Count(*) From #RFADetail) >= 1
Begin
Insert Into #tmpRFADet
Select InvoiceID, InvoiceType, SR, BillRef, OutletCode,
RCSID, ActiveInRCS, LineType ,SKUCode ,
UOM , SaleQty , SaleValue ,
PromotedQty,
PromotedValue ,RebateQty , RebateValue ,
RebateValue_Tax As RebateValue_Tax ,PriceExclTax ,
TaxPercentage , TaxAmount , PriceInclTax ,BudgetedQty ,  BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No],
SlabID, FreeBaseUOM, PrimarySerial, FreeSerial,isnull(TaxOnQty,0)
From #RFADetail,Customer Cust
Where Cust.CustomerID = #RFADetail.OutletCode

End



/*SR updation not required in this SP it will be done in the GetRFADate SP Hence below lines commented*/

/*Check for FreeQty Scheme*/
/*To Select Primary and its Free item in sequence - Start*/
--				If @ItemGroup = 1 And @FreeFlag = 1
--				Begin
/*Serial No. for Detail data*/
--					Set @SRNo = 1

--
--					Declare FreeItem Cursor For
--						Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial
--							From #RFAInfo
--							Where IsNull(FlagWord, 0) = 0
--							And SchemeID = @SchemeID
--							And FreeSKUSerial > 0
--							And InvoiceType <> 4
--
--						Union
--
--						Select Distinct SKUCode, InvoiceID, FreeSKUSerial, Serial
--							From #RFAInfo
--							Where IsNull(FlagWord, 0) = 0
--							And SchemeID = @SchemeID
--							And InvoiceType = 4
--
--					Open FreeItem
--					Fetch Next From FreeItem Into @SKUCode,@InvoiceId, @FreeSKUSerial, @Serial
--					While (@@Fetch_Status = 0)
--					Begin
--						If @PrevSKUCode <> @SKUCode
--							Set @SRNo = @SRNo + 1
--
--						Insert Into #RFADetail
--							Select  @SRNo, 0, InvoiceID, SchemeId, BillRef , OutletCode ,
--									RCSID , ActiveInRCS, LineType , SKUCode ,
--									UOM , Sum(SaleQty) ,Sum(SaleValue) ,
--									Sum(PromotedQty) , Sum(PromotedValue) ,Sum(RebateQty) , Sum(RebateValue) , Sum(PriceExclTax),
--									Max(TaxPercentage) , Sum(TaxAmount) , Sum(PriceInclTax) ,0 , Sum(BudgetedValue), InvoiceType,[Doc No],
--									SlabID, FreeBaseUOM, Max(Serial), Max(FreeSKUSerial),Sum(RebateValue_Tax)
--									From #RFAInfo
--									Where InvoiceID = @InvoiceId
--									And SchemeID = @SchemeID
--									And SKUCode = @SKUCode
--									And IsNull(FlagWord, 0) = 0
--									Group By InvoiceID, SchemeId, BillRef , OutletCode ,
--									RCSID , ActiveInRCS, LineType , SKUCode ,
--									UOM, InvoiceType,[Doc No], SlabID,FreeBaseUOM
--
--							Union ALL
--
--							Select @SRNo, 1, InvoiceID, SchemeId, BillRef , OutletCode ,
--									RCSID , ActiveInRCS, LineType , SKUCode ,
--									UOM , SaleQty , SaleValue ,
--									PromotedQty , PromotedValue ,RebateQty , RebateValue , PriceExclTax ,
--									TaxPercentage , TaxAmount , PriceInclTax ,0 ,  BudgetedValue , InvoiceType,[Doc No],
--									SlabID, FreeBaseUOM, Serial, FreeSKUSerial,Sum(RebateValue_Tax)
--									From #RFAInfo
--									Where InvoiceID = @InvoiceId
--									And IsNull(FlagWord, 0) = 1
--									And Serial = @FreeSKUSerial
--
--						Set @PrevSKUCode = @SKUCode
--						Fetch Next From FreeItem Into @SKUCode, @InvoiceId, @FreeSKUSerial, @Serial
--					End
--					Close FreeItem
--					Deallocate FreeItem


--					/*For FreeQty schemes RebateValue and RebateQty should not be shown in bottom frame*/
--					If @FreeFlag = 1
--						--Update #RFADetail Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,TaxAmount =0, PriceInclTax = 0
--						Update #RFADetail Set PriceExclTax =0,TaxAmount =0, PriceInclTax = 0
--							Where IsNull(Flagword, 0) = 0
--							And InvoiceType <> 4
--
--						If (Select Count(*) From #RFADetail) >= 1
--						Begin
--							Insert Into #tmpRFADet
--							Select InvoiceID, InvoiceType, SR, BillRef, OutletCode,
--								RCSID, ActiveInRCS, LineType ,SKUCode ,
--								UOM , SaleQty , SaleValue ,
--								PromotedQty,
--								PromotedValue ,RebateQty , RebateValue ,
--								Null As RebateValue_Tax ,PriceExclTax ,
--								TaxPercentage , TaxAmount , PriceInclTax ,BudgetedQty ,  BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No],
--								SlabID, FreeBaseUOM, PrimarySerial, FreeSerial,RebateValue_Tax
--								From #RFADetail,Customer Cust
--								Where Cust.CustomerID = #RFADetail.OutletCode
--						End
--						Else
--						Begin
--							Insert Into #tmpRFADet
--							Select Null As InvoiceID, Null As InvoiceType, Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
--							Null as LineType,Null as SKUCode,
--							Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
--							Null as RebateQty,Null as RebateValue, Null As RebateValue_Tax, Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
--							Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',
--							Null as SlabID, Null as FreeBaseUOM, Null as PrimarySerial , Null as FreeSerial,Null
--						End
--					End
--					/*To Select Primary and its Free item in sequence - End*/
--					Else
--					Begin
--						/*Abstract data*/
--
--						/*Detail data*/
--						If @FreeFlag = 1 /*RebateValue and RebateQty should not be shown in bottom frame*/
--							--Update #RFAInfo Set RebateQty = 0, RebateValue = 0, PriceExclTax =0,  TaxAmount =0, PriceInclTax = 0
--							Update #RFAInfo Set PriceExclTax =0,  TaxAmount =0, PriceInclTax = 0
--								Where IsNull(Flagword, 0) = 0
--								And InvoiceType <> 4
--						Select InvoiceID, InvoiceType, 0 as SR, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, SKUCode, UOM, Sum(SaleQty) as SaleQty,
--								Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty,
--								Sum(IsNull(RebateValue,0)) as RebateValue, Sum(IsNull(RebateValue_Tax,0)) As RebateValue_Tax, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
--								Max(PriceInclTax) PriceInclTax,0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No], SlabID, FreeBaseUOM,
--								Max(Serial) as PrimarySerial, Max(FreeSKUSerial) As FreeSerial Into #ConDetail
--								From #RFAInfo,Customer Cust
--								Where SchemeID = @SchemeID
--								And Cust.CustomerID = #RFAInfo.OutletCode
--								And IsNull(FlagWord,0) = 0
--								Group By InvoiceID, InvoiceType, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, UOM,Cust.Company_Name,[Doc No], SlabID, FreeBaseUOM
--								Order By SKUCode
--						Insert Into #ConDetail Select InvoiceID, InvoiceType, 0 as SR, BillRef, OutletCode, RCSID, ActiveInRCS, LineType,SKUCode, UOM, Sum(SaleQty) as SaleQty,
--								Sum(SaleValue) as SaleValue, Sum(PromotedQty) as PromotedQty, Sum(PromotedValue) as PromotedValue, Sum(IsNull(RebateQty,0)) as RebateQty,
--								Sum(IsNull(RebateValue,0)) as RebateValue, Sum(IsNull(RebateValue_Tax,0)) as RebateValue_Tax, Max(PriceExclTax) as PriceExclTax, Max(TaxPercentage) as TaxPercentage, Max(TaxAmount) as TaxAmount,
--								Max(PriceInclTax) PriceInclTax,0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName' ,[Doc No], SlabID, FreeBaseUOM,
--								Max(Serial)  as PrimarySerial, Max(FreeSKUSerial)  As FreeSerial--Into #ConDetail
--								From #RFAInfo,Customer Cust
--								Where SchemeID = @SchemeID
--								And Cust.CustomerID = #RFAInfo.OutletCode
--								And IsNull(FlagWord,0) = 1
--								Group By InvoiceId, InvoiceType, SKUCode, BillRef, OutletCode, RCSID, ActiveInRCS, LineType, UOM,Cust.Company_Name,[Doc No], SlabID, FreeBaseUOM
--								Order By SKUCode
--						If (Select Count(*) From  #ConDetail) >= 1
--						Begin
--							Insert Into #tmpRFADet
--							Select * From #ConDetail Order By LineType Desc
--						End
--						Else
--						Begin
--							Insert Into #tmpRFADet
--							Select Null As InvoiceID, Null As InvoiceType, Null as SR,Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,
--							Null as LineType,Null as SKUCode,
--							Null as UOM,Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,
--							Null as RebateQty,Null as RebateValue, Null As RebateValue_Tax, Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
--							Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',
--							Null as SlabID, Null as FreeBaseUOM,Null as PrimarySerial, Null as FreeSerial,Null
--						End
--						Drop Table #ConDetail

--					End

End/*Trade - Item based schemes - End*/
Else If @ApplicableOn = 'INVOICE'
--Start Check
Begin/*Trade - Invoice based schemes - Start*/
/*Invoice based Amt/Per*/
Insert Into #RFAInfo(InvoiceID, InvoiceType, BillRef, OutletCode, RCSID, SchemeDetail, Flagword,
RebateValue, SchemeID, ReferenceNumber,[Doc No],SRSchemeDetail_Tax)
Select IA.InvoiceID, IA.InvoiceType,
--@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef,
Case IsNULL(IA.GSTFlag ,0)
When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
Else
IsNULL(IA.GSTFullDocID,'')
End  as BillRef,
C.CustomerID as OutletCode,
IsNull(C.RCSOutletID, '') as RCSID,
Case InvoiceType When 4 Then
dbo.fn_Get_InvoiceSchemeDetail_SR(IA.InvoiceID,@SchemeID,0)
Else
IsNull(IA.MultipleSchemeDetails, '') End as SchemeDetail,
0 as FlagWord,
0 as RebateValue,
0 as SchemeID,
IA.ReferenceNumber,
IA.DocReference,
Case InvoiceType When 4 Then
dbo.fn_Get_InvoiceSchemeDetail_SR(IA.InvoiceID,@SchemeID,1)
Else
'' End
From InvoiceAbstract IA, Customer C
Where IA.CustomerID = C.CustomerID
And IA.InvoiceType In (1,3,4)
And (IA.Status & 128)=0
And IsNull(IA.MultipleSchemeDetails, 0) <> ''
And dbo.StripTimeFromDate(IA.InvoiceDate) = @InvoiceDate
And IA.InvoiceID In(Select Distinct InvoiceID From #Scheme Where [Scheme] = @SchemeID)




/*Invoice based Free qty*/

Insert Into #RFAInfo (InvoiceID, InvoiceType, BillRef, OutletCode, RCSID, SchemeDetail,
Serial, Flagword, RebateQty, Amount, SchemeID, SKUCode, ReferenceNumber, TaxPercentage,
TaxAmount,LineType,PriceInclTax,PriceExclTax,[Doc No])
Select IA.InvoiceID, IA.InvoiceType,
--@InvPrefix + Cast(IA.DocumentID as nVarchar) as BillRef,
Case IsNULL(IA.GSTFlag ,0)
When 0 then @InvPrefix + Cast(IA.DocumentID as nVarchar)
Else
IsNULL(IA.GSTFullDocID,'')
End  as BillRef,
C.CustomerID as OutletCode,
IsNull(C.RCSOutletID, '') as RCSID,
IsNull(ID.MultipleSchemeDetails, '') as SchemeDetail,
ID.Serial,
IsNull(ID.Flagword, 0),
Case ID.Flagword
When 1 Then (Case IA.InvoiceType When 4 Then (-1) * ID.Quantity Else ID.Quantity End)
Else 0 End,
ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID)) as Amount,
0 as SchemeID, ID.Product_Code,IA.ReferenceNumber,
ID.TaxCode ,
case When isnull(ID.TaxOnQty,0) = 0 Then
(ID.Quantity * (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (TaxCode / 100)))
else
(ID.Quantity * TaxCode)
End
As TaxAmount ,'Free',
case When isnull(ID.TaxOnQty,0) = 0 then
dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) + (dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) * (ID.TaxCode/100))
else
dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID) + ID.TaxCode
end,
dbo.mERP_fn_GetMarginPTR(ID.Product_Code,ID.InvoiceID, @SchemeID),IA.DocReference
From InvoiceAbstract IA, InvoiceDetail ID, Customer C
Where IA.InvoiceId = ID.InvoiceId
And IA.InvoiceType In (1,3,4)
And (IA.Status & 128)=0
And IA.CustomerID = C.CustomerID
And ID.Flagword = 1
And IsNull(IA.MultipleSchemeDetails, 0) <> ''
And dbo.StripTimeFromDate(IA.InvoiceDate) = @InvoiceDate
And IA.InvoiceID In(Select Distinct InvoiceID From #Scheme Where [Scheme] = @SchemeID)



--					Declare SchemeOutletCur Cursor For
--						Select Distinct OutletCode From #RFAInfo
--					Open SchemeOutletCur
--					Fetch Next From SchemeOutletCur Into @CustomerID
--					While (@@Fetch_Status = 0)
--					Begin
--						Select @SchemeOutlet = 0, @SchemeGroup = GroupID From dbo.mERP_fn_CheckTradeSchemeOutlet(@SchemeID, @CustomerID)
--						Update #RFAInfo Set SchemeOutlet = @SchemeOutlet, SchemeGroup = @SchemeGroup
--							Where OutletCode = @CustomerID
--						Update #RFAInfo Set ActiveInRCS = IsNull(TMDValue,N'')
--							From Cust_TMD_Master CTM, Cust_TMD_Details CTD
--							Where CTM.TMDID = CTD.TMDID
--							And CTD.CustomerID = @CustomerID
--							And OutletCode = @CustomerID
--						Fetch Next From SchemeOutletCur Into @CustomerID
--					End
--					Close SchemeOutletCur
--					Deallocate SchemeOutletCur


Update #RFAInfo Set SchemeOutlet = 0



/*Delete non scheme Outlet*/
Delete From #RFAInfo Where IsNull(SchemeOutlet, 0) = 2

/*Update SKU Category Levels and UOM - Start*/
--					Declare UpdateLevelCur Cursor For
--					Select Distinct SKUCode From #RFAInfo
--					Open UpdateLevelCur
--					Fetch Next From UpdateLevelCur Into @SKUCode
--					While (@@Fetch_Status = 0)
--					Begin
--						Select @UOM = Description From UOM Where UOM = (Select UOM From Items Where Product_Code = @SKUCode)
--
--						Update #RFAInfo Set UOM = @UOM
--							Where SKUCode = @SKUCode
--						Update #RFAInfo Set FreeBaseUOM = (Select UOM.Description From UOM, Items Where Items.Product_Code = @SKUCode And Items.UOM = UOM.UOM)
--							Where SKUCode = @SKUCode
--						Fetch Next From UpdateLevelCur Into @SKUCode
--					End
--					Close UpdateLevelCur
--					Deallocate UpdateLevelCur
/*Update SKU Category Levels and UOM - End*/

/* Update UOM */
Update RFA Set UOM = U.Description ,FreeBaseUOM  = U.Description
From #RFAInfo RFA,Items I , UOM U
Where RFA.SKUCode = I.Product_Code And
I.UOM = U.UOM

--1
Declare @TempTOQ int
Declare UpdateRebateCur Cursor For
Select InvoiceID, InvoiceType, SchemeDetail, Serial, Amount, FlagWord, SchemeOutlet, SR,SRSchemeDetail_Tax,TaxOnQty
From #RFAInfo
Where SchemeOutlet = 0
Open UpdateRebateCur
Fetch Next From UpdateRebateCur Into @InvoiceID, @InvoiceType, @SchemeDetail, @Serial, @Amount, @FlagWord, @SchemeOutlet, @InvSRID ,@SRSchemeDetail_Tax,@TempTOQ
While (@@Fetch_Status = 0)
Begin
If @FlagWord = 1
Begin

If ((Select Count(*) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0) Where SchemeID = @SchemeID) > 0)
Begin
If @TempTOQ= 0
BEGIN
Update #RFAInfo Set RebateValue = Case @InvoiceType When 4 Then (-1) * @Amount Else @Amount End,
RebateValue_Tax = (Case @InvoiceType When 4 Then (-1) * @Amount Else @Amount End) + (@Amount * TaxPercentage/100),
SchemeID = @SchemeID
Where InvoiceID = @InvoiceID And Serial = @Serial And SR = @InvSRID And FlagWord = @FlagWord
END
ELSE
BEGIN
Update #RFAInfo Set RebateValue = Case @InvoiceType When 4 Then (-1) * @Amount Else @Amount End,
RebateValue_Tax = (Case @InvoiceType When 4 Then (-1) * @Amount Else @Amount End) + (RebateQty * TaxPercentage),
SchemeID = @SchemeID
Where InvoiceID = @InvoiceID And Serial = @Serial And SR = @InvSRID And FlagWord = @FlagWord
END
End
Else
Update #RFAInfo Set RebateValue = 0
Where InvoiceID = @InvoiceID And Serial = @Serial
End
Else
Begin
Set @SchemeAmt = 0
Select @SchemeAmt = IsNull(SchAmt,0), @SlabID = SlabID From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SchemeDetail, @FlagWord, 0, 0)
Where SchemeID = @SchemeID

Set @SRSchemeAmt_Tax = 0
If @SRSchemeDetail_Tax <> '' And @InvoiceType = 4
Begin
Select @SRSchemeAmt_Tax = IsNull(SchAmt,0) From dbo.mERP_fn_GetInvSchemeDetail(@InvoiceID, @SRSchemeDetail_Tax, @FlagWord, 0, 0)
Where SchemeID = @SchemeID
End



If @SchemeAmt > 0 OR @SlabID > 0
Update #RFAInfo Set RebateValue  = Case @InvoiceType When 4 Then (-1) * @SchemeAmt Else @SchemeAmt End,
RebateValue_Tax  = (Case @InvoiceType When 4 Then (-1)  Else 1 End) *
(Case isNull(@SRSchemeAmt_Tax,0) When 0 Then @SchemeAmt Else @SRSchemeAmt_Tax End),
SchemeID = @SchemeID
Where InvoiceID = @InvoiceID And Isnull(Serial, 0) = 0


End

Fetch Next From UpdateRebateCur Into @InvoiceID, @InvoiceType, @SchemeDetail, @Serial, @Amount, @FlagWord, @SchemeOutlet, @InvSRID,@SRSchemeDetail_Tax,@TempTOQ
End
Close UpdateRebateCur
Deallocate UpdateRebateCur




/*Remove entry if Rebate value comes in (-)ve*/
Declare SRCursor Cursor For
Select Distinct InvoiceID, BillRef From #RFAInfo Where InvoiceType = 1 And FlagWord = 0
Open SRCursor
Fetch Next From SRCursor Into @InvoiceID, @BillRef
While (@@Fetch_Status = 0)
Begin
Set @InvRebateValue = 0
Set @SRRebateValue = 0

/*Invoice Rebate value*/
Select @InvRebateValue = Sum(RebateValue) From #RFAInfo Where InvoiceID = @InvoiceID
/*Sales Return Rebate value against the invoice*/
Select @SRRebateValue = Sum(RebateValue) From #RFAInfo Where ReferenceNumber = @BillRef

If (@InvRebateValue + @SRRebateValue) < = 0
Begin
Delete From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
--Select * From #RFAInfo Where InvoiceID = @InvoiceID Or ReferenceNumber = @BillRef
End
Fetch Next From SRCursor Into @InvoiceID, @BillRef
End
Close SRCursor
Deallocate SRCursor

/*Abstract data*/
If (Select Count(*) From #RFAInfo Where SchemeID = @SchemeID) >= 1
Begin
/*Detail data*/
Insert Into #tmpRFADet
Select  InvoiceID, InvoiceType, 0 as SR,
BillRef, OutletCode, RCSID, ActiveInRCS, LineType as LineType,
SKUCode, UOM, Sum(SaleQty) as SaleQty,
Sum(SaleValue) as SaleValue, Sum(PromotedQty) As PromotedQty,Sum(PromotedValue) As PromotedValue,
Sum(RebateQty) as RebateQty, Sum(IsNull(RebateValue, 0)) as RebateValue,
Sum(IsNull(RebateValue_Tax, 0)) as RebateValue_Tax,
IsNull(PriceExclTax, 0) as PriceExclTax, IsNull(TaxPercentage,0) as TaxPercentage,
IsNull(TaxAmount,0) as TaxAmount, IsNull(PriceInclTax,0) as PriceInclTax,
0 as BudgetedQty, 0 as BudgetedValue,Cust.Company_Name as 'OutletName',[Doc No], SlabID, FreeBaseUOM,
Max(Serial), Max(FreeSKUSerial),TaxOnQty
From #RFAInfo,Customer Cust
Where SchemeID = @SchemeID
And Cust.CustomerID = #RFAInfo.OutletCode
Group By SchemeID, InvoiceID, InvoiceType, OutletCode, RCSID, ActiveInRCS, SKUCode, UOM,
FreeBaseUOM, BillRef ,LineType,
PriceExclTax, TaxPercentage, TaxAmount, PriceInclTax,Cust.Company_Name,[Doc No], SlabID, FreeBaseUOM,TaxOnQty
Order By SKUCode
End
--					Else
--					Begin
--
--						Insert Into #tmpRFADet
--						Select Null As InvoiceID, Null As InvoiceType, Null as SR,
--							   Null as BillRef,Null as OutletCode,Null as RCSID,Null as  ActiveInRCS,Null as LineType,
--							   Null as SKUCode,Null as UOM,
--							   Null as SaleQty,Null as SaleValue,Null as  PromotedQty,Null as PromotedValue,Null as RebateQty,
--							   Null as RebateValue,Null as RebateValue_Tax, Null as PriceExclTax,Null as TaxAmount,Null as TaxPercentage,
--							   Null as PriceInclTax,Null as BudgetedQty,Null as BudgetedValue,Null as 'OutletName',Null as 'Doc No',
--							   Null as SlabID,Null as FreeBaseUOM, Null as PrimarySerial, Null As FreeSerial
--					End
End	/*Trade - Invoice based schemes - End*/
End /* Non QPS Scheme ends here */

--		/*To Update RebateValue_Tax value*/
--		Update #tmpRFADet Set RebateValue_Tax = T1.RebateValue + (T1.RebateValue * (T2.TaxPercentage/100))
--			From #tmpRFADet T1, #RFAInfo T2
--			Where T1.InvoiceID = T2.InvoiceID
--			And T1.SKUCode = T2.SKUCode


/* Specifically done to update the Taxamount in case of primary item for Trade scheme report purpose*/

Update #tmpRFADet Set TaxAmount = PromotedValue * TaxPercentage/100.
Where LineType = 'MAIN' and TaxOnQty=0

Update #tmpRFADet Set TaxAmount = SaleQty * TaxPercentage
Where LineType = 'MAIN' and TaxOnQty=1 And PromotedQty is NULL

Update #tmpRFADet Set TaxAmount = PromotedQty * TaxPercentage
Where LineType = 'MAIN' and TaxOnQty=1 And PromotedQty is NOT NULL

Insert Into #NonQPSData
Select RD.InvoiceID As InvoiceID, RD.OutletCode As CustomerID, @SchemeID As SchemeID,
RD.BillRef, RD.[Doc No] As DocID, RD.InvoiceType As InvoiceType, RD.SKUCode As Product_Code,
Case RD.LineType
When 'MAIN' Then 0
When 'Free' Then 1
When 'Sales Return - Saleable' Then 2
When 'Sales Return - Damaged' Then 3
End As [Type],
RD.SlabID As SlabID, @InvoiceDate As InvoiceDate, RD.SaleQty, RD.SaleValue, RD.RebateQty, RD.RebateValue,
RD.RebateValue_Tax,
Case When @Scheme_TLCFlag = 1 Then 0 Else RD.PromotedQty End as PromotedQty,
--Case When @Scheme_TLCFlag = 1 Then 0 Else RD.PromotedValue End as PromotedValue,
RD.PromotedValue,
(Select UOM From UOM Where Description = IsNull(RD.FreeBaseUOM, '')) As RebateUOM,
Case When @Scheme_TLCFlag = 1 Then Null Else (Select UOM From UOM Where Description = IsNull(RD.UOM, '')) End As PromotedUOM,
RD.PriceExclTax, RD.TaxPercentage As TaxPercent, RD.TaxAmount,
RD.PriceInclTax, RD.SR as Serial, RD.PrimarySerial, RD.FreeSerial,

Case RD.InvoiceType
When 3 Then (Select dbo.StripTimeFromDate(Min(InvoiceDate)) From InvoiceAbstract Where DocumentID = IA.DocumentID
And InvoiceType = 1 And isnull(CancelDate,'') <> '' and CustomerID = IA.CustomerID)
Else @InvoiceDate End As OriginalInvDate,
@InvoiceDate As DayCloseDate,
GetDate() As CreationDate,Isnull(TaxOnQty,0)
From #tmpRFADet RD, InvoiceAbstract IA
Where RD.InvoiceID = IA.InvoiceID


--Truncate table to get the data of next scheme.
Truncate Table #RFAInfo
Truncate Table #RFADetail
Truncate table #tmpRFADet
--Truncate table #tmpSKUWiseSales
--Truncate table #tmpSales

Fetch Next From SchCursor Into @SchemeID
End --SchCursor End
Close SchCursor
Deallocate SchCursor

--Delete data if exists for the given date
If ((Select Count(*) From tbl_merp_NonQPSData Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@InvoiceDate)) > 0)
Delete From tbl_merp_NonQPSData Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@InvoiceDate)

/* SCh Min Qty - FITC-4413 Process Start:*/

Declare @TmpInvoiceItems as Table (
InvoiceID Int,
SchemeID Int,
Product_Code Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6),
Salesvalue Decimal(18,6))
Declare @MinStataus as table (MinStatus Int)
Declare @TLCMinStatus as table(MinFlag int, MinCnt int, Product_Code Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into @TmpInvoiceItems
Select InvoiceID,SchemeID,Product_Code,SaleQty,IsNull(SaleValue,0) + IsNull(TaxAmount,0)  from #NonQPSData Where Type Not in(2,3)

Declare @Product_Code as Nvarchar(255)
Declare @Quantity as Nvarchar(255)
Declare @TMPAmount as Nvarchar(255)
Declare @tmpStr as Nvarchar(Max)
Declare @TMPInvoiceID as Int
Declare @tmpSchemeId as Int

Declare Cur_tmpInv Cursor for
Select Distinct InvoiceID,SchemeID from @TmpInvoiceItems
Open Cur_tmpInv
Fetch from Cur_tmpInv into @TMPInvoiceID,@tmpSchemeId
While @@fetch_status =0
Begin
If Exists (select * From tbl_merp_schemeAbstract Where Isnull(IsminQty,0) = 1 and SchemeId = @tmpSchemeId)
Begin
Set @tmpStr = ''
Declare Cur_Merge Cursor for
Select Product_Code,Isnull(Quantity,0),Isnull(Salesvalue,0)	from @TmpInvoiceItems Where InvoiceId = @TMPInvoiceID And SchemeID =  @tmpSchemeId
Open Cur_Merge
Fetch from Cur_Merge into @Product_Code,@Quantity,@TMPAmount
While @@fetch_status =0
Begin
If Isnull(@tmpStr ,'') <> ''
Begin
Set @tmpStr = @tmpStr + '|' + Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@TMPAmount as Nvarchar)
End
Else
Begin
Set @tmpStr = Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@TMPAmount as Nvarchar)
End
Fetch Next from Cur_Merge into @Product_Code,@Quantity,@TMPAmount
End
Close Cur_Merge
Deallocate Cur_Merge

Delete From @MinStataus
Delete From @TLCMinStatus

Select @Scheme_TLCFlag = isnull(TLCFlag,0)  From tbl_Merp_SchemeAbstract Where SchemeID = @tmpSchemeId

IF @Scheme_TLCFlag = 1
Begin
Insert Into @TLCMinStatus
Exec mERP_SP_Get_MinQtyItems_SCHTLC @tmpSchemeId,@tmpStr

If Not Exists(Select 'x' From @TLCMinStatus)
Begin
Update #NonQPSData Set SlabID = Null,PromotedQty = 0, PromotedValue = 0,RebateQty = 0,RebateValue = 0, RebateValue_Tax = 0,RebateUOM = Null,PromotedUOM = Null
Where InvoiceID = @TMPInvoiceID And SchemeId = @tmpSchemeId
End
End
Else
Begin
Insert Into @MinStataus
Exec mERP_SP_isAllItemsexistsMinQty @tmpSchemeId,@tmpStr

If (Select Top 1 Isnull(MinStatus,0) From @MinStataus) = 0
Begin
Update #NonQPSData Set SlabID = Null,PromotedQty = 0, PromotedValue = 0,RebateQty = 0,RebateValue = 0, RebateValue_Tax = 0,RebateUOM = Null,PromotedUOM = Null
Where InvoiceID = @TMPInvoiceID And SchemeId = @tmpSchemeId
End
End

End
Else
Begin
Goto SkipInvoice
End
SkipInvoice:
Fetch Next from Cur_tmpInv into @TMPInvoiceID,@tmpSchemeId
End
Close Cur_tmpInv
Deallocate Cur_tmpInv

Delete From @TmpInvoiceItems
Delete From @MinStataus
Delete From @TLCMinStatus

/* SCh Min Qty - FITC-4413 Process End:*/

Insert Into tbl_merp_NonQPSData
--Select * From #NonQPSData Order By InvoiceID, SchemeID, [Type]
/*To avoid the duplicate entry in tbl_merp_NonQPSData table*/
Select distinct InvoiceID,CustomerID,SchemeID,BillRef,DocID,InvoiceType,Product_Code,Type,SlabID,InvoiceDate,SaleQty,SaleValue,RebateQty,
RebateValue,RebateValue_Tax,PromotedQty,PromotedValue,RebateUOM,PromotedUOM,PriceExclTax,TaxPercent,TaxAmount,PriceInclTax,Serial,
PrimarySerial,FreeSerial,OriginalInvDate,DayCloseDate,GetDate() As CreationDate,TaxOnQty
From #NonQPSData Order By InvoiceID, SchemeID, [Type]

--To insert a log in DayCloseLog
If exists (select * from sysobjects where xtype='u' and name ='DayCloseLog')
Insert into DayCloseLog (SysDate,DayClose) Values (getdate(),@InvoiceDate)

Drop Table #RFAInfo
Drop Table #RFADetail
Drop table #tmpRFADet
--Drop table #tmpSKUWiseSales
--Drop table #tmpSales
Drop table #NonQPSData
Drop Table #Scheme
Drop Table #SchInfo

End
