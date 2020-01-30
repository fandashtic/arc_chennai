
CREATE Procedure mERP_spr_CustomerDetail (@FromDate DateTime, @ToDate DateTime)
AS
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

--Removing Duplicate Records from Beat_Salesman Table starts
Begin Tran
Declare @TmpBeatSalesman Table
(BeatID Int,
SalesmanID Int,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
MON Int,TUE Int, WED Int, THU Int, FRI Int, SAT Int, SUN Int)

Insert Into @TmpBeatSalesman
select distinct * from Beat_Salesman

Delete from Beat_Salesman

Insert Into Beat_Salesman
select * from @TmpBeatSalesman
Commit Tran
--Removing Duplicate Records from Beat_Salesman Table ends

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

Set Dateformat dmy

If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

-- Customer Outstanding

Create Table #temp
(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS, DocumentID int null,
Documenttype int null,
[Value] Decimal(18,6) null,  [BeatID] int)

Insert #temp(CustomerID, DocumentID,  Documenttype, [Value], BeatID)
Select InvoiceAbstract.CustomerID, InvoiceID,
-- (Case InvoiceAbstract.InvoiceType When 4 then 1 When 5 then 1 When 2 then 6 Else 4 End),
(Case InvoiceAbstract.InvoiceType When 5 then 1 When 2 then 6 Else 4 End),
-- Sum(Case InvoiceAbstract.InvoiceType When 4 then 0-Isnull(InvoiceAbstract.Balance,0)
Sum(Case InvoiceAbstract.InvoiceType
When 5 then 0-Isnull(InvoiceAbstract.Balance,0) When 6 then 0-Isnull(InvoiceAbstract.Balance,0)
Else IsNull(InvoiceAbstract.Balance,0) End), BeatID
from InvoiceAbstract
Where (InvoiceAbstract.InvoiceDate between @FromDate and @ToDate
Or  InvoiceAbstract.CancelDate  between @FromDate and @ToDate)
and  InvoiceAbstract.Balance >= 0 and
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6)
-- and  InvoiceAbstract.Status & 128 = 0
group by InvoiceAbstract.CustomerID,InvoiceID,InvoiceType, BeatID



Insert #temp(CustomerID, DocumentID,  Documenttype, [Value], BeatID)
select Creditnote.CustomerID, CreditID, 2, 0 - sum(Creditnote.Balance), 0
from Creditnote
where Creditnote.DocumentDate between @FromDate and @ToDate and
Creditnote.Balance > 0
Group By Creditnote.CustomerID, CreditID


Insert #temp(CustomerID, DocumentID,  Documenttype, [Value], BeatID)
select Debitnote.CustomerID, DebitID, 5, sum(Debitnote.Balance), 0
From debitnote
Where Debitnote.DocumentDate between @FromDate and @ToDate and
Debitnote.Balance >= 0   And
isnull(DebitNote.Flag,0) <> 2
Group By Debitnote.CustomerID, DebitID


Insert #temp(CustomerID, DocumentID,  Documenttype, [Value], BeatID)
Select Collections.CustomerID, DocumentID, 3, 0 - Sum(Collections.Balance), 0
From Collections
Where Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0
Group By Collections.CustomerID, DocumentID



Declare @DocID int
Declare @DocType int
Declare @CustID varchar(255)
Declare @BeatId int

Declare GetDocs Cursor For
Select DocumentID,DocumentType,CustomerID, BeatID from #temp

Open GetDocs
Fetch From GetDocs into @DocID,@DocType,@custID, @BeatID

While @@fetch_status = 0
BEGIN
If @DocType = 4 or @DocType =5  --or @DocType =6
BEGIN

Update #temp Set [Value] = [Value] +
(Select isnull(Sum(CD.AdjustedAmount),0) -
(dbo.mERP_fn_getRealisedBalance_ITC(MAx(C.DocumentID)))
from CollectionDetail CD, Collections C, #temp T
Where T.DocumentID=@DocID And
T.CustomerID = @CustID And
T.DocumentType = @DocType And
T.DocumentID = CD.DocumentID And
CD.DocumentType = @DocType And
Isnull(C.paymentmode,0)=1 And
C.DocumentID = CD.CollectionID And
isnull(C.Status,0) & 192 = 0 And
isnull(C.Realised,0) not in (1,2))
where DocumentID = @DocID and DocumentType = @DocType
And CustomerID = @CustID
End
ELSE IF (@DocType = 1 or  @DocType = 2 )
Begin
Update #temp Set Value = Value - (Select isnull(Sum(CD.AdjustedAmount),0) + (dbo.mERP_fn_getRealisedBalance_ITC(Max(C.DocumentID))) from CollectionDetail CD, Collections C,#temp T
Where T.DocumentID=@DocID And
T.CustomerID = @CustID And
T.DocumentType = @DocType And
CD.Documenttype = @Doctype AND
T.DocumentID = CD.DocumentID And
C.DocumentID = CD.CollectionID
And  isnull(C.Status,0) & 192 = 0
And  isnull(C.Realised,0) not in (1,2))where DocumentID = @DocID and DocumentType = @DocType And CustomerID = @CustID
End
Fetch Next From GetDocs into @DocID,@DocType,@CustID, @beatID
END
Close GetDocs
Deallocate GetDocs


-----------------------------------------------------------------
-- Customer List


Create Table #CustList
(CustomerID nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #CustList
Select CustomerID From Customer
Where ModifiedDate Between @FromDate And @ToDate
And Customer.CustomerCategory Not in (4,5)
--CR
Insert Into #CustList
Select CustomerID From Customer
Where Active = 1
And CustomerID  Not In (Select CustomerID From #CustList)
And Customer.CustomerCategory Not in (4,5)
--CR

Insert Into #CustList
Select CustomerID From Customer
Where CreationDate Between @FromDate And @ToDate
And CustomerID  Not In (Select CustomerID From #CustList)
And Customer.CustomerCategory Not in (4,5)

Insert Into #CustList
Select Distinct CustomerID  from Invoiceabstract
Where (CreationTime Between @FromDate And @ToDate
Or CancelDate  between @FromDate and @ToDate)
--And IsNull(Status, 0) & 128 = 0
And CustomerID  Not In (Select CustomerID From #CustList)
--CR
Insert Into #CustList
Select Distinct CustomerID  from tbl_merp_olclassmapping
Where (CreationDate Between @FromDate And @ToDate
Or ModifiedDate  between @FromDate and @ToDate)
And CustomerID  Not In (Select CustomerID From #CustList)
--CR

-- Channel type name changed, and new channel classifications added

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
From #OLClassMapping olcm  right outer join Customer C on olcm.CustomerID = C.CustomerID

---------------------------------------------------------------------

Select [WD_Code] = @WDCode, [WDCode] = @WDCode, [WDDest] = @WDDest, [FromDate] = @FromDate, [ToDate] = @ToDate ,
[CustomerID] = C.CustomerID, [CustomerName] = Company_Name,
[RCS ID] = RCSOutletID,
[Active In RCS] = (Case when IsNull(RCSOutletID,'') <> '' then 'Yes' else 'No' end),

[Beat ID] = Cast(B.BeatID as nVarchar) ,

[Beat] = B.Description,

[DS ID] = Cast (BS.SalesmanID As nVarchar),

[DSName] = (Select Salesman_Name From Salesman Where SalesmanID = BS.SalesmanID),

[DS Type] = '',

[DS SubType] = IsNull((Select DSTypeValue From DSType_Master Where DSTypeID =
(Select DSTypeID from DSType_Details where DSTypeCtlPos = 1 and
SalesmanID = BS.SalesmanID)), '') ,

[Handheld DS] = isNull((Select DSTypeValue From DSType_Master Where DSTypeID =
(Select DSTypeID From DSType_Details Where  DSTypeCtlPos = 2 And
SalesmanID =  BS.SalesmanID)),'No'),

[Channel Class] = IsNull((Select isNull(TMDValue, '') From Cust_TMD_Master Where TMDID =
(Select TMDID From Cust_TMD_Details Where TMDCtlPos = 6 And Cust_TMD_Details.CustomerID = C.CustomerID)), '') ,

[Channel ID] = Cast(C.ChannelType AS nVarchar),
[Channel] = (Select ChannelDesc From Customer_Channel Where ChannelType = C.ChannelType),
[New Channel Type] = IsNull(olcl.[Channel Type], @TOBEDEFINED) ,
[New Outlet Type] = IsNull(olcl.[Outlet Type], @TOBEDEFINED),
[New Loyalty Program] = IsNull(olcl.[Loyalty Program], @TOBEDEFINED),

-- "Outstanding" = (Select Sum([Value]) From #temp Where #temp.CustomerID = C.CustomerID) ,
[Outstanding] = ((Select IsNull(Sum([Value]),0) From #temp Where #temp.CustomerID = BS.CustomerID and #temp.BeatID = BS.BeatID)) ,


[Total Time Spent with HH] = IsNull((Select Cast(Sum(isNull(Time_Spent,0)) as Decimal(18,6)) /60  From DS_TimeSpent Where
Visit_Status in('V','E') And Call_Date Between @FromDate And @ToDate And CUST_CD = BS.CustomerID
and SLSMAN_CD = BS.SalesmanID), 0) ,

[No. of Days with HH] = (Select Count(Distinct dbo.StripDateFromTime(Call_Date)) From DS_TimeSpent  Where CUST_CD = BS.CustomerID
And Visit_Status in('V','E') And Call_Date Between @FromDate And @ToDate),


[Order Taken] = (Case (Select Count(*) from SOAbstract Where  IsNull(SOAbstract.ForumSc,0) = 0 and  SOAbstract.CustomerID = C.CustomerID
and SoAbstract.SoDate between @FromDate And @ToDate)
When '0' then 'No' else 'Yes' end),

[Billing Address] = Replace(Replace(BillingAddress, char(10), ''), char(44), '') ,
[Shipping Address] = Replace(Replace(ShippingAddress, char(10), ''), char(44), ''),


[Merchandise] = dbo.mERP_fn_MerchList(C.CustomerID) ,
[DateTime_Of_Gen] = getdate(),
[Active] = (Case when c.Active=1 then "Yes" else "No" end),
[Base GOI Market ID] = cast(Null as Int),
[Base GOI Market Name] = cast(Null as Nvarchar(240)),
[Latitude] = isnull((Select Top 1 cast((case When Isnull(Latitude,0) = 0 Then '0.000000' Else Isnull(Latitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.CustomerID),'0.000000'),
[Longitude] = isnull((Select Top 1 cast((case When Isnull(Longitude,0) = 0 Then '0.000000' Else Isnull(Longitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.CustomerID),'0.000000')
,C.CreationDate CreationTime, isnull(C.MobileNumber,'') MobileNo
,[Registration Status]=Case When ISNULL(c.IsRegistered,0)=0 Then 'UnRegistered' Else 'Registered' End
,"DSMobileNo" = (Select Isnull(MobileNumber,'') From Salesman Where SalesmanID = BS.SalesmanID)
,"Default Beat" = Case When (Isnull(B.BeatID,0) - Isnull(C.DefaultBeatID,0)) = 0 Then 'Yes' Else 'No' End
,'GSTIN' = Isnull(GSTIN,'')
Into #TempDetails
From
Customer c Inner Join Beat_Salesman BS On BS.CustomerID = C.CustomerID
Inner join Beat B On B.BeatiD = BS.beatID Inner join #OLClassCustLink olcl
on olcl.CustomerID = c.CustomerID
Where C.CustomerID In (Select #CustList.CustomerID From #CustList)
and (c.CustomerID <> '0' Or c.Company_name <> 'WalkIn Customer')
Order By c.CustomerID

Update T Set T.[Base GOI Market ID] = T1.MarketID,T.[Base GOI Market Name] = T1.MarketName
From #TempDetails T, MarketInfo T1,CustomerMarketInfo T2
Where Ltrim(Rtrim(T.CustomerID)) = Ltrim(Rtrim(T2.CustomerCode))
And T2.Active = 1
And T1.MMID = T2.MMID
--And T1.Active = 1

Update #TempDetails set [DS SubType] = '' Where Isnull([DS ID],0) = 0
Update #TempDetails set [DS ID] = '' Where Isnull([DSName],'') = ''

Select [WD_Code],[WDCode], [WDDest], [FromDate], [ToDate], [CustomerID], [CustomerName], [RCS ID], [Active In RCS],
[Beat ID], [Beat], [DS ID], [DSName], [DS Type], [DS SubType], [Handheld DS], [Channel Class], [Channel ID],
[Channel], [New Channel Type], [New Outlet Type], [New Loyalty Program], [Outstanding], [Total Time Spent with HH],
[No. of Days with HH], [Order Taken], [Billing Address], [Shipping Address], [Merchandise], [DateTime_Of_Gen],
[Active],[Base GOI Market ID],[Base GOI Market Name],[Latitude],[Longitude], Cast(CreationTime as nvarchar) [CreationTime], MobileNo,[Registration Status]
,Isnull(DSMobileNo,'')  As 'DSMobileNo',[Default Beat],Isnull(GSTIN,'') As 'GSTIN'
from #TempDetails

Drop Table #TempDetails
Drop Table #temp
Drop Table #CustList
Drop Table #OLClassMapping
Drop Table #OLClassCustLink
