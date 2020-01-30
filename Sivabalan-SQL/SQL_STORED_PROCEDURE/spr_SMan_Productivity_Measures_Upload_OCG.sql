Create Procedure spr_SMan_Productivity_Measures_Upload_OCG
(
@SmanName as nVarchar(4000),
@SmanType as nVarchar(4000),
@CategoryType as nVarchar(4000),
@Hierarchy as nVarchar(20),
@CatGrp as nVarchar(4000),
@Category as nVarchar(4000),
@FromDate as DateTime,
@ToDate as DateTime
)
As
Begin
Set DateFormat DMY
Declare @WKFromDate as DateTime
Declare @WKToDate as DateTime
Declare @Month as Integer
Declare @QrtFromDt Datetime
Declare @QrtToDt Datetime
Declare @Year int
Declare @CatLevel as Nvarchar(10)

/* Report should be upload only if the last day of the month is Closed */
Declare @DayClosed Int
Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@ToDate))
Set @DayClosed = 1
End

If @DayClosed = 0
GoTo OvernOut
/* End */

If Day(@ToDate) <= 21
Begin
Set @WKFromDate = Cast((Cast(Day(dateadd(d, -6, @ToDate)) As nVarchar) + '-' + Cast(Month(@ToDate) As nVarchar) + '-' + Cast(Year(@ToDate) As nVarchar)) As Datetime)
End
Else
Begin
Set @WKFromDate = Cast((Cast(22 As nVarchar) + '-' + Cast(Month(@ToDate) As nVarchar) + '-' + Cast(Year(@ToDate) As nVarchar)) As Datetime)
End

Set @WKToDate = @ToDate

Select @Month = Month(@FromDate)

If @Month  >= 1 and @Month  <= 3
Set @Month  = 10
Else If @Month  >= 4 and @Month  <= 6
Set @Month  = 1
Else If @Month  >= 7 and @Month  <= 9
Set @Month  = 4
Else
Set @Month  = 7

SET @Year = DatePart(yyyy, @FromDate)

If @Month = 10
Select @QrtFromDt = CAST(CAST(1 AS nvarchar) + '/' + CAST(@Month AS nvarchar) + '/' + CAST(@Year - 1 AS nvarchar) AS datetime)
Else
Select @QrtFromDt = CAST(CAST(1 AS nvarchar) + '/' + CAST(@Month AS nvarchar) + '/' + CAST(@Year AS nvarchar) AS datetime)

Select @QrtToDt = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@QrtFromDt)+3,0))

Create Table #tmpFinalOutputdata(
[WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] DateTime, [To Date] DateTime,
[WK From Date] DateTime, [WK To Date] DateTime,
[Salesman ID] Integer,
[Salesman Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Salesman Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Handheld DS] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Supervisor] nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Category Level] nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Total Outlets] Integer,
[TTL No. of Bills] Integer,
[Unique Outlets Billed] Integer,
[Total Bill Value] Decimal(18,6),
[TTL No. of Lines]  Int,
[TTL Unique Lines Cut] Int,
[Acct Receivables %age] Decimal(18,6) Default 0,
[CAlls Productivity] Decimal(18,6),
[Outlet Productivity] Decimal(18,6) Default 0,
[Lines Productivity] Decimal(18,6),
[Average Bill Value] Decimal(18,6),
[Business Growth] Decimal(18,6) Default 0,
[No.Of Market Visit Days with HH] Int,
[Total No.Of Market Visit Days] Int,
[WK_TTL No. of Bills] Integer,
[WK_Unique Outlets Billed] Integer,
[WK_Total Bill Value] Decimal(18,6),
[WK_TTL No. of Lines]  Int,
[WK_TTL Unique Lines Cut] Int,
[WK_Acct Receivables %age] Decimal(18,6) Default 0,
[WK_CAlls Productivity] Decimal(18,6),
[WK_Outlet Productivity] Decimal(18,6) Default 0,
[WK_Lines Productivity] Decimal(18,6),
[WK_Average Bill Value] Decimal(18,6),
[WK_Business Growth] Decimal(18,6) Default 0,
[WK_No.Of Market Visit Days with HH] Int,
[WK_Total No.Of Market Visit Days] Int,
[Category Type Level] Nvarchar(50))

Create Table #tmpOutputdata(
[WDCode] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Dest Code] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] DateTime, [To Date] DateTime,
[WK From Date] DateTime, [WK To Date] DateTime,
[Salesman ID] Integer,
[Salesman Name] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Salesman Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Handheld DS] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Supervisor] nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Category Level] nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Total Outlets] Integer,
[TTL No. of Bills] Integer,
[Unique Outlets Billed] Integer,
[Total Bill Value] Decimal(18,6),
[TTL No. of Lines]  Int,
[TTL Unique Lines Cut] Int,
[Acct Receivables %age] Decimal(18,6),
[CAlls Productivity] Decimal(18,6),
[Outlet Productivity] Decimal(18,6),
[Lines Productivity] Decimal(18,6),
[Average Bill Value] Decimal(18,6),
[Business Growth] Decimal(18,6),
[No.Of Market Visit Days with HH] Int,
[Total No.Of Market Visit Days] Int,
[WK_TTL No. of Bills] Integer,
[WK_Unique Outlets Billed] Integer,
[WK_Total Bill Value] Decimal(18,6),
[WK_TTL No. of Lines]  Int,
[WK_TTL Unique Lines Cut] Int,
[WK_Acct Receivables %age] Decimal(18,6),
[WK_CAlls Productivity] Decimal(18,6),
[WK_Outlet Productivity] Decimal(18,6),
[WK_Lines Productivity] Decimal(18,6),
[WK_Average Bill Value] Decimal(18,6),
[WK_Business Growth] Decimal(18,6),
[WK_No.Of Market Visit Days with HH] Int,
[WK_Total No.Of Market Visit Days] Int,
[Category Type Level] Nvarchar(50))

CREATE TABLE #TmpINV(
InvoiceID Int,
InvoiceDate DateTime,
InvoiceType Int,
SalesManID Int,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Amount Decimal(18,6),
Balance Decimal(18,6),
NetValue Decimal(18,6))

CREATE TABLE #TmpQtrSales(
InvoiceID Int,
SalesManID Int,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Amount Decimal(18,6))

Declare @TmpItem as Table(
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL)

Declare @DSTypeMaster As Table (SalesmanID Int, DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL)

Insert Into @TmpItem
select I.Product_code,IC2.Category_Name,IC3.Category_Name,''
From items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid

Insert Into #TmpINV
--		select IA.Invoiceid,dbo.striptimeFromdate(IA.Invoicedate),Isnull(IA.InvoiceType,0),IA.SalesManID,IA.Customerid,ID.Product_Code,'','','',
select IA.Invoiceid,IA.Invoicedate,Isnull(IA.InvoiceType,0),IA.SalesManID,IA.Customerid,ID.Product_Code,'','','',
Case When IA.InvoiceType in (1,3) Then ID.Amount When IA.InvoiceType in (4) Then (- ID.Amount) End,
IA.Balance,IA.Netvalue
From invoiceabstract IA , invoiceDetail ID
--		Where dbo.striptimeFromdate(Invoicedate) between dbo.striptimeFromdate(@FromDate) and dbo.striptimeFromdate(@ToDate)
Where Invoicedate  between @FromDate and @ToDate
and ( IsNull(IA.Status,0) & 128 = 0)
And IA.Invoiceid = ID.Invoiceid  Order by IA.Invoiceid asc

--		Insert Into #TmpQtrSales
--		Select IA.InvoiceID,IA.SalesmanID,T.Division,T.SubCategory,'',InD.Product_Code,Sum(InD.Amount)
--		From InvoiceAbstract IA,InvoiceDetail InD,Salesman SM,@TmpItem T
--		Where (IsNull(IA.Status,0) & 128 = 0)
--		and dbo.stripDateFromTime(IA.InvoiceDate) Between @QrtFromDt and @QrtToDt
--		and IA.InvoiceType in(1,3)
--		and IA.InvoiceID = InD.InvoiceID
--		and IA.SalesmanID = SM.SalesmanID
--		and InD.Product_Code = T.Product_Code
--		Group By IA.InvoiceID,IA.SalesmanID,InD.Product_Code,T.Division,T.SubCategory,T.GroupName

Insert Into @DSTypeMaster
select Distinct S.SalesmanID,DM.DSTypeValue
From salesman S,DSType_Details DT,DSType_Master DM,tbl_mERP_DSTypeCGMapping DSM
Where S.SalesManID = DT.SalesManID
And DT.DstypeId = DM.DSTypeID
And DM.DSTypeCTlPos = 1
And DSM.Active = 1
And DSM.DSTypeID = DM.DSTypeID

-- If CategoryType = All Then.......

Declare @LoopFlag  as Int
Declare @Continue int
Declare @TmpCategoryType as Nvarchar(50)
Truncate Table #TmpOutPutdata
Set @LoopFlag = 0

ForCategoryTypeAll:
Set @Continue = 1
If @CategoryType = '%' Or @CategoryType = 'All' Or @CategoryType = N''
Begin
If @LoopFlag = 0
Begin
Set @TmpCategoryType = 'Regular'
Set @CatLevel = 'CG'
End
Else If @LoopFlag = 1
Begin
Set @TmpCategoryType = 'Operational'
Set @CatLevel = 'OCG'
End
End
Else
Begin
Set @TmpCategoryType = @CategoryType
End

CREATE TABLE #tmpSM(
FromDate DateTime,
ToDate DateTime,
WKFromDate DateTime,
WKToDate DateTime,
SalesManID int NULL,
SalesMan_Name nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
DSType nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Supervisor nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
HH varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
DivCount Int,
SubCatCount Int,
CatGrpCount Int)

CREATE TABLE #tmpCustMap(
SalesManID Int,
CustomerID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CategoryID Int,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL)

IF OBJECT_ID('tempdb..#tmpSSupName') IS NOT NULL
Drop table #tmpSSupName
CREATE TABLE #tmpSSupName(
SalesManID int NULL,
Supervisor nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS)

--Declare @TmpLines as Table(
IF OBJECT_ID('tempdb..#TmpLines') IS NOT NULL
Drop table #TmpLines
Create Table #TmpLines(
InvoiceID Int,
SalesManID int,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

--Declare @TmpWKLines as Table(
IF OBJECT_ID('tempdb..#TmpWKLines') IS NOT NULL
Drop table #TmpWKLines
Create Table #TmpWKLines(
InvoiceID Int,
SalesManID int,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

CREATE TABLE #TmpWKINV(
InvoiceID Int,
InvoiceDate DateTime,
InvoiceType Int,
SalesManID Int,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
Amount Decimal(18,6),
Balance Decimal(18,6),
NetValue Decimal(18,6))


--Declare @tmpInvAbs as Table (
IF OBJECT_ID('tempdb..#tmpInvAbs') IS NOT NULL
Drop table #tmpInvAbs
Create Table #tmpInvAbs(
InvoiceID Int,
InvoiceDate DateTime,
SalesManID Int,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
NetValue Decimal(18,6),
Balance Decimal(18,6))

--Declare #tmpWKInvAbs as Table (
IF OBJECT_ID('tempdb..#tmpWKInvAbs') IS NOT NULL
Drop table #tmpWKInvAbs
Create Table #tmpWKInvAbs(
InvoiceID Int,
InvoiceDate DateTime,
SalesManID Int,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SubCategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL,
NetValue Decimal(18,6),
Balance Decimal(18,6))

--	Declare @TAge  as Table (InvoiceID Int ,Balance Decimal(18,6),NetValue Decimal(18,6))
--	Declare @TmpCat as Table (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpSubCat as Table (Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpGroup as Table (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpQS as Table (SalesmanID Int,AvgSales Decimal(18,6))
--	Declare @TmpSCat as Table (SalesmanID Int,Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpSSubCat as Table (SalesmanID Int,Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpSGroup as Table (SalesmanID Int,GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TAge') IS NOT NULL
Drop table #TAge
Create Table #TAge   (InvoiceID Int ,Balance Decimal(18,6),NetValue Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpCat') IS NOT NULL
Drop table #TmpCat
Create Table #TmpCat  (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpSubCat') IS NOT NULL
Drop table #TmpSubCat
Create Table #TmpSubCat (Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpGroup') IS NOT NULL
Drop table #TmpGroup
Create Table #TmpGroup  (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpQS') IS NOT NULL
Drop table #TmpQS
Create Table #TmpQS  (SalesmanID Int,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpSCat') IS NOT NULL
Drop table #TmpSCat
Create Table #TmpSCat (SalesmanID Int,Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpSSubCat') IS NOT NULL
Drop table #TmpSSubCat
Create Table #TmpSSubCat(SalesmanID Int,Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpSGroup') IS NOT NULL
Drop table #TmpSGroup
Create Table #TmpSGroup  (SalesmanID Int,GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))


--	Declare @TWKAge  as Table (InvoiceID Int ,Balance Decimal(18,6),NetValue Decimal(18,6))
--	Declare @TmpWKCat as Table (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpWKSubCat as Table (Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpWKGroup as Table (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpWKSCat as Table (SalesmanID Int,Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpWKSSubCat as Table (SalesmanID Int,Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
--	Declare @TmpWKSGroup as Table (SalesmanID Int,GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))

IF OBJECT_ID('tempdb..#TWKAge') IS NOT NULL
Drop table #TWKAge
Create Table #TWKAge (InvoiceID Int ,Balance Decimal(18,6),NetValue Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKCat') IS NOT NULL
Drop table #TmpWKCat
Create Table  #TmpWKCat  (Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKSubCat') IS NOT NULL
Drop table #TmpWKSubCat
Create Table  #TmpWKSubCat (Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKGroup') IS NOT NULL
Drop table #TmpWKGroup
Create Table #TmpWKGroup  (GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKSCat') IS NOT NULL
Drop table #TmpWKSCat
Create Table #TmpWKSCat (SalesmanID Int,Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKSSubCat') IS NOT NULL
Drop table #TmpWKSSubCat
Create Table  #TmpWKSSubCat (SalesmanID Int,Subcategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))
IF OBJECT_ID('tempdb..#TmpWKSGroup') IS NOT NULL
Drop table #TmpWKSGroup
Create Table  #TmpWKSGroup  (SalesmanID Int,GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,AvgSales Decimal(18,6))

IF OBJECT_ID('tempdb..#TCatAge') IS NOT NULL
Drop table #TCatAge
--Declare #TCatAge  as Table (
Create Table #TCatAge(
InvoiceID Int,
SalesmanID int,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Subcategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Balance Decimal(18,6),
NetValue Decimal(18,6))

Declare @TWKCatAge  as Table (
InvoiceID Int,
SalesmanID int,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
GroupName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Subcategory nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Balance Decimal(18,6),
NetValue Decimal(18,6))

Declare @TmptblCGDivMapping as table (Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Declare @Beat_Salesman as Table (SalesManID Int,CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL)

Declare @OCGFlag as Int
Declare @CompaniesToUploadCode as nVarchar(255)
Declare @WDCode as nVarchar(255)
Declare @WDDestCode as nVarchar(255)
Declare @Delimeter as nVarchar

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Set @WDDestCode= @WDCode
Else
Begin
Set @WDDestCode= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Set @OCGFlag = (select Top 1 Isnull(Flag,0) From tbl_merp_Configabstract where screenCode = 'OCGDS')

If @TmpCategoryType = 'Regular'
Begin
Insert Into @TmptblCGDivMapping
select Distinct Division,CategoryGroup From tblCGDivMapping

Update T Set T.GroupName = G.CategoryGroup From @TmpItem T,tblCGDivMapping G
Where T.Division = G.Division
End
Else If @TmpCategoryType = 'Operational'
Begin
Declare @OCGGroup AS table (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Insert Into @OCGGroup
Select Distinct F.Product_Code,P.GroupName From Fn_GetOCGSKU('%') F,ProductCategoryGroupAbstract P
Where F.GroupID = P.GroupID

Update T Set T.GroupName = G.GroupName From @TmpItem T,@OCGGroup G
Where T.Product_Code = G.Product_Code

Insert Into @TmptblCGDivMapping
select Distinct Division,GroupName From @TmpItem
End

/* Month Data Prepare Start */

Update #TmpQtrSales set GroupName = Null
Update #TmpINV Set Division = Null,SubCategory = Null,GroupName = Null

Update T Set T.GroupName = I.GroupName From @TmpItem I,#TmpQtrSales T
Where T.Product_Code = I.Product_Code

Update T Set T.Division = T1.Division,T.SubCategory = T1.SubCategory,T.GroupName = T1.GroupName From #TmpINV T,@TmpItem T1
Where T.Product_code = T1.Product_code

Insert Into #tmpInvAbs
Select InvoiceID,InvoiceDate,SalesManID,CustomerID,Division,SubCategory,GroupName,Sum(Amount),Max(Balance) From #TmpINV
Where InvoiceType in (1,3)
Group By InvoiceID,InvoiceDate,SalesManID,CustomerID,Division,SubCategory,GroupName

Insert Into @Beat_Salesman
Select Distinct SalesManID,CustomerID From Beat_SalesMan Where Isnull(SalesManID,0) <> 0

Insert into #tmpCustMap
Select Distinct BS.SalesManID,CM.CustomerID,CM.CategoryID,'','','' From
CustomerProductCategory CM,Customer C,@Beat_Salesman BS
Where
CM.Active = 1 And
C.CustomerID = CM.CustomerID
And C.Active = 1
And C.CustomerCategory <> 5
And C.CustomerID = BS.CustomerID
Order By CM.CustomerID

Update T Set T.Division = IC.Category_Name From #tmpCustMap T,(Select Distinct categoryID,Category_Name From ItemCategories Where isnull(Level,0) = 2) IC
Where T.CategoryID = IC.CategoryID

Update T Set T.SubCategory = IC.Category_Name From #tmpCustMap T,(Select Distinct categoryID,Category_Name From ItemCategories Where isnull(Level,0) = 3) IC
Where T.CategoryID = IC.CategoryID

Update T Set T.GroupName = CG.CategoryGroup From #tmpCustMap T,(Select Distinct Division,CategoryGroup From @TmptblCGDivMapping) CG
Where T.Division = CG.Division

Update T Set T.GroupName = T1.CategoryGroup,T.Division = T1.Division From #tmpCustMap T,
(Select Distinct IC2.Category_Name Division,IC3.Category_Name SubCategory,CG.CategoryGroup From
(Select Distinct CategoryID,Category_Name From ItemCategories Where level = 2) IC2,
(Select Distinct ParentID,Category_Name From ItemCategories Where level = 3) IC3,@TmptblCGDivMapping CG
Where IC3.ParentID = IC2.CategoryID
And IC2.Category_Name = CG.Division) T1
Where T.SubCategory = T1.SubCategory

Insert #TmpLines (InvoiceID,SalesManID,GroupName,Division,SubCategory,Product_Code)
Select Distinct InvoiceID,SalesmanID,GroupName,Division,SubCategory,Product_Code From #TmpINV Where InvoiceType In (1,3)

/* Month Data Prepare End */
--*********************************************************************************************************************************
/* Week Data Prepare Start */

Insert Into #TmpWKINV
Select * From #TmpINV Where InvoiceDate Between @WKFromDate and @WKToDate

Insert Into #tmpWKInvAbs
Select InvoiceID,InvoiceDate,SalesManID,CustomerID,Division,SubCategory,GroupName,Sum(Amount),Max(Balance) From #TmpWKINV
Where InvoiceType in (1,3)
Group By InvoiceID,InvoiceDate,SalesManID,CustomerID,Division,SubCategory,GroupName

Insert #TmpWKLines (InvoiceID,SalesManID,GroupName,Division,SubCategory,Product_Code)
Select Distinct InvoiceID,SalesmanID,GroupName,Division,SubCategory,Product_Code From #TmpWKINV Where InvoiceType In (1,3)

Truncate table #tmpSSupName
Declare @SID Int
Declare @SuName Varchar(2000)
Declare  Cur_SupervisorName Cursor For
Select Distinct SalesManID From #TmpINV
Open Cur_SupervisorName
Fetch Next From Cur_SupervisorName Into @SID
While @@Fetch_Status = 0
Begin
Set @SuName = NULL
If exists (select * from dbo.sysobjects
where name Like 'tbl_mERP_SupervisorSalesman' and xtype in (N'U'))
Begin
Select @SuName = Isnull(@SuName,'') +  SalesmanName   + ' | '    From Salesman2
Where SalesmanID In (Select SupervisorID From tbl_mERP_SupervisorSalesman
Where SalesmanID in (@SID))
if @SuName is null
Begin
if  @SID = 0
Set @SuName = ''
else
Set @SuName = 'No Supervisor'
End
else
Begin
Set @SuName = left(@SuName,len(@SuName)-1)
End
End
Else
Begin
if  @SID = 0
Set @SuName = ''
else
Set @SuName = 'N/A'

End
IF @SuName = ''
Set @SuName = 'All Supervisor'
IF @SuName = 'N/A'
Set @SuName = ''
Insert into #tmpSSupName values(@SID,rtrim(ltrim(@SuName)))
Fetch Next From Cur_SupervisorName Into @SID
End
Close Cur_SupervisorName
Deallocate Cur_SupervisorName



/* Week Data Prepare End */
--*********************************************************************************************************************************
--	Insert Into #tmpSM
--	select Distinct @FromDate,@ToDate,@WKFromDate,@WKToDate,Cast(S.SalesManID as Int) SalesManID,S.SalesMan_Name,'' DSType,
--	(Case
--		When dbo.mERP_fn_GetSupervisorName_ITC(IsNull(S.SalesManID, 0)) = '' Then 'All Supervisor'
--		When dbo.mERP_fn_GetSupervisorName_ITC(IsNull(S.SalesManID, 0)) = 'N/A' Then ''
--		Else dbo.mERP_fn_GetSupervisorName_ITC(IsNull(S.SalesManID, 0))
--	End),
--	IA.GroupName,IA.Division,IA.SubCategory,'' HH,0,0,0
--	From salesman S,
--	(Select Distinct SalesManID,CustomerID,Product_Code,GroupName,Division,Subcategory From #TmpINV) IA
--	Where S.SalesManID = IA.SalesManID

Insert Into #tmpSM
select Distinct @FromDate,@ToDate,@WKFromDate,@WKToDate,Cast(S.SalesManID as Int) SalesManID,S.SalesMan_Name,'' DSType,
SupName.Supervisor,
IA.GroupName,IA.Division,IA.SubCategory,'' HH,0,0,0
From salesman S,#tmpSSupName SupName,
(Select Distinct SalesManID,CustomerID,Product_Code,GroupName,Division,Subcategory From #TmpINV) IA
Where S.SalesManID = IA.SalesManID and SupName.SalesManID  = IA.SalesManID

Update A Set A.DSType = T.DSType From #tmpSM A, @DSTypeMaster T
Where T.SalesmanID = A.SalesmanID

Update T Set T.DivCount = T1.Cnt From #tmpSM T,
(Select SalesManID,Division,Count(Distinct Customerid) Cnt From #tmpCustMap Group  By SalesManID,Division) T1
Where T.Division = T1.Division
And T.SalesManID = T1.SalesManID

Update T Set T.SubCatCount = T1.Cnt From #tmpSM T,
(Select SalesManID,SubCategory,Count(Distinct Customerid) Cnt From #tmpCustMap Group  By SalesManID,SubCategory) T1
Where T.SubCategory = T1.SubCategory
And T.SalesManID = T1.SalesManID

Update T Set T.CatGrpCount = T1.Cnt From #tmpSM T,
(Select SalesManID,GroupName,Count(Distinct Customerid) Cnt From #tmpCustMap Group  By SalesManID,GroupName) T1
Where T.GroupName = T1.GroupName
And T.SalesManID = T1.SalesManID

Update T set T.HH = Cast((Isnull(T1.DSTypeValue,'No')) as Nvarchar) From #tmpSM T,
(select Cast(DT.SalesManID as Int) SalesManID, cast(Dm.DSTypeValue as Nvarchar) DSTypeValue
From DStype_Details DT,DSType_Master DM
Where DM.DSTypeCTlPos = 2
And DT.DSTypeCTlPos = 2
And DM.DSTypeId = DT.DSTypeId) T1
Where T.SalesManID = T1.SalesManID

/* Start Update */

If Isnull(@OCGFlag,0) = 1
Begin
IF @TmpCategoryType = 'Operational'
Begin
Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct Top 1 0,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor','All',0,'All' From #tmpSM
End
End
Else
Begin
Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct Top 1 0,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor','All',0,'All' From #tmpSM
End

Update #tmpOutputdata set [Total Outlets] =
(Select Count(Distinct C.CustomerID) From Customer C
Where C.Active = 1 And C.CustomerCategory <> 5)

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 1,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor',I.GroupName,0,@CatLevel From #tmpSM T,#TmpINV I Order By I.GroupName

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 0,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,'All',0,'All' From #tmpSM

Update T set T.[Total Outlets] = T1.Cnt From #tmpOutputdata T,
(Select BS.SalesManID,Count(Distinct CM.CustomerID) Cnt From
CustomerProductCategory CM,Customer C,@Beat_Salesman BS
Where C.CustomerID = CM.CustomerID
And BS.CustomerID = C.CustomerID
And C.Active = 1
And C.CustomerCategory <> 5
And Isnull(BS.SalesManID,0) <> 0
Group By BS.SalesManID) T1
Where T.[Salesman ID]= T1.SalesManID

If Isnull(@OCGFlag,0) = 1
Begin
IF @TmpCategoryType = 'Operational'
Begin
Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 2,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor',I.Division,0,'Division' From #tmpSM T,#TmpINV I Order By I.Division

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 3,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor',I.SubCategory,0,'SubCategory' From #tmpSM T,#TmpINV I Order By I.SubCategory

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 2,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,Division,DivCount,'Division' From #tmpSM Order By Division

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 3,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,SubCategory,SubCatCount,'SubCategory' From #tmpSM Order By SubCategory
End
End
Else
Begin
Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 2,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor',I.Division,0,'Division' From #tmpSM T,#TmpINV I Order By I.Division

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 3,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,Null,'All Salesman','All DS Types','NA','All Supervisor',I.SubCategory,0,'SubCategory' From #tmpSM T,#TmpINV I Order By I.SubCategory

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 2,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,Division,DivCount,'Division' From #tmpSM Order By Division

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 3,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,SubCategory,SubCatCount,'SubCategory' From #tmpSM Order By SubCategory
End

Insert Into #tmpOutputdata([WDCode],[WD Code],[WD Dest Code],[From Date],[To Date],[WK From Date],[WK To Date],[Salesman ID],[Salesman Name],[Salesman Type],[Handheld DS],[Supervisor],[Category Level],[Total Outlets],[Category Type Level])
Select Distinct 1,@WDCode,@WDDestCode,Fromdate,Todate,WKFromdate,WKTodate,SalesManID,SalesMan_name,Dstype,HH,Supervisor,GroupName,CatGrpCount,@CatLevel From #tmpSM Order By GroupName


--	Delete From #tmpOutputdata Where [Category Level] Not in (Select Distinct Division From #TmpINV Where InvoiceType in (1,3)) And WDCode = 2
--	Delete From #tmpOutputdata Where [Category Level] Not in (Select Distinct Subcategory From #TmpINV Where InvoiceType in (1,3)) And WDCode = 3

Update #tmpOutputdata Set [Total Outlets] =
(isNull((dbo.fn_GetOutletCount_OCG('','',#tmpOutputdata.[Category Level] ,@TmpCategoryType)),0))
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 1
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [Total Outlets] =
(Select Count(Distinct CP.Customerid) From CustomerProductCategory CP ,Customer C, ItemCategories IC
Where (CP.CategoryID = (Select CategoryID From ItemCategories Where Category_Name = #tmpOutputdata.[Category Level])
OR IC.ParentID = (Select CategoryID From ItemCategories Where Category_Name = #tmpOutputdata.[Category Level]))
And C.CustomerID = CP.CustomerID And C.Active = 1 And CP.CategoryID = IC.CategoryID And C.CustomerCategory <> 5)
From #tmpOutputdata
Where Isnull(#tmpOutputdata.[Salesman ID],0) = 0
And #tmpOutputdata.WDCode = 2

Update #tmpOutputdata Set [Total Outlets] =
(Select Count(Distinct CP.Customerid) From CustomerProductCategory CP ,Customer C, ItemCategories IC
Where (CP.CategoryID = (Select CategoryID From ItemCategories Where Category_Name = #tmpOutputdata.[Category Level])
OR IC.ParentID = (Select CategoryID From ItemCategories Where Category_Name = #tmpOutputdata.[Category Level]))
And C.CustomerID = CP.CustomerID And C.Active = 1 And CP.CategoryID = IC.CategoryID And C.CustomerCategory <> 5)
From #tmpOutputdata
Where Isnull(#tmpOutputdata.[Salesman ID],0) = 0
And #tmpOutputdata.WDCode = 3

--*********************************************************************************************************************
Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3)) T1
Where T.[Category Level] = 'All'
And Isnull(T.[Salesman ID],0) = 0
And T.WDCode = 0

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct InvoiceID) cnt From #TmpINV  Where InvoiceType In (1,3) Group By SalesManID) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,GroupName) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By GroupName) T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,Division) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By Division) T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,SubCategory)T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct InvoiceID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

--*******************************************************************************************************************************
/* Unique Billed Outlet Start */
Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3))T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct CustomerID) cnt From #TmpINV Where InvoiceType In (1,3) Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* Unique Billed Outlet End */
--*******************************************************************************************************************************
/* Total Bill value Start */
Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select Sum(NetValue) cnt From #tmpInvAbs)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Sum(NetValue) cnt From #tmpInvAbs Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select Division,Sum(NetValue) cnt From #tmpInvAbs Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Sum(NetValue) cnt From #tmpInvAbs Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

--
Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Sum(NetValue) cnt From #tmpInvAbs Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Sum(NetValue) cnt From #tmpInvAbs Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Sum(NetValue) cnt From #tmpInvAbs Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Sum(NetValue) cnt From #tmpInvAbs Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* Total Bill value End */
--*******************************************************************************************************************************
/* TTL No.OF Lines Start */
Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select Count(Product_Code) cnt From #TmpLines)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Product_Code) cnt From #TmpLines Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Product_Code) cnt From #TmpLines Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Product_Code) cnt From #TmpLines Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

--
Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Count(Product_Code) cnt From #TmpLines Group By SalesmanID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,GroupName,Count(Product_Code) cnt From #TmpLines Group By SalesmanID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Division,Count(Product_Code) cnt From #TmpLines Group By SalesmanID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,SubCategory,Count(Product_Code) cnt From #TmpLines Group By SalesmanID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

--
/* TTL No.OF Lines End */
--*******************************************************************************************************************************
/* TTL Unique Lines Start */

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct Product_Code) cnt From #TmpLines)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct Product_Code) cnt From #TmpLines Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct Product_Code) cnt From #TmpLines Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct Product_Code) cnt From #TmpLines Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct Product_Code) cnt From #TmpLines Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct Product_Code) cnt From #TmpLines Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct Product_Code) cnt From #TmpLines Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct Product_Code) cnt From #TmpLines Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* TTL Unique Lines End */
--*******************************************************************************************************************************
/*
/* Business Growth% Start */

Update #tmpOutputdata Set [Business Growth] =
(Case IsNull((Select Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6)) cnt From #TmpQtrSales),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100  End)
Else
(([Total Bill Value]/(Select Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6)) cnt From #TmpQtrSales) )*100 - 100)
End)
Where Isnull([Salesman ID],0) = 0
And [Category Level] = 'All'
And WDCode = 0

Insert Into #TmpQS
Select SalesmanID,Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6)) cnt From #TmpQtrSales Group By SalesmanID

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpQS T2 Where T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) ),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpQS T2
Where T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) )) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] = 'All'
And #tmpOutputdata.WDCode = 0
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Insert Into #TmpGroup
Select  GroupName , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By GroupName

Insert Into #TmpCat
Select  Division , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By Division

Insert Into #TmpSubCat
Select  SubCategory , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By SubCategory

Insert Into #TmpSGroup
Select  SalesmanID,GroupName , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By SalesmanID,GroupName

Insert Into #TmpSCat
Select  SalesmanID,Division , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By SalesmanID,Division

Insert Into #TmpSSubCat
Select  SalesmanID,SubCategory , Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6))
From #TmpQtrSales
Group By SalesmanID,SubCategory

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpGroup T2 Where T2.GroupName = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpGroup T2
Where T2.GroupName = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 1
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpSGroup T2 Where T2.GroupName = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) ),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpSGroup T2
Where T2.GroupName = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) )) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 1
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpCat T2 Where T2.Category = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpCat T2
Where T2.Category = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 2
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpSCat T2 Where T2.Category = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0)),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpSCat T2
Where T2.Category = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0))) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 2
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpSubCat T2 Where T2.SubCategory = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpSubCat T2
Where T2.SubCategory = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 3
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [Business Growth] =
(Case isNull((Select AvgSales From #TmpSSubCat T2 Where T2.SubCategory = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0)),0)
When 0 Then (Case isNull([Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([Total Bill Value]/(Select AvgSales From #TmpSSubCat T2
Where T2.SubCategory = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0))) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 3
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

/* Business Growth% End */
*/
--*********************************************************************************************************************************
If Exists(Select * From SysObjects Where Name = 'DS_TimeSpent' And Xtype = 'u')
Begin
Select * into #DS_TimeSpent From DS_TimeSpent Where Visit_Status in('V','E')
--			And dbo.StripDateFromTime(CAll_Date) Between @FromDate And @ToDate
And CAll_Date Between @FromDate And @ToDate

Update #tmpOutputdata Set [No.Of Market Visit Days with HH] =
(Select Count(Distinct dbo.StripDateFromTime(CAll_Date)) From #DS_TimeSpent  Where SLSMAN_CD = #tmpOutputdata.[Salesman ID])
Where isNull([Salesman ID],0) <> 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [No.Of Market Visit Days with HH] =
(Select Count(Distinct dbo.StripDateFromTime(CAll_Date)) From #DS_TimeSpent)
Where isNull([Salesman ID],0) = 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [WK_No.Of Market Visit Days with HH] =
(Select Count(Distinct dbo.StripDateFromTime(CAll_Date)) From #DS_TimeSpent  Where SLSMAN_CD = #tmpOutputdata.[Salesman ID]
And CAll_Date Between @WKFromDate And @WKToDate)
Where isNull([Salesman ID],0) <> 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [WK_No.Of Market Visit Days with HH] =
(Select Count(Distinct dbo.StripDateFromTime(CAll_Date)) From #DS_TimeSpent
Where CAll_Date Between @WKFromDate And @WKToDate)
Where isNull([Salesman ID],0) = 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [Total No.Of Market Visit Days] =
(Select Count(Distinct(dbo.StripDateFromTime(InvoiceDate))) From #TmpINV
Where SalesmanID = #tmpOutputdata.[Salesman ID])
Where isNull([Salesman ID],0) <> 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [Total No.Of Market Visit Days] =
(Select Count(Distinct(dbo.StripDateFromTime(InvoiceDate))) From #TmpINV)
Where isNull([Salesman ID],0) = 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [WK_Total No.Of Market Visit Days] =
(Select Count(Distinct(dbo.StripDateFromTime(InvoiceDate))) From #TmpWKINV
Where SalesmanID = #tmpOutputdata.[Salesman ID])
Where isNull([Salesman ID],0) <> 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [WK_Total No.Of Market Visit Days] =
(Select Count(Distinct(dbo.StripDateFromTime(InvoiceDate))) From #TmpWKINV)
Where isNull([Salesman ID],0) = 0 And [Category Level] = 'All'

Update #tmpOutputdata Set [No.Of Market Visit Days with HH] = 0	,[Total No.Of Market Visit Days] = 0,
[WK_No.Of Market Visit Days with HH] = 0,[WK_Total No.Of Market Visit Days] = 0
Where ((isNull([Salesman ID],0) = 0 And [Category Level] <> 'All')
Or (isNull([Salesman ID],0) <>0 And [Category Level] <> 'All'))

Drop Table #DS_TimeSpent
End
Else
Begin
Update #tmpOutputdata Set [No.Of Market Visit Days with HH] = 0,[Total No.Of Market Visit Days] = 0,[WK_No.Of Market Visit Days with HH] = 0, [WK_Total No.Of Market Visit Days] = 0
End
--*********************************************************************************************************************************
/* [WK_TTL No. of Bills] Start */

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3)) T1
Where T.[Category Level] = 'All'
And Isnull(T.[Salesman ID],0) = 0
And T.WDCode = 0

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,GroupName) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By GroupName) T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,Division) T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By Division) T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,SubCategory)T1
Where T.[Salesman ID] = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[WK_TTL No. of Bills] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct InvoiceID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* [WK_TTL No. of Bills] End */
--*********************************************************************************************************************************
/* [WK_Unique Outlets Billed] Start */

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3))T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[WK_Unique Outlets Billed] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct CustomerID) cnt From #TmpWKINV Where InvoiceType in (1,3) Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* [WK_Unique Outlets Billed] End */
--*********************************************************************************************************************************
/* [WK_Total Bill Value] Start */

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select Sum(NetValue) cnt From #tmpWKInvAbs)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Sum(NetValue) cnt From #tmpWKInvAbs Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select Division,Sum(NetValue) cnt From #tmpWKInvAbs Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Sum(NetValue) cnt From #tmpWKInvAbs Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

--
Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Sum(NetValue) cnt From #tmpWKInvAbs Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Sum(NetValue) cnt From #tmpWKInvAbs Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Sum(NetValue) cnt From #tmpWKInvAbs Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Total Bill Value] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Sum(NetValue) cnt From #tmpWKInvAbs Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* [WK_Total Bill Value] End */
--*********************************************************************************************************************************
/* [WK_TTL No. of Lines] Start */

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select Count(Product_Code) cnt From #TmpWKLines)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Product_Code) cnt From #TmpWKLines Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Product_Code) cnt From #TmpWKLines Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Product_Code) cnt From #TmpWKLines Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Count(Product_Code) cnt From #TmpWKLines Group By SalesmanID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,GroupName,Count(Product_Code) cnt From #TmpWKLines Group By SalesmanID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Division,Count(Product_Code) cnt From #TmpWKLines Group By SalesmanID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL No. of Lines] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,SubCategory,Count(Product_Code) cnt From #TmpWKLines Group By SalesmanID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* [WK_TTL No. of Lines] End */
--*******************************************************************************************************************************
/* [WK_TTL Unique Lines Cut] Start */

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select Count(Distinct Product_Code) cnt From #TmpWKLines)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,Count(Distinct Product_Code) cnt From #TmpWKLines Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select Division,Count(Distinct Product_Code) cnt From #TmpWKLines Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SubCategory,Count(Distinct Product_Code) cnt From #TmpWKLines Group By SubCategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Count(Distinct Product_Code) cnt From #TmpWKLines Group By SalesManID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,GroupName,Count(Distinct Product_Code) cnt From #TmpWKLines Group By SalesManID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,Division,Count(Distinct Product_Code) cnt From #TmpWKLines Group By SalesManID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_TTL Unique Lines Cut] = T1.Cnt From #tmpOutputdata T,
(Select SalesManID,SubCategory,Count(Distinct Product_Code) cnt From #TmpWKLines Group By SalesManID,SubCategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesManID
And T.[Category Level] = T1.SubCategory
And T.WDCode = 3

/* [WK_TTL Unique Lines Cut] End */
--*********************************************************************************************************************************
/*
/* [WK_Business Growth] Start */

Update #tmpOutputdata Set [WK_Business Growth] =
(Case IsNull((Select Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6)) cnt From #TmpQtrSales),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100  End)
Else
(([WK_Total Bill Value]/(Select Cast(isnull(Sum(Amount)/3,0) as Decimal(18,6)) cnt From #TmpQtrSales) )*100 - 100)
End)
Where Isnull([Salesman ID],0) = 0
And [Category Level] = 'All'
And WDCode = 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpQS T2 Where T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) ),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpQS T2
Where T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) )) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] = 'All'
And #tmpOutputdata.WDCode = 0
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpGroup T2 Where T2.GroupName = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpGroup T2
Where T2.GroupName = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 1
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpSGroup T2 Where T2.GroupName = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) ),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpSGroup T2
Where T2.GroupName = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0) )) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 1
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpCat T2 Where T2.Category = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpCat T2
Where T2.Category = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 2
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpSCat T2 Where T2.Category = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0)),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpSCat T2
Where T2.Category = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0))) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 2
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpSubCat T2 Where T2.SubCategory = #tmpOutputdata.[Category Level]),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpSubCat T2
Where T2.SubCategory = #tmpOutputdata.[Category Level])) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 3
And Isnull(#tmpOutputdata.[Salesman ID],0) = 0

Update #tmpOutputdata Set [WK_Business Growth] =
(Case isNull((Select AvgSales From #TmpSSubCat T2 Where T2.SubCategory = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0)),0)
When 0 Then (Case isNull([WK_Total Bill Value],0) When 0 Then 0 Else 100 End)
Else ([WK_Total Bill Value]/(Select AvgSales From #TmpSSubCat T2
Where T2.SubCategory = #tmpOutputdata.[Category Level] And T2.SalesmanId = Isnull(#tmpOutputdata.[Salesman ID],0))) * 100 - 100 End)
Where #tmpOutputdata.[Category Level] <> 'All'
And #tmpOutputdata.WDCode = 3
And Isnull(#tmpOutputdata.[Salesman ID],0) <> 0

/* [WK_Business Growth] End */
--*********************************************************************************************************************************
/* Acct Receivable % Age Start */
Insert Into #TAge
Select Distinct InvoiceID,Balance,Sum(Amount) From #TmpINV Where InvoiceType in (1,3) group By InvoiceID,Balance

Insert Into #TCatAge
Select Distinct InvoiceID,SalesmanID,Product_Code,GroupName,Division,Subcategory,
(Case isNull(NetValue,0)
When 0 Then 0
Else ((Cast(isNull(Balance,0) as Decimal(18,6)) /Cast(isNull(Netvalue,0) as Decimal(18,6)))* Sum(Amount))
End)
,Sum(Amount)
From #TmpINV Where InvoiceType in (1,3) group By InvoiceID,SalesmanID,Product_Code,GroupName,Division,Subcategory,NetValue,Balance

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TAge)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By SalesmanID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,GroupName,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By SalesmanID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select Division,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Division,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By SalesmanID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select Subcategory,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By Subcategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Subcategory
And T.WDCode = 3

Update T Set T.[Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Subcategory,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TCatAge Group By SalesmanID,Subcategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Subcategory
And T.WDCode = 3

/* Acct Receivable % Age End */

--*********************************************************************************************************************************
/* [WK_Acct Receivables %age] Start */

Insert Into #TWKAge
Select Distinct InvoiceID,Balance,Sum(Amount) From #TmpWKINV Where InvoiceType in (1,3) group By InvoiceID,Balance

Insert Into @TWKCatAge
Select Distinct InvoiceID,SalesmanID,Product_Code,GroupName,Division,Subcategory,
(Case isNull(NetValue,0)
When 0 Then 0
Else ((Cast(isNull(Balance,0) as Decimal(18,6)) /Cast(isNull(Netvalue,0) as Decimal(18,6)))* Sum(Amount))
End)
,Sum(Amount)
From #TmpWKINV Where InvoiceType in (1,3) group By InvoiceID,SalesmanID,Product_Code,GroupName,Division,Subcategory,NetValue,Balance

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From #TWKAge)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By SalesmanID)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = 'All'
And T.WDCode = 0

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select GroupName,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By GroupName)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,GroupName,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By SalesmanID,GroupName)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.GroupName
And T.WDCode = 1

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select Division,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By Division)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Division,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By SalesmanID,Division)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Division
And T.WDCode = 2

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select Subcategory,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By Subcategory)T1
Where Isnull(T.[Salesman ID],0) = 0
And T.[Category Level] = T1.Subcategory
And T.WDCode = 3

Update T Set T.[WK_Acct Receivables %age] = T1.Cnt From #tmpOutputdata T,
(Select SalesmanID,Subcategory,cast((cast((Sum(Balance) / (Case When Isnull(Sum(NetValue),0) = 0 Then 1 Else Isnull(Sum(NetValue),0) End)) as Decimal(18,6)) * 100) As Decimal(18,6)) cnt From @TWKCatAge Group By SalesmanID,Subcategory)T1
Where Isnull(T.[Salesman ID],0) = T1.SalesmanID
And T.[Category Level] = T1.Subcategory
And T.WDCode = 3

/* [WK_Acct Receivables %age] End */
*/
--*********************************************************************************************************************************

Update #tmpOutputdata Set [CAlls Productivity] = (Case Isnull([Total Outlets],0) When 0 Then 0 Else (Cast([TTL No. of Bills] as Decimal(18,6))/(Cast([Total Outlets] * 4 as Decimal(18,6) ))) * 100 End)
--	Update #tmpOutputdata Set [Outlet Productivity] =(Case IsNull([Total Outlets],0) When 0 Then 0 Else (Cast([Unique Outlets Billed] as Decimal(18,6))/Cast([Total Outlets] as Decimal(18,6))) * 100 End)
Update #tmpOutputdata Set [Lines Productivity] = (Case Isnull([TTL No. of Bills],0) When 0 Then 0 Else Cast([TTL No. of Lines] as Decimal(18,6))/Cast([TTL No. of Bills] as Decimal(18,6)) End)
Update #tmpOutputdata Set [Average Bill Value] = (Case Isnull([TTL No. of Bills],0) When 0 Then 0 Else Cast([Total Bill Value] as Decimal(18,6))/Cast([TTL No. of Bills] as Decimal(18,6)) End)

Update #tmpOutputdata Set [WK_CAlls Productivity] = (Case Isnull([Total Outlets],0) When 0 Then 0 Else (Cast([WK_TTL No. of Bills] as Decimal(18,6))/(Cast([Total Outlets] * 4 as Decimal(18,6) ))) * 100 End)
--	Update #tmpOutputdata Set [WK_Outlet Productivity] =(Case IsNull([Total Outlets],0) When 0 Then 0 Else (Cast([WK_Unique Outlets Billed] as Decimal(18,6))/Cast([Total Outlets] as Decimal(18,6))) * 100 End)
Update #tmpOutputdata Set [WK_Lines Productivity] = (Case Isnull([WK_TTL No. of Bills],0) When 0 Then 0 Else Cast([WK_TTL No. of Lines] as Decimal(18,6))/Cast([WK_TTL No. of Bills] as Decimal(18,6)) End)
Update #tmpOutputdata Set [WK_Average Bill Value] = (Case Isnull([WK_TTL No. of Bills],0) When 0 Then 0 Else Cast([WK_Total Bill Value] as Decimal(18,6))/Cast([WK_TTL No. of Bills] as Decimal(18,6)) End)

Update #tmpOutputdata Set [Acct Receivables %age] = 0
Update #tmpOutputdata Set [Outlet Productivity] = 0
Update #tmpOutputdata Set [Business Growth] = 0
Update #tmpOutputdata Set [WK_Acct Receivables %age] = 0
Update #tmpOutputdata Set [WK_Outlet Productivity] = 0
Update #tmpOutputdata Set [WK_Business Growth] = 0

/* End Update */
ChK:
Insert Into #tmpFinalOutputdata
Select * From #tmpOutputdata

TrunCate table #tmpOutputdata

If (@CategoryType = '%' Or @CategoryType = 'All' Or @CategoryType = N'') And @LoopFlag = 0 And (select Isnull(Flag,0) From tbl_merp_Configabstract where screenCode = 'OCGDS') = 1
Begin
Set @LoopFlag = 1
Drop Table #TmpWKINV
Drop Table #tmpSM
Drop Table #tmpCustMap

Delete From #TmpWKLines
Delete From #TmpLines
Delete From #tmpInvAbs
Delete From #tmpWKInvAbs
Delete From #TAge
Delete From #TmpCat
Delete From #TmpSubCat
Delete From #TmpGroup
Delete From #TmpQS
Delete From #TmpSCat
Delete From #TmpSSubCat
Delete From #TmpSGroup
Delete From #TWKAge
Delete From #TmpWKCat
Delete From #TmpWKSubCat
Delete From #TmpWKGroup
Delete From #TmpWKSCat
Delete From #TmpWKSSubCat
Delete From #TmpWKSGroup
Delete From @TmptblCGDivMapping
Delete From #TCatAge
Delete From @TWKCatAge
Delete From @Beat_Salesman
Delete From @OCGGroup

Goto ForCategoryTypeAll
End
Else
Begin
Goto OUT
End

OUT:
Delete From #tmpFinalOutputdata Where ([TTL No. of Bills] is Null and [Unique Outlets Billed] Is Null)

Select Distinct * From #tmpFinalOutputdata Order By [Salesman ID],[WDCode],[Category Type Level] Asc

Drop Table #TmpINV
Drop Table #TmpWKINV
Drop Table #TmpQtrSales
Drop Table #tmpSM
Drop Table #tmpCustMap
Drop Table #tmpOutputdata
Drop Table #tmpFinalOutputdata
End
OvernOut:
