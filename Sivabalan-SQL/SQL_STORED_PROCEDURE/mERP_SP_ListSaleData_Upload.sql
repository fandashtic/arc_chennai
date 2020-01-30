Create Procedure mERP_SP_ListSaleData_Upload(@FromDate as datetime,@ToDate as datetime)
As
DECLARE @SchID nvarchar(1000), @SchemeID nvarchar(1000)
DECLARE @INV AS NVARCHAR(50)
DECLARE @SC AS NVARCHAR(50)
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Begin
Set dateformat dmy
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()

/* Close Day validation included*/
Declare @CloseDaydate datetime
Select Top 1 @CloseDaydate = Lastinventoryupload from setup
If @FromDate >@CloseDaydate
Goto TheEND
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'
SELECT @SC = Prefix FROM VoucherPrefix WHERE TranID = N'SALE CONFIRMATION'

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Create Table #XMLData(ID Int Identity(1,1),XMLStr nVarchar(max))
-- new channel classifications added-------------------------------

Declare @TOBEDEFINED nVarchar(50)

Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)

CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #OLClassCustLink (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelType Int, Active Int, [Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

CREATE Table #tmpInvoiceDetail(
InvoiceID Int ,
Product_Code Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS ,
Batch_Code Int ,
Batch_Number Nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS ,
Quantity decimal(18, 6) ,
SalePrice decimal(18, 6) ,
TaxCode decimal(18, 6) ,
DiscountPercentage decimal(18, 6) ,
DiscountValue decimal(18, 6) ,
Amount decimal(18, 6) ,
PurchasePrice decimal(18, 6) ,
STPayable decimal(18, 6) ,
FlagWord Int ,
SaleID Int ,
PTR decimal(18, 6) ,
PTS decimal(18, 6) ,
MRP decimal(18, 6) ,
TaxID Int ,
CSTPayable decimal(18, 6) ,
TaxCode2 decimal(18, 6) ,
TaxSuffered decimal(18, 6) ,
TaxSuffered2 decimal(18, 6) ,
ReasonID Int ,
UOM Int ,
UOMQty decimal(18, 6) ,
UOMPrice decimal(18, 6) ,
ComboID Int ,
Serial Int ,
FreeSerial Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
SPLCATSerial Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
SpecialCategoryScheme Int ,
SCHEMEID Int ,
SPLCATSCHEMEID Int ,
SCHEMEDISCPERCENT decimal(18, 6) ,
SCHEMEDISCAMOUNT decimal(18, 6) ,
SPLCATDISCPERCENT decimal(18, 6) ,
SPLCATDISCAMOUNT decimal(18, 6) ,
ExciseDuty decimal(18, 6) ,
SalePriceBeforeExciseAmount decimal(18, 6) ,
ExciseID Int ,
salesstaffid Int ,
TaxSuffApplicableOn Int ,
TaxSuffPartOff decimal(18, 6) ,
Vat Int ,
CollectTaxSuffered Int ,
TaxAmount decimal(18, 6) ,
TaxSuffAmount decimal(18, 6) ,
STCredit decimal(18, 6) ,
TaxApplicableOn Int ,
TaxPartOff decimal(18, 6) ,
OtherCG_Item Int ,
SplCatCode Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
QuotationID Int ,
MultipleSchemeID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MultipleSplCatSchemeID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
TotSchemeAmount decimal(18, 6) ,
MultipleSchemeDetails Nvarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MultipleSplCategorySchDetail Nvarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS ,
GroupID Int ,
MultipleRebateID Nvarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MultipleRebateDet Nvarchar(Max) COLLATE SQL_Latin1_General_CP1_CI_AS ,
RebateRate decimal(18, 6),MRPPerPack Decimal(18,6),
CSTaxCode int)

If not exists (select * from sysobjects where xtype='u' and name ='tmpInvoiceAbstract')
begin
CREATE Table tmpInvoiceAbstract(
InvoiceID int ,
InvoiceType int ,
InvoiceDate datetime ,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS ,
BillingAddress nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
ShippingAddress nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
UserName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
GrossValue decimal(18, 6) ,
DiscountPercentage decimal(18, 6) ,
DiscountValue decimal(18, 6) ,
NetValue decimal(18, 6) ,
CreationTime datetime ,
Status int ,
TaxLocation nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
InvoiceReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
ReferenceNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
AdditionalDiscount decimal(18, 6) ,
Freight decimal(18, 6) ,
CreditTerm int ,
PaymentDate datetime ,
DocumentID int ,
NewReference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
NewInvoiceReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
OriginalInvoice int ,
ClientID int ,
Memo1 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
Memo2 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
Memo3 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MemoLabel1 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MemoLabel2 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MemoLabel3 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
Flags int ,
ReferredBy int ,
Balance decimal(18, 6) ,
SalesmanID int ,
BeatID int ,
PaymentMode int ,
PaymentDetails nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
ReturnType int ,
Salesman2 int ,
DocReference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
AmountRecd decimal(18, 6) ,
AdjRef nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
AdjustedAmount decimal(18, 6) ,
GoodsValue decimal(18, 6) ,
AddlDiscountValue decimal(18, 6) ,
TotalTaxSuffered decimal(18, 6) ,
TotalTaxApplicable decimal(18, 6) ,
ProductDiscount decimal(18, 6) ,
RoundOffAmount decimal(18, 6) ,
AdjustmentValue decimal(18, 6) ,
Denominations nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS ,
ServiceCharge nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
BranchCode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS ,
CFormNo nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS ,
DFormNo nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS ,
CancelDate datetime ,
VanNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS ,
TaxOnMRP int ,
DocSerialType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
SchemeID int ,
SchemeDiscountPercentage decimal(18, 6) ,
SchemeDiscountAmount decimal(18, 6) ,
ClaimedAmount decimal(18, 6) ,
ClaimedAlready int ,
ExciseDuty decimal(18, 6) ,
DiscountBeforeExcise int ,
SalePriceBeforeExcise int ,
CustomerPoints decimal(18, 6) ,
VatTaxAmount decimal(18, 6) ,
SONumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
GroupID nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS ,
DeliveryStatus int ,
DeliveryDate datetime ,
InvoiceSchemeID nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS ,
MultipleSchemeDetails nvarchar(2550) COLLATE SQL_Latin1_General_CP1_CI_AS ,
TaxDiscountFlag int ,
DSTypeID int,
GSTFlag int,
GSTFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
FromStateCode int,
ToStateCode int,
GSTIN nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS )
End
else
Begin
truncate table tmpInvoiceAbstract
end
Declare @TmpInv as Table (InvoiceID Int)
Insert Into @TmpInv
Select Distinct InvoiceId
From InvoiceAbstract
Where Isnull(InvoiceType,0) in (1,3,4,5)
And (InvoiceDate Between @FromDATE And @TODATE)
--OR (CancelDate Between @FromDATE And @TODATE)

INSERT INTO tmpInvoiceAbstract
(InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue
,DiscountPercentage,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference
,ReferenceNumber,AdditionalDiscount,Freight,CreditTerm,PaymentDate,DocumentID,NewReference
,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3,MemoLabel1,MemoLabel2,MemoLabel3
,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType,Salesman2,DocReference
,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered,TotalTaxApplicable,ProductDiscount
,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode,CFormNo,DFormNo,CancelDate,VanNumber,TaxOnMRP
,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise
,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails
,TaxDiscountFlag,DSTypeID,GSTFlag,GSTFullDocID,FromStateCode,ToStateCode, GSTIN)
SELECT InvoiceID,InvoiceType,InvoiceDate,CustomerID,BillingAddress,ShippingAddress,UserName,GrossValue
,DiscountPercentage,DiscountValue,NetValue,CreationTime,Status,TaxLocation,InvoiceReference
,ReferenceNumber,AdditionalDiscount,Freight,CreditTerm,PaymentDate,
DocumentID,
NewReference
,NewInvoiceReference,OriginalInvoice,ClientID,Memo1,Memo2,Memo3,MemoLabel1,MemoLabel2,MemoLabel3
,Flags,ReferredBy,Balance,SalesmanID,BeatID,PaymentMode,PaymentDetails,ReturnType,Salesman2,DocReference
,AmountRecd,AdjRef,AdjustedAmount,GoodsValue,AddlDiscountValue,TotalTaxSuffered,TotalTaxApplicable,ProductDiscount
,RoundOffAmount,AdjustmentValue,Denominations,ServiceCharge,BranchCode,CFormNo,DFormNo,CancelDate,VanNumber,TaxOnMRP
,DocSerialType,SchemeID,SchemeDiscountPercentage,SchemeDiscountAmount,ClaimedAmount,ClaimedAlready,ExciseDuty,DiscountBeforeExcise
,SalePriceBeforeExcise,CustomerPoints,VatTaxAmount,SONumber,GroupID,DeliveryStatus,DeliveryDate,InvoiceSchemeID,MultipleSchemeDetails
,TaxDiscountFlag,DSTypeID,isnull(GSTFlag,0),ISNULL(GSTFullDocID,'') ,Isnull(FromStateCode,0),Isnull(ToStateCode,0) ,IsNull(GSTIN,'')
FROM InvoiceAbstract Where InvoiceId In (Select Distinct invoiceID From @TmpInv)

Insert Into #tmpInvoiceDetail
Select InvoiceID,Product_Code,Batch_Code,Batch_Number,Quantity,SalePrice,
TaxCode,DiscountPercentage,DiscountValue,Amount,PurchasePrice,STPayable,
FlagWord,SaleID,PTR,PTS,MRP,TaxID,CSTPayable,TaxCode2,TaxSuffered,TaxSuffered2,
ReasonID,UOM,UOMQty,UOMPrice,ComboID,Serial,FreeSerial,SPLCATSerial,
SpecialCategoryScheme,SCHEMEID,SPLCATSCHEMEID,SCHEMEDISCPERCENT,SCHEMEDISCAMOUNT,
SPLCATDISCPERCENT,SPLCATDISCAMOUNT,ExciseDuty,SalePriceBeforeExciseAmount,
ExciseID,salesstaffid,TaxSuffApplicableOn,TaxSuffPartOff,Vat,CollectTaxSuffered,
TaxAmount,TaxSuffAmount,STCredit,TaxApplicableOn,TaxPartOff,OtherCG_Item,SplCatCode,
QuotationID,MultipleSchemeID,MultipleSplCatSchemeID,TotSchemeAmount,MultipleSchemeDetails,
MultipleSplCategorySchDetail,GroupID,MultipleRebateID,MultipleRebateDet,RebateRate,MRPPerPack,Isnull(GSTCSTaxCode,0)
From InvoiceDetail Where InvoiceId In (Select Distinct invoiceID From @TmpInv)

Create Table #tmpSchemeId ( SchId Int )

Declare CurSchId Cursor For
Select Ia.multipleschemedetails FROM tmpInvoiceAbstract Ia
where Ia.InvoiceType in (1,3,4,5) AND
((Ia.InvoiceDate BETWEEN @FROMDATE AND @TODATE)
--or (Ia.CancelDate between @FROMDATE AND @TODATE)
)
Open CurSchId
Fetch Next From CurSchId Into @SchemeID
While @@Fetch_Status = 0
Begin
Insert Into #tmpSchemeId
Select * from dbo.sp_SplitIn2Rows(@SchemeID, ',')
Fetch Next From CurSchId Into @SchemeID
End
Close CurSchId
Deallocate CurSchId

Declare CurSchId Cursor For
Select Id.multipleschemeid, Id.multiplesplcatschemeid FROM tmpInvoiceAbstract Ia Join InvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
where Ia.InvoiceType in (1,3,4,5) AND
((Ia.InvoiceDate BETWEEN @FROMDATE AND @TODATE)
--or (Ia.CancelDate between @FROMDATE AND @TODATE)
)
Open CurSchId
Fetch Next From CurSchId Into @SchID, @SchemeID
While @@Fetch_Status = 0
Begin
Insert Into #tmpSchemeId
Select * from dbo.sp_SplitIn2Rows(@SchID, ',')
Insert Into #tmpSchemeId
Select * from dbo.sp_SplitIn2Rows(@SchemeID, ',')
Fetch Next From CurSchId Into @SchID, @SchemeID
End
Close CurSchId
Deallocate CurSchId

Select Distinct SchId Into #tmpSchId FROM #tmpSchemeId where convert( Int, SchId ) > 0

Select SSD.* Into #tbl_merp_SchemeSlabDetail from tbl_merp_SchemeSlabDetail SSD Join #tmpSchId Sc on SSD.SchemeId =  Sc.SchId

Select SS.* Into #tbl_merp_SchemeSale from tbl_merp_SchemeSale SS Join tmpInvoiceAbstract Ia on SS.InvoiceId =  Ia.InvoiceId
where Ia.InvoiceType in (1,3,4,5) AND
((Ia.InvoiceDate BETWEEN @FROMDATE AND @TODATE)
--or (Ia.CancelDate between @FROMDATE AND @TODATE)
)

Insert Into #OLClassMapping
Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc,
olc.SubOutlet_Type_Desc
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And
olcm.Active = 1

Insert Into #OLClassCustLink
Select olcm.OLClassID, C.CustomerId, C.ChannelType , C.Active, IsNull(olcm.[Channel Type], @TOBEDEFINED),
IsNull(olcm.[Outlet Type], @TOBEDEFINED) , IsNull(olcm.[Loyalty Program], @TOBEDEFINED)
From #OLClassMapping olcm
Right Outer Join Customer C on olcm.CustomerID = C.CustomerID
--Where olcm.CustomerID =* C.CustomerID

-------------------------------------------------

Create table #TmpSaleDataAbstract(
documentId Int,
WDCode nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,
WDDest nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,
Fromdate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
ToDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
InvoiceID int,
InvoiceNo nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
SaleType nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
Docref nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
InvDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
InvoiceType nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
DeliveryDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
OrderReference nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
PaymentMode nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nvarchar(350)COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerAddress nvarchar(500)COLLATE SQL_Latin1_General_CP1_CI_AS,
ChannelID int,
ChannelName nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
BeatName nvarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,
DSID int,
DSName nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
DSSubType nvarchar(350)COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
DocType nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
InvGrossValue decimal(18,6),
TotalDisc  decimal(18,6),
TotSchemeDisc Decimal(18,6),
TotTradeDisc Decimal(18,6),
TotAddlDisc Decimal(18,6),
TotalTax decimal(18,6),
InvNetValue decimal(18,6),
RoundOff decimal(18,6),
AdjustedAmount decimal(18,6),
AmountReceivable decimal(18,6),
SchSeqNo int,
Schemes nvarchar(40)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchemeValue decimal(18,6),
--InvCreationDate datetime,
InvCreationDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
InvRefNo nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderID int,
OrderNo nvarchar(2000)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderRefNo nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
OrderType nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
GrossValue decimal(18,6),
NetValue decimal(18,6),
GenerationDateTime nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrgDocStatus nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
StateType nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
RegUnReg nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS
)

insert into #TmpSaleDataAbstract
SELECT
IA.DocumentID ,
@WDCode,
@WDDest, "From Date" = Convert(varchar,@FromDate,103) , "To Date" = Convert(varchar,@ToDate,103),
Invoiceid ,
--@INV + CAST(IA.DocumentID AS nVARCHAR),
Case IsNULL(IA.GSTFlag ,0)
When 0 then @INV + CAST(IA.DocumentID AS nVARCHAR)
Else
IsNULL(IA.GSTFullDocID,'')
End,
case when IA.InvoiceType in (1,3) and isnull(IA.SONumber,'')='' then
'INVOICE'
when IA.InvoiceType in (1,3) and isnull(IA.SONumber,'')<>'' then
'INVFROMSC'
when IA.InvoiceType=4 and (isnull(IA.Status,0) & 32) <> 0 Then
'SALESRETURNDAMAGE'
when IA.InvoiceType=4 and (isnull(IA.Status,0) & 32) = 0 Then
'SALESRETURNSALEABLE'
end,
IA.DocReference,
Convert(varchar,InvoiceDate,103),
case when isnull(status,0) & 64 <> 0 then 'Cancel'
when IA.invoicetype in (1,4) and isnull(status,0) & 192 = 0 then
'Open'
when IA.invoicetype=3 and isnull(status,0) & 192 = 0 then
'Amendment'
else
'Cancel'
end,
convert(varchar,DeliveryDate,103),
case when status=4 then referencenumber else '' end,
case IsNull(PaymentMode,0)
When 0 Then 'Credit'
When 1 Then 'Cash'
When 2 Then 'Cheque'
When 3 Then 'DD'
Else 'Credit'
End,
--"Payment Date" = IA.PaymentDate,
Customer.CustomerID,
Customer.Company_Name,
Customer.RCSOutletID,
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Customer.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),


--Customer.ChannelTYpe,
cc.code,
CC.ChannelDesc,
Beat.Description,
--"Salesman" = Salesman.Salesman_Name
--DD.DSTypeID,
Salesman.SalesmanID,
Salesman.Salesman_Name,
--(select DSTypename from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
(select DSTypeValue from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
case when IA.GroupID='0' Or isNull(IA.GroupID,'-1' ) = '-1' then
'All'
else
dbo.mERP_fn_Get_GroupNames(IA.GroupID)
end,
IA.DocSerialType,
--"Goods Value" = GoodsValue,
IA.GoodsValue,
Cast((select sum(discountvalue-schemediscamount-splcatdiscamount)
from #tmpInvoiceDetail where invoiceid=IA.invoiceid) as Decimal(18,6)),
--Cast((select isnull(sum(schemediscamount),0) from #tmpInvoiceDetail where #tmpInvoiceDetail.invoiceid=IA.invoiceid) as Decimal(18,6)),

--Total scheme discount Amount [InvoiceBased + Item Based]
(IA.SchemeDiscountAmount +
(select sum(schemediscamount+splcatdiscamount) from #tmpInvoiceDetail where invoiceid=IA.invoiceid)),

--Cast(IA.GoodsValue * (DiscountPercentage /100) as Decimal(18,6))-IA.SchemeDiscountAmount,
cast(IA.AddlDiscountValue as decimal(18,6)),
--Cast((IA.GoodsValue * (AdditionalDiscount / 100)) as Decimal(18,6)),
0,

-- TotalTaxApplicable,
Cast(( select sum(Isnull(STPayable,0)+Isnull(CSTpayable,0)) from #tmpInvoiceDetail
where invoiceid=IA.invoiceid) as Decimal(18,6)),

IA.Netvalue,
RoundOffAmount,
IsNull(IA.AdjustedAmount, 0),
IA.Balance,
IA.SCHEMEID,
--CAST(Round((IA.SchemeDiscountPercentage), 2) AS nVARCHAR) + '%',
CAST((IA.SchemeDiscountPercentage) AS nVARCHAR),
IA.SchemeDiscountAmount,
Convert(nvarchar,IA.CreationTime,103) +' '+ Convert(varchar,IA.CreationTime,8),
IA.NewReference,
(case when IA.InvoiceType=1 then
(select Top 1 SoNumber from soabstract where Sonumber=IA.SONumber)
when  IA.invoicetype=3 then (select Top 1 SoNumber from soabstract where Sonumber in
(select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType=1 order by InvoiceId desc)) end),
(case when IA.InvoiceType=1 then
(select Top 1 Documentreference from soabstract where Sonumber=IA.SONumber)
when  IA.invoicetype=3 then
(select Top 1 Documentreference from soabstract where Sonumber in
(select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType=1 order by InvoiceId desc)) end),
(case when IA.InvoiceType=1 then
(select Top 1 RefNumber from soabstract where Sonumber=IA.SONumber)
when  IA.invoicetype=3 then (select Top 1 RefNumber from soabstract where Sonumber in
(select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType=1 order by InvoiceId desc )) end),
(case when IA.InvoiceType=1 then
( select Top 1 Convert(varchar,SoDate,103) from soabstract where Sonumber=IA.SONumber)
when  IA.invoicetype=3 then
(select Top 1 Convert(varchar,SoDate,103) from soabstract where Sonumber in
(select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType=1 order by InvoiceId desc)) end),
(case when IA.InvoiceType=1 then
(select
Case When soabstract.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = SOAbstract.OrderType)
Else
case when soabstract.ForumSC=1 then 'Manual Order' else 'HH order' end
End
from soabstract where Sonumber=IA.SONumber
)
--(select case when soabstract.ForumSC=1 then 'Manual Order' else 'HH order' end from soabstract where Sonumber=IA.SONumber)
when IA.invoicetype=3 then
(select
Case When soabstract.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = SOAbstract.OrderType)
Else
case when soabstract.ForumSC=1 then 'Manual Order' else 'HH order' end
End
from soabstract where Sonumber in (select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)
)
end),
Cast((case when IA.InvoiceType=1 then
(select Sum(quantity * SalePrice) from SoDetail where Sonumber=IA.SOnumber)
when  IA.invoicetype=3 then
(select Sum(quantity * SalePrice) from SoDetail where Sonumber in
(select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType=1 order by InvoiceId desc )) end) as Decimal(18,6)),
Cast((case when IA.InvoiceType=1 then
(select soabstract.value from soabstract where Sonumber=IA.SoNumber)
when IA.invoicetype=3 then
(select soabstract.value from soabstract where Sonumber in
(select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=IA.DocumentID
and IV.InvoiceType= 1 order by InvoiceId desc)) end) as Decimal(18,6)),
Convert(varchar,getdate(),103) + ' ' + Convert(varchar,getdate(),108),
case when isnull(status,0) & 64 <> 0 then 'Cancel'
when IA.invoicetype in (1,4) and isnull(status,0) & 192 = 0 then
'Open'
When isnull(status,0) & 128 <> 0 Then 'Amended'
when IA.invoicetype=3 and isnull(status,0) & 192 = 0 then
'Amendment'
else
'Cancel'
end ,
case when ( Isnull(IA.FromStateCode,0) > 0 And Isnull(IA.ToStateCode,0) > 0 And Isnull(IA.FromStateCode,0) = Isnull(IA.ToStateCode,0) ) then 'Intra State'
when ( Isnull(IA.FromStateCode,0) > 0 And Isnull(IA.ToStateCode,0) > 0 And Isnull(IA.FromStateCode,0) <> Isnull(IA.ToStateCode,0) ) then 'Inter state'
Else '' End ,
Case When IsNull(IA.GSTIN,'') = '' Then 'UnRegistered' Else 'Registered' End
FROM tmpInvoiceAbstract IA
Inner Join Customer on IA.CustomerID = Customer.CustomerID
Inner Join Customer_Channel CC on CC.ChannelType=Customer.ChannelType
Left Outer Join Beat on IA.BeatID = Beat.BeatID
Inner Join Salesman on IA.SalesmanID = Salesman.SalesmanID
Left Outer Join DStype_Details DD On Salesman.SalesmanID = DD.SalesmanID
WHERE  InvoiceType in (1,3,4,5) AND
((InvoiceDate BETWEEN @FROMDATE AND @TODATE)
--or (CancelDate between @FROMDATE AND @TODATE)
) AND
--IA.CustomerID = Customer.CustomerID AND
--CC.ChannelType=Customer.ChannelType and
--IA.BeatID *= Beat.BeatID And
--IA.SalesmanID = Salesman.SalesmanID
--And  Salesman.SalesmanID *= DD.SalesmanID
DD.DSTypeCtlPos = 1
--and ((IA.Status & 192) = 0 or (IA.Status & 64 <> 0))
Order By  IA.DocumentID

insert into #TmpSaleDataAbstract( DocumentID,WDCode,WDDest,Fromdate,ToDate,
InvoiceID,InvoiceNo,SaleType, Docref, InvDate,DeliveryDate,CustomerID, CustomerName,RCSID,CustomerAddress,ChannelID,
ChannelName,BeatName,DSID,DSName,DSSubType,GrossValue,NetValue,OrderID,OrderNo,OrderRefNo,OrderDate,GenerationDateTime,OrderType,InvoiceType,
CategoryGroup,InvCreationDate,OrgDocStatus,StateType, RegUnReg   )
select DocumentID ,@WDCode,
@WDDest,Convert(varchar,@FromDate,103) ,Convert(varchar,@ToDate,103),
S.SONumber,
@SC + Cast(DocumentID as nVarchar),'ORDER', DocumentReference, Convert(varchar,SODate,103),Convert(varchar,DeliveryDate,103), Customer.CustomerID,
Customer.Company_Name,
Customer.RCSOutletID,
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Customer.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),


--Customer.ChannelTYpe,
CC.Code,
CC.ChannelDesc,
Beat.Description,
--"Salesman" = Salesman.Salesman_Name
--DD.DSTypeID,
Salesman.SalesmanID,
Salesman.Salesman_Name,
--(select DSTypename from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
(select DSTypeValue from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
(select Sum(quantity * SalePrice) from SoDetail where Sonumber=S.SOnumber),
S.Value,S.SONumber,DocumentReference,PODocReference,Convert(varchar,SODate,103) ,
Convert(varchar,getdate(),103) + ' ' + Convert(varchar,getdate(),108),
Case when S.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = S.OrderType)
Else
Case when S.ForumSC=1 then 'Manual Order' else 'HH order' end
End,
--Case when S.ForumSC=1 then 'Manual Order' else 'HH order' end ,
Case When isnull(S.Status,0) & 192 = 192 then
'Cancel'
when (isnull(SoRef,0) >0) then
'Amendment'
Else
'Open'
End,
case when S.GroupID='0' Or isNull(S.GroupID,'-1' ) = '-1' then
'All'
else
dbo.mERP_fn_Get_GroupNames(S.GroupID)
end,
Convert(nvarchar,S.CreationTime,103) +' '+ Convert(varchar,S.CreationTime,8),
Case When isnull(S.Status,0) & 192 = 192 then
'Cancel'
when (isnull(SoRef,0) >0) then
'Amendment'
When isnull(S.Status,0) & 256 = 256 And isnull(S.status,0)& 64 = 64 Then
'Amended'
Else
'Open'
End,
case when ( Isnull(S.FromStateCode,0) > 0 And Isnull(S.ToStateCode,0) > 0 And Isnull(S.FromStateCode,0) = Isnull(S.ToStateCode,0) ) then 'Intra State'
when ( Isnull(S.FromStateCode,0) > 0 And Isnull(S.ToStateCode,0) > 0 And Isnull(S.FromStateCode,0) <> Isnull(S.ToStateCode,0) ) then 'Inter state'
Else '' End,
--Case When IsNull(S.GSTIN ,'') = '' Then 'UnRegistered' Else 'Registered' End
''
from SOAbstract S
Inner Join Customer on  S.CustomerID = Customer.CustomerID
Inner Join Customer_Channel CC on CC.ChannelType=Customer.ChannelType
Left Outer Join Beat on S.BeatID = Beat.BeatID
Inner Join Salesman on S.SalesmanID = Salesman.SalesmanID
Left Outer join DStype_Details DD on Salesman.SalesmanID = DD.SalesmanID
where
--S.SONumber Not in (select IsNull(SONumber,0) from InvoiceAbstract)    And
((SODate BETWEEN @FROMDATE AND @TODATE)
--or (CancelDate between @FROMDATE AND @TODATE)
)
And ((isnull(Status,0) & 320 = 0) or (isnull(Status,0) & 192=192))
--and S.CustomerID = Customer.CustomerID AND
--CC.ChannelType=Customer.ChannelType and
--S.BeatID *= Beat.BeatID And
--S.SalesmanID = Salesman.SalesmanID
--And  Salesman.SalesmanID *= DD.SalesmanID
And DD.DSTypeCtlPos = 1
order by S.sonumber

Update #TmpSaleDataAbstract Set InvoiceType = 'Expired' From SOAbstract
Where SOAbstract.SONumber  = #TmpSaleDataAbstract.InvoiceID
And Convert(Nvarchar(10),SOAbstract.SODate,103) <= @Expirydate
And InvoiceType in('Open','Amendment')
And SaleType='ORDER'

Select
-- "InvoiceId" = #TmpSaleDataAbstract.InvoiceId ,
"creditId" = cn.creditId,
-- "Notevalue" = IsNull(cn.NoteValue, 0),
"Adjamount" = sum(IsNUll(cd.AdjustedAmount, 0))
Into #tmpCredit
from #TmpSaleDataAbstract
join Collectiondetail cd on #TmpSaleDataAbstract.Invoiceid = cd.Invoiceid and cd.documenttype = 10
join collections col on cd.collectionid = col.documentId and IsNull(col.status, 0) <> 192
join Creditnote cn on cd.Documentid = cn.creditid
group by cn.creditId

select I.DocumentId, sum(IsNull(cd.AdjustedAmount,0)) 'AdjustedAmount' , col.customerId, CD.DocumentID 'CreditID' Into #tmpAdjamount
from Collectiondetail cd Join collections col on cd.collectionid = col.documentId and IsNull(col.status, 0) <> 192
join Invoiceabstract I on cd.Invoiceid = I.Invoiceid
where cd.Documentid in ( select distinct creditId from #tmpCredit )
group by I.DocumentId, col.customerId, CD.DocumentID

select I.DocumentId, I.InvoiceId, sum(IsNull(cold.AdjustedAmount,0)) AdjustedAmount, cold.DocumentId 'CreditId' Into #tmpColD
from #tmpAdjamount tmp Join Invoiceabstract I on tmp.DocumentId = I.documentId and IsNull(I.status, 0) & 128 = 0
Join collectionDetail cold on I.InvoiceId = cold.InvoiceId and cold.documenttype = 10
group by I.DocumentId, I.InvoiceId, cold.DocumentId

Alter Table #TmpSaleDataAbstract Add SupervisorID int
Alter Table #TmpSaleDataAbstract Add SupervisorName nvarchar(255)
Alter Table #TmpSaleDataAbstract Add SupervisorType nvarchar(100)

update tmpAbstract set SupervisorID = sup.SalesmanID , SupervisorName = sup.SalesmanName,SupervisorType=SType.TypeDesc
from #TmpSaleDataAbstract tmpAbstract,InvoiceAbstract IA,
Salesman2 sup,tbl_merp_SupervisorType SType
Where sup.TypeID=SType.TypeID
And tmpAbstract.SaleType in('INVOICE','INVFROMSC','SALESRETURNDAMAGE','SALESRETURNSALEABLE')
And tmpAbstract.InvoiceID = IA.InvoiceID
And IA.Salesman2=sup.SalesmanID

update tmpAbstract set SupervisorID = sup.SalesmanID , SupervisorName = sup.SalesmanName,SupervisorType=SType.TypeDesc
from #TmpSaleDataAbstract tmpAbstract,SOAbstract SA,
Salesman2 sup,tbl_merp_SupervisorType SType
Where sup.TypeID=SType.TypeID
And tmpAbstract.SaleType in('ORDER')
And tmpAbstract.InvoiceID = SA.SONumber
And SA.SupervisorID=sup.SalesmanID

Create Table #Abstract(_0 nVarchar(255),
_1 nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,
_2 nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,
_3 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
_4 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
_5 int,
_6 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_7 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_8 nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
_9 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
_10 nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
_11 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
_12 nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
_13 nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,
_14 nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
_15 nvarchar(350)COLLATE SQL_Latin1_General_CP1_CI_AS,
_16 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_17 nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
_18 int,
_19 nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
_20 nvarchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,
_21 nvarchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,
_22 nvarchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,
_23 nvarchar(300)COLLATE SQL_Latin1_General_CP1_CI_AS,
_24 int,
_25 nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
_26 nvarchar(350)COLLATE SQL_Latin1_General_CP1_CI_AS,
_27 int,
_28 nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
_29 nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
_30 nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
_31 nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
_32 decimal(18,6),
_33  decimal(18,6),
_34 Decimal(18,6),
_35 Decimal(18,6),
--TotAddlDisc Decimal(18,6),
_36 decimal(18,6),
_37 decimal(18,6),
_38 decimal(18,6),
_39 decimal(18,6),
_40 decimal(18,6),
--SchSeqNo int,
--Schemes nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,
--SchemeValue decimal(18,6),
--InvCreationDate datetime,
_41 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_42 nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
_43 int,
_44 nvarchar(2000)COLLATE SQL_Latin1_General_CP1_CI_AS,
_45 nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
_46 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS ,
_47 nvarchar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
_48 decimal(18,6),
_49 decimal(18,6),
_50 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_51 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,    --for loyalty changes
_52 decimal(18,6),
_53 decimal(18,6),
_54 decimal(18,6),
_55 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_56 Int ,
_57 nvarchar(240)COLLATE SQL_Latin1_General_CP1_CI_AS,
_58 nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
_59 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_60 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_61 nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS
)

Insert Into #Abstract
select Distinct dbo.mERP_fn_FilterSplChar_ITC(cast(#TmpSaleDataAbstract.Invoiceid as nvarchar)+';'+SaleType),
"WDCode" = WDCode,
"WDDest" = WDDest,
"From Date" = FromDate ,
"To Date" = ToDate,
"DocID" = #TmpSaleDataAbstract.Invoiceid ,
"DocNo" = dbo.mERP_fn_FilterSplChar_ITC(InvoiceNo) ,
"DocType"= SaleType,
"Doc Ref" = dbo.mERP_fn_FilterSplChar_ITC(#TmpSaleDataAbstract.Docref),
"Doc Date" = InvDate,
"Doc Status" = #TmpSaleDataAbstract.InvoiceType,
"DeliveryDate"= #TmpSaleDataAbstract.DeliveryDate,
"OrderReference"= dbo.mERP_fn_FilterSplChar_ITC(OrderReference),
"Payment Mode" = #TmpSaleDataAbstract.PaymentMode,
--"Payment Date" = InvoiceAbstract.PaymentDate,
"CustomerID" = #TmpSaleDataAbstract.CustomerID,
"CustomerName" = dbo.mERP_fn_FilterSplChar_ITC(CustomerName),
"RCSID" = dbo.mERP_fn_FilterSplChar_ITC(RCSID),
"Customer Address" =  dbo.mERP_fn_FilterSplChar_ITC(CustomerAddress),
"ChannelID" = ChannelID,
"ChannelName" = ChannelName,
"New Channel Type" = IsNull(olcl.[Channel Type], @TOBEDEFINED),
"New Outlet Type" = IsNull(olcl.[Outlet Type], @TOBEDEFINED),
"New Loyalty Program" = IsNull(olcl.[Loyalty Program], @TOBEDEFINED),
"BeatName" = dbo.mERP_fn_FilterSplChar_ITC(BeatName),
--"Salesman" = Salesman.Salesman_Name
"DSID" =DSID,
"DSName" = dbo.mERP_fn_FilterSplChar_ITC(DSName),
"DS SubType" = dbo.mERP_fn_FilterSplChar_ITC(DSSubType),
"Supervisor ID" = SupervisorID,
"Supervisor Name" = dbo.mERP_fn_FilterSplChar_ITC(SupervisorName),
"Supervisor Type" = SupervisorType,
"CategoryGroup" = CategoryGroup,
"Transaction Type" = dbo.mERP_fn_FilterSplChar_ITC(DocType),
--"Goods Value" = GoodsValue,
"GrossValue" = InvGrossValue,
"TotalDisc" = TotalDisc,
"TotSchemeDisc" = TotSchemeDisc,
"TotTradeDisc" = TotTradeDisc,
--"TotAddlDisc" = TotAddlDisc,
"TotalTax" = TotalTax,
"NetValue" =InvNetValue,
"RoundOff" =RoundOff,
"AdjustedAmount" = #TmpSaleDataAbstract.AdjustedAmount,
"AmountReceivable" = AmountReceivable,
--"SchSeqNo" = SchSeqNo,
--"Scheme%" = Schemes,
--"SchemeValue" = SchemeValue,
"CreationDate" = InvCreationDate,
"InvRefNo" = dbo.mERP_fn_FilterSplChar_ITC(InvRefNo),
"OrderID" =OrderID,
"OrderNo" = dbo.mERP_fn_FilterSplChar_ITC(OrderNo),
"OrderRefNo" = dbo.mERP_fn_FilterSplChar_ITC(OrderRefNo),
"OrderDate" = OrderDate,
"OrderType" = dbo.mERP_fn_FilterSplChar_ITC(OrderType),
"OrderGrossValue" = #TmpSaleDataAbstract.GrossValue,
"OrderNetValue" = #TmpSaleDataAbstract.NetValue,
"Credit Limit Exceed" = (Case When #TmpSaleDataAbstract.Invoiceid in (select invoiceid from GT_Invoice where Alerttype in (1,2,3,4)) then 'Yes' else 'No' end),
"GV No" = '',--cn.GiftVoucherNo,

"GV Amount" = 0,--cn.NoteValue,
"GV Adj.Val" = 0,--cd.AdjustedAmount,
"GV Bal.Amt" = 0,--cn.NoteValue - IsNull(( select sum(#tmpAdjamount.AdjustedAmount) from #tmpAdjamount where DocumentId < #TmpSaleDataAbstract.DocumentID and customerId = #TmpSaleDataAbstract.CustomerId and CD.CreditID = #tmpAdjamount.CreditID), 0) - cd.AdjustedAmount,
"GenerationDateTime" =GenerationDateTime,
"Base GOI Market ID" = cast(Null as Int),
"Base GOI Market Name" = cast(Null as Nvarchar(240)),
"Reason"= Null,
"OrgDocStatus"=OrgDocStatus,
"StateType" = StateType,
"RegUnReg"  = IsNull(RegUnReg,'')
--	"Reason"=Case When isnull(IA.CancelReasonID,0)<>0 then (select dbo.mERP_fn_FilterSplChar_ITC(IR.Reason) From invoiceReasons IR Where IA.CancelReasonID=IR.ID)
--					When isnull(IA.amendReasonID,0)<>0 then (select dbo.mERP_fn_FilterSplChar_ITC(IR.Reason) From invoiceReasons IR Where IA.AmendReasonID=IR.ID)End
from
#TmpSaleDataAbstract join #OLClassCustLink olcl on olcl.CustomerID = #TmpSaleDataAbstract.CustomerID
--	Join InvoiceAbstract IA On #TmpSaleDataAbstract.Invoiceid = IA.Invoiceid
left outer join #tmpColD cd on #TmpSaleDataAbstract.Invoiceid = cd.Invoiceid
left outer join Creditnote cn on cd.CreditId = cn.creditid
--	  Where olcl.CustomerID = #TmpSaleDataAbstract.CustomerID

Update T Set T._58 = IR.Reason From #Abstract T,InvoiceAbstract IA,invoiceReasons IR
Where T._5 = IA.Invoiceid And
(Case When isnull(IA.CancelReasonID,0) <> 0 then isnull(IA.CancelReasonID,0) Else isnull(IA.amendReasonID,0) End) = IR.ID

Update T Set T._56 = T1.MarketID,T._57 = T1.MarketName
From #Abstract T, MarketInfo T1,CustomerMarketInfo T2
Where Ltrim(Rtrim(T._14)) = Ltrim(Rtrim(T2.CustomerCode))
And T2.Active = 1
And T1.MMID = T2.MMID
--And T1.Active = 1


-------------------------------------------------------------------------
--						   			Detail Procedure				   --
-------------------------------------------------------------------------

Declare @ID nVarchar(255)

Create table #Detail
(
_0  nVarchar(255),
_62 nvarchar(25),
_63 int,
_64 nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
_65 nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
_66 int,
_67 nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
_68 int,
_69 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_70 decimal(18,6),
_71 decimal(18,6),
_72 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_73 decimal(18,6),
_74 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_75 decimal(18,6),
_76 nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
_77 decimal(18,6),
_78 decimal(18,6),
_79 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_80 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_81 nvarchar(50),
_82 nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
_83 decimal(18,6),
_84 decimal(18,6),
_85 decimal(18,6),
_86 decimal(18,6),
_87 decimal(18,6),
_88 nvarchar(50),
_89 nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
_90 nVarchar(100),
_91 nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,
_92 nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,
_93 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_94 decimal(18,6),
_95 nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
_96 decimal(18,6),
_97 Int
,_98 Decimal(18,6)
,_99 nVarChar(5)COLLATE SQL_Latin1_General_CP1_CI_AS
,_100 Int
)

Create table #TmpSaleDetail
(
Type nvarchar(25),
ID int,
pcode nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
pname nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
Bcode int,
Batch_Number nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
Serial int,
BaseUom nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
BUOM_Quantity decimal(18,6),
SalePrice decimal(18,6),
SaleTax nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
PurTax nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
TaxValue decimal(18,6),
Volume decimal(18,6),
PTR decimal(18,6),
PTS decimal(18,6),
--MRP decimal(18,6),
MRPPerPack decimal(18,6),
Bill_UOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
Bill_Quantity decimal(18,6),
Free_Type nvarchar(50),
Ref_ItemSeqNo nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchSeqNo nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
Comp_ActivityCode nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,
Scheme_Desc nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,
DiscPerc nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
DiscountValue decimal(18,6),
SchemePerc nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchemeValue decimal(18,6),
Netvalue decimal(18,6),
GrossValue decimal(18,6),
TotDiscValue decimal(18,6),
IsCompany int,
OrderBaseUOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderBaseUOMQTY decimal(18,6),
OrderUOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderQTY decimal(18,6)
, PurTaxVal Decimal(18,6)
, PurTaxType nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS
, CSTaxCode int
)


Declare @PrevID nVarchar(255)
Set @PrevID = ''

Declare DetailCursor Cursor For
Select _0 From #Abstract
Open DetailCursor
Fetch Next From DetailCursor Into @ID
While @@Fetch_Status = 0
Begin
Declare @SCHEME_TYPE int
Declare @Type int
Declare @SchDescription nvarchar(250)
Declare @DocumentID int
Declare @DocumentType nvarchar(20)
Declare @Pos1 int
Declare @Length int
Declare @so_number nvarchar(250)
Begin
If @ID <> @PrevID
Begin

Insert Into #XMLData Select 'Abstract _1="' + Cast(Isnull(_1, '') as nVarchar(20)) + '"' +
' _2="' + Cast(Isnull(_2, '') as nVarchar(20)) + '"' +
' _3="' + Cast(Isnull(_3, '') as nVarchar(50)) + '"' +
' _4="' + Cast(Isnull(_4, '') as nVarchar(50)) + '"' +
' _5="' + Cast(Isnull(_5, 0) as nVarchar) + '"' +
' _6="' + Cast(Isnull(_6, '') as nVarchar(25)) + '"' +
' _7="' + Cast(Isnull(_7, '') as nVarchar(50)) + '"' +
' _8="' + Cast(Isnull(_8, '') as nVarchar(510)) + '"' +
' _9="' + Cast(Isnull(_9, '') as nVarchar(50)) + '"' +
' _10="' + Cast(Isnull(_10, '') as nVarchar(30)) + '"' +
' _11="' + Cast(Isnull(_11, '') as nVarchar(50)) + '"' +
' _12="' + Cast(Isnull(_12, '') as nVarchar(510)) + '"' +
' _13="' + Cast(Isnull(_13, '') as nVarchar(10)) + '"' +
' _14="' + Cast(Isnull(_14, '') as nVarchar(250)) + '"' +
' _15="' + Cast(Isnull(_15, '') as nVarchar(350)) + '"' +
' _16="' + Cast(Isnull(_16, '') as nVarchar(50)) + '"' +
' _17="' + Cast(Isnull(_17, '') as nVarchar(510)) + '"' +
' _18="' + Cast(Isnull(_18, 0) as nVarchar) + '"' +
' _19="' + Cast(Isnull(_19, '') as nVarchar(150)) + '"' +
' _20="' + Cast(Isnull(_20, '') as nVarchar(256)) + '"' +
' _21="' + Cast(Isnull(_21, '') as nVarchar(256)) + '"' +
' _22="' + Cast(Isnull(_22, '') as nVarchar(256)) + '"' +
' _23="' + Cast(Isnull(_23, '') as nVarchar(300)) + '"' +
' _24="' + Cast(Isnull(_24, 0) as nVarchar) + '"' +
' _25="' + Cast(Isnull(_25, '') as nVarchar(250)) + '"' +
' _26="' + Cast(Isnull(_26, '') as nVarchar(350)) + '"' +
' _27="' + Cast(Isnull(_27, 0) as nVarchar) + '"' +
' _28="' + Cast(Isnull(_28, '') as nVarchar(255)) + '"' +
' _29="' + Cast(Isnull(_29, '') as nVarchar(100)) + '"' +
' _30="' + Cast(Isnull(_30, '') as nVarchar(150)) + '"' +
' _31="' + Cast(Isnull(_31, '') as nVarchar(150)) + '"' +
' _32="' + Cast(Isnull(_32, 0) as nVarchar) + '"' +
' _33="' + Cast(Isnull(_33, 0) as nVarchar) + '"' +
' _34="' + Cast(Isnull(_34, 0) as nVarchar) + '"' +
' _35="' + Cast(Isnull(_35, 0) as nVarchar) + '"' +
' _36="' + Cast(Isnull(_36, 0) as nVarchar) + '"' +
' _37="' + Cast(Isnull(_37, 0) as nVarchar) + '"' +
' _38="' + Cast(Isnull(_38, 0) as nVarchar) + '"' +
' _39="' + Cast(Isnull(_39, 0) as nVarchar) + '"' +
' _40="' + Cast(Isnull(_40, 0) as nVarchar) + '"' +
' _41="' + Convert(nVarchar,_41, 103)  + '"' +
' _42="' + Cast(Isnull(_42, '') as nVarchar(255)) + '"' +
' _43="' + Cast(Isnull(_43, 0) as nVarchar) + '"' +
' _44="' + Cast(Isnull(_44, '') as nVarchar(2000)) + '"' +
' _45="' + Cast(Isnull(_45, '') as nVarchar(510)) + '"' +
' _46="' + Cast(Isnull(_46, '') as nVarchar(50)) + '"' +
' _47="' + Cast(Isnull(_47, '') as nVarchar(30)) + '"' +
' _48="' + Cast(Isnull(_48, 0) as nVarchar) + '"' +
' _49="' + Cast(Isnull(_49, 0) as nVarchar) + '"' +
' _50="' + Cast(Isnull(_50, '') as nVarchar(50)) + '"' + --for loyalty changes
' _51="' + Cast(Isnull(_51, '') as nVarchar(50)) + '"' + --for loyalty changes
' _52="' + Cast(Isnull(_52, 0) as nVarchar) + '"' +
' _53="' + Cast(Isnull(_53, 0) as nVarchar) + '"' +
' _54="' + Cast(Isnull(_54, 0) as nVarchar) + '"' +
' _55="' + Convert(nVarchar,_55, 103 ) + '"' +
' _56="' + Cast(Isnull(_56, 0) as nVarchar) + '"' +
' _57="' + Cast(Isnull(_57, 0) as nVarchar(240)) + '"'+
' _58="' + Cast(Isnull(_58, '') as nVarchar(255)) + '"'+
' _59="' + Cast(Isnull(_59, '') as nVarchar(50)) + '"' +
' _60="' + Cast(Isnull(_60, '') as nVarchar(50)) + '"' +
' _61="' + Cast(Isnull(_61, '') as nVarchar(15)) + '"'
From #Abstract
Where _0 = @ID

End

Set @Pos1 = CharIndex(N';', @ID, 1)
Set @DocumentID = cast(SubString(@ID, 1, @Pos1 - 1) as int)
Set @DocumentType = Cast(SubString(@ID,@Pos1+1,Len(@ID)) as nvarchar)


select @so_number = sonumber from Invoiceabstract where InvoiceId = @DocumentID and Invoicetype = 1
If isnull(@so_number,'') = ''
select @so_number = sonumber from Invoiceabstract where DocumentID =
( select DocumentID from Invoiceabstract where InvoiceId = @DocumentID ) and Invoicetype = 1
select sum(sd.quantity) as quantity, sd.product_code as product_code,
sd.uom as sd_uom, uom.description as sd_uomdesc, Itm.UOM1 as ItmUOM1, Itm.UOM2 as ItmUOM2,
Itm.UOM1_Conversion as UOM1_Conversion, Itm.UOM2_Conversion as UOM2_Conversion
Into #tmpsd from sodetail sd Join uom on sd.uom = uom.uom
Join Items Itm on sd.product_code = Itm.product_code
where sd.sonumber = @so_number
group by sd.product_code, sd.uom, uom.description, Itm.UOM1, Itm.UOM2,
Itm.UOM1_Conversion, Itm.UOM2_Conversion

If @DocumentType=N'Order'
Begin

insert into #TmpSaleDetail
select "Type"='NonScheme',
"ID"  = SD.SONumber,
"pcode" = I.Product_Code,
"pname" = productname,
"BCode" = '',
"Batch_Number" = SD.Batch_Number,
"Serial" = SD.Serial,
"BaseUom" = U.Description,
"BUOM_Quantity" = SD.Quantity,
"SalePrice" = (Case When I.UOM1=SD.UOM then (SD.SalePrice) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2=SD.UOM then (SD.SalePrice) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion
End  Else SD.SalePrice end),
--"SaleTax" =  CAST(Round((SD.SaleTax+SD.TaxCode2), 2) AS nVARCHAR) + '%',
"SaleTax" =  CAST((SD.SaleTax+SD.TaxCode2) AS nVARCHAR),
--"PurTax" = CAST(ISNULL((SD.TaxSuffered), 0) AS nVARCHAR) + '%',
"PurTax" = CAST(ISNULL((SD.TaxSuffered), 0) AS nVARCHAR),
--"TaxValue" =(SD.quantity * SD.Saleprice) * (SD.SaleTax /100) ,
"TaxValue" =  Case Isnull(SD.TaxOnQty,0) When 0 then  ((((SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100))
*(IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))/100)) Else
(SD.Quantity * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))) End,
/*"Volume" = (Case When I.UOM1=SD.UOM then dbo.sp_Get_ReportingQty(SD.Quantity, Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End)  When I.UOM2=SD.UOM  then dbo.sp_Get_ReportingQty(SD.Quantity, Case When IsNull(I.UOM2_Conversion,
0) = 0 Then 1 Else I.UOM2_Conversion End)  Else SD.Quantity  End),*/
"Volume" =  Isnull(SD.Quantity,0) * IsNull(I.COnversiOnFactOr,0),
--"PTR" = case when SD.Batch_Number = '' then I.PTR else (select Max(PTR) from Batch_products where Product_code=I.product_code and Batch_number=SD.Batch_number) end,
--"PTS" = case when SD.Batch_Number = '' then I.PTS else (select Max(PTS) from Batch_products where Product_code=I.product_code and Batch_number=SD.Batch_number) end,
"PTR" = I.PTR,
"PTS" = I.PTS,
--"MRP" = I.MRP,
--"MRPPerPack" = I.MRPPerPack,
"MRPPerPack" = SD.MRPPerPack,

"Bill_UOM" = '', --(Select Description From UOM Where UOM = SD.UOM),
-- --"Bill_Quantity" = SD.UOMQty,
"Bill_Quantity" = 0, -- (Case When I.UOM1 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1
--  Else I.UOM2_Conversion
-- End  Else SD.Quantity  End),

"Free_Type" = '',
"Ref_ItemSeqNo" = '',
"SchSeqNo" = 0,
"Comp_ActivityCode" = 0,
"Scheme_Desc" = '',
--"DiscPerc" = CAST(Round(SD.Discount, 2) AS nVARCHAR) + '%',
"DiscPerc" = CAST(Round(SD.Discount, 2) AS nVARCHAR),
"DiscountValue" = (SD.Quantity * SD.SalePrice) * (SD.Discount / 100),
--"SchemePerc" = CAST(Round(cast(0 as decimal), 2) AS nVARCHAR) + '%',
"SchemePerc" = CAST(Round(cast(0 as decimal), 2) AS nVARCHAR),
"SchemeValue" = 0,
"Netvalue" = Case Isnull(SD.TaxOnQty,0) When 0 then  ((SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100) + ((SD.Quantity * SD.SalePrice) * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))/100)) Else
((SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100) + (SD.Quantity  * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0)))) End,
-- - (SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100)
"GrossValue"= (SD.Quantity * SD.saleprice),
"TotDiscValue" = 0,
"IsCompany" = 0,
U.Description,
SD.Quantity,
(Select Description From UOM Where UOM = SD.UOM),
(Case When I.UOM1 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End  Else SD.
Quantity  End)
,0,'' , isnull(SD.GSTCSTaxCode,0)
from SODetail SD,Items I ,UOM U
where SD.SONumber in (@DocumentID)
and I.product_code=SD.product_code
and I.UOM=U.UOM
End
Else
Begin

Select ID.*,"BP_PTS"=IsNull(BP.PTS,0),"BP_TQO"=BP.TOQ,"BP_PurTax"=IsNull(BP.TaxSuffered,0),"BP_TaxType" = IsNull(TT.TaxType ,'')
Into #EachInvoicedetail From  #tmpInvoiceDetail ID
Left Join Batch_products BP On Bp.Batch_Code = ID.Batch_Code
Left Join tbl_mERP_Taxtype TT On TT.TaxID = BP.TaxType
Where ID.Invoiceid=@DocumentID

Insert into #TmpSaleDetail
select case when ID.Flagword=0 then 'NonScheme' else 'Scheme' end,
"ID"  = ID.Invoiceid,
"pcode" = ID.Product_Code,
"pname" = productname,
"BCode" = Batch_Code,
"Batch_Number" = Batch_Number,
"Serial" = serial,
"BaseUom" = U.Description,
"BUOM_Quantity" = ID.Quantity,
"SalePrice" = (  Case When I.UOM1=ID.UOM then (ID.SalePrice) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2=ID.UOM then (ID.SalePrice) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion
End  Else (ID.SalePrice)  End),
--"SaleTax" =  CAST(Round((ID.TaxCode+ID.TaxCode2), 2) AS nVARCHAR) + '%',
"SaleTax" =  CAST((ID.TaxCode+ID.TaxCode2) AS nVARCHAR),
--"PurTax" = CAST(ISNULL((ID.TaxSuffered), 0) AS nVARCHAR) + '%',
"PurTax" = CAST(ISNULL((ID.TaxSuffered), 0) AS nVARCHAR),
--"Tax Value" = ID.TaxAmount,
"TaxValue" = (Isnull(STPayable,0) + IsNull(CSTPayable,0)),
/* "Volume" = (Case When I.UOM1=ID.UOM then dbo.sp_Get_ReportingQty(ID.Quantity, Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End)  When I.UOM2=ID.UOM  then dbo.sp_Get_ReportingQty(ID.Quantity, Case When IsNull(I.UOM2_Conversion,
0) = 0 Then 1 Else I.UOM2_Conversion End)  Else ID.Quantity  End),*/
--"Volume" =  dbo.sp_Get_ReportingQty(ID.Quantity,I.Reportingunit),
"Volume" =  Isnull(ID.Quantity,0) * IsNull(I.COnversiOnFactOr,0),
--"PTR" = ID.PTR,
--"PTS" = ID.PTS,
--"MRP" = ID.MRP,

"PTR" = I.PTR,
"PTS" = I.PTS,
--"MRP" = I.MRP,
--"MRPPerPack" = I.MRPPerPack,
"MRPPerPack" = ID.MRPPerPack,


"Bill_UOM" = (Select Description From UOM Where UOM = ID.UOM),
--"Bill_Quantity" = ID.UOMQty,
"Bill_Quantity" = (Case When I.UOM1 = ID.UOM then (ID.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = ID.UOM then (ID.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) =
0 Then 1 Else I.UOM2_Conversion End  Else ID.Quantity  End),
"Free_Type" = case when ID.SalePrice=0 and ID.Flagword=0 and (ID.MultipleSchemeID='' or ID.MultipleSchemeID='0') and ID.MultipleSPLCATSCHEMEID='' then
'MANUALFREE'
when ID.SalePrice=0 and ID.Flagword=1 and (ID.MultipleSchemeID<>'' or ID.MultipleSPLCATSCHEMEID <> '') Then
case when (select 1 from tbl_merp_schemeabstract where schemeID=ID.SchemeID and ApplicableOn=1) > 0 Then
'ITEMBASED'
when (select 1 from tbl_merp_schemeabstract where schemeID=ID.SchemeID and ApplicableOn=2) > 0 Then
'INVOICEBASED'
else
''
end
else
''
End,
"Ref_ItemSeqNo" = case when ID.Flagword=0 then '' when ID.Flagword=1 and ID.MultipleSchemeID='' then ID.SPLCatSerial else ID.FreeSerial end,
"SchSeqNo" =  dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),1) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),1) else '|'+ dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),1) end ,
"Comp_ActivityCode" = dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),2) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),2) else '|' + dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),2) end ,
"Scheme_Desc" = dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),3) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),3) else '|' + dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),3) end ,
--"DiscPerc" = CAST(Round(case when (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent) < 0 then 0 else (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent)  end , 2) AS nVARCHAR) + '%',
"DiscPerc" = CAST((case when (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent) < 0 then 0 else (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent)  end) AS nVARCHAR),
--"DiscPerc" = CAST(Round((0), 2) AS nVARCHAR) + '%',
"DiscountValue" = DiscountValue - SchemeDiscAmount - SplCatDiscAmount,
--"SchemePerc" = CAST(Round((ID.SchemeDiscPercent+ID.SplCatDiscPercent), 2) AS nVARCHAR) + '%',
"SchemePerc" = CAST((ID.SchemeDiscPercent+ID.SplCatDiscPercent) AS nVARCHAR),
"SchemeValue" =  SchemeDiscAmount+SplCatDiscAmount +
Case When ID.Flagword=1 Then
isnull(ID.PTR,0) * ID.Quantity
--	Case When isnull(ID.PTR,0) = 0 Then 0
--	Else
--		IsNull((select sum( SchemeValue) from #tbl_merp_SchemeSale SS, #tbl_merp_SchemeSlabDetail SD Where SS.Product_Code = ID.Product_Code
--		And SS.InvoiceID = ID.InvoiceID
--		And SS.SlabID = SD.SlabID
--		And SD.SlabType = 3 And SS.Serial = ID.Serial)
--		--+ (select((ID.Quantity * I.PTR) * (TX.Percentage / 100)) from Tax TX where TX.Tax_Code = I.Sale_Tax)
--		,0)
--	End
Else 0 End,
"Netvalue" =  ISNULL((ID.Amount), 0),
"GrossValue"= (ID.Quantity * ID.saleprice),
"TotDiscValue" = ID.DiscountValue,
--"IsCompany" = (case when (select count(*) from schemes_rec where schemename in (select schemes.schemename from schemes where SchemeID=ID.SchemeID)) > 0 then 1 else 0 end),
"IsCompany" = 1,

(select top 1 sd_uom from #tmpsd sd where sd.Product_Code = ID.Product_Code ),
(select sum(sd.Quantity) from #tmpsd sd where sd.Product_Code = ID.Product_Code ),
(select Top 1 sd.sd_uomdesc from #tmpsd sd where sd.Product_Code = ID.Product_Code ),
(select SUM(Case When ItmUOM1 = sd.sd_UOM then ((sd.Quantity))/	Case When IsNull(UOM1_Conversion, 0) = 0 Then 1
Else UOM1_Conversion End
When ItmUOM2 = sd.sd_UOM then ((sd.Quantity))/
Case When IsNull(UOM2_Conversion, 0) = 0 Then 1
Else UOM2_Conversion End
Else (sd.Quantity)
End )
from #tmpsd sd
where sd.Product_Code = ID.Product_Code )
, PurTaxVal=Case IsNull(ID.BP_TQO,0) When 0 Then ID.Quantity * BP_PTS * BP_PurTax / 100.00 Else ID.Quantity * BP_PurTax End
, PurTaxType=BP_TaxType
, CSTaxCode = isnull(ID.CSTaxCode ,0)
--from #tmpInvoiceDetail ID,Items I,UOM U where invoiceid=@DocumentID
from #EachInvoicedetail ID,Items I,UOM U where invoiceid=@DocumentID
and ID.product_code=I.Product_Code
and I.UOM=U.UOM

Drop Table #EachInvoicedetail
End


Insert Into #Detail Select
@ID,
Type,
ID,
Upper(LTrim(RTrim(pcode))),
pname,
Bcode,
dbo.mERP_fn_FilterSplChar_ITC(Batch_Number),
Serial,
Baseuom,
BUOM_Quantity,
Volume,
Bill_UOM,
Bill_Quantity,
OrderBaseUOM,
OrderBaseUOMQTY,
OrderUOM,
OrderQTY,
SalePrice,
SaleTax,
PurTax,
GrossValue,
TotDiscValue,
TaxValue,
Netvalue,
PTR,
PTS,
--		MRP,
MRPPerPack,
Free_Type,
dbo.mERP_fn_FilterSplChar_ITC(Ref_ItemSeqNo),
dbo.mERP_fn_FilterSplChar_ITC(SchSeqNo),
dbo.mERP_fn_FilterSplChar_ITC(Comp_ActivityCode),
--dbo.mERP_fn_FilterSplChar_ITC(Scheme_Desc),
/* As Per ITC, Scheme Description should be sent with blank value*/
'',
Discperc,
DiscountValue,
SchemePerc,
SchemeValue,
IsCompany
,PurTaxVal
,PurTaxType
,CSTaxCode
--"Status" = 0
from #TmpSaleDetail  as Detail
order by type,pcode

Insert Into #XMLData Select  'Detail _62="' + Cast(IsNull(_62, '') as nVarchar(25)) + '"' +
' _63="' + Cast(IsNull(_63, 0) as nVarchar) + '"' +
' _64="' + Cast(IsNull(_64, '') as nVarchar(100)) + '"' +
' _65="' + Cast(IsNull(_65, '') as nVarchar(250)) + '"' +
' _66="' + Cast(IsNull(_66, 0) as nVarchar) + '"' +
' _67="' + Cast(IsNull(_67, '') as nVarchar(100)) + '"' +
' _68="' + Cast(IsNull(_68, 0) as nVarchar) + '"' +
' _69="' + Cast(IsNull(_69 , '') as nVarchar(50)) + '"' +
' _70="' + Cast(IsNull(_70 , 0) as nVarchar) + '"' +
' _71="' + Cast(IsNull(_71 , 0) as nVarchar) + '"' +
' _72="' + Cast(IsNull(_72 , '') as nVarchar(25)) + '"' +
' _73="' + Cast(IsNull(_73 , 0) as nVarchar) + '"' +
' _74="' + Cast(IsNull(_74 , '') as nVarchar(50)) + '"' +
' _75="' + Cast(IsNull(_75 , 0) as nVarchar) + '"' +
' _76="' + Cast(IsNull(_76 , '') as nVarchar(50)) + '"' +
' _77="' + Cast(IsNull(_77 , 0) as nVarchar) + '"' +
' _78="' + Cast(IsNull(_78 , 0) as nVarchar) + '"' +
' _79="' + Cast(IsNull(_79 , '') as nVarchar(25)) + '"' +
' _80="' + Cast(IsNull(_80 , '') as nVarchar(25)) + '"' +
' _81="' + Cast(IsNull(_81 , 0) as nVarchar) + '"' +
' _82="' + Cast(IsNull(_82 , '') as nVarchar) + '"' +
' _83="' + Cast(IsNull(_83 , 0) as nVarchar) + '"' +
' _84="' + Cast(IsNull(_84 , 0) as nVarchar) + '"' +
' _85="' + Cast(IsNull(_85 , 0) as nVarchar) + '"' +
' _86="' + Cast(IsNull(_86 , 0) as nVarchar) + '"' +
' _87="' + Cast(IsNull(_87 , 0) as nVarchar) + '"' +
' _88="' + Cast(IsNull(_88 , '') as nVarchar(50)) + '"' +
' _89="' + Cast(IsNull(_89 , '') as nVarchar(250)) + '"' +
' _90="' + Cast(IsNull(_90 , '') as nVarchar(100)) + '"' +
' _91="' + Cast(IsNull(_91 , '') as nVarchar(max)) + '"' +
' _92="' + Cast(IsNull(_92 , '') as nVarchar(max)) + '"' +
' _93="' + Cast(IsNull(_93 , 0) as nVarchar(25)) + '"' +
' _94="' + Cast(IsNull(_94 , 0) as nVarchar) + '"' +
' _95="' + Cast(IsNull(_95 , 0) as nVarchar(25)) + '"' +
' _96="' + Cast(IsNull(_96 , 0) as nVarchar) + '"' +
' _97="' + Cast(IsNull(_97 , 0) as nVarchar) + '"' +
' _98="' + Cast(IsNull(_98 , 0) as nVarchar) + '"' +
' _99="' + Cast(IsNull(_99 , '') as nVarchar(5)) + '"'  +
' _100="' + Cast(IsNull(_100 , 0) as nVarchar) + '"'
From #Detail
Where _0 = @ID

Set @PrevID = @ID

--		drop table #TmpSaleDetail
Truncate Table #TmpSaleDetail
Drop Table #tmpsd

End
Fetch Next From DetailCursor Into @ID
End
Close DetailCursor
Deallocate DetailCursor

Select * Into #XMLDataFinal from #XMLData order by 1

Select XMLStr from #XMLDataFinal  as XMLData  order by ID For XML Auto, Root('Root')

--/*
Drop Table #tmpSchemeId
Drop Table #tmpSchId
Drop Table #tbl_merp_SchemeSlabDetail
Drop Table #tbl_merp_SchemeSale
Drop Table #tmpCredit
Drop Table #tmpAdjamount
Drop Table #tmpColD
--Drop Table #tmpsd
--*/
Drop Table #XMLData
Drop Table #XMLDataFinal
drop table #TmpSaleDetail
Drop table #TmpSaleDataAbstract
Drop Table #OLClassMapping
Drop Table #OLClassCustLink
Drop Table #Abstract
Drop Table #Detail
Truncate table tmpInvoiceAbstract
Drop table #tmpInvoiceDetail
TheEND:
End
