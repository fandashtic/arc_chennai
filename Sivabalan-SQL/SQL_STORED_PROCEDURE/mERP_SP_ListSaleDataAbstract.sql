Create Procedure mERP_SP_ListSaleDataAbstract(@FromDate as datetime,@ToDate as datetime)
As
DECLARE @INV AS NVARCHAR(50)
DECLARE @SC AS NVARCHAR(50)
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Begin
Set dateformat dmy

Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()

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


-- new channel classifications added-------------------------------


CREATE TABLE #temp(
[Details] Nvarchar(81) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
InvoiceID Int,
[WDCode] Nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WDDest] Nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[From Date] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[To Date] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocID] Int NULL,
[DocNo] Nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocType] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Doc Ref] Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Doc Date] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Doc Status] Nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryDate] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderReference] Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payment Mode] Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] Nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] Nvarchar(350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RCSID] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Address] Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChannelID] Int NULL,
[ChannelName] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New Channel Type] Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New Outlet Type] Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New Loyalty Program] Nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Base GOI Market ID] Int NULL,
[Base GOI Market Name] Nvarchar(240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BeatName] Nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSID] Int NULL,
[DSName] Nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS SubType] Nvarchar(350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Supervisor ID] Int NULL,
[Supervisor Name] Nvarchar(255) COLLATE Latin1_General_CI_AI NULL,
[Supervisor Type] Nvarchar(100) COLLATE Latin1_General_CI_AI NULL,
[CategoryGroup] Nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Transaction Type] Nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrossValue] decimal(18, 6) NULL,
[TotalDisc] decimal(18, 6) NULL,
[TotSchemeDisc] decimal(18, 6) NULL,
[TotTradeDisc] decimal(18, 6) NULL,
[TotalTax] decimal(18, 6) NULL,
[NetValue] decimal(18, 6) NULL,
[RoundOff] decimal(18, 6) NULL,
[AdjustedAmount] decimal(18, 6) NULL,
[AmountReceivable] decimal(18, 6) NULL,
[CreationDate] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvRefNo] Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] Int NULL,
[OrderNo] Nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderRefNo] Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderType] Nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderGrossValue] decimal(18, 6) NULL,
[OrderNetValue] decimal(18, 6) NULL,
[Credit Limit Exceed] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GV No] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GV Amount] decimal(18, 6) NULL,
[GV Adj.Val] decimal(38, 6) NULL,
[GV Bal.Amt] decimal(38, 6) NULL,
[GenerationDateTime] Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reason]  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
OrgDocStatus nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
StateType nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
RegUnReg nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
)

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
Right Outer Join Customer C On olcm.CustomerID = C.CustomerID

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
[Base GOI Market ID] Int,
[Base GOI Market Name]  nvarchar(240)COLLATE SQL_Latin1_General_CP1_CI_AS,
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
Schemes nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchemeValue decimal(18,6),
--InvCreationDate datetime,
InvCreationDate nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
InvRefNo nvarchar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
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
RegUnReg  nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
)
insert into #TmpSaleDataAbstract
SELECT
Invoiceabstract.DocumentID ,
@WDCode,
@WDDest, "From Date" = Convert(varchar,@FromDate,103) , "To Date" = Convert(varchar,@ToDate,103),
Invoiceid ,
Case IsNULL(Invoiceabstract.GSTFlag ,0)
When 0 then @INV + CAST(Invoiceabstract.DocumentID AS nVARCHAR)
Else
IsNULL(Invoiceabstract.GSTFullDocID,'')
End,

case when Invoiceabstract.InvoiceType in (1,3) and isnull(Invoiceabstract.SONumber,'')='' then
'INVOICE'
when Invoiceabstract.InvoiceType in (1,3) and isnull(Invoiceabstract.SONumber,'')<>'' then
'INVFROMSC'
when Invoiceabstract.InvoiceType=4 and (isnull(InvoiceAbstract.Status,0) & 32) <> 0 Then
'SALESRETURNDAMAGE'
when Invoiceabstract.InvoiceType=4 and (isnull(InvoiceAbstract.Status,0) & 32) = 0 Then
'SALESRETURNSALEABLE'
end,
InvoiceAbstract.DocReference,
Convert(varchar,InvoiceDate,103),
case when isnull(status,0) & 64 <> 0 then 'Cancel'
when invoiceabstract.invoicetype in (1,4) and isnull(status,0) & 192 = 0 then
'Open'
when invoiceabstract.invoicetype=3 and isnull(status,0) & 192 = 0 then
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
--"Payment Date" = InvoiceAbstract.PaymentDate,
Customer.CustomerID,
Customer.Company_Name,
Customer.RCSOutletID,
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Customer.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),


--Customer.ChannelTYpe,
cc.code,
CC.ChannelDesc,
cast(Null as Int),
cast(Null as Nvarchar(240)),
Beat.Description,
--"Salesman" = Salesman.Salesman_Name
--DD.DSTypeID,
Salesman.SalesmanID,
Salesman.Salesman_Name,
--(select DSTypename from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
(select DSTypeValue from DSTYPE_Master where DSTYPEID=DD.DSTypeID),
case when InvoiceAbstract.GroupID='0' Or isNull(InvoiceAbstract.GroupID,'-1' ) = '-1' then
'All'
else
dbo.mERP_fn_Get_GroupNames(InvoiceAbstract.GroupID)
end,
InvoiceAbstract.DocSerialType,
--"Goods Value" = GoodsValue,
InvoiceAbstract.GoodsValue,
Cast((select sum(discountvalue-schemediscamount-splcatdiscamount) from invoicedetail where invoiceid=invoiceabstract.invoiceid) as Decimal(18,6)),
--Cast((select isnull(sum(schemediscamount),0) from invoicedetail where invoicedetail.invoiceid=invoiceabstract.invoiceid) as Decimal(18,6)),

--Total scheme discount Amount [InvoiceBased + Item Based]
(InvoiceAbstract.SchemeDiscountAmount + (select sum(schemediscamount+splcatdiscamount) from invoicedetail where invoiceid=invoiceabstract.invoiceid)),

--Cast(InvoiceAbstract.GoodsValue * (DiscountPercentage /100) as Decimal(18,6))-InvoiceAbstract.SchemeDiscountAmount,
cast(InvoiceAbstract.AddlDiscountValue as decimal(18,6)),
--Cast((InvoiceAbstract.GoodsValue * (AdditionalDiscount / 100)) as Decimal(18,6)),
0,

-- TotalTaxApplicable,
Cast(( select sum(Isnull(STPayable,0)+Isnull(CSTpayable,0)) from invoicedetail where invoiceid=invoiceabstract.invoiceid) as Decimal(18,6)),

InvoiceAbstract.Netvalue,
RoundOffAmount,
IsNull(InvoiceAbstract.AdjustedAmount, 0),
InvoiceAbstract.Balance,
InvoiceAbstract.SCHEMEID,
--CAST(Round((InvoiceAbstract.SchemeDiscountPercentage), 2) AS nVARCHAR) + '%',
CAST((InvoiceAbstract.SchemeDiscountPercentage) AS nVARCHAR),
InvoiceAbstract.SchemeDiscountAmount,
Convert(nvarchar,InvoiceAbstract.CreationTime,103) +' '+ Convert(varchar,InvoiceAbstract.CreationTime,8),
InvoiceAbstract.NewReference,
(case when invoiceabstract.InvoiceType=1 then (select Top 1 SoNumber from soabstract where Sonumber=InvoiceAbstract.SONumber) when  Invoiceabstract.invoicetype=3 then (select Top 1 SoNumber from soabstract where Sonumber in (select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)) end),
(case when invoiceabstract.InvoiceType=1 then (select Top 1 Documentreference from soabstract where Sonumber=InvoiceAbstract.SONumber) when  Invoiceabstract.invoicetype=3 then (select Top 1 Documentreference from soabstract where Sonumber in (select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)) end),
(case when invoiceabstract.InvoiceType=1 then (select Top 1 RefNumber from soabstract where Sonumber=InvoiceAbstract.SONumber) when  Invoiceabstract.invoicetype=3 then (select Top 1 RefNumber from soabstract where Sonumber in (select top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)) end),
(case when invoiceabstract.InvoiceType=1 then (select Top 1 Convert(varchar,SoDate,103) from soabstract where Sonumber=InvoiceAbstract.SONumber) when  Invoiceabstract.invoicetype=3 then (select Top 1 Convert(varchar,SoDate,103) from soabstract where Sonumber in (select  top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)) end),
(case when invoiceabstract.InvoiceType=1 then
(select
Case When soabstract.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = SOAbstract.OrderType)
Else
case when soabstract.ForumSC=1 then 'Manual Order' else 'HH order' end
End
from soabstract where Sonumber=InvoiceAbstract.SONumber
)
when Invoiceabstract.invoicetype=3 then
(select
Case When soabstract.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = SOAbstract.OrderType)
Else
case when soabstract.ForumSC=1 then 'Manual Order' else 'HH order' end
End
from soabstract where Sonumber in (select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)
)
end),
Cast((case when invoiceabstract.InvoiceType=1 then
(select Sum(quantity * SalePrice) from SoDetail where Sonumber=InvoiceAbstract.SOnumber)
when  Invoiceabstract.invoicetype=3 then
(select Sum(quantity * SalePrice) from SoDetail where Sonumber in (select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc))
end) as Decimal(18,6)),
Cast((case when invoiceabstract.InvoiceType=1 then (select soabstract.value from soabstract where Sonumber=InvoiceAbstract.SoNumber)  when  Invoiceabstract.invoicetype=3 then (select soabstract.value from soabstract where Sonumber in (select Top 1 IV.SONumber from InvoiceAbstract IV where IV.DocumentID=InvoiceAbstract.DocumentID and IV.InvoiceType=1 Order by Invoiceid desc)) end) as Decimal(18,6)),
Convert(varchar,getdate(),103) + ' ' + Convert(varchar,getdate(),108),
case when isnull(status,0) & 64 <> 0 then 'Cancel'
when InvoiceAbstract.invoicetype in (1,4) and isnull(InvoiceAbstract.status,0) & 192 = 0 then
'Open'
When isnull(status,0) & 128 <> 0 Then 'Amended'
when InvoiceAbstract.invoicetype=3 and isnull(InvoiceAbstract.status,0) & 192 = 0 then
'Amendment'
else
'Cancel'
end ,
case when ( Isnull(InvoiceAbstract.FromStateCode,0) > 0 And Isnull(InvoiceAbstract.ToStateCode,0) > 0 And Isnull(InvoiceAbstract.FromStateCode,0) = Isnull(InvoiceAbstract.ToStateCode,0) ) then 'Intra State'
when ( Isnull(InvoiceAbstract.FromStateCode,0) > 0 And Isnull(InvoiceAbstract.ToStateCode,0) > 0 And Isnull(InvoiceAbstract.FromStateCode,0) <> Isnull(InvoiceAbstract.ToStateCode,0) ) then 'Inter state'
Else '' End ,
Case When IsNull(InvoiceAbstract.GSTIN,'') = '' Then 'UnRegistered' Else 'Registered' End
FROM InvoiceAbstract
Inner Join  Customer On  InvoiceAbstract.CustomerID = Customer.CustomerID
Inner Join Customer_Channel CC On  CC.ChannelType=Customer.ChannelType
Left Outer Join Beat On  InvoiceAbstract.BeatID = Beat.BeatID
Inner Join  Salesman On  InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Left Outer Join DStype_Details DD On  Salesman.SalesmanID = DD.SalesmanID
WHERE  InvoiceType in (1,3,4,5) AND
((InvoiceDate BETWEEN @FROMDATE AND @TODATE)
--or (CancelDate between @FROMDATE AND @TODATE)
) And DD.DSTypeCtlPos = 1
--and ((InvoiceAbstract.Status & 192) = 0 or (InvoiceAbstract.Status & 64 <> 0))
Order By  InvoiceAbstract.DocumentID



insert into #TmpSaleDataAbstract(DocumentID, WDCode,WDDest,Fromdate,ToDate,
InvoiceID,InvoiceNo,SaleType, Docref, InvDate,DeliveryDate,CustomerID, CustomerName,RCSID,CustomerAddress,ChannelID,
ChannelName,[Base GOI Market ID],[Base GOI Market Name],BeatName,DSID,DSName,DSSubType,GrossValue,NetValue,OrderID,OrderNo,OrderRefNo,OrderDate,GenerationDateTime,OrderType,InvoiceType,
CategoryGroup,InvCreationDate,OrgDocStatus,StateType,RegUnReg)
select DocumentID, @WDCode,
@WDDest,Convert(varchar,@FromDate,103) ,Convert(varchar,@ToDate,103),
S.SONumber,
@SC + Cast(DocumentID as nVarchar),'ORDER', DocumentReference, Convert(varchar,SODate,103),Convert(varchar,DeliveryDate,103), Customer.CustomerID,
Customer.Company_Name,
Customer.RCSOutletID,
IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(Customer.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),


--Customer.ChannelTYpe,
CC.Code,
CC.ChannelDesc,
cast(Null as Int),
cast(Null as Nvarchar(240)),
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
End  ,
case when ( Isnull(S.FromStateCode,0) > 0 And Isnull(S.ToStateCode,0) > 0 And Isnull(S.FromStateCode,0) = Isnull(S.ToStateCode,0) ) then 'Intra State'
when ( Isnull(S.FromStateCode,0) > 0 And Isnull(S.ToStateCode,0) > 0 And Isnull(S.FromStateCode,0) <> Isnull(S.ToStateCode,0) ) then 'Inter state'
Else '' End,
--Case When IsNull(S.GSTIN,'') = '' Then 'UnRegistered' Else 'Registered' End
''
from SOAbstract S
Inner Join Customer On S.CustomerID = Customer.CustomerID
Inner Join Customer_Channel CC On CC.ChannelType=Customer.ChannelType
Left Outer Join Beat On S.BeatID = Beat.BeatID
Inner Join Salesman On S.SalesmanID = Salesman.SalesmanID
Left Outer Join DStype_Details DD On Salesman.SalesmanID = DD.SalesmanID
where
-- S.SONumber Not in (select IsNull(SONumber,0) from InvoiceAbstract)  And                  -- To get all sale orders
((SODate BETWEEN @FROMDATE AND @TODATE)
--	or (CancelDate between @FROMDATE AND @TODATE)
)
And ((isnull(Status,0) & 320 = 0) or (isnull(Status,0) & 192=192))
And DD.DSTypeCtlPos = 1
order by S.sonumber

Update #TmpSaleDataAbstract Set InvoiceType = 'Expired' From SOAbstract
Where SOAbstract.SONumber  = #TmpSaleDataAbstract.InvoiceID
And Convert(Nvarchar(10),SOAbstract.SODate,103) <= @Expirydate
And InvoiceType in('Open','Amendment')
And SaleType='ORDER'

Select
--	  "InvoiceId" = #TmpSaleDataAbstract.InvoiceId ,
"creditId" = cn.creditId,
--	  "Notevalue" = IsNull(cn.NoteValue, 0),
"Adjamount" = sum(IsNUll(cd.AdjustedAmount, 0))
--	  "Adjamount" = IsNUll(cd.AdjustedAmount, 0)
Into #tmpCredit
from #TmpSaleDataAbstract
join Collectiondetail cd on #TmpSaleDataAbstract.Invoiceid = cd.Invoiceid and cd.documenttype = 10
join collections col on cd.collectionid = col.documentId and IsNull(col.status, 0) <> 192
join Creditnote cn on cd.Documentid = cn.creditid
group by cn.creditId

select I.DocumentId, IsNUll(sum(cd.AdjustedAmount),0) 'AdjustedAmount' , col.customerId, CD.DocumentID 'CreditID' Into #tmpAdjamount
from Collectiondetail cd Join collections col on cd.collectionid = col.documentId and IsNull(col.status, 0) <> 192
join Invoiceabstract I on cd.Invoiceid = I.Invoiceid
where cd.Documentid in ( select distinct creditId from #tmpCredit )
group by I.DocumentId, col.customerId, CD.DocumentID

select I.DocumentId, I.InvoiceId, IsNUll(sum(cold.AdjustedAmount),0) AdjustedAmount, cold.DocumentId 'CreditId' Into #tmpColD
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

Update T Set T.[Base GOI Market ID] = T1.MarketID,T.[Base GOI Market Name] = T1.MarketName
From #TmpSaleDataAbstract T, MarketInfo T1,CustomerMarketInfo T2
Where Ltrim(Rtrim(T.CustomerID)) = Ltrim(Rtrim(T2.CustomerCode))
And T2.Active = 1
And T1.MMID = T2.MMID
--And T1.Active = 1

Insert Into #temp
select Distinct "Details" = cast(#TmpSaleDataAbstract.Invoiceid as nvarchar)+';'+SaleType,
"Invoiceid" = #TmpSaleDataAbstract.Invoiceid,
"WDCode" = WDCode,
"WDDest" = WDDest,
"From Date" = FromDate ,
"To Date" = ToDate,
"DocID" = #TmpSaleDataAbstract.Invoiceid ,
"DocNo" = InvoiceNo  ,
"DocType"= SaleType,
"Doc Ref" = #TmpSaleDataAbstract.Docref,
"Doc Date" = InvDate,
"Doc Status" =#TmpSaleDataAbstract.InvoiceType,
"DeliveryDate"=#TmpSaleDataAbstract.DeliveryDate,
"OrderReference"=OrderReference,
"Payment Mode" = #TmpSaleDataAbstract.PaymentMode,
--"Payment Date" = InvoiceAbstract.PaymentDate,
"CustomerID" = #TmpSaleDataAbstract.CustomerID,
"CustomerName" = CustomerName,
"RCSID" = RCSID,
"Customer Address" =  CustomerAddress,
"ChannelID" = ChannelID,
"ChannelName" = ChannelName,
"New Channel Type" = IsNull([olcl].[Channel Type], @TOBEDEFINED) ,
"New Outlet Type" = IsNull([olcl].[Outlet Type], @TOBEDEFINED),
"New Loyalty Program" = IsNull(olcl.[Loyalty Program], @TOBEDEFINED),
"Base GOI Market ID" = [Base GOI Market ID],
"Base GOI Market Name" = [Base GOI Market Name],
"BeatName" = BeatName,
--"Salesman" = Salesman.Salesman_Name
"DSID" =DSID, "DSName" = DSName, "DS SubType" =DSSubType,
"Supervisor ID" = SupervisorID,  "Supervisor Name" = SupervisorName,"Supervisor Type"=SupervisorType,
"CategoryGroup" = CategoryGroup,
"Transaction Type" = DocType,
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
"InvRefNo" = InvRefNo,
"OrderID" =OrderID,
"OrderNo" =OrderNo,
"OrderRefNo" = OrderRefNo,
"OrderDate" =OrderDate,
"OrderType" = OrderType,
"OrderGrossValue" = #TmpSaleDataAbstract.GrossValue,
"OrderNetValue" = #TmpSaleDataAbstract.NetValue,
"Credit Limit Exceed" = (Case When #TmpSaleDataAbstract.Invoiceid in (select invoiceid from GT_Invoice where Alerttype in (1,2,3,4)) then 'Yes' else 'No' end),
"GV No" = '',--cn.GiftVoucherNo,
"GV Amount" =0,-- cn.NoteValue,
"GV Adj.Val" = 0,--cd.AdjustedAmount,
"GV Bal.Amt" = 0,--cn.NoteValue - IsNull(( select sum(AdjustedAmount) from #tmpAdjamount where DocumentId < #TmpSaleDataAbstract.DocumentID and customerId = #TmpSaleDataAbstract.CustomerId and CD.CreditID = #tmpAdjamount.CreditID), 0) - cd.AdjustedAmount,
"GenerationDateTime" = GenerationDateTime,
"Reason" = Null,
"OrgDocStatus"=OrgDocStatus,
"StateType" = StateType ,
"RegUnReg" = IsNull(RegUnReg,'')
--	  "Reason"=Case When isnull(IA.CancelReasonID,0)<>0 then (select IR.Reason From invoiceReasons IR Where IA.CancelReasonID=IR.ID)
--					When isnull(IA.amendReasonID,0)<>0 then (select IR.Reason From invoiceReasons IR Where IA.AmendReasonID=IR.ID)End
from
#TmpSaleDataAbstract join #OLClassCustLink olcl on olcl.CustomerID = #TmpSaleDataAbstract.CustomerID
--	  Join InvoiceAbstract IA On #TmpSaleDataAbstract.Invoiceid = IA.Invoiceid
left outer join #tmpColD cd on #TmpSaleDataAbstract.Invoiceid = cd.Invoiceid
left outer join Creditnote cn on cd.CreditId = cn.creditid
--	  Where olcl.CustomerID = #TmpSaleDataAbstract.CustomerID

Update T Set T.Reason = IR.Reason From #temp T,InvoiceAbstract IA,invoiceReasons IR
Where T.Invoiceid = IA.Invoiceid And --IA.InvoiceType <> 1 And
(Case When isnull(IA.CancelReasonID,0) <> 0 then isnull(IA.CancelReasonID,0) Else isnull(IA.amendReasonID,0) End) = IR.ID

Select Distinct Details,WDCode,WDDest,[From Date],[To Date],DocID,DocNo,DocType,[Doc Ref],[Doc Date],[Doc Status],DeliveryDate,OrderReference,
[Payment Mode],CustomerID,CustomerName,RCSID,[Customer Address],ChannelID,ChannelName,[New Channel Type],[New Outlet Type],
[New Loyalty Program],[Base GOI Market ID],[Base GOI Market Name],BeatName,DSID,DSName,[DS SubType],[Supervisor ID],[Supervisor Name],
[Supervisor Type],CategoryGroup,[Transaction Type],GrossValue,TotalDisc,TotSchemeDisc,TotTradeDisc,TotalTax,NetValue,RoundOff,
AdjustedAmount,AmountReceivable,CreationDate,InvRefNo,OrderID,OrderNo,OrderRefNo,OrderDate,OrderType,OrderGrossValue,OrderNetValue,
[Credit Limit Exceed],[GV No],[GV Amount],[GV Adj.Val],[GV Bal.Amt],GenerationDateTime,Reason,OrgDocStatus,StateType, "RegStatus"=IsNull(RegUnReg,'') From #temp

Drop table #temp
Truncate table #TmpSaleDataAbstract
Drop table #TmpSaleDataAbstract
Drop Table #OLClassMapping
Drop Table #OLClassCustLink

Drop Table #tmpCredit
Drop Table #tmpAdjamount
Drop Table #tmpColD

End
