Create Procedure mERP_SP_NonClaimPointsSch_Upload_XML(@ParmMonth nVarchar(25))
As
Begin
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Set dateformat dmy
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup
If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End
Create Table #XMLData(ID Int Identity(1,1), XMLStr nVarchar(max))

Declare @TillDate DateTime
Declare @DtMonth DateTime
Declare @FromDate DateTime
Declare @ToDate DateTime
Declare @Month nVarchar(25)
Set @TillDate = GetDate()
If @ParmMonth = '' Or @ParmMonth = '%'
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else if  Len(@ParmMonth) > 7
Begin
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
End
Else if isDate(Cast(('01' + '/' + @ParmMonth) as nVarchar(15))) = 0
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else
Set @Month = Cast(@ParmMonth as nVarchar(7))
Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
Select @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DtMonth)+1,0))

Declare @DayClosed int
Declare @SchemeCount int
Declare @QPSPostcount int
Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@ToDate))
BEGIN
/* UAT point - Report should get upload only when QPS data posting is compeleted for the particular month*/
select @SchemeCount= count(*)
From tbl_mERP_SchemeAbstract SA
Join tbl_mERP_SchemePayoutPeriod SPP On SPP.SchemeID = SA.SchemeID And SPP.Active = 1
Join tbl_mERP_SchemeOutlet SO On SPP.SchemeID = SO.SchemeID
Where SA.SchemeType = 4 And SPP.PayoutPeriodTo Between @FromDate And @ToDate And IsNull(SA.RFAApplicable,0) = 0 and isnull(SO.QPS,0)=1
if @SchemeCount > 0
BEGIN
select @QPSPostcount = count(*)
From tbl_mERP_SchemeAbstract SA
Join tbl_mERP_SchemePayoutPeriod SPP On SPP.SchemeID = SA.SchemeID And SPP.Active = 1
Join tbl_mERP_SchemeOutlet SO On SPP.SchemeID = SO.SchemeID
Where SA.SchemeType = 4 And SPP.PayoutPeriodTo Between @FromDate And @ToDate And IsNull(SA.RFAApplicable,0) = 0 and isnull(SO.QPS,0)=1
and isnull(SPP.status,0) = 128
/* If there is any QPS scheme for the particular month, then data posting should happen for all the schemes then only report will get generate*/
if @QPSPostcount = @SchemeCount
BEGIN
Set @DayClosed = 1
END
END
ELSE
BEGIN
Set @DayClosed = 1
END
END
End


/* Report should be generated only if the last day of the month is Closed */
If @DayClosed = 0
Goto OvernOut

Create Table #tmpNonClaimPointsSch
(
PayoutID Int,
SchemeID Int,
WDCode nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,
WDDest nVarchar(20) Collate SQL_Latin1_General_CP1_CI_AS,
Fromdate nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,
ToDate nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,
ActivityCode nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
[Description] nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
[Scheme From Date] nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS,
[Scheme To Date] nVarchar(50) Collate SQL_Latin1_General_CP1_CI_AS
)
---------------Abstract part
Insert Into #tmpNonClaimPointsSch
Select	Distinct SPP.ID As 'PayoutID',
SA.SchemeID,
@WDCode,
@WDDest,
Convert(varchar,@FromDate,103),
Convert(varchar,@ToDate,103),
SA.ActivityCode,
SA.[Description],
Convert(varchar,SPP.PayoutPeriodFrom,103) as 'Scheme From Date', Convert(varchar,SPP.PayoutPeriodTo,103) as 'Scheme To Date'

From tbl_mERP_SchemeAbstract SA
--Join tbl_mERP_CSRedemption CSR On CSR.SchemeID = SA.SchemeID And CSR.RFAstatus <> 2
Join tbl_mERP_SchemePayoutPeriod SPP On SPP.SchemeID = SA.SchemeID And SPP.Active = 1 --And SPP.ID = CSR.PayOutId
Where SA.SchemeType = 4 And SPP.PayoutPeriodTo Between @FromDate And @ToDate And IsNull(SA.RFAApplicable,0) = 0


Create Table #Abstract
(
_0 Int,
_00 Int,
_1 nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
_2 nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
_3 nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
_4 nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
_5 nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
_6 nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
_7 nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
_8 nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
)

Insert Into #Abstract
Select PayoutID,
SchemeID,
@WDCode,
@WDDest,
Fromdate,
ToDate,
dbo.mERP_fn_FilterSplChar_ITC(ActivityCode),
dbo.mERP_fn_FilterSplChar_ITC([Description]),
[Scheme From Date],
[Scheme To Date]
From #tmpNonClaimPointsSch


---------------Detail part
Create Table #Detail
(
_0 Int,
_00 Int,
_9 nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
_10 nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
_11 Decimal(18,6),
_12 Decimal(18,6),
_13 Decimal(18,6)
)

Create Table #tmpNonClaimPointsSchDetail
(
PayoutID Int,
SchemeID Int,
OutletCode nVarchar(255),
OutletName nVarchar(255),
TotalPoints Decimal(18,6),
TotalSpent Decimal(18,6),
RedeemedPoints Decimal(18,6)
)

Create Table #tmpOutlet (OutletCode nvarchar(30),Company_Name nvarchar(300),ChannelDesc nvarchar(255),Points decimal(18,6), Redeemed decimal(18,6),
RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000))
Create Table #tmpfinal (OutletCode nvarchar(30),Company_Name nvarchar(300),ChannelDesc nvarchar(255),Points decimal(18,6), Redeemed decimal(18,6),
RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000))

Declare @PrevID nVarchar(255)
Declare @CurrentID nVarchar(255)
Declare @PayoutID Int
Declare @tFromDate datetime
Declare @tToDate datetime
Declare @nSchemeID Int
Set @PrevID = ''


Declare DetailCursor Cursor For
Select _0,_00 From #Abstract
Open DetailCursor
Fetch Next From DetailCursor Into @PayoutID,@nSchemeID
While @@FETCH_STATUS = 0
Begin
Set @CurrentID = CAST(@PayoutID As nVarchar(50)) + CHAR(15) + CAST(@nSchemeID As nVarchar(50))

If (@CurrentID <> @PrevID)
Begin
Insert Into #XMLData (XMLStr)
Select
'Abstract _1="' + Cast(Isnull(_1, '') as nVarchar(20)) + '"' +
' _2="' + Cast(Isnull(_2, '') as nVarchar(20)) + '"' +
' _3="' + Cast(Isnull(_3, '') as nVarchar(50)) + '"' +
' _4="' + Cast(Isnull(_4, '') as nVarchar(50)) + '"' +
' _5="' + Cast(Isnull(_5, 0) as nVarchar(255)) + '"' +
' _6="' + Cast(Isnull(_6, '') as nVarchar(255)) + '"' +
' _7="' + Cast(Isnull(_7, '') as nVarchar(50)) + '"'+
' _8="' + Cast(Isnull(_8, '') as nVarchar(50)) + '"'
From #Abstract Where _0 = @PayoutID And _00 = @nSchemeID
End
/*Report Detail part*/


Declare @RFAClaim int
Declare @PayStatus int
Declare @LastRFAStatus int

Declare @UnitRate decimal(18,6)

Declare @tmpFromdate datetime
Declare @tmpTodate datetime
Select @tmpFromdate = dbo.striptimefromdate(PayoutPeriodFrom) ,@tmpTodate = dbo.striptimefromdate(PayoutPeriodTo) From tbl_mERP_SchemePayoutPeriod SPP Where ID = @PayoutID and schemeid=@nSchemeId

select @RFAClaim = isnull(RFAApplicable,0) from tbl_merp_schemeabstract where schemeid = @nSchemeID
select @PayStatus = isnull(Status,0) from tbl_merp_schemePayOutPeriod where [id]=@PayoutID
/* Since 128 status is introduced for data posting, we are checking the below condition*/
if (@PayStatus = 128 or @PayStatus = 129)
set @PayStatus  = 0

select @LastRFAStatus = RFAStatus from tbl_mERP_CSRedemption where schemeid=@nSchemeId and PayoutId=@Payoutid and RFAStatus <> 2
and Id = (select max(ID) from tbl_mERP_CSRedemption where schemeid=@nSchemeId and PayoutId=@Payoutid and RFAStatus <> 2)
Select @UnitRate= SS.UnitRate from tbl_mERP_SchemeSlabDetail SS  where schemeID=@nSchemeID

--FOR NON QPS
insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)
select  PA.OutletCode,C.Company_Name,cc.ChannelDesc,PA.Points,0 [Redeemed],0 [RedeemedValue],0 [AmountSpent],'' [PlannedPayout]
from Customer C,Customer_Channel CC ,tbl_mERP_CSOutletPointAbstract PA
Where C.ChannelType=CC.ChannelType
AND isnull(PA.QPS,0)=0
--AND Points > 0
AND PA.SchemeID=@nSchemeID
And PA.PayoutID =@PayoutId
And PA.OutletCode=C.CustomerID
And dbo.stripdatefromtime(PA.TransactionDate) between @tmpFromdate and @tmpTodate
UNION ALL
--FOR QPS
select  PA.OutletCode,C.Company_Name,cc.ChannelDesc,PA.Points,0 [Redeemed],0 [RedeemedValue],0 [AmountSpent],'' [PlannedPayout]
from Customer C,Customer_Channel CC ,tbl_mERP_CSOutletPointAbstract PA
Where C.ChannelType=CC.ChannelType
AND isnull(PA.QPS,0)=1
--AND Points > 0
AND PA.SchemeID=@nSchemeID
And PA.PayoutID =@PayoutId
And PA.OutletCode=C.CustomerID


If (@PayStatus <> 1 or @Paystatus <> 192) --RFA not claimed or not dropped
BEGIN
insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)
select  OutletCode,C.Company_Name,cc.ChannelDesc,0,T.RedeemedPoints,T.RedeemValue,T.AmountSpent,T.PlannedPayout
from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC
where C.ChannelType=CC.ChannelType
And T.outletcode = C.CustomerID
And SchemeId=@nSchemeID
And PayoutID=@PayoutId
And RFAStatus = @LastRFAStatus and RFAstatus <> 2
END

insert into #tmpfinal (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent)
select distinct OutletCode,Company_Name,ChannelDesc,sum(points) as Points,sum(Redeemed) as Redeemed,sum(RedeemValue) as RedeemValue,sum(AmountSpent) as AmountSpent  from #tmpOutlet
group by OutletCode,Company_Name,ChannelDesc having sum(points)>0  order by Company_Name

update #tmpfinal set PlannedPayout = T1.PlannedPayout
from
(select T.outletcode, T.PlannedPayout from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC
where C.ChannelType=CC.ChannelType
And T.outletcode = C.CustomerID
And SchemeId=@nSchemeID
And PayoutID=@PayoutId
And RFAStatus = @LastRFAStatus and RFAstatus <>2) T1
where T1.outletcode = #tmpfinal.outletcode

Insert Into #Detail
Select
@PayoutID,
@nSchemeID,
dbo.mERP_fn_FilterSplChar_ITC(OutletCode),
dbo.mERP_fn_FilterSplChar_ITC(Company_Name),
Points,
AmountSpent,
Redeemed
From #tmpfinal

Insert Into #XMLData (XMLStr)
Select
'Detail _9="' + Cast(IsNull(_9, '') as nVarchar(255)) + '"' +
' _10="' + Cast(IsNull(_10, '') as nVarchar(255)) + '"' +
' _11="' + Cast(IsNull(_11, 0) as nVarchar) + '"' +
' _12="' + Cast(IsNull(_12, 0) as nVarchar) + '"' +
' _13="' + Cast(IsNull(_13, 0) as nVarchar) + '"'
From #Detail
Where _0 = @PayoutID And _00 = @nSchemeID
Delete from #tmpfinal
delete from #tmpOutlet
Set @PrevID = @CurrentID
Fetch Next From DetailCursor Into @PayoutID, @nSchemeID
End
Close DetailCursor
Deallocate DetailCursor

Select XMLStr from #XMLData as XMLData order by ID For XML Auto,
Root('Root')

Drop table #tmpNonClaimPointsSch
Drop table #tmpNonClaimPointsSchDetail
Drop Table #Abstract
Drop Table #Detail
Drop table #tmpOutlet
OvernOut:
Drop Table #XMLData
End
