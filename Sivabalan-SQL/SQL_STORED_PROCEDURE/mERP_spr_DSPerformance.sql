Create Procedure mERP_spr_DSPerformance(
@CatGroup nVarchar(1000),
@DStype nVarchar(4000),
@SalesName nVarchar(4000),
@ReportType nVarchar(50),
@DateOrMonth as nVarchar(25),
@UptoWeek nVarchar(50)
--,@CategoryType nVarchar(150)
)
As
Begin

Set Dateformat DMY

Declare @Period as nVarchar(8)
Declare @FromDate as DateTime
Declare @ToDate as Datetime
Declare @dtMonth Datetime
Declare @MonthLastDate Datetime
Declare @MonthFirstDate Datetime
Declare @TillDate as Datetime
Declare @RptGenerationDate as Datetime
Declare @Counter as Int
Declare @PMMaxCount as Int
Declare @Delimeter as nVarchar(1)
Declare @Month nVarchar(25)
Declare @RptDate Datetime
Declare @PMID Int,@PMDSTypeID Int
Declare @LastInvoiceDate Datetime
Declare @DaycloseDate as DateTime
--Set @DaycloseDate = (Select Convert(Nvarchar(10),LastInventoryUpload,103) From Setup)
Set @DaycloseDate = (Select Top 1 Convert(nvarchar(10),DayCloseDate,103) From DayCloseModules Where Module = 'GGDR Final Data')
Set @Delimeter = Char(15)

Declare @ParamType Int,@Frequency Int,@isFocusParam nVarchar(255)
Declare @CGGroups as nVarchar(100)
Declare @SalesmanID as Int,@Level Int
Declare @TillDateActual Int
Declare @TillDatePointsEarned Decimal(18,6)
Declare @TodaysActual Int
Declare @TillDateActualSales Decimal(18,6)
Declare @TodaysActualSales Decimal(18,6)
Declare @ToDaysPointsEarned Decimal(18,6)
Declare @NoOfDaysInvoiced Int,@ParamID Int
Declare @SlabID Int,@FocusID Int
Declare @SLAB_EVERY Int,@DSGroups nVarchar(50)
Declare @SLAB_Value Decimal(18,6),@DSTypeID Int
Declare @SalesmanName nVarchar(100)


/* Business Achievement*/
Declare @ToTalSalesPercentage Decimal(18,6),@Target  as Decimal(18,6),@MaxPoints Decimal(18,6),@DayClosed Int
Declare @GateUOB_Target as int, @GateUOB_Slab as Decimal(18,6)

Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Declare @GRNTOTAL nVarchar(50)
Declare @MAXPOINT_TOTAL nVarchar(50)

Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Total:', Default)
Set @MAXPOINT_TOTAL = dbo.LookupDictionaryItem(N'Max Points Total:', Default)

Create Table #tmpCatGroup(GroupName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpDStype(DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpSalesman(Salesman nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpPM(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime, Flag int, CPM_Param int,TargetParameterType int, DependDaysWorked Integer)

Create Table #tmpPM1(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime,TargetParameterType int)

Create Table #tmpInvoice(InvoiceID Int,InvoiceDate Datetime,
SalesmanID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCategory nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
Company nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Amount Decimal(18,6) ,InvoiceType Int,InvoiceDateWithTime Datetime,DSTypeID Int,Quantity Decimal(18,6),UOM1Qty Decimal(18,6),UOM2Qty Decimal(18,6)
,OutletID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpOutput([ID] Int Identity(1,1),ParamID Int,[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSID Int,
DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
Target Decimal(18,6),[Average Till Date] Decimal(18,6),
[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
[Till Date Points Earned] Decimal(18,6),
[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Flag int,TargetParameterType int, TargetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpOutputBA([ID] Int Identity(1,1),[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSID Int,
DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
Target Decimal(18,6),[Average Till Date] Decimal(18,6),
[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
[Till Date Points Earned] Decimal(18,6),
[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpInvDateWise(InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
PointsEarned Decimal(18,6))

Create Table #tmpDistinctPMDS(RowID Int Identity(1,1),PMID Int,DSTypeID Int,SalesmanName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpFocusItems (Product Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProLevel Int,Min_Qty Decimal(18,6),UOM Int)
Create Table #tmpMinQtyInvItems(Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)

Create Table #tmpGateUOB(SalesmanID int, GateUOBCnt int)
Create Table #tmpGateDays(SalesmanID int, NoofDays int)
Create Table #tmpUOB(SalesmanID int, UOBCnt int)
Create Table #tmpDependGateDays(SalesmanID int, InvoiceDate Datetime, NoofDays int, Flag int)

Declare @InvalidID int

If @CatGroup = N'%' Or @CatGroup = N''
Begin
Insert Into #tmpCatGroup(GroupName) Values ('GR1,GR3')
Insert Into #tmpCatGroup(GroupName) Values ('GR1')
Insert Into #tmpCatGroup(GroupName) Values ('GR2')
Insert Into #tmpCatGroup(GroupName) Values ('GR3')
End
Else
Begin
/* When GR1&GR3 Selected then Metrics with CategoryGroup GR1, or GR2 or GR3 OR GR1|GR3 should be Selected */
Insert Into #tmpCatGroup
Select * From dbo.sp_SplitIn2rows(@CatGroup,@Delimeter)

Update #tmpCatGroup Set GroupName = Replace(GroupName,'|',',')

If (Select Count(GroupName) From #tmpCatGroup Where GroupName = ('GR1,GR3')) > =1
Begin
Insert Into #tmpCatGroup(GroupName) Values ('GR1')
Insert Into #tmpCatGroup(GroupName) Values ('GR3')
End
End

If @DSType = N'' Or @DSType = N'%'
Begin
Insert into #tmpDStype
Select Distinct DSTypeValue From DSType_Master Where DSTypeCtlPos = 1
End
Else
Begin
Insert Into #tmpDStype
Select * From dbo.sp_SplitIn2rows(@DSType,@Delimeter)
End

If @SalesName = N'%' Or @SalesName = N''
Begin
Insert into #tmpSalesman
Select Salesman_Name From Salesman
End
Begin
Insert into #tmpSalesman
Select * From dbo.sp_SplitIn2rows(@SalesName,@Delimeter)
End

Select @TillDate = GetDate()
Select @RptGenerationDate = @TillDate

Set @ReportType = Ltrim(Rtrim(@ReportType))
If @ReportType = '%' Or @ReportType =  N''
Begin
Set @ReportType = 'Daily'
Set @DateOrMonth = @TillDate
End

Declare @OCG int
Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'
--Select @OCG=Case @CategoryType When 'Regular' Then 0 When 'Operational' then 1 else 1 End

If @ReportType = N'Monthly'
Begin
/* Will be given in MM/YYYY Format */
If @DateOrMonth = '' Or @DateOrMonth = '%'
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else if  Len(@DateOrMonth) > 7
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else if isDate(Cast(('01' + '/' + @DateOrMonth) as nVarchar(15))) = 0
Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else
Set @Month = Cast(@DateOrMonth as nVarchar(7))

Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')

set dateformat dmy
Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
Set @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
If @UptoWeek = N'Week 1'
Begin
Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(DD, 7,  @FromDate))))
End
Else If @UptoWeek =  N'Week 2'
Begin
Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 14,  @FromDate))))
End
Else If @UptoWeek =  N'Week 3'
Begin
Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 21,  @FromDate))))
End
Else If @UptoWeek =  N'Week 4' or @UptoWeek = N'' Or @UptoWeek = N'%'
Begin
Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(MM, +1,  @DtMonth))))
End
If @ToDate > Convert(nVarchar(10), Getdate(), 103)
Begin
Set @ToDate = Convert(nVarchar(10), Getdate(), 103)
End

Set @MonthLastDate = @ToDate
Select @MonthFirstDate = @FromDate
End
Else If @ReportType = N'Daily'
Begin
If @DateOrMonth = '' Or @DateOrMonth = '%'
Set @RptDate = @TillDate
Else if isDate(@DateOrMonth) = 0
Set @RptDate = @TillDate
Else
Set @RptDate = cast(@DateOrMonth as Datetime)

Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @RptDate, 106), 8), ' ', '-')
Select @FromDate = 	@RptDate
Select @ToDate = @RptDate
Select @MonthLastDate = DATEADD(s,-1,DATEADD(m, DATEDIFF(m,0,@FromDate)+1,0))
Select @MonthFirstDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(@FromDate)-1),@FromDate),103)
End

If  (@TillDate > @MonthLastDate) Or (@TillDate < @MonthFirstDate)
Select @TillDate= @MonthLastDate

/* To Find Whether Day isclosed for the current month Last Day */
Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
If @ReportType = N'Monthly'
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@MonthLastDate))
Select @DayClosed = 1
End
Else If @ReportType = N'Daily'
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@RptDate))
Select @DayClosed = 1
End
End

-- To check Winner SKU DayClose
Declare @DayClosed_WinnerSKU int
Select @DayClosed_WinnerSKU = 0
IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
IF @ReportType = N'Monthly'
Begin
If ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'GGDR Final Data') >= dbo.StripTimeFromDate(@MonthLastDate))
Select @DayClosed_WinnerSKU = 1
End
End

Declare @DayClosed_Gate int
Declare @DayClosed_TLCNOA int
Declare @LastDate_TLCNOA Datetime
Declare @Month1 nVarchar(25)
Declare @dtMonth1 Datetime

Set @DayClosed_Gate = 0
IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
IF @ReportType = N'Monthly'
Begin
IF ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB') >= dbo.StripTimeFromDate(@MonthLastDate))
and ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB Monthly') >= dbo.StripTimeFromDate(@MonthLastDate))
Select @DayClosed_Gate = 1
End
Else IF @ReportType = N'Daily'
Begin
IF ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB') >= dbo.StripTimeFromDate(@RptDate))
and ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB Monthly') >= dbo.StripTimeFromDate(@RptDate))
Select @DayClosed_Gate = 1
End
End

If @ReportType = N'Monthly'
Begin
/* Will be given in MM/YYYY Format */
If @DateOrMonth = '' Or @DateOrMonth = '%'
Set @Month1 = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else if  Len(@DateOrMonth) > 7
Set @Month1 = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else if isDate(Cast(('01' + '/' + @DateOrMonth) as nVarchar(15))) = 0
Set @Month1 = Right((Convert(nVarchar(10), @TillDate, 103)),7)
Else
Set @Month1 = Cast(@DateOrMonth as nVarchar(7))

Set @DtMonth1 = cast(Cast('01' + '/' +  @Month1 as nVarchar(15)) as datetime)

Select @LastDate_TLCNOA = DATEADD(s,-1,DATEADD(m, DATEDIFF(m,0,@DtMonth1)+1,0))
End
Else If @ReportType = N'Daily'
Begin
If @DateOrMonth = '' Or @DateOrMonth = '%'
Set @DtMonth1 = @TillDate
Else if isDate(@DateOrMonth) = 0
Set @DtMonth1 = @TillDate
Else
Set @DtMonth1 = cast(@DateOrMonth as Datetime)

Select @LastDate_TLCNOA = DATEADD(s,-1,DATEADD(m, DATEDIFF(m,0,@DtMonth1)+1,0))
End

Select @DayClosed_TLCNOA = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@LastDate_TLCNOA))
Select @DayClosed_TLCNOA = 1
End

Declare @MonthLastDay_Gate int
Select @MonthLastDay_Gate = 0
IF (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
IF ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB') >= dbo.StripTimeFromDate(@LastDate_TLCNOA))
and ((Select dbo.StripTimeFromDate(DayCloseDate) From DayCloseModules Where Module = 'PM GateUOB Monthly') >= dbo.StripTimeFromDate(@LastDate_TLCNOA))
Select @MonthLastDay_Gate = 1
End

/* Last InvoiceDate taken */
Select @LastInvoiceDate = Max(InvoiceDate) From InvoiceAbstract
Where IsNull(Status,0) & 128 = 0 And InvoiceType in(1,3,4)

/* To get config date and validating */
Declare @CFValue nVarchar(10)
Declare @CFYear nVarchar(4)
Declare @CFMonth nVarchar(4)
Declare @CFDate DateTime
Declare @ParamDate DateTime
Declare @ValidFlag int

Set @ValidFlag = 1

If (Select isnull(Flag, 0) From tbl_mERP_ConfigAbstract where ScreenCode = 'RPT01') = 1
Begin
Select @CFValue = isnull(Value, 0) From tbl_mERP_ConfigDetail where ScreenCode = 'RPT01'

Select @CFYear = Substring(@CFValue, 1, 4)
Select @CFMonth = Substring(@CFValue, 5, 2)

If IsDate(Cast('01' + '/' + @CFMonth + '/' + @CFYear as nvarchar(15))) = 1
Select @CFDate = Cast(Cast('01' + '/' + @CFMonth + '/' + @CFYear as nvarchar(15)) as DateTime)
Else
Select @CFDate = dbo.StripDateFromTime(GetDate())

If @FromDate < @CFDate
Set @ValidFlag = 0
Else
Set @ValidFlag = 1
End

If @ValidFlag = 0
Begin
/* Filter the Invoices Which comes in between MonthFromDate And ReportGenerationdate(TillDate) */
Insert Into #tmpInvoice
Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
,IA.CustomerID
From
InvoiceAbstract IA,InvoiceDetail Ide,Items I
,ItemCategories IC,ItemCategories IC1,
ItemCategories IC2,ItemCategories IC3,
tblcgdivmapping CGDiv,Salesman SM
Where
( IsNull(IA.Status,0) & 128 = 0)
And dbo.StripTimeFromDate(IA.InvoiceDate) Between @MonthFirstDate And @TillDate
And IA.InvoiceType in(1,3,4)
And IA.InvoiceID = Ide.InvoiceID
And Ide.Product_Code = I.Product_Code
And I.CategoryID = IC.CategoryID
And IC.ParentID = IC1.CategoryID
And IC1.ParentID = IC2.CategoryID
And IC2.ParentID = IC3.CategoryID
And IC2.Category_Name = CGDiv.Division
And IA.SalesmanID = SM.SalesmanID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
End
Else
Begin
/* Filter the Invoices Which comes in between MonthFromDate And ReportGenerationdate(TillDate) */
Insert Into #tmpInvoice
Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
,IA.CustomerID
From
InvoiceAbstract IA,InvoiceDetail Ide,Items I
,ItemCategories IC,ItemCategories IC1,
ItemCategories IC2,ItemCategories IC3,
tblcgdivmapping CGDiv,Salesman SM
Where
--( IsNull(IA.Status,0) & 128 = 0)
((IA.InvoiceType in(1, 3) and isnull(IA.Status,0) & 128 = 0)
OR (IA.InvoiceType = 4 and isnull(IA.Status,0) & 32 = 0 and isnull(IA.Status,0) & 128 = 0))
And dbo.StripTimeFromDate(IA.InvoiceDate) Between @MonthFirstDate And @TillDate
And IA.InvoiceType in(1,3,4)
And IA.InvoiceID = Ide.InvoiceID
And Ide.Product_Code = I.Product_Code
And I.CategoryID = IC.CategoryID
And IC.ParentID = IC1.CategoryID
And IC1.ParentID = IC2.CategoryID
And IC2.ParentID = IC3.CategoryID
And IC2.Category_Name = CGDiv.Division
And IA.SalesmanID = SM.SalesmanID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
End

if @OCG=1
update #tmpInvoice set CategoryGroup = CGDiv.CategoryGroup From #tmpInvoice I, tblCGDivMapping CGDiv where I.Division = CGDiv.Division

Update #tmpInvoice Set Invoicedate = dbo.StripTimeFromDate(Invoicedate)

-- Gate-UOB 3 month dataposting
Select * Into #tmpPM_GateUOB_Data From PM_GateUOB_Data Where PMMonth = @Period

--Gate-UOB 1 month dataposting
Select * Into #tmpPM_GateUOB_MonthlyData From PM_GateUOB_MonthlyData Where PMMonth = @Period

Create table #DSPMSalesman (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 From tbl_merp_PMetric_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
where PMM.PMID in (Select PMID From tbl_mERP_PMMaster Where Period =@Period )
And PMM.Active = 1 And PMM.PMDSTypeid = DST.DSTypeid
And PMM.Salesmanid = S.Salesmanid
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

If @OCG=1
BEGIN
Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And TDF.Target > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
BEGIN
Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And TDF.Target > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END


If @OCG=1
BEGIN
Insert into #DSPMSalesman (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
Begin
Insert into #DSPMSalesman (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END

/* For OCG*/
If @OCG=0
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End
Else
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End

update #DSPMSalesman set TargetStatus = 1 where Salesmanid in (Select Distinct Salesmanid From tbl_merp_PMetric_TargetDefn where Target > 0 And Active = 1
And PMId in (Select Distinct PMID From tbl_mERP_PMMaster Where Period =@Period))
update #DSPMSalesman set SalesStatus = 1 where Salesmanid in (Select Distinct Salesmanid From #tmpInvoice Where Salesmanid not in (Select Salesmanid From #DSPMSalesman Where TargetStatus = 1))
Update #DSPMSalesman set DSTypeValue = CurrentdsType
Update #DSPMSalesman set SalesStatus = 1 Where DSTypeValue = CurrentdsType And TargetStatus = 1

IF @OCG=0
Begin
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))
End
ELSE
BEGIN
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
--ParamFocus.FocusID,
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))
END
/*If there is no sales for a salesman, then if that salesman alone is Selected then, report is generating blank
but if all salesman is Selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that
particular salesman is Selected*/
If @OCG=0
Begin
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And PMTar.Target > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))

END
ELSE
BEGIN
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And PMTar.Target > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))
END
If @OCG=0
Begin
Insert Into #tmpPM1(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))
END
ELSE
BEGIN
Insert Into #tmpPM1(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints',isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And Param.ParameterType not in(6,7,13)
And ((Param.ParameterType not in(6,7,13) and  isnull(Param.TargetParameterType,0) = 0)
or (Param.ParameterType in(10)))
END

Declare @tmpPMID int, @tmpDSID int, @DSTYPEValue Nvarchar(255)
Declare Cur_PM1 Cursor For
Select PMID,SalesManID,DSType From #tmpPM1
Open Cur_PM1
Fetch next From Cur_PM1 Into @tmpPMID,@tmpDSID,@DSTYPEValue
While @@Fetch_Status = 0
Begin
If not exists (Select * From #tmpPM where PMID=@tmpPMID And Salesmanid = @tmpDSID And DSType = @DSTYPEValue)
Begin
insert into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints,TargetParameterType From #tmpPM1 where PMID=@tmpPMID And Salesmanid = @tmpDSID And DSTYPE = @DSTYPEValue
end
Fetch next From Cur_PM1 into @tmpPMID,@tmpDSID ,@DSTYPEValue
End
Close Cur_PM1
Deallocate Cur_PM1

--To get Absolute PM Param details
Declare @PeriodLastDate Datetime
Select @PeriodLastDate = dbo.mERP_fn_getToDate(@Period)

Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
DS_MaxPoints,Param_MaxPoints,TargetParameterType)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints', isnull(Param.TargetParameterType,0) 'TargetParameterType'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DStypeID From (
Select Distinct DS.SalesmanID as SalesmanID, DS.DSTypeID  as DSTypeID From DSType_Details DS
Inner Join Salesman S ON DS.SalesmanID = S.SalesmanID Where DS.DSTypeCtlPos = 1 and dbo.StripTimeFromDate(S.CreationDate) <= dbo.StripTimeFromDate(@PeriodLastDate)
Union
Select Distinct SalesmanID as SalesmanID,DSTypeID as DSTypeID From #tmpInvoice) Temp
) DSDet
--,(Select Distinct SalesmanID, DSTypeID From DSType_Details Where DSTypeCtlPos = 1) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID and SM.Active = 1
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And Param.ParameterType in (3) and isnull(Param.TargetParameterType,0) <> 0
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
--And dbo.StripTimeFromDate(SM.CreationDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)
--And dbo.StripTimeFromDate(SM.CreationDate) <= dbo.StripTimeFromDate(@PeriodLastDate)
--(dbo.StripTimeFromDate(SM.CreationDate) >= dbo.StripTimeFromDate(@MonthFirstDate)
--	or dbo.StripTimeFromDate(SM.CreationDate) < dbo.StripTimeFromDate(@MonthFirstDate))

Declare @GatePMID int
Declare @GatePercentage Decimal(18,6)
Declare @GateFlag int
Declare @GateDSTypeID int

Declare @TargetParameterType integer
Declare @GateUOB_AbsoluteTarget Decimal(18,6)
Declare @ComparisonType integer
Declare @GateUOB_GrowthTarget Decimal(18,6)
Declare @GateUOB_Cutoff Decimal(18,6)
Declare @DependDaysWorked integer
Declare @DependCounter integer

/* Depend-Days Worked Start */

Declare CursorDepend Cursor For
Select Rowid From #tmpPM Where isnull(ParameterType,0) = 14
Open CursorDepend
Fetch next From CursorDepend Into @DependCounter
While @@Fetch_Status = 0
Begin
Delete From #tmpDependGateDays

Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,@ToTalSalesPercentage =0,
@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
@TodaysActualSales = 0,@DSTypeID=0, @GatePercentage = 0, @GateFlag = 0, @GateUOB_Target =  0,
@GateUOB_Slab = 0, @GateUOB_AbsoluteTarget = 0, @ComparisonType = 0, @GateUOB_GrowthTarget = 0, @DependDaysWorked = 0

Select @GatePMID = PMID, @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode, @GateDSTypeID = DSTypeID, @TargetParameterType = isnull(TargetParameterType,0) From #tmpPM Where RowID = @DependCounter

Truncate Table #TmpFocusItems

Insert Into #TmpFocusItems (Product, ProLevel,Min_Qty,UOM)
Select Distinct ProdCat_Code,ProdCat_Level,Isnull(Min_Qty,0),Isnull(UOM,0) From tbl_mERP_PMParamFocus Where ParamID =  @ParamID

If @ParamType = 14 /* Depend-Days Worked */
Begin
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpDependGateDays(SalesmanID, InvoiceDate, NoofDays)
Select SalesmanID, InvoiceDate, Count(InvoiceDate) From
(Select SalesmanID, IA.InvoiceDate, IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.InvoiceDate,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID, InvoiceDate
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpDependGateDays(SalesmanID, InvoiceDate, NoofDays)
Select SalesmanID, InvoiceDate, Count(InvoiceDate) From
(Select SalesmanID, IA.InvoiceDate, IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.InvoiceDate,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID, InvoiceDate
End
Else If @Level = 3
Begin
Insert Into #tmpDependGateDays(SalesmanID, InvoiceDate, NoofDays)
Select SalesmanID, InvoiceDate, Count(InvoiceDate)	From
(Select SalesmanID, IA.InvoiceDate, IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.InvoiceDate,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID, InvoiceDate
End
Else If @Level = 4
Begin
Insert Into #tmpDependGateDays(SalesmanID, InvoiceDate, NoofDays)
Select SalesmanID, InvoiceDate, Count(InvoiceDate)	From
(Select SalesmanID, IA.InvoiceDate, IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.InvoiceDate,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID, InvoiceDate
End
Else If @Level = 5
Begin
Insert Into #tmpDependGateDays(SalesmanID, InvoiceDate, NoofDays)
Select SalesmanID, InvoiceDate, Count(InvoiceDate) From
(Select SalesmanID, IA.InvoiceDate, IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.InvoiceDate,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID, InvoiceDate
End
End /*End of Focus Param*/

--If (Select isnull(NoofDays, 0) From #tmpGateDays Where SalesmanID = @SalesmanID) >= 1
--Begin
IF @Frequency = 1 /* Daily Frequency */
Begin
Select @Target = Min(SLAB_START) From tbl_mERP_PMParamSlab Where ParamID = @ParamID

Update #tmpDependGateDays Set Flag = 1 Where isnull(NoofDays,0) >= isnull(@Target,0)
Select @DependDaysWorked = Count(*) From #tmpDependGateDays Where isnull(Flag,0) = 1

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = 0,TillDatePointsEarned = 0,NoOfDaysInvoiced = 0,
AverageTillDate = 0 , Target = @Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate, DependDaysWorked = @DependDaysWorked
Where RowID = @DependCounter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = 0,TillDatePointsEarned = 0,NoOfDaysInvoiced = 0,
ToDaysActual = 0,PointsEarnedToday=0,AverageTillDate = 0 ,
Target = @Target, MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate, DependDaysWorked = @DependDaysWorked
Where RowID = @DependCounter
End /* End Of Monthly Frequency */

End /*End of Depend�Days worked */

Fetch next From CursorDepend Into @DependCounter
End
Close CursorDepend
Deallocate CursorDepend

/* Depend-Days Worked End */

/* Other Parameters Start */

Declare Cur_Counter Cursor For
Select Rowid From #tmpPM Where isnull(ParameterType,0) <> 14
Open Cur_Counter
Fetch next From Cur_Counter Into @Counter
While @@Fetch_Status = 0
Begin
Delete From #tmpInvDateWise
Delete From #tmpMinQtyInvItems
Delete From #tmpGateUOB
Delete From #tmpGateDays
Delete From #tmpUOB

Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,@ToTalSalesPercentage =0,
@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
@TodaysActualSales = 0,@DSTypeID=0, @GatePercentage = 0, @GateFlag = 0, @GateUOB_Target =  0,
@GateUOB_Slab = 0, @GateUOB_AbsoluteTarget = 0, @ComparisonType = 0, @GateUOB_GrowthTarget = 0, @DependDaysWorked = 0

Select @GatePMID = PMID, @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode, @GateDSTypeID = DSTypeID, @TargetParameterType = isnull(TargetParameterType,0) From #tmpPM Where RowID = @Counter

Truncate Table #TmpFocusItems
Insert Into #TmpFocusItems (Product, ProLevel,Min_Qty,UOM)
Select Distinct ProdCat_Code,ProdCat_Level,Isnull(Min_Qty,0),Isnull(UOM,0) From tbl_mERP_PMParamFocus Where --PmProductName = Case when @isFocusParam ='Overall' Then 'ALL' else @isFocusParam end And
ParamID =  @ParamID

Insert into #tmpMinQtyInvItems (Division,Sub_Category,MarketSKU, Product_Code)
Select Division,Sub_Category,MarketSKU, Product_Code From dbo.mERP_fn_Get_CSProductminrange_PM(@ParamID)

If @ParamType = 1 /* Lines Cut */
Begin
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut) ,Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
Group By IA.InvoiceID,IA.InvoiceDate,IA.SalesmanID,TI.UOM,TI.Min_Qty
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By InvoiceDate
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.InvoiceID,IA.InvoiceDate,IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.Division
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By InvoiceDate
End
Else If @Level = 3
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.InvoiceID,IA.InvoiceDate,IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.SubCategory
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By InvoiceDate
End
Else If @Level = 4
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.InvoiceID,IA.InvoiceDate,IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.MarketSKU
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By InvoiceDate
End
Else If @Level = 5
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.InvoiceID,IA.InvoiceDate,IA.SalesmanID,TI.UOM,TI.Min_Qty,IA.Product_Code
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By InvoiceDate
End
End /*End of Focus Param*/

If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
Select @TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @TodaysActual = isNull(LinesOrBillsOrBA,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise


Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 1
And @TillDateActual Between SLAB_START And SLAB_END And
@TillDateActual >= SLAB_EVERY_QTY

Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced ,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */
Else If @Frequency = 1
Begin

UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
Where
Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY

Update #tmpInvDateWise Set
PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
Where SlabID > 0

Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0

Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=@TodaysPointsEarned,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End
End /* End of Datewise InvoiceDetails */
End /*End of Lines Cut */


If @ParamType = 2 /* Bills Cut */
Begin
Create Table #tmpInvDateWise_BC(InvoiceId int,InvoiceDate Datetime ,LinesOrBillsOrBA int,InvoiceDateWithTime Datetime)

If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise_BC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select Ia.InvoiceID,IA.InvoiceDate,Count(Distinct IA.InvoiceID),Max(IA.InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where IA.SalesmanID = @SalesmanID
And IA.DSTypeID = @DSTypeID
And IA.CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And IA.InvoiceType In(1,3)
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty
Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_BC
Group by InvoiceDate
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpInvDateWise_BC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_BC where invoiceid in (Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_BC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Division) From #tmpMinQtyInvItems) <>
(Select count(Distinct Division) From #tmpInvoice where invoiceid =@InvalidID
And Division in (Select Division From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_BC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv


Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_BC
Group by InvoiceDate

End
Else If @Level = 3
Begin

Insert Into #tmpInvDateWise_BC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_BC where invoiceid in (
Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)



Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_BC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Sub_Category) From #tmpMinQtyInvItems) <>
(Select count(Distinct SubCategory) From #tmpInvoice where invoiceid =@InvalidID
And subcategory in (Select Sub_Category From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_BC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_BC
Group by InvoiceDate

End
Else If @Level = 4
Begin
Insert Into #tmpInvDateWise_BC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceId,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_BC where invoiceid in(Select distinct IA.InvoiceId
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_BC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(MarketSKU) From #tmpMinQtyInvItems) <>
(Select count(Distinct MarketSKU) From #tmpInvoice where invoiceid =@InvalidID
And MarketSKU in (Select MarketSKU From #tmpMinQtyInvItems))

Delete From #tmpInvDateWise_BC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_BC
Group by InvoiceDate
End
Else If @Level = 5
Begin

Insert Into #tmpInvDateWise_BC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_BC where invoiceid in(Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_BC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Product_Code) From #tmpMinQtyInvItems) <>
(Select count(Distinct Product_Code) From #tmpInvoice where invoiceid =@InvalidID
And Product_Code in (Select Product_Code From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_BC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_BC
Group by InvoiceDate

End
End /*End of Focus Param*/
If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
Select @TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
Select @TodaysActual = isNull(LinesOrBillsOrBA,0)
From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)

Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 1
And @TillDateActual Between SLAB_START And SLAB_END And
@TillDateActual >= SLAB_EVERY_QTY

Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced ,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End /* End Of Monthly Frequency */
Else If @Frequency = 1
Begin
UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
Where
Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY

Update #tmpInvDateWise Set
PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
Where SlabID > 0

Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0

Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday = @TodaysPointsEarned,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End
End /* End of Datewise InvoiceDetails */
Drop Table #tmpInvDateWise_BC
End /*End of Bills Cut */


If @ParamType = 3 /* Business Achievement Begins*/
Begin
Begin /* If target defined */
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime)
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
Group By InvoiceDate
End
Else
Begin
If @Level = 2
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime)
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And Division In (Select Distinct Product From #TmpFocusItems Where ProLevel = 2)
Group By InvoiceDate
Else If @Level = 3
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime)
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And SubCategory In (Select Distinct Product From #TmpFocusItems Where ProLevel = 3)
Group By InvoiceDate
Else If @Level = 4
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime)
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And MarketSKU In (Select Distinct Product From #TmpFocusItems Where ProLevel = 4)
Group By InvoiceDate
Else If @Level = 5
Insert Into #tmpInvDateWise(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime)
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And Product_Code In (Select Distinct Product From #TmpFocusItems Where ProLevel = 5)
Group By InvoiceDate
End /* Focus param Ends */

IF isnull(@TargetParameterType,0) = 0
Begin


If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
Begin
If @Frequency = 2 /* Monthly */
Begin
Select @Target = isNull(Target,0), @MaxPoints = case When Target > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_mERP_PMetric_TargetDefn
Where ParamID = @ParamID --And FocusID = @FocusID
And Active = 1 --And Target >= 0
And SalesmanID =@SalesmanID
And DSTypeID = @DSTypeID

Select @TillDateActualSales = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0)
From  #tmpInvDateWise Where InvoiceDate = @FromDate

if Exists (Select ParamID From tbl_mERP_PMetric_TargetDefn Where ParamID = @ParamID --And FocusID = @FocusID
And Active = 1 And SalesmanID =@SalesmanID And Target > 0)
Begin
Select @ToTalSalesPercentage  = case When isnull(@Target,0) = 0 then 0 Else (@TillDateActualSales /Cast(@Target as Decimal(18,6))*100)  end
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @ToTalSalesPercentage Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints

End
Else
Begin
Select @ToTalSalesPercentage  = @TillDateActualSales
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @ToTalSalesPercentage Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = 0
--Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints
End
IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActualSales,PointsEarnedToday=0,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced ,
Target = @Target ,MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */
Else If @Frequency = 1 /* Daily Frequency Begins */
Begin
Select @Target = isNull(Target,0), @MaxPoints = isNull(MaxPoints,0) From tbl_mERP_PMetric_TargetDefn
Where ParamID = @ParamID
--And FocusID = @FocusID
And Active = 1 --And Target >= 0
And SalesmanID =@SalesmanID
And DSTypeID = @DSTypeID

/* Update SalesPercentage */
if @Target > 0
Update #tmpInvDateWise Set SalesPercentage = LinesOrBillsOrBA/Cast(@Target as Decimal(18,6)) * 100
ELSE
Update #tmpInvDateWise Set SalesPercentage = LinesOrBillsOrBA
UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
Where
Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 2
And SalesPercentage Between Slab.SLAB_START And Slab.SLAB_END

Update #tmpInvDateWise Set PointsEarned = (@MaxPoints * Cast(Slab_Value as Decimal(18,6)))/100 Where SlabID > 0

/* When PointsEarned is greater than the MaxPoints Then show the
MaxPoints as the PointsEarned */
--							Update #tmpInvDateWise Set PointsEarned = @MaxPoints
--							Where isNull(PointsEarned,0) > @MaxPoints
--							And SlabID > 0

Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0

Select @TillDateActualSales = Sum(LinesOrBillsOrBA),@TillDatePointsEarned = Sum(PointsEarned) From #tmpInvDateWise
Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0),@TodaysPointsEarned = isNull(PointsEarned,0)
From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActualSales,
PointsEarnedToday=(Case @DayClosed When 0 Then 0 Else @ToDaysPointsEarned End),
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,
GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End /* Daily Frequency Ends */
End /* DateWise InvoiceDetails */

End /* Calculated Target */
Else
Begin
If @Frequency = 2 /* Monthly */
Begin

Select @Target = Max(SLAB_START) From tbl_mERP_PMParamSlab
Where ParamID = @ParamID

Select @MaxPoints = Case When @Target > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_mERP_PMParam
Where ParamID = @ParamID

Select @TillDateActualSales = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0)
From  #tmpInvDateWise Where InvoiceDate = @FromDate

Select @ToTalSalesPercentage  = @TillDateActualSales
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @ToTalSalesPercentage Between SLAB_START And SLAB_END

Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTranDate = @LastInvoiceDate Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActualSales,PointsEarnedToday=0,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced ,
Target = @Target ,MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */
Else If @Frequency = 1 /* Daily Frequency Begins */
Begin
Select @Target = Max(SLAB_START) From tbl_mERP_PMParamSlab
Where ParamID = @ParamID

Select @MaxPoints = Case When @Target > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_mERP_PMParam
Where ParamID = @ParamID

Update #tmpInvDateWise Set SalesPercentage = LinesOrBillsOrBA

UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
Where
Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 2
And SalesPercentage Between Slab.SLAB_START And Slab.SLAB_END

Update #tmpInvDateWise Set PointsEarned = (@MaxPoints * Cast(Slab_Value as Decimal(18,6)))/100 Where SlabID > 0

Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0

Select @TillDateActualSales = Sum(LinesOrBillsOrBA),@TillDatePointsEarned = Sum(PointsEarned) From #tmpInvDateWise
Select @TodaysActualSales = isNull(LinesOrBillsOrBA,0),@TodaysPointsEarned = isNull(PointsEarned,0)
From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,
TillDatePointsEarned = (Case @DayClosed When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActualSales,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActualSales,
PointsEarnedToday=(Case @DayClosed When 0 Then 0 Else @ToDaysPointsEarned End),
AverageTillDate = Cast(@TillDateActualSales as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,
GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate
Where RowID = @Counter

End /* Daily Frequency Ends */
End /* Absolute Target */


End /*End Of target Defined*/
End /* Business Achievement Ends*/

If @ParamType = 8 /* Total Bills Cut */
Begin
Create Table #tmpInvDateWise_TBC(InvoiceId int,InvoiceDate Datetime ,LinesOrBillsOrBA int,InvoiceDateWithTime Datetime)

If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise_TBC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select Ia.InvoiceID,IA.InvoiceDate,Count(Distinct IA.InvoiceID),Max(IA.InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where IA.SalesmanID = @SalesmanID
And IA.DSTypeID = @DSTypeID
And IA.CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And IA.InvoiceType In(1,3)
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty
Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_TBC
Group by InvoiceDate
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpInvDateWise_TBC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_TBC where invoiceid in (Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_TBC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Division) From #tmpMinQtyInvItems) <>
(Select count(Distinct Division) From #tmpInvoice where invoiceid =@InvalidID
And Division in (Select Division From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_TBC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv


Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_TBC
Group by InvoiceDate

End
Else If @Level = 3
Begin

Insert Into #tmpInvDateWise_TBC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_TBC where invoiceid in (
Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)



Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_TBC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Sub_Category) From #tmpMinQtyInvItems) <>
(Select count(Distinct SubCategory) From #tmpInvoice where invoiceid =@InvalidID
And subcategory in (Select Sub_Category From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_TBC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_TBC
Group by InvoiceDate

End
Else If @Level = 4
Begin
Insert Into #tmpInvDateWise_TBC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceId,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_TBC where invoiceid in(Select distinct IA.InvoiceId
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_TBC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(MarketSKU) From #tmpMinQtyInvItems) <>
(Select count(Distinct MarketSKU) From #tmpInvoice where invoiceid =@InvalidID
And MarketSKU in (Select MarketSKU From #tmpMinQtyInvItems))

Delete From #tmpInvDateWise_TBC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_TBC
Group by InvoiceDate
End
Else If @Level = 5
Begin

Insert Into #tmpInvDateWise_TBC(InvoiceId,InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select IA.InvoiceID,InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime)
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty

Delete From #tmpInvDateWise_TBC where invoiceid in(Select distinct IA.InvoiceID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.InvoiceDate,TI.UOM,TI.Min_Qty,IA.InvoiceID,TI.Product
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) < TI.Min_Qty)

Declare AllInv Cursor For Select distinct InvoiceID From #tmpInvDateWise_TBC
open AllInv
Fetch From AllInv into @InvalidID
While @@Fetch_status=0
Begin
If (Select count(Product_Code) From #tmpMinQtyInvItems) <>
(Select count(Distinct Product_Code) From #tmpInvoice where invoiceid =@InvalidID
And Product_Code in (Select Product_Code From #tmpMinQtyInvItems))
Delete From #tmpInvDateWise_TBC where Invoiceid=@InvalidID
Fetch next From AllInv into @InvalidID
End
Close AllInv
Deallocate AllInv

Insert into #tmpInvDateWise (InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Count(Distinct InvoiceID),Max(InvoiceDateWithTime) From #tmpInvDateWise_TBC
Group by InvoiceDate

End
End /*End of Focus Param*/
If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
Select @MaxPoints = MaxPoints From tbl_merp_PMParam Where ParamID = @ParamID --and DSTypeID = @DSTypeID
Select @TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
Select @TodaysActual = isNull(LinesOrBillsOrBA,0)
From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)

Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TillDateActual Between SLAB_START And SLAB_END And
@TillDateActual >= SLAB_EVERY_QTY

-- Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then  @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

Select @TillDatePointsEarned = (@SLAB_VALUE * @MaxPoints) / 100

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = 0 , Target = 0 ,MaxPoints = @MaxPoints, GenerationDate = @RptGenerationDate, LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = 0,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End /* End Of Monthly Frequency */

--					Else If @Frequency = 1
--					Begin
--						UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
--						Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
--						Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
--						From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
--						Where
--						Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
--						And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
--						And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY
--
--						Update #tmpInvDateWise Set
--						PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
--						Where SlabID > 0
--
--						Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
--
--						Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
--						Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
--						Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
--						@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--
--						IF @ReportType = 'Monthly'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--						Else if @ReportType = 'Daily'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							ToDaysActual = @TodaysActual,PointsEarnedToday = @TodaysPointsEarned,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--					End

End /* End of Datewise InvoiceDetails */
Drop Table #tmpInvDateWise_TBC
End /*End of Total Bills Cut */


If @ParamType = 10 /* Gate-UOB */
Begin
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpGateUOB(SalesmanID, GateUOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID ,OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpGateUOB(SalesmanID, GateUOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID ,OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesManID
End
Else If @Level = 3
Begin
Insert Into #tmpGateUOB(SalesmanID, GateUOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID ,OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 4
Begin
Insert Into #tmpGateUOB(SalesmanID, GateUOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID ,OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 5
Begin
Insert Into #tmpGateUOB(SalesmanID, GateUOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID ,OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
End /*End of Focus Param*/

--If (Select isnull(GateUOBCnt, 0) From #tmpGateUOB Where SalesmanID = @SalesmanID) >= 1
--Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
If isnull(@TargetParameterType,0) = 0
Begin

Select @Target = Sum(isnull(OutletCount,0)) From #tmpPM_GateUOB_Data Where PMID =  @GatePMID
and PMMonth = @Period and PMParamID = @ParamID and DSID = @SalesmanID And PMDSTypeID = @GateDSTypeID
Select @TillDateActual = Sum(isnull(GateUOBCnt,0)) From #tmpGateUOB
--Select @TodaysActual = isNull(LinesOrBillsOrBA,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

IF isnull(@Target,0) > 0 and isnull(@TillDateActual,0) > 0
Select @GatePercentage = @TillDateActual * 100 / @Target
Else IF  isnull(@Target,0) = 0 and isnull(@TillDateActual,0) > 0
Select @GatePercentage = 100
Else
Select @GatePercentage = 0

Select @GateUOB_Slab = Min(SLAB_START) From tbl_mERP_PMParamSlab Where ParamID = @ParamID and SLAB_GIVEN_AS = 2
IF isnull(@Target,0) > 0 and isnull(@GateUOB_Slab,0) > 0
Begin
Set @GateUOB_Target = Cast(Ceiling((@Target * @GateUOB_Slab) / 100) as int)
End
Else IF isnull(@Target,0) > 0
Set @GateUOB_Target = @Target
Else
Set @GateUOB_Target = 0

Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @GatePercentage >= SLAB_START
--And @GatePercentage Between SLAB_START And SLAB_END
--And @TillDateActual >= SLAB_EVERY_QTY

--Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End
IF @SlabID > 0
Select @GateFlag = 1
Else
Select @GateFlag = 2

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = 0 , Target = @GateUOB_Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate, Flag = @GateFlag
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = 0 ,
Target = @GateUOB_Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate, Flag = @GateFlag
Where RowID = @Counter
End /* Calculated Target*/

Else
Begin
-- @GateUOB_Target - Calculated,  @GateUOB_AbsoluteTarget - Absolute,  @GateUOB_GrowthTarget - Growth

Select @GateUOB_AbsoluteTarget = Min(isnull(AbsoluteTarget,0)) From tbl_mERP_PMParamSlab Where ParamID = @ParamID and SLAB_GIVEN_AS = 2
Set @GateUOB_AbsoluteTarget = isnull(@GateUOB_AbsoluteTarget,0)

Select @Target = Sum(isnull(OutletCount,0)) From #tmpPM_GateUOB_Data Where PMID =  @GatePMID
and PMMonth = @Period and PMParamID = @ParamID and DSID = @SalesmanID And PMDSTypeID = @GateDSTypeID

Select @GateUOB_GrowthTarget  = Sum(isnull(OutletCount,0)) From #tmpPM_GateUOB_MonthlyData Where PMID = @GatePMID
and PMMonth = @Period and PMParamID = @ParamID and DSID = @SalesmanID And PMDSTypeID = @GateDSTypeID

Select @ComparisonType  = isnull(ComparisonType,0), @GateUOB_Cutoff = isnull(Cutoff_Percentage,0) From tbl_mERP_PMParam Where ParamID = @ParamID

set @GateUOB_Cutoff = isnull(@GateUOB_Cutoff,0)
Set @GateUOB_GrowthTarget = isnull(@GateUOB_GrowthTarget,0)
Set @Target = isnull(@Target,0)

IF @GateUOB_GrowthTarget > 0 and isnull(@GateUOB_Cutoff,0) > 0
Set @GateUOB_GrowthTarget = @GateUOB_GrowthTarget + Cast(Ceiling((@GateUOB_GrowthTarget * @GateUOB_Cutoff) / 100) as int)
Else
Set @GateUOB_GrowthTarget = 0

Select @GateUOB_Slab = Min(SLAB_START) From tbl_mERP_PMParamSlab Where ParamID = @ParamID and SLAB_GIVEN_AS = 2
IF isnull(@Target,0) > 0 and isnull(@GateUOB_Slab,0) > 0
Begin
Set @GateUOB_Target = Cast(Ceiling((@Target * @GateUOB_Slab) / 100) as int)
End
Else IF isnull(@Target,0) > 0
Set @GateUOB_Target = @Target
Else
Set @GateUOB_Target = 0

IF isnull(@Target,0) > 0
Begin
IF isnull(@TargetParameterType,0) = 1  -- Absolute Mode
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End

Else IF isnull(@TargetParameterType,0) = 2  -- Mixed-Lesser Mode
Begin
IF isnull(@ComparisonType,0) = 0   -- Mixed-Lesser (Calculated & Growth & Absolute)
Begin
IF @GateUOB_Target > 0 and @GateUOB_AbsoluteTarget > 0 and @GateUOB_GrowthTarget > 0
Begin
Select @Target = Case When @GateUOB_Target <= @GateUOB_AbsoluteTarget and @GateUOB_Target <= @GateUOB_GrowthTarget Then @GateUOB_Target
When @GateUOB_AbsoluteTarget <= @GateUOB_GrowthTarget Then @GateUOB_AbsoluteTarget
Else @GateUOB_GrowthTarget End

Set @GateUOB_Target = @Target
End
Else IF @GateUOB_GrowthTarget = 0 and @GateUOB_Target > 0
Begin
IF @GateUOB_Target <= @GateUOB_AbsoluteTarget
Begin
Set @Target = @GateUOB_Target
End
Else
Begin
Set @GateUOB_Target = @GateUOB_AbsoluteTarget
Set @Target = @GateUOB_Target
End
End
Else IF @GateUOB_Target = 0 and @GateUOB_GrowthTarget > 0
Begin
IF @GateUOB_GrowthTarget <= @GateUOB_AbsoluteTarget
Begin
Set @GateUOB_Target = @GateUOB_GrowthTarget
Set @Target = @GateUOB_Target
End
Else
Begin
Set @GateUOB_Target = @GateUOB_AbsoluteTarget
Set @Target = @GateUOB_Target
End
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End

End
Else IF isnull(@ComparisonType,0) = 1   -- Mixed-Lesser (Calculated & Growth)
Begin
IF @GateUOB_GrowthTarget > 0 and @GateUOB_Target > 0
Begin
IF @GateUOB_GrowthTarget <= @GateUOB_Target
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else IF @GateUOB_GrowthTarget > 0 and @GateUOB_Target = 0
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else IF isnull(@ComparisonType,0) = 2   -- Mixed-Lesser (Absolute & Growth)
Begin
IF @GateUOB_GrowthTarget > 0 and @GateUOB_GrowthTarget <= @GateUOB_AbsoluteTarget
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
End
Else IF isnull(@ComparisonType,0) = 3   -- Mixed-Lesser (Calculated & Absolute)
Begin
IF isnull(@GateUOB_Target,0) > 0
Begin
IF @GateUOB_AbsoluteTarget <= @GateUOB_Target
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
End

--If @GateUOB_Target > 0
--Begin
--	If @GateUOB_AbsoluteTarget <= @GateUOB_Target
--	Begin
--		Set @Target = @GateUOB_AbsoluteTarget
--		Set @GateUOB_Target = @Target
--	End
--	Else
--	Begin
--		Set @Target = @GateUOB_Target
--	End
--End
--Else
--Begin
--	Set @Target = @GateUOB_AbsoluteTarget
--	Set @GateUOB_Target = @Target
--End
End

Else IF isnull(@TargetParameterType,0) = 3  -- Mixed-Greater Mode
Begin
IF isnull(@ComparisonType,0) = 0   -- Mixed-Greater (Calculated & Growth & Absolute)
Begin
IF @GateUOB_Target > 0 and @GateUOB_AbsoluteTarget > 0 and @GateUOB_GrowthTarget > 0
Begin
Select @Target = Case When @GateUOB_Target >= @GateUOB_AbsoluteTarget and @GateUOB_Target >= @GateUOB_GrowthTarget Then @GateUOB_Target
When @GateUOB_AbsoluteTarget >= @GateUOB_GrowthTarget Then @GateUOB_AbsoluteTarget
Else @GateUOB_GrowthTarget End

Set @GateUOB_Target = @Target
End
Else IF @GateUOB_GrowthTarget = 0 and @GateUOB_Target > 0
Begin
IF @GateUOB_Target >= @GateUOB_AbsoluteTarget
Begin
Set @Target = @GateUOB_Target
End
Else
Begin
Set @GateUOB_Target = @GateUOB_AbsoluteTarget
Set @Target = @GateUOB_Target
End
End
Else IF @GateUOB_Target = 0 and @GateUOB_GrowthTarget > 0
Begin
IF @GateUOB_GrowthTarget >= @GateUOB_AbsoluteTarget
Begin
Set @GateUOB_Target = @GateUOB_GrowthTarget
Set @Target = @GateUOB_Target
End
Else
Begin
Set @GateUOB_Target = @GateUOB_AbsoluteTarget
Set @Target = @GateUOB_Target
End
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End

End
Else IF isnull(@ComparisonType,0) = 1   -- Mixed-Greater (Calculated & Growth)
Begin
IF @GateUOB_GrowthTarget > 0 and @GateUOB_Target > 0
Begin
IF @GateUOB_GrowthTarget >= @GateUOB_Target
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else IF @GateUOB_GrowthTarget > 0 and @GateUOB_Target = 0
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else IF isnull(@ComparisonType,0) = 2   -- Mixed-Greater (Absolute & Growth)
Begin
IF @GateUOB_GrowthTarget > 0 and @GateUOB_GrowthTarget >= @GateUOB_AbsoluteTarget
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
End
Else IF isnull(@ComparisonType,0) = 3   -- Mixed-Greater (Calculated & Absolute)
Begin
IF isnull(@GateUOB_Target,0) > 0
Begin
IF @GateUOB_AbsoluteTarget >= @GateUOB_Target
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
Else
Begin
Set @Target = @GateUOB_Target
End
End
Else
Begin
Set @Target = @GateUOB_AbsoluteTarget
Set @GateUOB_Target = @Target
End
End

--If @GateUOB_Target > 0
--Begin
--	If @GateUOB_AbsoluteTarget >= @GateUOB_Target
--	Begin
--		Set @Target = @GateUOB_AbsoluteTarget
--		Set @GateUOB_Target = @Target
--	End
--	Else
--	Begin
--		Set @Target = @GateUOB_Target
--	End
--End
--Else
--Begin
--	Set @Target = @GateUOB_AbsoluteTarget
--	Set @GateUOB_Target = @Target
--End
End

Else IF isnull(@TargetParameterType,0) = 4  -- Growth
Begin
Set @Target = @GateUOB_GrowthTarget
Set @GateUOB_Target = @Target
End

Else
Begin
Set @Target = 0
Set @GateUOB_Target = 0
End
End

Select @TillDateActual = Sum(isnull(GateUOBCnt,0)) From #tmpGateUOB
IF isnull(@TillDateActual,0) > 0 and isnull(@TillDateActual,0) >= isnull(@Target,0)
Set @SlabID = 1

--IF isnull(@Target,0) > 0 and isnull(@TillDateActual,0) > 0
--	Select @GatePercentage = @TillDateActual * 100 / @Target
--Else IF  isnull(@Target,0) = 0 and isnull(@TillDateActual,0) > 0
--	Select @GatePercentage = 100
--Else
--	Select @GatePercentage = 0

--Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
--From tbl_mERP_PMParamSlab Where
--ParamID = @ParamID And SLAB_GIVEN_AS = 2
--And @GatePercentage Between SLAB_START And SLAB_END

IF @SlabID > 0
Select @GateFlag = 1
Else
Select @GateFlag = 2

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = 0 , Target = @GateUOB_Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate, Flag = @GateFlag
Where RowID = @Counter
Else IF @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = 0 ,
Target = @GateUOB_Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate, Flag = @GateFlag
Where RowID = @Counter

End /* Absolute Target */

End /* End Of Monthly Frequency */

--					Else If @Frequency = 1
--					Begin
--
--						UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
--						Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
--						Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
--						From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
--						Where
--						Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
--						And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
--						And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY
--
--						Update #tmpInvDateWise Set
--						PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
--						Where SlabID > 0
--
--						Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
--
--						Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
--						Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
--						@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--						Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
--
--						IF @ReportType = 'Monthly'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--						Else if @ReportType = 'Daily'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							ToDaysActual = @TodaysActual,PointsEarnedToday=@TodaysPointsEarned,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--					End

--End /* End of Datewise InvoiceDetails */
End /*End of Gate-UOB */

If @ParamType = 11 /* Gate-Days Worked */
Begin
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpGateDays(SalesmanID, NoofDays)
Select SalesmanID, Count(Distinct(InvoiceDate)) From
(Select SalesmanID ,dbo.StripTimeFromDate(IA.InvoiceDate) 'InvoiceDate'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,dbo.StripTimeFromDate(IA.InvoiceDate)
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpGateDays(SalesmanID, NoofDays)
Select SalesmanID, Count(Distinct(InvoiceDate)) From
(Select SalesmanID ,dbo.StripTimeFromDate(IA.InvoiceDate) 'InvoiceDate'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,dbo.StripTimeFromDate(IA.InvoiceDate)
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 3
Begin
Insert Into #tmpGateDays(SalesmanID, NoofDays)
Select SalesmanID, Count(Distinct(InvoiceDate)) From
(Select SalesmanID ,dbo.StripTimeFromDate(IA.InvoiceDate) 'InvoiceDate'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,dbo.StripTimeFromDate(IA.InvoiceDate)
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 4
Begin
Insert Into #tmpGateDays(SalesmanID, NoofDays)
Select SalesmanID, Count(Distinct(InvoiceDate)) From
(Select SalesmanID ,dbo.StripTimeFromDate(IA.InvoiceDate) 'InvoiceDate'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,dbo.StripTimeFromDate(IA.InvoiceDate)
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 5
Begin
Insert Into #tmpGateDays(SalesmanID, NoofDays)
Select SalesmanID, Count(Distinct(InvoiceDate)) From
(Select SalesmanID ,dbo.StripTimeFromDate(IA.InvoiceDate) 'InvoiceDate'
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,dbo.StripTimeFromDate(IA.InvoiceDate)
Having cast((Case
When TI.UOM = 1 Then Sum(Isnull(IA.Quantity,0))
When TI.UOM = 2 Then Sum(Isnull(IA.UOM1Qty,0))
When TI.UOM = 3 Then Sum(Isnull(IA.UOM2Qty,0))
When TI.UOM = 4 Then Sum(Isnull(IA.Amount,0)) End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
End /*End of Focus Param*/

--If (Select isnull(NoofDays, 0) From #tmpGateDays Where SalesmanID = @SalesmanID) >= 1
--Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
IF Exists(Select 'x' From #tmpPM Where PMID = @GatePMID and isNull(CGGroups,'') = @CGGroups
and ParameterType = 14 and DSTypeCode = @DSTypeID and SalesmanID = @SalesmanID)
Select @TillDateActual = isnull(DependDaysWorked,0) From #tmpPM
Where PMID = @GatePMID and isNull(CGGroups,'') = @CGGroups and ParameterType = 14
and DSTypeCode = @DSTypeID and SalesmanID = @SalesmanID
Else
Select @TillDateActual = Sum(isnull(NoofDays, 0)) From #tmpGateDays

Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 1
And @TillDateActual Between SLAB_START And SLAB_END

Select @Target = Min(SLAB_START) From tbl_mERP_PMParamSlab Where ParamID = @ParamID
IF isnull(@SlabID,0) > 0
Select @GateFlag = 1
Else
Select @GateFlag = 2

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = 0 , Target = @Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate, Flag =@GateFlag
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = 0 ,
Target = @Target ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate, Flag =@GateFlag
Where RowID = @Counter
End /* End Of Monthly Frequency */

--					Else If @Frequency = 1
--					Begin
--
--						UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
--						Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
--						Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
--						From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
--						Where
--						Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
--						And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
--						And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY
--
--						Update #tmpInvDateWise Set
--						PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
--						Where SlabID > 0
--
--						Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
--
--						Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
--						Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
--						@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--						Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
--
--						IF @ReportType = 'Monthly'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--						Else if @ReportType = 'Daily'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							ToDaysActual = @TodaysActual,PointsEarnedToday=@TodaysPointsEarned,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--					End

--End /* End of Datewise InvoiceDetails */
End /*End of Gate-Days Worked */

If @ParamType = 12 /* UOB */
Begin
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpUOB(SalesmanID, UOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID , OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpUOB(SalesmanID, UOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID , OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.Division = TI.Product
And TI.ProLevel = 2
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 3
Begin
Insert Into #tmpUOB(SalesmanID, UOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID , OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.SubCategory = TI.Product
And TI.ProLevel = 3
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 4
Begin
Insert Into #tmpUOB(SalesmanID, UOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID , OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.MarketSKU = TI.Product
And TI.ProLevel = 4
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
Else If @Level = 5
Begin
Insert Into #tmpUOB(SalesmanID, UOBCnt)
Select SalesmanID, Count(Distinct OutletID) From
(Select SalesmanID , OutletID
From #tmpInvoice IA,#TmpFocusItems TI
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And IA.Product_Code = TI.Product
And TI.ProLevel = 5
Group By IA.SalesmanID,TI.UOM,TI.Min_Qty,OutletID
Having Cast((Case
When TI.UOM = 1 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Quantity,0)
When IA.invoicetype =3 Then Isnull(IA.Quantity,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Quantity,0) End)
When TI.UOM = 2 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM1Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM1Qty,0) End)
When TI.UOM = 3 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =3 Then Isnull(IA.UOM2Qty,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.UOM2Qty,0) End)
When TI.UOM = 4 Then Sum(Case When IA.invoicetype =1 Then Isnull(IA.Amount,0)
When IA.invoicetype =3 Then Isnull(IA.Amount,0)
When IA.invoicetype =4 Then -1 * Isnull(IA.Amount,0) End)
End) as Decimal(18,6)) >= TI.Min_Qty) T
Group By SalesmanID
End
End /*End of Focus Param*/

If (Select isnull(UOBCnt, 0) From #tmpUOB Where SalesmanID = @SalesmanID) >= 1
Begin
If @Frequency = 2 /* Monthly Frequency */
Begin
Select @TillDateActual = Sum(isnull(UOBCnt,0)) From #tmpUOB
--Select @TodaysActual = isNull(LinesOrBillsOrBA,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise

Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 1
And @TillDateActual Between SLAB_START And SLAB_END
--And @TillDateActual >= SLAB_EVERY_QTY

Select @TillDatePointsEarned = Case isNull(@SLAB_EVERY,0)  When 0 Then   @SLAB_VALUE Else Cast((@TillDateActual/@SLAB_EVERY) as Int ) * @SLAB_VALUE End

IF @ReportType = 'Monthly'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = 0 , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = 0 ,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */

--					Else If @Frequency = 1
--					Begin
--						UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
--						Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
--						Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
--						From  #tmpInvDateWise Inv,tbl_mERP_PMParamSlab Slab
--						Where
--						Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 1
--						And Inv.LinesOrBillsOrBA Between Slab.SLAB_START And Slab.SLAB_END
--						And Inv.LinesOrBillsOrBA >= Slab.SLAB_EVERY_QTY
--
--						Update #tmpInvDateWise Set
--						PointsEarned = Case isNull(Slab_Every,0) When 0 Then Slab_Value Else Cast(LinesOrBillsOrBA/Slab_Every as Int) * Slab_Value End
--						Where SlabID > 0
--
--						Update #tmpInvDateWise Set PointsEarned = 0 Where isNull(SlabID,0) = 0
--
--						Select @TillDatePointsEarned = Sum(PointsEarned),@TillDateActual = Sum(LinesOrBillsOrBA) From #tmpInvDateWise
--						Select @TodaysActual = isNull(LinesOrBillsOrBA,0) ,
--						@TodaysPointsEarned = isNull(PointsEarned,0) From  #tmpInvDateWise Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
--						Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise
--
--						IF @ReportType = 'Monthly'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = @TillDatePointsEarned,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--						Else if @ReportType = 'Daily'
--							UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
--							ToDaysActual = @TodaysActual,PointsEarnedToday=@TodaysPointsEarned,
--							AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
--							LastTrAndate = @LastInvoiceDate
--							Where RowID = @Counter
--					End

End /* End of Datewise InvoiceDetails */
End /*End of UOB */

Fetch next From Cur_Counter into @Counter
--Set @Counter = @Counter + 1
End /* End of While */
Close Cur_Counter
Deallocate Cur_Counter

/* Other Parameters End */

/* Start: Total Lines Cut */

Create Table #tmpPM_TLC(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime)

Create Table #tmpPM1_TLC(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime)

Create Table #tmpInvDateWise_TLC(InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
PointsEarned Decimal(18,6))

Create table #DSPMSalesman_TLC (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
Insert into #DSPMSalesman_TLC (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 From tbl_merp_PMOutletAch_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
where PMM.PMID in (Select PMID From tbl_mERP_PMMaster Where Period =@Period )
And PMM.Active = 1 And PMM.PMDSTypeid = DST.DSTypeid
And PMM.Salesmanid = S.Salesmanid
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

If @OCG=1
BEGIN
Insert into #DSPMSalesman_TLC (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMOutletAch_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And isnull(TDF.Target,0) > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
BEGIN
Insert into #DSPMSalesman_TLC (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMOutletAch_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And isnull(TDF.Target,0) > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END


If @OCG=1
BEGIN
Insert into #DSPMSalesman_TLC (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman_TLC) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
Begin
Insert into #DSPMSalesman_TLC (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman_TLC) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END

/* For OCG*/
If @OCG=0
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman_TLC T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End
Else
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman_TLC T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End

update #DSPMSalesman_TLC set TargetStatus = 1 where Salesmanid in (Select Distinct Salesmanid From tbl_merp_PMOutletAch_TargetDefn where isnull(Target,0) > 0 And Active = 1
And PMId in (Select Distinct PMID From tbl_mERP_PMMaster Where Period =@Period))
update #DSPMSalesman_TLC set SalesStatus = 1 where Salesmanid in (Select Distinct Salesmanid From #tmpInvoice Where Salesmanid not in (Select Salesmanid From #DSPMSalesman_TLC Where TargetStatus = 1))
Update #DSPMSalesman_TLC set DSTypeValue = CurrentdsType
Update #DSPMSalesman_TLC set SalesStatus = 1 Where DSTypeValue = CurrentdsType And TargetStatus = 1

IF @OCG=0
Begin
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)
End
ELSE
BEGIN
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
--ParamFocus.FocusID,
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)
END
/*If there is no sales for a salesman, then if that salesman alone is Selected then, report is generating blank
but if all salesman is Selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that
particular salesman is Selected*/
If @OCG=0
Begin
Insert Into #tmpPM_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMOutletAch_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman_TLC) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And isnull(PMTar.Target,0) > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm_TLC)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)

END
ELSE
BEGIN
Insert Into #tmpPM_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMOutletAch_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman_TLC) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And isnull(PMTar.Target,0) > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm_TLC)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)
END
If @OCG=0
Begin
Insert Into #tmpPM1_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman_TLC Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman_TLC)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)
END
ELSE
BEGIN
Insert Into #tmpPM1_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman_TLC Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman_TLC)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(6)
END

Declare @tmpPMID_TLC int, @tmpDSID_TLC int, @DSTYPEValue_TLC Nvarchar(255)
Declare Cur_PM1_TLC Cursor For
Select PMID,SalesManID,DSType From #tmpPM1_TLC
Open Cur_PM1_TLC
Fetch next From Cur_PM1_TLC Into @tmpPMID_TLC,@tmpDSID_TLC,@DSTYPEValue_TLC
While @@Fetch_Status = 0
Begin
If not exists (Select * From #tmpPM_TLC where PMID=@tmpPMID_TLC And Salesmanid = @tmpDSID_TLC And DSType = @DSTYPEValue_TLC)
Begin
insert into #tmpPM_TLC(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
Select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints From #tmpPM1_TLC where PMID=@tmpPMID_TLC And Salesmanid = @tmpDSID_TLC And DSTYPE = @DSTYPEValue_TLC
end
Fetch next From Cur_PM1_TLC into @tmpPMID_TLC,@tmpDSID_TLC ,@DSTYPEValue_TLC
End
Close Cur_PM1_TLC
Deallocate Cur_PM1_TLC


Declare @TodaysActual_TLC Decimal(18,6), @TillDateActual_TLC Decimal(18,6)
Declare @TotalPercentge_TLC Decimal(18,6)

Declare Cur_Counter_TLC Cursor For
Select Rowid From #tmpPM_TLC
Open Cur_Counter_TLC
Fetch next From Cur_Counter_TLC Into @Counter
While @@Fetch_Status = 0
Begin

Delete From #tmpInvDateWise_TLC
--Delete From #tmpMinQtyInvItems

Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,
@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
@TodaysActualSales = 0,@DSTypeID=0, @TillDateActual_TLC = 0, @TodaysActual_TLC = 0, @TotalPercentge_TLC = 0

Select @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode From #tmpPM_TLC Where RowID = @Counter

Truncate Table #TmpFocusItems
Insert Into #TmpFocusItems (Product, ProLevel,Min_Qty,UOM)
Select Distinct ProdCat_Code,ProdCat_Level,Isnull(Min_Qty,0),Isnull(UOM,0) From tbl_mERP_PMParamFocus Where --PmProductName = Case when @isFocusParam ='Overall' Then 'ALL' else @isFocusParam end And
ParamID =  @ParamID

--Insert into #tmpMinQtyInvItems (Division,Sub_Category,MarketSKU, Product_Code)
--Select Division,Sub_Category,MarketSKU, Product_Code From dbo.mERP_fn_Get_CSProductminrange_PM(@ParamID)


If @ParamType = 6 /* TLC Begins*/
Begin
Begin /* If target defined */
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise_TLC(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
Group By InvoiceID,InvoiceDate,SalesmanID
) T
Group By InvoiceDate
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpInvDateWise_TLC(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And Division In (Select Distinct Product From #TmpFocusItems Where ProLevel = 2)
Group By InvoiceID,InvoiceDate,SalesmanID
) T
Group By InvoiceDate
End
Else If @Level = 3
Begin
Insert Into #tmpInvDateWise_TLC(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And SubCategory In (Select Distinct Product From #TmpFocusItems Where ProLevel = 3)
Group By InvoiceID,InvoiceDate,SalesmanID
) T
Group By InvoiceDate
End
Else If @Level = 4
Begin
Insert Into #tmpInvDateWise_TLC(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And MarketSKU In (Select Distinct Product From #TmpFocusItems Where ProLevel = 4)
Group By InvoiceID,InvoiceDate,SalesmanID
) T
Group By InvoiceDate
End
Else If @Level = 5
Begin
Insert Into #tmpInvDateWise_TLC(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime)
Select InvoiceDate,Sum(LinesCut),Max(InvoiceDateWithTime) From
(Select InvoiceID,InvoiceDate,SalesmanID ,Count(Distinct Product_Code) 'LinesCut',
Max(InvoiceDateWithTime) 'InvoiceDateWithTime'
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3)
And Product_Code In (Select Distinct Product From #TmpFocusItems Where ProLevel = 5)
Group By InvoiceID,InvoiceDate,SalesmanID
) T
Group By InvoiceDate
End
End/*End of Focus Param*/

If (Select Count(InvoiceDate) From #tmpInvDateWise_TLC) >= 1
Begin
If @Frequency = 2 /* Monthly */
Begin
Select @Target = isNull(Target,0), @MaxPoints = case When isnull(Target,0) > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_merp_PMOutletAch_TargetDefn
Where ParamID = @ParamID --And FocusID = @FocusID
And Active = 1 --And Target >= 0
And SalesmanID =@SalesmanID
And DSTypeID = @DSTypeID

Select @TillDateActual_TLC = Sum(LinesOrBillsOrBA) From #tmpInvDateWise_TLC
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise_TLC
If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
Select @TodaysActual_TLC = isNull(LinesOrBillsOrBA,0)
From  #tmpInvDateWise_TLC Where InvoiceDate = @FromDate

if Exists (Select ParamID From tbl_merp_PMOutletAch_TargetDefn Where ParamID = @ParamID --And FocusID = @FocusID
And Active = 1 And SalesmanID =@SalesmanID And isnull(Target,0) > 0)
Begin
Select @TotalPercentge_TLC  = case When isnull(@Target,0) = 0 then 0 Else (@TillDateActual_TLC /Cast(@Target as Decimal(18,6))*100)  end
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_TLC Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--Select @TillDatePointsEarned = Cast(@SLAB_VALUE as Decimal(18,6))
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints
End
Else
Begin
Select @TotalPercentge_TLC  = @TillDateActual_TLC
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_TLC Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = 0
--Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints
End
IF @ReportType = 'Monthly'
UpDate #tmpPM_TLC Set TillDateActual = @TillDateActual_TLC,
TillDatePointsEarned = (Case @DayClosed_TLCNOA When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual_TLC as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM_TLC Set TillDateActual = @TillDateActual_TLC,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual_TLC,PointsEarnedToday=0,
AverageTillDate = Cast(@TillDateActual_TLC as decimal(18,6))/@NoOfDaysInvoiced ,
Target = @Target ,MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */
Else If @Frequency = 1 /* Daily Frequency Begins */
Begin
Select @Target = isNull(Target,0), @MaxPoints = isNull(MaxPoints,0) From tbl_merp_PMOutletAch_TargetDefn
Where ParamID = @ParamID
--And FocusID = @FocusID
And Active = 1 --And Target >= 0
And SalesmanID =@SalesmanID
And DSTypeID = @DSTypeID

/* Update SalesPercentage */
if @Target > 0
Update #tmpInvDateWise_TLC Set SalesPercentage = LinesOrBillsOrBA/Cast(@Target as Decimal(18,6)) * 100
ELSE
Update #tmpInvDateWise_TLC Set SalesPercentage = LinesOrBillsOrBA
UpDate   Inv Set Inv.SlabID = isNull(Slab.SLABID,0),
Inv.Slab_Every = isNull(Slab.SLAB_EVERY_QTY,0),
Inv.Slab_Value = isNull(Slab.SLAB_VALUE,0)
From  #tmpInvDateWise_TLC Inv,tbl_mERP_PMParamSlab Slab
Where
Slab.ParamID = @ParamID And Slab.SLAB_GIVEN_AS = 2
And SalesPercentage Between Slab.SLAB_START And Slab.SLAB_END

Update #tmpInvDateWise_TLC Set PointsEarned = (@MaxPoints * Cast(Slab_Value as Decimal(18,6)))/100 Where SlabID > 0

/* When PointsEarned is greater than the MaxPoints Then show the
MaxPoints as the PointsEarned */
--							Update #tmpInvDateWise Set PointsEarned = @MaxPoints
--							Where isNull(PointsEarned,0) > @MaxPoints
--							And SlabID > 0

Update #tmpInvDateWise_TLC Set PointsEarned = 0 Where isNull(SlabID,0) = 0

Select @TillDateActual_TLC = Sum(LinesOrBillsOrBA),@TillDatePointsEarned = Sum(PointsEarned) From #tmpInvDateWise_TLC
Select @TodaysActual_TLC = isNull(LinesOrBillsOrBA,0),@TodaysPointsEarned = isNull(PointsEarned,0)
From  #tmpInvDateWise_TLC Where dbo.StripTimeFromDate(InvoiceDate) = dbo.StripTimeFromDate(@FromDate)
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise_TLC

IF @ReportType = 'Monthly'
UpDate #tmpPM_TLC Set TillDateActual = @TillDateActual_TLC,
TillDatePointsEarned = (Case @DayClosed_TLCNOA When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
AverageTillDate = Cast(@TillDateActual_TLC as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM_TLC Set TillDateActual = @TillDateActual_TLC,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual_TLC,
PointsEarnedToday=(Case @DayClosed_TLCNOA When 0 Then 0 Else @ToDaysPointsEarned End),
AverageTillDate = Cast(@TillDateActual_TLC as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
MaxPoints = @MaxPoints,
GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End /* Daily Frequency Ends */
End /* DateWise InvoiceDetails */
End /*End Of target Defined*/
End /* TLC Ends*/
Fetch next From Cur_Counter_TLC into @Counter
--Set @Counter = @Counter + 1
End /* End of While */
Close Cur_Counter_TLC
Deallocate Cur_Counter_TLC

Insert Into #TmpPM(PMID ,SalesmanID,Salesman_Name ,DSTypeID,	DSTypeCode ,DSType ,PMCode ,PMDescription ,CGGroups ,
ParameterType ,Frequency ,ParamID ,Prod_Level ,	isFocusParam ,	FocusID ,DS_MaxPoints ,
Param_MaxPoints,TillDateActual ,NoOfDaysInvoiced ,AverageTillDate ,	Target ,MaxPoints ,
TillDatePointsEarned ,	ToDaysActual ,PointsEarnedToday )
Select PMID ,SalesmanID,Salesman_Name ,DSTypeID,	DSTypeCode ,DSType ,PMCode ,PMDescription ,CGGroups ,
ParameterType ,Frequency ,ParamID ,Prod_Level ,	isFocusParam ,	FocusID ,DS_MaxPoints ,
Param_MaxPoints,TillDateActual ,NoOfDaysInvoiced ,AverageTillDate ,	Target ,MaxPoints ,
TillDatePointsEarned ,	ToDaysActual ,PointsEarnedToday
From #tmpPM_TLC

/* End: Total Lines Cut */


/* Start: NOA */

Create Table #tmpPM_NOA(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime)

Create Table #tmpPM1_NOA(RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--CGGroups_Display nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTrAndate Datetime)

Create Table #tmpInvDateWise_NOA(InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
PointsEarned Decimal(18,6),OutletID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create table #DSPMSalesman_NOA (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
Insert into #DSPMSalesman_NOA (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 From tbl_merp_NOA_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
where PMM.PMID in (Select PMID From tbl_mERP_PMMaster Where Period =@Period )
And PMM.Active = 1 And PMM.PMDSTypeid = DST.DSTypeid
And PMM.Salesmanid = S.Salesmanid
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

Create Table #tmpOutletAchieve(OutletID nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, TargetAmt Decimal(18,6),
AchieveAmt_Till Decimal(18,6), AchieveAmt_Today Decimal(18,6), Count_AchTill int, Count_AchToday int)

If @OCG=1
BEGIN
Insert into #DSPMSalesman_NOA (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_NOA_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And isnull(TDF.NOACount,0) > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
BEGIN
Insert into #DSPMSalesman_NOA (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman
From DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_NOA_TargetDefn TDF,
(Select PMID From tbl_mERP_PMMaster Where Period =@Period ) T Where
T.PMID = PMDS.PMID
And  PMDS.DsType = DT.DSTypeValue
And DT.DSTYPEID = D.DSTYPEID
And S.SalesManid = D.SalesManid  And DT.DSTypectlpos =1
And TDF.PMID = T.PMID
And isnull(TDF.NOACount,0) > 0
And TDF.Active = 1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END


If @OCG=1
BEGIN
Insert into #DSPMSalesman_NOA (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman_NOA) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)

END
ELSE
Begin
Insert into #DSPMSalesman_NOA (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 From #tmpInvoice I, DSType_Master DT, Salesman S
Where I.SalesManid not in (Select Distinct SalesManid From #DSPMSalesman_NOA) And Amount > 0
And DT.DSTYPEID = I.DSTYPEID
And I.SalesManid = S.SalesManid
And DT.DSTypectlpos =1
And S.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
END

/* For OCG*/
If @OCG=0
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman_NOA T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End
Else
Begin
Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman_NOA T1, (Select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1) T
Where T1.Salesmanid = T.Salesmanid
End

update #DSPMSalesman_NOA set TargetStatus = 1 where Salesmanid in (Select Distinct Salesmanid From tbl_merp_NOA_TargetDefn where isnull(NOACount,0) > 0 And Active = 1
And PMId in (Select Distinct PMID From tbl_mERP_PMMaster Where Period =@Period))
update #DSPMSalesman_NOA set SalesStatus = 1 where Salesmanid in (Select Distinct Salesmanid From #tmpInvoice Where Salesmanid not in (Select Salesmanid From #DSPMSalesman_NOA Where TargetStatus = 1))
Update #DSPMSalesman_NOA set DSTypeValue = CurrentdsType
Update #DSPMSalesman_NOA set SalesStatus = 1 Where DSTypeValue = CurrentdsType And TargetStatus = 1

IF @OCG=0
Begin
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)
End
ELSE
BEGIN
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
--ParamFocus.FocusID,
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID
And SM.Salesman_Name In(Select Salesman From #tmpSalesman)
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)
END
/*If there is no sales for a salesman, then if that salesman alone is Selected then, report is generating blank
but if all salesman is Selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that
particular salesman is Selected*/
If @OCG=0
Begin
Insert Into #tmpPM_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param, tbl_merp_NOA_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman_NOA) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And isnull(PMTar.NOACount,0) > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm_NOA)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)

END
ELSE
BEGIN
Insert Into #tmpPM_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_NOA_TargetDefn PMTar,
tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct PMID,Salesmanid,DSTypeValue From #DSPMSalesman_NOA) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.SalesmanID = PMTar.SalesmanID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And isnull(PMTar.NOACount,0) > 0
And isnull(PMTar.Active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPm_NOA)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)
END
If @OCG=0
Begin
Insert Into #tmpPM1_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman_NOA Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman_NOA)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)
END
ELSE
BEGIN
Insert Into #tmpPM1_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice) DSDet
,(Select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue From #DSPMSalesman_NOA Where SalesStatus = 1) TMPDS
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And SM.Salesman_Name  = TMPDS.Salesman_Name
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman_NOA)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(7)
END

Declare @tmpPMID_NOA int, @tmpDSID_NOA int, @DSTYPEValue_NOA Nvarchar(255)
Declare Cur_PM1_NOA Cursor For
Select PMID,SalesManID,DSType From #tmpPM1_NOA
Open Cur_PM1_NOA
Fetch next From Cur_PM1_NOA Into @tmpPMID_NOA,@tmpDSID_NOA,@DSTYPEValue_NOA
While @@Fetch_Status = 0
Begin
If not exists (Select * From #tmpPM_NOA where PMID=@tmpPMID_NOA And Salesmanid = @tmpDSID_NOA And DSType = @DSTYPEValue_NOA)
Begin
insert into #tmpPM_NOA(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
Select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints From #tmpPM1_NOA where PMID=@tmpPMID_NOA And Salesmanid = @tmpDSID_NOA And DSTYPE = @DSTYPEValue_NOA
end
Fetch next From Cur_PM1_NOA into @tmpPMID_NOA,@tmpDSID_NOA ,@DSTYPEValue_NOA
End
Close Cur_PM1_NOA
Deallocate Cur_PM1_NOA


Declare @TodaysActual_NOA Decimal(18,6), @TillDateActual_NOA Decimal(18,6)
Declare @TotalPercentge_NOA Decimal(18,6), @Count_Ach_Today int, @TotalPercentge_Today Decimal(18,6)
Declare @Target_NOA Decimal(18,6) , @OutletID nVarchar(30), @Count_Ach int, @AchieveAmt Decimal(18,6), @OID nvarchar(30)

Declare Cur_Counter_NOA Cursor For
Select Rowid From #tmpPM_NOA
Open Cur_Counter_NOA
Fetch next From Cur_Counter_NOA Into @Counter
While @@Fetch_Status = 0
Begin

Delete From #tmpInvDateWise_NOA
--Delete From #tmpMinQtyInvItems

Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,
@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
@TodaysActualSales = 0,@DSTypeID=0, @TillDateActual_NOA = 0, @TodaysActual_NOA = 0, @TotalPercentge_NOA = 0, @AchieveAmt = 0

Select @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode From #tmpPM_NOA Where RowID = @Counter

Truncate Table #TmpFocusItems
Insert Into #TmpFocusItems (Product, ProLevel,Min_Qty,UOM)
Select Distinct ProdCat_Code,ProdCat_Level,Isnull(Min_Qty,0),Isnull(UOM,0) From tbl_mERP_PMParamFocus Where --PmProductName = Case when @isFocusParam ='Overall' Then 'ALL' else @isFocusParam end And
ParamID =  @ParamID

--Insert into #tmpMinQtyInvItems (Division,Sub_Category,MarketSKU, Product_Code)
--Select Division,Sub_Category,MarketSKU, Product_Code From dbo.mERP_fn_Get_CSProductminrange_PM(@ParamID)


If @ParamType = 7 /* NOA Begins*/
Begin
Begin /* If target defined */
If @isFocusParam = 'OverAll'
Begin
Insert Into #tmpInvDateWise_NOA(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime,OutletID)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime),OutletID
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
Group By InvoiceDate,OutletID
End
Else
Begin /*Focus Param*/
If @Level = 2
Begin
Insert Into #tmpInvDateWise_NOA(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime,OutletID)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime),OutletID
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And Division In (Select Distinct Product From #TmpFocusItems Where ProLevel = 2)
Group By InvoiceDate,OutletID

End
Else If @Level = 3
Begin
Insert Into #tmpInvDateWise_NOA(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime,OutletID)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime),OutletID
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And SubCategory In (Select Distinct Product From #TmpFocusItems Where ProLevel = 3)
Group By InvoiceDate,OutletID
End
Else If @Level = 4
Begin
Insert Into #tmpInvDateWise_NOA(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime,OutletID)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime),OutletID
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And MarketSKU In (Select Distinct Product From #TmpFocusItems Where ProLevel = 4)
Group By InvoiceDate,OutletID
End
Else If @Level = 5
Begin
Insert Into #tmpInvDateWise_NOA(InvoiceDate,LinesOrBillsOrBA,InvoiceDateWithTime,OutletID)
Select InvoiceDate,Sum(Case InvoiceType When 1 Then Amount When 3 Then Amount When 4 Then (-1) * Amount End),
Max(InvoiceDateWithTime),OutletID
From #tmpInvoice
Where SalesmanID = @SalesmanID
And DSTypeID = @DSTypeID
And CategoryGroup In(Select * From dbo.sp_splitIn2rows(@CGGroups,','))
And InvoiceType In(1,3,4)
And Product_Code In (Select Distinct Product From #TmpFocusItems Where ProLevel = 5)
Group By InvoiceDate,OutletID
End
End/*End of Focus Param*/

If (Select Count(InvoiceDate) From #tmpInvDateWise_NOA) >= 1
Begin
If @Frequency = 2 /* Monthly */
Begin
Select @Target = isNull(NOACount,0), @MaxPoints = case When isnull(NOACount,0) > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_merp_NOA_TargetDefn
Where ParamID = @ParamID And Active = 1	And SalesmanID =@SalesmanID And DSTypeID = @DSTypeID

Select @Count_Ach = 0, @AchieveAmt = 0, @OID = '', @Count_Ach_Today = 0, @TotalPercentge_Today = 0

/* To find Till Date and today Actual achievement count */
Truncate Table #tmpOutletAchieve
Insert Into #tmpOutletAchieve(OutletID, TargetAmt)
Select OutletID, Sum(isNull(Target,0)) From tbl_merp_NOA_TargetDefn_Detail Where TargetDefnID
in(Select TargetDefnID From tbl_merp_NOA_TargetDefn Where ParamID = @ParamID
And Active = 1 And SalesmanID =@SalesmanID And DSTypeID = @DSTypeID)
Group By OutletID

Update #tmpOutletAchieve Set Count_AchTill = 0, Count_AchToday = 0

Update T Set T.AchieveAmt_Till = T1.AchAmt
From #tmpOutletAchieve T,  (Select Sum(LinesOrBillsOrBA) as AchAmt, OutletID From #tmpInvDateWise_NOA Group By OutletID) T1
Where
T.OutletID = T1.OutletID

Update #tmpOutletAchieve Set Count_AchTill = 1 Where isnull(TargetAmt,0) > 0 and isnull(AchieveAmt_Till,0) >= isnull(TargetAmt,0)


Update T Set T.AchieveAmt_Today = T1.AchAmt
From #tmpOutletAchieve T,  (Select Sum(LinesOrBillsOrBA) as AchAmt, OutletID From #tmpInvDateWise_NOA Where InvoiceDate = @FromDate  Group By OutletID) T1
Where
T.OutletID = T1.OutletID

Update #tmpOutletAchieve Set Count_AchToday = 1 Where isnull(TargetAmt,0) > 0 and isnull(AchieveAmt_Today,0) >= isnull(TargetAmt,0)

--Select @TillDateActual_NOA = @Count_Ach
Select @TillDateActual_NOA = Count(Count_AchTill) From #tmpOutletAchieve Where Count_AchTill > 0
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise_NOA
If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
--Select @TodaysActual_NOA =@Count_Ach_Today
Select @TodaysActual_NOA = Count(Count_AchToday) From #tmpOutletAchieve Where Count_AchToday > 0

if Exists (Select ParamID From tbl_merp_NOA_TargetDefn Where ParamID = @ParamID
And Active = 1 And SalesmanID =@SalesmanID And isnull(NOACount,0) > 0)
Begin

Select @TotalPercentge_NOA  = case When isnull(@Target,0) = 0 then 0 Else (@TillDateActual_NOA /Cast(@Target as Decimal(18,6))*100)  end
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_NOA Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = Cast(@SLAB_VALUE as Decimal(18,6))                          -- @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100

End
Else
Begin
Select @TotalPercentge_NOA  = @TillDateActual_NOA
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_NOA Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = 0
--Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints
End
IF @ReportType = 'Monthly'
UpDate #tmpPM_NOA Set TillDateActual = @TillDateActual_NOA,
TillDatePointsEarned = (Case @DayClosed_TLCNOA When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
--AverageTillDate = Cast(@TillDateActual_NOA as decimal(18,6))/@NoOfDaysInvoiced ,
AverageTillDate = 0,
Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM_NOA Set TillDateActual = @TillDateActual_NOA,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
TodaysActual = @TodaysActual_NOA,PointsEarnedToday=0,
--AverageTillDate = Cast(@TillDateActual_NOA as decimal(18,6))/@NoOfDaysInvoiced ,
AverageTillDate = 0,
Target = @Target ,MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
End /* End Of Monthly Frequency */

Else If @Frequency = 1 /* Daily Frequency Begins */
Begin
Select @Target = isNull(NOACount,0), @MaxPoints = isNull(MaxPoints,0) From tbl_merp_NOA_TargetDefn
Where ParamID = @ParamID
--And FocusID = @FocusID
And Active = 1 --And Target >= 0
And SalesmanID =@SalesmanID
And DSTypeID = @DSTypeID

Select @Count_Ach = 0, @AchieveAmt = 0, @OID = '', @Count_Ach_Today = 0, @TotalPercentge_Today = 0
/* To find Till Date and today Actual achievement count */
Truncate Table #tmpOutletAchieve
Insert Into #tmpOutletAchieve(OutletID, TargetAmt)
Select OutletID, Sum(isNull(Target,0)) From tbl_merp_NOA_TargetDefn_Detail Where TargetDefnID
in(Select TargetDefnID From tbl_merp_NOA_TargetDefn Where ParamID = @ParamID
And Active = 1 And SalesmanID =@SalesmanID And DSTypeID = @DSTypeID)
Group By OutletID

Update #tmpOutletAchieve Set Count_AchTill = 0, Count_AchToday = 0

Update T Set T.AchieveAmt_Till = T1.AchAmt
From #tmpOutletAchieve T,  (Select Sum(LinesOrBillsOrBA) as AchAmt, OutletID From #tmpInvDateWise_NOA Group By OutletID) T1
Where
T.OutletID = T1.OutletID

Update #tmpOutletAchieve Set Count_AchTill = 1 Where isnull(TargetAmt,0) > 0 and isnull(AchieveAmt_Till,0) >= isnull(TargetAmt,0)


Update T Set T.AchieveAmt_Today = T1.AchAmt
From #tmpOutletAchieve T,  (Select Sum(LinesOrBillsOrBA) as AchAmt, OutletID From #tmpInvDateWise_NOA Where InvoiceDate = @FromDate  Group By OutletID) T1
Where
T.OutletID = T1.OutletID

Update #tmpOutletAchieve Set Count_AchToday = 1 Where isnull(TargetAmt,0) > 0 and isnull(AchieveAmt_Today,0) >= isnull(TargetAmt,0)


--Select @TillDateActual_NOA = @Count_Ach
Select @TillDateActual_NOA = Count(Count_AchTill) From #tmpOutletAchieve Where Count_AchTill > 0
Select @NoOfDaysInvoiced = Count(Distinct InvoiceDate) From #tmpInvDateWise_NOA
If @NoOfDaysInvoiced = 0 Set @NoOfDaysInvoiced = 1
--Select @TodaysActual_NOA = @Count_Ach_Today
Select @TodaysActual_NOA = Count(Count_AchToday) From #tmpOutletAchieve Where Count_AchToday > 0
/* To find Till Date and today Actual achievement count */

if Exists (Select ParamID From tbl_merp_NOA_TargetDefn Where ParamID = @ParamID
And Active = 1 And SalesmanID =@SalesmanID And isnull(NOACount,0) > 0)
Begin
Select @TotalPercentge_NOA  = case When isnull(@Target,0) = 0 then 0 Else (@TillDateActual_NOA /Cast(@Target as Decimal(18,6))*100)  end
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_NOA Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = Cast(@SLAB_VALUE as Decimal(18,6))

Select @TotalPercentge_Today  = case When isnull(@Target,0) = 0 then 0 Else (@TodaysActual_NOA /Cast(@Target as Decimal(18,6))*100)  end
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_Today Between SLAB_START And SLAB_END
Select @ToDaysPointsEarned = Cast(@SLAB_VALUE as Decimal(18,6))

End
Else
Begin
Select @TotalPercentge_NOA  = @TillDateActual_NOA
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @TotalPercentge_NOA Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = 0, @ToDaysPointsEarned = 0
--Select @TillDatePointsEarned = @MaxPoints * Cast(@SLAB_VALUE as Decimal(18,6))/100
--If @TillDatePointsEarned > @MaxPoints
--	Select @TillDatePointsEarned = @MaxPoints
End

IF @ReportType = 'Monthly'
UpDate #tmpPM_NOA Set TillDateActual = @TillDateActual_NOA,
TillDatePointsEarned = (Case @DayClosed_TLCNOA When 0 Then 0 Else @TillDatePointsEarned End),
NoOfDaysInvoiced = @NoOfDaysInvoiced,
--AverageTillDate = Cast(@TillDateActual_NOA as decimal(18,6))/@NoOfDaysInvoiced ,
AverageTillDate = 0,
Target = @Target ,
MaxPoints = @MaxPoints,GenerationDate = @RptGenerationDate,
LastTrAndate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM_NOA Set TillDateActual = @TillDateActual_NOA,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual_NOA,
PointsEarnedToday=(Case @DayClosed_TLCNOA When 0 Then 0 Else @ToDaysPointsEarned End),
--AverageTillDate = Cast(@TillDateActual_NOA as decimal(18,6))/@NoOfDaysInvoiced , Target = @Target ,
AverageTillDate = 0,
MaxPoints = @MaxPoints,
GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate
Where RowID = @Counter

End /* Daily Frequency Ends */

End /* DateWise InvoiceDetails */
End /*End Of target Defined*/
End /* NOA Ends*/
Fetch next From Cur_Counter_NOA into @Counter
--Set @Counter = @Counter + 1
End /* End of While */
Close Cur_Counter_NOA
Deallocate Cur_Counter_NOA

Insert Into #TmpPM(PMID ,SalesmanID,Salesman_Name ,DSTypeID,	DSTypeCode ,DSType ,PMCode ,PMDescription ,CGGroups ,
ParameterType ,Frequency ,ParamID ,Prod_Level ,	isFocusParam ,	FocusID ,DS_MaxPoints ,
Param_MaxPoints,TillDateActual ,NoOfDaysInvoiced ,AverageTillDate ,	Target ,MaxPoints ,
TillDatePointsEarned ,	ToDaysActual ,PointsEarnedToday )
Select PMID ,SalesmanID,Salesman_Name ,DSTypeID,	DSTypeCode ,DSType ,PMCode ,PMDescription ,CGGroups ,
ParameterType ,Frequency ,ParamID ,Prod_Level ,	isFocusParam ,	FocusID ,DS_MaxPoints ,
Param_MaxPoints,TillDateActual ,NoOfDaysInvoiced ,AverageTillDate ,	Target ,MaxPoints ,
TillDatePointsEarned ,	ToDaysActual ,PointsEarnedToday
From #tmpPM_NOA

/* End: NOA */


/*To Insert DSType And Param info From PMetric_TargetDefn table for Salesman having Target with nil Invoices*/
Create table #tDSTgtZeroInv (TGT_PMID Int, TGT_DSTYPEID Int, TGT_PARAMID Int, TGT_SMID int, TGT_TARGETVAL Decimal(18,6), TGT_MAXPOINT Decimal(18,6),
TGT_FREQUENCY Int, TGT_ISFOCUSPARAM nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS, TGT_PARAMMAX Decimal(18,6), TGT_PARAMTYPE Int)
Declare @TGTPMID Int, @TGTDSTYPEID Int, @TGTPARAMID Int
Declare Cur_TgtPMLst Cursor For
Select Distinct PMID, PMDSTYPEID, PARAMID From tbl_merp_PMetric_TargetDefn where Active = 1 And PMID in (Select Distinct PMID From #tmpPM)
Open Cur_TgtPMLst
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
While @@Fetch_Status = 0
Begin
Insert into #tDSTgtZeroInv(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX)
Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.TARGET, Tdf.MAXPOINTS, PMP.FREQUENCY,
(PMFocus.PMProductName),PMP.ParameterType, PMP.MaxPoints
From tbl_merp_PMetric_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus
Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID
And Tdf.SALESMANID not in (Select Distinct SalesmanID From #tmpPM Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(AverageTillDate,0) <> 0)
And PMP.ParamID = Tdf.ParamID
And PMP.ParamID = PMFocus.ParamID
--As per ITC request, only Selected salesman details should be displayed in the report
And Tdf.SALESMANID in (Select salesmanid From salesman where salesman_name in(Select Salesman From #tmpSalesman))
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
End
Close Cur_TgtPMLst
Deallocate Cur_TgtPMLst


Declare Cur_TgtPMLst Cursor For
Select Distinct PMID, PMDSTYPEID, PARAMID From tbl_merp_PMOutletAch_TargetDefn where Active = 1 And PMID in (Select Distinct PMID From #tmpPM)
Open Cur_TgtPMLst
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
While @@Fetch_Status = 0
Begin
Insert into #tDSTgtZeroInv(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX)
Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.TARGET, Tdf.MAXPOINTS, PMP.FREQUENCY,
(PMFocus.PMProductName),PMP.ParameterType, PMP.MaxPoints
From tbl_merp_PMOutletAch_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus
Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID
And Tdf.SALESMANID not in (Select Distinct SalesmanID From #tmpPM Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(AverageTillDate,0) <> 0)
And PMP.ParamID = Tdf.ParamID
And PMP.ParamID = PMFocus.ParamID
--As per ITC request, only Selected salesman details should be displayed in the report
And Tdf.SALESMANID in (Select salesmanid From salesman where salesman_name in(Select Salesman From #tmpSalesman))
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
End
Close Cur_TgtPMLst
Deallocate Cur_TgtPMLst

Declare Cur_TgtPMLst Cursor For
Select Distinct PMID, PMDSTYPEID, PARAMID From tbl_merp_NOA_TargetDefn where Active = 1 And PMID in (Select Distinct PMID From #tmpPM)
Open Cur_TgtPMLst
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
While @@Fetch_Status = 0
Begin
Insert into #tDSTgtZeroInv(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX)
Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.NOACount, Tdf.MAXPOINTS, PMP.FREQUENCY,
(PMFocus.PMProductName),PMP.ParameterType, PMP.MaxPoints
From tbl_merp_NOA_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus
Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID
And Tdf.SALESMANID not in (Select Distinct SalesmanID From #tmpPM Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(TillDateActual,0) <> 0)
And PMP.ParamID = Tdf.ParamID
And PMP.ParamID = PMFocus.ParamID
--As per ITC request, only Selected salesman details should be displayed in the report
And Tdf.SALESMANID in (Select salesmanid From salesman where salesman_name in(Select Salesman From #tmpSalesman))
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
End
Close Cur_TgtPMLst
Deallocate Cur_TgtPMLst

--	Select Distinct PMID,DSTypeID,Salesman_Name From #tmpPM

Update #tmpPM Set GenerationDate = @RptGenerationDate,LastTrAndate = @LastInvoiceDate

Insert Into #tmpDistinctPMDS(PMID,DSTypeID,SalesmanName)
Select Distinct PMID,DSTypeID,Salesman_Name From #tmpPM
Union
/*Fetch Non existing PM And DS information*/
--As per QC Team analysis, DS Type filter is not working in the report. It is fixed.
Select Distinct TGT_PMID,TGT_DSTYPEID, SM.Salesman_Name From #tDSTgtZeroInv tDST, Salesman SM,
tbl_mERP_PMDSType PMDST
Where SM.SalesManID = tDST.TGT_SMID
And PMDST.PMID = tDST.TGT_PMID
And PMDST.DSTypeID=tDST.TGT_DSTYPEID
And PMDST.DSType in (Select DStype From #tmpDStype)

Update #tmpPM Set GenerationDate = @RptGenerationDate


/* GGDR Process Start :*/
If @ReportType = 'Monthly'
Begin
Create Table #TmpGGDRDSData (
DSID Int,
DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

CREATE TABLE #TmpGGDRAbstract(
[DetailID] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS ID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS Type] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Beat] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Target] [decimal](18, 6) NULL Default 0,
[TargetUOM] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cat GRP] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OCG] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Actual] [decimal](18, 6) NULL Default 0,
[Current Status] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Day Close Date] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare @RedOBJData as Table (DSID Int,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @GreenOBJData as Table (DSID Int,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #TmpGGDRDSPointsData (
Paramid Int,
DSID Int,
DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Parameter Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
TillDateActual Decimal(18,6),
SlabFrom Decimal(18,6),
SlabTo Decimal(18,6),
ForEvery Decimal(18,6),
PointValue Decimal(18,6))

Declare @GGDRDSName as Nvarchar(255)
Declare @GGDRDSNameList as Nvarchar(4000)
Declare @Char as Nvarchar(5)
Set @Char = Char(15)
Insert Into #TmpGGDRDSData
Select Distinct SalesManID,Salesman_Name,DSType,CGGroups From #tmpPM Where Isnull(ParameterType,0) In (4,5)

Declare Cur_GGDRDS Cursor for
Select Distinct DSName From #TmpGGDRDSData
Open Cur_GGDRDS
Fetch From Cur_GGDRDS into @GGDRDSName
While @@fetch_status =0
Begin
If Isnull(@GGDRDSNameList,'') <> ''
Begin
Set @GGDRDSNameList = @GGDRDSNameList + cast(@Char as Nvarchar) + Cast(@GGDRDSName as Nvarchar(255))
End
Else
Begin
Set @GGDRDSNameList = Cast(@GGDRDSName as Nvarchar(255))
End

Fetch Next From Cur_GGDRDS into @GGDRDSName
End
Close Cur_GGDRDS
Deallocate Cur_GGDRDS

Truncate Table #TmpGGDRAbstract
Insert Into #TmpGGDRAbstract ([DetailID],[Month],[CustomerID],[Customer Name],[DS ID],[DS Name],[DS Type],[Beat],[Status],[Target],[TargetUOM],[Cat GRP],[OCG],[Actual],[Current Status],[Last Day Close Date])
Exec mERP_spr_TargetsforGGDRAbstract @DateOrMonth,'%',@GGDRDSNameList,'%'

Delete From #TmpGGDRAbstract Where [Status] = [Current Status]

Insert Into @RedOBJData
Select Distinct [DS ID],[DS Type],(Case When Isnull(@OCG,0) = 0 Then [Cat GrP] Else Left(OCG,3) End),[CustomerID] From #TmpGGDRAbstract Where [Status] = 'Red'

Insert Into @GreenOBJData
Select Distinct [DS ID],[DS Type],(Case When Isnull(@OCG,0) = 0 Then [Cat GrP] Else left(OCG,3) End),[CustomerID] From #TmpGGDRAbstract Where [Status] = 'Eligible for Green'

update Red set Red.CategoryGroup = Case When Red.CategoryGroup = 'GR3' Then 'GR1' Else Red.CategoryGroup End from @RedOBJData Red

Update T Set T.TilldateActual = T1.Cnt
From #tmpPM T, (Select DSID,DSType,CategoryGroup,Count(Distinct CustomerID) Cnt From @RedOBJData Group By DSID,DSType,CategoryGroup) T1
Where T.SalesManID = T1.DSID
And T.DSType = T1.DSType
And T.CGGroups like  '%' + T1.CategoryGroup + '%'
And Isnull(T.ParameterType,0) = 5

update Green set Green.CategoryGroup = Case When Green.CategoryGroup = 'GR3' Then 'GR1' Else Green.CategoryGroup End from @GreenOBJData Green

Update T Set T.TilldateActual = T1.Cnt
From #tmpPM T, (Select DSID,DSType,CategoryGroup,Count(Distinct CustomerID) Cnt From @GreenOBJData Group By DSID,DSType,CategoryGroup) T1
Where T.SalesManID = T1.DSID
And T.DSType = T1.DSType
And T.CGGroups like  '%' + T1.CategoryGroup + '%'
And Isnull(T.ParameterType,0) = 4

/* Points Calculation Start: */
If @DaycloseDate  >= DateAdd(d,-1,DateAdd(m,1,Cast(('01/' + cast(@DateOrMonth as nvarchar)) as dateTime)))
Begin
Insert Into #TmpGGDRDSPointsData (ParamID,DSID,DSname,DSType,Parameter,TilldateActual)
Select ParamID,SalesManID,SalesMan_name,DSType,Isnull(ParameterType,0),TilldateActual From #tmpPM Where Isnull(ParameterType,0) In (4,5) And Isnull(TilldateActual ,0) > 0

Declare @GGDRParamID as Int
Declare @GGDRTilldateActual as Decimal(18,6)

Declare Cur_GGDRPoints Cursor for
Select ParamID,TilldateActual From #TmpGGDRDSPointsData
Open Cur_GGDRPoints
Fetch From Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
While @@fetch_status =0
Begin
Update T Set T.SlabFrom = T1.Slab_Start,
T.SlabTo = T1.Slab_End,
T.ForEvery = T1.Slab_Every_Qty,
T.PointValue = T1.Slab_Value From #TmpGGDRDSPointsData T,
(Select ParamID,Slab_Start,Slab_End,Slab_Every_Qty,Slab_Value From tbl_mERP_PMParamSlab Where ParamID = @GGDRParamID And @GGDRTilldateActual Between Slab_Start And Slab_End) T1
Where T.paramID = T1.ParamID

Fetch Next From Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
End
Close Cur_GGDRPoints
Deallocate Cur_GGDRPoints

Update T Set T.TillDatePointsEarned = T1.NetPoints From #tmpPM T,
(Select ParamID,DSID,DSname,DSType,Parameter,TilldateActual,
((Cast(TilldateActual/
(Case
When isnull(ForEvery,0) = 0 Then 1
Else isnull(ForEvery,0)
End) as Int)) * PointValue
) NetPoints
From #TmpGGDRDSPointsData) T1
Where T.ParamID = T1.ParamID
And T.SalesmanID = T1.DSID
And T.SalesMan_Name = T1.DSName
And T.DSType = T1.DSType
And Isnull(T.ParameterType,0) = T1.Parameter
And T.TilldateActual = T1.TilldateActual
End
/* Points Calculation End. */

Declare @OCGFlag as int
Declare @TmpGGDRCust as Table (DSID Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
status nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
, CatGrp_Green nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
set @OCGFlag = (Select Top 1 isnull(Flag,0) From tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

Insert Into @TmpGGDRCust
Select Distinct T.SalesManID,T.DSType,B.CustomerId,G.PMCatGroup ,G.OutletStatus
, Case When Isnull(@OCGFlag,0) = 0 Then CatGrouP Else OCG End
From Beat_salesman B,#tmpPM T,GGDROutlet G
Where B.SalesmanId = T.SalesManID And Isnull(T.ParameterType,0) In (4,5)
And isnull(B.CustomerId,'') <> ''
And B.CustomerId = G.OutletID
And Isnull(G.Active,0) = 1
And cast(('01-' + @DateOrMonth) as DateTime) Between cast(('01-' + G.Fromdate) as DateTime) And cast(('01-' + G.Todate) as DateTime)


Create Table #GreenTarget(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #FinalTarget(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Truncate Table #GreenTarget
Insert into #GreenTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
Select DSID,DSType, CustomerId, CatGrp_Green, CategoryGroup From @TmpGGDRCust
Where Status = 'EG'
Group By DSID,DSType,CustomerId, CatGrp_Green, CategoryGroup

Create Table #tmpDSCG(DSID Int, CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into #tmpDSCG(DSID, CategoryGroup)
Select SalesmanID,GroupName from dbo.fn_CG_View_PM()

Insert into #FinalTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
Select a.DSID, a.DSType, a.CustomerID, a.CategoryGroup, a.PMCatGrp From #GreenTarget a, #tmpDSCG b
Where a.DSID = b.DSID and a.CategoryGroup = b.CategoryGroup

Declare @Tar_DSID as Int
Declare @Tar_DSType as Nvarchar(255)
Declare @Tar_CatGroup as Nvarchar(255)

Declare Cur_GGDRtarget Cursor for
Select Distinct SalesManID,DSType,CGGroups From #tmpPM Where Isnull(ParameterType,0) In (4,5)
Open Cur_GGDRtarget
Fetch From Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
While @@fetch_status =0
Begin

Update T Set T.Target = T1.Cnt From #tmpPM T,
(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
Where Status = 'R' And DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = Replace(@Tar_CatGroup,',','|')
Group By DSID,DSType)T1
Where T.SalesmanId = T1.DSID
And T.DSType = T1.DSType
And T.SalesmanId = @Tar_DSID
And T.DSType = @Tar_DSType
And T.CGGroups = @Tar_CatGroup
And Isnull(T.ParameterType,0) = 5

--				Update T Set T.Target = T1.Cnt From #tmpPM T,
--				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
--				Where Status = 'EG' And DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = Replace(@Tar_CatGroup,',','|')
--				Group By DSID,DSType)T1
--				Where T.SalesmanId = T1.DSID
--				And T.DSType = T1.DSType
--				And T.SalesmanId = @Tar_DSID
--				And T.DSType = @Tar_DSType
--				And T.CGGroups = @Tar_CatGroup
--				And Isnull(T.ParameterType,0) = 4

Update T Set T.Target = T1.Cnt From #tmpPM T,
(Select DSID,DSType,Count(Distinct CustomerId) Cnt From #FinalTarget
Where DSId = @Tar_DSID And DStype = @Tar_DSType And PMCatGrp = Replace(@Tar_CatGroup,',','|')
Group By DSID,DSType)T1
Where T.SalesmanId = T1.DSID
And T.DSType = T1.DSType
And T.SalesmanId = @Tar_DSID
And T.DSType = @Tar_DSType
And T.CGGroups = @Tar_CatGroup
And Isnull(T.ParameterType,0) = 4

Fetch Next From Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
End
Close Cur_GGDRtarget
Deallocate Cur_GGDRtarget

Drop Table #TmpGGDRDSData
Drop Table #TmpGGDRAbstract
Drop Table #TmpGGDRDSPointsData
Drop Table #GreenTarget
Drop Table #tmpDSCG
Drop Table #FinalTarget
End
/* GGDR Process End.*/



/* Blockbuster Process Start :*/

If @ReportType = 'Monthly'
Begin
Create Table #TmpGGDRDSData_BL (
DSID Int,
DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

CREATE TABLE #TmpGGDRAbstract_BL(
[DetailID] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Month] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS ID] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS Name] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DS Type] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Beat] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Target] [decimal](18, 6) NULL Default 0,
[TargetUOM] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cat GRP] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OCG] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Actual] [decimal](18, 6) NULL Default 0,
[Current Status] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Day Close Date] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare @RedOBJData_BL as Table (DSID Int,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @GreenOBJData_BL as Table (DSID Int,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #TmpGGDRDSPointsData_BL (
Paramid Int,
DSID Int,
DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Parameter Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
TillDateActual Decimal(18,6),
SlabFrom Decimal(18,6),
SlabTo Decimal(18,6),
ForEvery Decimal(18,6),
PointValue Decimal(18,6), Target Decimal(18,6), Percentage Decimal(18,6))

Declare @GGDRDSName_BL as Nvarchar(255)
Declare @GGDRDSNameList_BL as Nvarchar(4000)
Declare @Char_BL as Nvarchar(5)
Set @Char_BL = Char(15)
Insert Into #TmpGGDRDSData_BL
Select Distinct SalesManID,Salesman_Name,DSType,CGGroups From #tmpPM Where Isnull(ParameterType,0) In (9)

Declare Cur_GGDRDS_BL Cursor for
Select Distinct DSName From #TmpGGDRDSData_BL
Open Cur_GGDRDS_BL
Fetch From Cur_GGDRDS_BL into @GGDRDSName_BL
While @@fetch_status =0
Begin
If Isnull(@GGDRDSNameList_BL,'') <> ''
Begin
Set @GGDRDSNameList_BL = @GGDRDSNameList_BL + cast(@Char_BL as Nvarchar) + Cast(@GGDRDSName_BL as Nvarchar(255))
End
Else
Begin
Set @GGDRDSNameList_BL = Cast(@GGDRDSName_BL as Nvarchar(255))
End

Fetch Next From Cur_GGDRDS_BL into @GGDRDSName_BL
End
Close Cur_GGDRDS_BL
Deallocate Cur_GGDRDS_BL

Truncate Table #TmpGGDRAbstract_BL
Insert Into #TmpGGDRAbstract_BL ([DetailID],[Month],[CustomerID],[Customer Name],[DS ID],[DS Name],[DS Type],[Beat],[Status],[Target],[TargetUOM],[Cat GRP],[OCG],[Actual],[Current Status],[Last Day Close Date])
Exec mERP_spr_TargetsforGGDRAbstract_Blockbuster @DateOrMonth,'%',@GGDRDSNameList_BL,'%'

Delete From #TmpGGDRAbstract_BL Where [Status] = [Current Status]

--		Insert Into @RedOBJData_BL
--		Select Distinct [DS ID],[DS Type],(Case When Isnull(@OCG,0) = 0 Then [Cat GrP] Else Left(OCG,3) End),[CustomerID] From #TmpGGDRAbstract_BL Where [Status] = 'Red'

Insert Into @GreenOBJData_BL
Select Distinct [DS ID],[DS Type],(Case When Isnull(@OCG,0) = 0 Then [Cat GrP] Else left(OCG,3) End),[CustomerID] From #TmpGGDRAbstract_BL Where [Status] = 'Eligible for Green'

--		update Red set Red.CategoryGroup = Case When Red.CategoryGroup = 'GR3' Then 'GR1' Else Red.CategoryGroup End from @RedOBJData_BL Red

--		Update T Set T.TilldateActual = T1.Cnt
--		From #tmpPM T, (Select DSID,DSType,CategoryGroup,Count(Distinct CustomerID) Cnt From @RedOBJData_BL Group By DSID,DSType,CategoryGroup) T1
--		Where T.SalesManID = T1.DSID
--		And T.DSType = T1.DSType
--		And T.CGGroups like  '%' + T1.CategoryGroup + '%'
--		And Isnull(T.ParameterType,0) = 5

update Green set Green.CategoryGroup = Case When Green.CategoryGroup = 'GR3' Then 'GR1' Else Green.CategoryGroup End from @GreenOBJData_BL Green

Update T Set T.TilldateActual = T1.Cnt
From #tmpPM T, (Select DSID,DSType,CategoryGroup,Count(Distinct CustomerID) Cnt From @GreenOBJData_BL Group By DSID,DSType,CategoryGroup) T1
Where T.SalesManID = T1.DSID
And T.DSType = T1.DSType
And T.CGGroups like  '%' + T1.CategoryGroup + '%'
And Isnull(T.ParameterType,0) = 9


Declare @OCGFlag_BL as int
Declare @TmpGGDRCust_BL as Table (DSID Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
status nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
, CatGrp_Green nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
set @OCGFlag_BL = (Select Top 1 isnull(Flag,0) From tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

Insert Into @TmpGGDRCust_BL
Select Distinct T.SalesManID,T.DSType,B.CustomerId,G.PMCatGroup ,G.OutletStatus
, Case When Isnull(@OCGFlag_BL,0) = 0 Then CatGrouP Else OCG End
From Beat_salesman B,#tmpPM T,GGDROutlet G
Where B.SalesmanId = T.SalesManID And Isnull(T.ParameterType,0) In (9)
And isnull(B.CustomerId,'') <> ''
And B.CustomerId = G.OutletID
And Isnull(G.Active,0) = 1
And cast(('01-' + @DateOrMonth) as DateTime) Between cast(('01-' + G.Fromdate) as DateTime) And cast(('01-' + G.Todate) as DateTime)
And isnull(G.Flag,'') <> 'WS'

Create Table #GreenTarget_BL(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #FinalTarget_BL(DSID Int,	DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Truncate Table #GreenTarget_BL
Insert into #GreenTarget_BL(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
Select DSID,DSType, CustomerId, CatGrp_Green, CategoryGroup From @TmpGGDRCust_BL
Where Status = 'EG'
Group By DSID,DSType,CustomerId, CatGrp_Green, CategoryGroup

Create Table #tmpDSCG_BL(DSID Int, CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into #tmpDSCG_BL(DSID, CategoryGroup)
Select SalesmanID,GroupName from dbo.fn_CG_View_PM()

Insert into #FinalTarget_BL(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
Select a.DSID, a.DSType, a.CustomerID, a.CategoryGroup, a.PMCatGrp From #GreenTarget_BL a, #tmpDSCG_BL b
Where a.DSID = b.DSID and a.CategoryGroup = b.CategoryGroup

Declare @Tar_DSID_BL as Int
Declare @Tar_DSType_BL as Nvarchar(255)
Declare @Tar_CatGroup_BL as Nvarchar(255)

Declare Cur_GGDRtarget_BL Cursor for
Select Distinct SalesManID,DSType,CGGroups From #tmpPM Where Isnull(ParameterType,0) In (9)
Open Cur_GGDRtarget_BL
Fetch From Cur_GGDRtarget_BL into @Tar_DSID_BL,@Tar_DSType_BL,@Tar_CatGroup_BL
While @@fetch_status =0
Begin

--				Update T Set T.Target = T1.Cnt From #tmpPM T,
--				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust_BL
--				Where Status = 'R' And DSId = @Tar_DSID_BL And DStype = @Tar_DSType_BL And CategoryGroup = Replace(@Tar_CatGroup_BL,',','|')
--				Group By DSID,DSType)T1
--				Where T.SalesmanId = T1.DSID
--				And T.DSType = T1.DSType
--				And T.SalesmanId = @Tar_DSID_BL
--				And T.DSType = @Tar_DSType_BL
--				And T.CGGroups = @Tar_CatGroup_BL
--				And Isnull(T.ParameterType,0) = 5

Update T Set T.Target = T1.Cnt From #tmpPM T,
(Select DSID,DSType,Count(Distinct CustomerId) Cnt From #FinalTarget_BL
Where DSId = @Tar_DSID_BL And DStype = @Tar_DSType_BL And PMCatGrp = Replace(@Tar_CatGroup_BL,',','|')
Group By DSID,DSType)T1
Where T.SalesmanId = T1.DSID
And T.DSType = T1.DSType
And T.SalesmanId = @Tar_DSID_BL
And T.DSType = @Tar_DSType_BL
And T.CGGroups = @Tar_CatGroup_BL
And Isnull(T.ParameterType,0) = 9

Fetch Next From Cur_GGDRtarget_BL into @Tar_DSID_BL,@Tar_DSType_BL,@Tar_CatGroup_BL
End
Close Cur_GGDRtarget_BL
Deallocate Cur_GGDRtarget_BL

Declare @DSID_BL int
/* Points Calculation Start: */
If @DaycloseDate  >= DateAdd(d,-1,DateAdd(m,1,Cast(('01/' + cast(@DateOrMonth as nvarchar)) as dateTime)))
Begin
Insert Into #TmpGGDRDSPointsData_BL (ParamID,DSID,DSname,DSType,Parameter,TilldateActual, Target, Percentage)
Select ParamID,SalesManID,SalesMan_name,DSType,Isnull(ParameterType,0),TilldateActual, isnull(Target,0),
--(isnull(TilldateActual,0) / isnull(Target,0)) * 100
Case When isnull(Target,0) > 0 Then (isnull(TilldateActual,0) / isnull(Target,0)) * 100 Else 0 End

From #tmpPM Where Isnull(ParameterType,0) In (9) And Isnull(TilldateActual ,0) > 0

Declare @GGDRParamID_BL as Int
Declare @GGDRTilldateActual_BL as Decimal(18,6)
Declare @GGDRPercentage_BL as Decimal(18,6)

Declare Cur_GGDRPoints_BL Cursor for
Select ParamID,TilldateActual,Percentage, DSID From #TmpGGDRDSPointsData_BL
Open Cur_GGDRPoints_BL
Fetch From Cur_GGDRPoints_BL into @GGDRParamID_BL,@GGDRTilldateActual_BL,@GGDRPercentage_BL, @DSID_BL
While @@fetch_status =0
Begin
Update T Set T.SlabFrom = T1.Slab_Start,
T.SlabTo = T1.Slab_End,
T.ForEvery = T1.Slab_Every_Qty,
T.PointValue = T1.Slab_Value From #TmpGGDRDSPointsData_BL T,
(Select ParamID,Slab_Start,Slab_End,Slab_Every_Qty,Slab_Value From tbl_mERP_PMParamSlab
Where ParamID = @GGDRParamID_BL And @GGDRPercentage_BL Between Slab_Start And Slab_End) T1
Where T.paramID = T1.ParamID and T.DSID = @DSID_BL

Fetch Next From Cur_GGDRPoints_BL into @GGDRParamID_BL,@GGDRTilldateActual_BL,@GGDRPercentage_BL, @DSID_BL
End
Close Cur_GGDRPoints_BL
Deallocate Cur_GGDRPoints_BL

Update T Set T.TillDatePointsEarned = T1.NetPoints From #tmpPM T,
(Select ParamID,DSID,DSname,DSType,Parameter,TilldateActual,
((Cast(TilldateActual/
(Case
When isnull(ForEvery,0) = 0 Then 1
Else isnull(ForEvery,0)
End) as Int)) * PointValue
) NetPoints
From #TmpGGDRDSPointsData_BL) T1
Where T.ParamID = T1.ParamID
And T.SalesmanID = T1.DSID
And T.SalesMan_Name = T1.DSName
And T.DSType = T1.DSType
And Isnull(T.ParameterType,0) = T1.Parameter
And T.TilldateActual = T1.TilldateActual
End
/* Points Calculation End. */

Drop Table #TmpGGDRDSData_BL
Drop Table #TmpGGDRAbstract_BL
Drop Table #TmpGGDRDSPointsData_BL
Drop Table #GreenTarget_BL
Drop Table #tmpDSCG_BL
Drop Table #FinalTarget_BL
End

/* Blockbuster Process End.*/

/* Winner SKU Start */

-- To Update CPM_Param to find dependent Param
Update tmp Set tmp.CPM_Param = PMParam.CPM_ParamID From #tmpPM tmp, tbl_merp_PMParam PMParam Where tmp.ParamID = PMParam.ParamID

Declare @Counter_WinnerSKU int
Declare @DSType_WinnerSKU nvarchar(255)
Declare @DependentParam int
Declare @DependentParamID int
Declare @DependentCutoff Decimal(18,6)
Declare @DependentTarget Decimal(18,6)
Declare @DependentActual Decimal(18,6)
Declare @DependentValue Decimal(18,6)
Declare @PointsFlag int

IF @ReportType = 'Monthly'
Begin
Select * Into #TmpGGRRFinal_WinnerSKU From GGRRFinalData
Where Cast('01-' + [Month] as dateTime) = Cast('01-'+ @DateOrMonth as DateTime) and isnull(Flag,'') = 'WS'

IF @OCG=0
Begin
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct DSID, DSType From #TmpGGRRFinal_WinnerSKU) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSType = DSMast.DSTypeValue
And SM.SalesmanID = DSDet.DSID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(13)
End
ELSE
BEGIN
/* Filter the PM based on the report parameter Selected */
Insert Into #tmpPM(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
DS_MaxPoints,Param_MaxPoints)
Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
--ParamFocus.FocusID,
isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDSType DS,
Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus
,(Select Distinct DSID, DSType From #TmpGGRRFinal_WinnerSKU) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DStype.DSType = DS.DStype
And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup)
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSType = DSMast.DSTypeValue
And SM.SalesmanID = DSDet.DSID
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
And Param.ParameterType in(13)
END

Declare Cur_WinnerSKU Cursor For
Select Rowid From #tmpPM Where ParameterType = 13
Open Cur_WinnerSKU
Fetch next From Cur_WinnerSKU Into @Counter_WinnerSKU
While @@Fetch_Status = 0
Begin

Select @TillDateActual=0, @TillDatePointsEarned=0, @SlabID=0, @SLAB_EVERY=0, @SLAB_VALUE=0, @Target=0, @MaxPoints=0, @PointsFlag = 0,
@DependentParam = 0, @DependentParamID = 0, @DependentCutoff = 0, @DependentTarget = 0, @DependentActual = 0, @DependentValue = 0

Select @ParamType = ParameterType, @Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = SalesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode,@DSType_WinnerSKU = DSType
From #tmpPM Where RowID = @Counter_WinnerSKU

If @ParamType = 13
Begin
If @isFocusParam = 'OverAll'
Begin
Select @Target = Count(DSID), @TillDateActual = SUM(Case When D_Actual - D_Target >=0 Then 1 Else 0 End),
@TillDatePointsEarned = Sum(Case When D_Actual - D_Target >=0 Then isnull(Points,0) Else 0 End)
From #TmpGGRRFinal_WinnerSKU Where DSID = @SalesmanID and DsType = @DSType_WinnerSKU and PMCategory = Replace(@CGGroups,',','|')


--				Select  Count(DSID),  SUM(Case When D_Actual - D_Target >=0 Then 1 Else 0 End),
--					 Sum(Case When D_Actual - D_Target >=0 Then isnull(Points,0) Else 0 End)
--				From #TmpGGRRFinal_WinnerSKU Where DSID = @SalesmanID and DsType = @DSType_WinnerSKU and DSID = 8

If @Frequency = 2 /* Monthly */
Begin
Select @DependentParam = Dependent_CPM_ParamID, @DependentCutoff = Dependent_Cutoff
From tbl_merp_PmParam Where ParamID = @ParamID

Select @DependentParamID = ParamID, @DependentTarget = isnull(Target,0), @DependentActual = isnull(TillDateActual,0)
From #tmpPM Where CPM_Param = @DependentParam and DSTypeCode = @DSTypeID and SalesmanID = @SalesmanID and isNull(CGGroups,'') = @CGGroups

IF @DependentTarget > 0 and @DependentCutoff > 0 and @DependentParamID > 0
Begin
Select @DependentValue = (@DependentTarget * @DependentCutoff) / 100
IF @DependentActual < @DependentValue
Set @PointsFlag = 1
End

--Select @DependentTarget, @DependentValue, @DependentActual, @DependentCutoff,  @DependentParamID

IF @ReportType = 'Monthly'
Begin
UpDate #tmpPM Set TillDateActual = @TillDateActual,
TillDatePointsEarned = (Case When @DayClosed_WinnerSKU = 0 Then 0
When @DayClosed_WinnerSKU = 1 and @PointsFlag = 1 Then 0
When @DayClosed_WinnerSKU = 1 and @PointsFlag = 0 Then @TillDatePointsEarned
End),
NoOfDaysInvoiced = 0, AverageTillDate = 0, Target = @Target, MaxPoints = 0,
GenerationDate = @RptGenerationDate, LastTrAndate = @LastInvoiceDate Where RowID = @Counter_WinnerSKU
End
Else If @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActual, TillDatePointsEarned = 0,NoOfDaysInvoiced = 0,
ToDaysActual = 0, PointsEarnedToday=0, AverageTillDate = 0, Target = @Target, MaxPoints = 0,
GenerationDate = @RptGenerationDate, LastTrAndate = @LastInvoiceDate
Where RowID = @Counter_WinnerSKU
End /* End Of Monthly Frequency */
End
End
Fetch next From Cur_WinnerSKU into @Counter_WinnerSKU
End
Close Cur_WinnerSKU
Deallocate Cur_WinnerSKU

--Select * From #tmpPM Where ParameterType=  13

Drop Table #TmpGGRRFinal_WinnerSKU
End
/* Winner SKU End */


--To Update Max Points
Update #tmpPM Set MaxPoints = Param_MaxPoints Where Parametertype in(1, 2, 8, 9, 12, 13)

-- To update TargetParameterType as 0 other then Business Achievement and Gate-UOB
Update #tmpPM Set TargetParameterType = 0 Where ParameterType Not in(3,10)

/* To Add Subtotal And GrAndTotal Row Begins */
Select @PMMaxCount = 0
Declare Cur_Counter2 Cursor For
Select Rowid From #tmpDistinctPMDS order by PMID,SalesmanName
Open Cur_Counter2
Fetch next From Cur_Counter2 Into @Counter
While @@Fetch_Status = 0
Begin

Select @PMID = 0,@PMDSTypeID = 0,@MaxPoints=0,@TillDatePointsEarned=0,@ToDaysPointsEarned=0,@SalesmanName=''
Select @PMID = PMID ,@PMDSTypeID = DSTypeID,@SalesmanName=SalesmanName From #tmpDistinctPMDS Where RowID = @Counter

--		Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
--		@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
--		From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName

IF @ReportType = 'Monthly' and @MonthLastDay_Gate = 1
Begin
IF Exists(Select 'x' From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
and isnull(Flag,0) = 2)
Begin
Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,
@TillDatePointsEarned = 0,	@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
End
Else
Begin
Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,
@TillDatePointsEarned = Sum(isnull(Case ParameterType When 1 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 2 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 8 Then (Case @DayClosed When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 9 Then (Case @DayClosed When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 12 Then (Case @DayClosed_TLCNOA When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else
(Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End) End) End)
When 13 Then (Case @DayClosed_WinnerSKU When 0 Then 0 When 1 Then (Case When isNull(MaxPoints,0) >= isNull(TillDatePointsEarned,0) Then Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) Else Cast(isNull(MaxPoints,0) as Decimal(18,6)) End) End)

Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End,0)),
--,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
End
End
Else
Begin
Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,
@TillDatePointsEarned = Sum(isnull(Case ParameterType When 1 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 2 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 8 Then (Case @DayClosed When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 9 Then (Case @DayClosed When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 12 Then (Case @DayClosed_TLCNOA When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else
(Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End) End) End)

Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End,0)),
--,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
End

-- For Report Order By Process, Here New Temp table(#TempVal) used.

Select Distinct ParamID,@WDCode as 'WDCode' ,@WDDest as 'WDDest',Salesman_Name as 'DSName',DSType  as 'DS Type',
PMCode as 'Performance Metrics Code',PMDescription as 'Description',Replace(CGGroups,',','|') [Category Group],@FromDate [From Date],Convert(nVarchar(10), @ToDate, 103) [To Date],
(Case ParameterType When 1 Then N'Lines Cut' When 2 Then N'Bills Cut' When 3 Then N'Business Achievement'
When 4 Then 'Go Green OBJ' When 5 Then 'Reduce Red OBJ' When 6 Then 'Total Lines Cut'
When 7 Then 'Numeric Outlet Ach' When 8 Then 'Total Bills Cut' When 9 Then 'Blockbuster'
When 10 Then 'Gate-UOB' When 11 Then 'Gate-Days Worked' When 12 Then 'UOB' When 13 Then 'Winner SKU'
When 14 Then 'Depend-Days Worked' End) 'Parameter',
isFocusParam 'Overall or Focus',(Case Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End) 'Frequency',
(Case ParameterType
When 3 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then Cast(isNull(Target,0)/25. as decimal(18,6))
Else Cast(isNull(Target,0) as Decimal(18,6)) End)
When 4 Then Cast(isNull(Target,0) as Decimal(18,6))
When 5 Then Cast(isNull(Target,0) as Decimal(18,6))
When 6 Then Cast(isNull(Target,0) as Decimal(18,6))
When 7 Then Cast(isNull(Target,0) as Decimal(18,6))
--When 8 Then Cast(isNull(Target,0) as Decimal(18,6))
When 9 Then Cast(isNull(Target,0) as Decimal(18,6))
When 10 Then Cast(isNull(Target,0) as Decimal(18,6))
When 11 Then Cast(isNull(Target,0) as Decimal(18,6))
When 13 Then Cast(isNull(Target,0) as Decimal(18,6))
When 14 Then Cast(isNull(Target,0) as Decimal(18,6))
Else NULL End) Target,
Case ParameterType When 6 Then Null When 7 Then Null When 8 Then Null When 9 Then Null Else AverageTillDate End [Average Till Date],
TillDateActual [Till date Actual],
(Case ParameterType When 3 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 6 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 7 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 8 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 9 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 12 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 13 Then Cast(isNull(MaxPoints,0) as Decimal(18,6))
When 1 Then (Case When @ReportType = 'Monthly' Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End)
When 2 Then (Case When @ReportType = 'Monthly' Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End)
Else NULL End) [Max Points],
(Case ParameterType When 3 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 6 Then (Case @DayClosed_TLCNOA When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 7 Then (Case @DayClosed_TLCNOA When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 8 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 9 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
When 1 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 2 Then (Case When @ReportType = 'Monthly' Then (Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)
When 12 Then (Case @DayClosed_TLCNOA When 0 Then 0 When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then 0 Else
(Case When isNull(MaxPoints,0) > 0 and isNull(TillDatePointsEarned,0) > isNull(MaxPoints,0) Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End) End) End)
When 13 Then (Case When isNull(MaxPoints,0) >= isNull(TillDatePointsEarned,0) Then Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) Else Cast(isNull(MaxPoints,0) as Decimal(18,6)) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)[Till Date Points Earned],
--ToDaysActual [Todays Actual],
(Case ParameterType When 6 Then (Case When @ReportType = 'Daily' Then NULL Else ToDaysActual End)
When 7 Then (Case When @ReportType = 'Daily' Then NULL Else ToDaysActual End)
When 8 Then (Case When @ReportType = 'Daily' Then NULL Else ToDaysActual End)
When 9 Then (Case When @ReportType = 'Daily' Then NULL Else ToDaysActual End)
Else ToDaysActual End) [Todays Actual],
(Case ParameterType When 3 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
When 6 Then (Case @DayClosed_TLCNOA When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
When 7 Then (Case @DayClosed_TLCNOA When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
When 8 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
When 9 Then (Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
Else (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End) [Points Earned Today],
Convert(nVarchar(10),GenerationDate,103) + N' ' + Convert(nVarchar(8),GenerationDate,108) [Generation Date],
Convert(nVarchar(10),LastTrAndate,103) + N' ' + Convert(nVarchar(8),LastTrAndate,108) [Last Transaction Date],
(Case ParameterType When 1 Then 2 When 2 Then 1 When 3 Then 3 When 4 Then 4 When 5 Then 5 When 6 Then 6 When 7 Then 7 When 8 Then 8
When 9 Then 9 When 10 Then 10 When 11 Then 11 When 12 Then 12 When 13 Then 13 When 14 Then 14 End) 'ParameterTypeID',
Frequency 'FrequencyID'
, isnull(Flag,0) 'Flag',isnull(TargetParameterType,0) 'TargetParameterType'
,Case ParameterType When 3 Then (Case When isnull(TargetParameterType,0) = 0 Then 'Calculated' Else 'Absolute' End)
When 10 Then (Case When isnull(TargetParameterType,0) = 0 Then 'Calculated' When isnull(TargetParameterType,0) = 1 Then 'Absolute'
When isnull(TargetParameterType,0) = 2 Then 'Mixed-Lesser' When isnull(TargetParameterType,0) = 3 Then 'Mixed-Greater' When isnull(TargetParameterType,0) = 4 Then 'Growth' End)
Else '' End as TargetType

Into #TempVal
From #tmpPM ,tbl_mERP_PMParamType ParamType
Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
And ParamType.ID = ParameterType

Insert Into #tmpOutput(ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
[Last Transaction Date], [Flag],TargetParameterType,TargetType)
Select ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
[Last Transaction Date], [Flag],TargetParameterType,TargetType
From #TempVal Order by [Performance Metrics Code],[DS Type],DSName,ParameterTypeID,FrequencyID Asc

Drop table #TempVal

/*Insert Empty data for Salesman with Nil invoices for Business Achievment Param*/
Insert Into #tmpOutputBA([WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date], [Last Transaction Date])
Select @WDCode ,@WDDest,SM.Salesman_Name,DST.DSType,PM.PMCode,PM.Description,Replace(PM.CGGroups,',','|'),
@FromDate,@ToDate, Case TGT_PARAMTYPE When 3 Then N'Business Achievement' When 6 Then N'Total Lines Cut' When 7 Then N'Numeric Outlet Ach' End, tDStgt.TGT_ISFOCUSPARAM,
(Case tDStgt.TGT_FREQUENCY When 1 Then N'Daily' When 2 Then N'Monthly' End),
(Case TGT_PARAMTYPE When 3 Then (Case When (TGT_FREQUENCY = 2 And @ReportType = 'Daily') Then Cast(isNull(TGT_TARGETVAL,0)/25. as decimal(18,6)) Else Cast(isNull(TGT_TARGETVAL,0) as Decimal(18,6)) End)
When 6 Then  Cast(isNull(TGT_TARGETVAL,0) as Decimal(18,6))
When 7 Then  Cast(isNull(TGT_TARGETVAL,0) as Decimal(18,6))
Else NULL End),
NULL,NULL,Cast(IsNull(TGT_PARAMMAX,0) as Decimal(18,6)), NULL, NULL,NULL,
Convert(nVarchar(10),@RptGenerationDate,103) + N' ' + Convert(nVarchar(8),@RptGenerationDate,108),
Convert(nVarchar(10),@LastInvoiceDate,103) + N' ' + Convert(nVarchar(8),@LastInvoiceDate,108)
From #tDSTgtZeroInv tDStgt, tbl_mERP_PMMaster PM, tbl_mERP_PMDSType DST, SalesMan SM
Where PM.PMID = tDStgt.TGT_PMID
And DST.DSTypeID = tDStgt.TGT_DSTypeID
And SM.SalesmanID = tDStgt.TGT_SMID
--As per QC Team analysis, DS Type filter is not working in the report. It is fixed.
And DST.DSType in (Select DSType From #tmpDSType)
And PM.PMID = @PMID And DST.DSTypeID = @PMDSTypeID And SM.Salesman_Name = @SalesmanName
Order By PM.PMCode,DST.DSType,SM.Salesman_Name

update A set a.Target=b.target,
A.[Average Till Date] = B.[Average Till Date],
A.[Till date Actual] = B.[Till date Actual],
A.[Max Points] =B.[Max Points],
A.[Till Date Points Earned]= B.[Till Date Points Earned],
A.[Todays Actual] = B.[Todays Actual],
A.[Points Earned Today] = B.[Points Earned Today]
From #tmpOutputBA B,#tmpOutput A where a.[Performance Metrics Code]=b.[Performance Metrics Code] And a.[Overall or Focus] = B.[Overall or Focus] And
a.Parameter = b.parameter And a.dsname=b.dsname And (a.Parameter='Business Achievement' OR a.Parameter='Total Lines Cut' OR a.Parameter='Numeric Outlet Ach')  And A. [DS Type] = B.[DS Type]
And a.[Category Group]=b.[Category Group] and isnull(A.TargetParameterType,0) = 0

Update #tmpOutput Set [Max Points] = 0 Where isnull(Target,0) = 0 And  [WDCode] <> 'Max Points Total:' and Parameter Not in('Lines Cut', 'Bills Cut', 'Total Bills Cut', 'Blockbuster', 'UOB', 'Winner SKU')
delete From #tmpOutPutBA

if Exists (Select top 1 * From #Tmpoutput where DSName = @SalesmanName And [Performance Metrics Code] = (Select Top 1 PMCODE From tbl_mERP_PMMaster Where PMID = @PMID) )
Begin
If @ReportType = 'Monthly'
Insert Into #tmpOutput([WDCode],[Max Points],[Till Date Points Earned])
Select @MAXPOINT_TOTAL,Case IsNull(@MaxPoints,0) When 0 Then (Select IsNull(Max(MaxPoints),0) From tbl_mERP_PMDSType Where DsTypeID=@PMDSTypeID) Else @MaxPoints End,
(Case When @TillDatePointsEarned > @MaxPoints Then @MaxPoints Else @TillDatePointsEarned End)
Else If @ReportType = 'Daily'
Insert Into #tmpOutput([WDCode],[Max Points],[Points Earned Today])
Select @MAXPOINT_TOTAL,Case IsNull(@MaxPoints,0) When 0 Then (Select IsNull(Max(MaxPoints),0) From tbl_mERP_PMDSType Where DsTypeID=@PMDSTypeID) Else @MaxPoints End,
(Case When @ToDaysPointsEarned > @MaxPoints Then @MaxPoints Else @ToDaysPointsEarned End)
End
Fetch next From Cur_Counter2 Into @Counter

End
Close Cur_Counter2
Deallocate Cur_Counter2

Delete From #tmpOutput Where isnull(Parameter,'') = 'Depend-Days Worked'

If (Select Count(DSName) From #tmpOutput) >=1
Begin

/*To Insert GrAndTotal Total */
If @ReportType = 'Monthly'
Insert Into #tmpOutput([WDCode],[Till Date Points Earned])
Select @GRNTOTAL,Sum(Cast(isNull([Till Date Points Earned],0) as decimal(18,6))) From #tmpOutput Where [WDCode] = @MAXPOINT_TOTAL
Else If @ReportType = 'Daily'
Insert Into #tmpOutput([WDCode],[Points Earned Today])
Select @GRNTOTAL,Sum(Cast(isNull([Points Earned Today],0) as Decimal(18,6))) From #tmpOutput Where [WDCode] = @MAXPOINT_TOTAL
End

Update T1  Set T1.DSID = T2.Cnt  From #tmpOutput T1,(Select SalesMan_Name, SalesManId as Cnt  From Salesman) T2 Where T1.DSName = T2.SalesMan_Name
Update 	#tmpOutput set Target = 0 Where isnull(Target,0) = 0 And (Parameter = 'Business Achievement' OR Parameter = 'Total Lines Cut' OR Parameter = 'Numeric Outlet Ach')

If @ReportType = 'Monthly'
Begin
Select ParamID,[WDCode],[WDDest],[From Date],[To Date],cast(DSID as Nvarchar(10)) DSID, DSName ,[DS Type],[Performance Metrics Code],Description,[Category Group],
Parameter,[Overall or Focus],Frequency,TargetType [Target Type],Target,[Average Till Date],[Till date Actual],[Max Points],
[Till Date Points Earned],[Generation Date],[Last Transaction Date]
From #tmpOutput Order By [ID]
End
Else If @ReportType = 'Daily'
Begin
Select ParamID,[WDCode],[WDDest],[From Date],[To Date],cast(DSID as Nvarchar(10)) DSID,DSName ,[DS Type],[Performance Metrics Code],Description,[Category Group],
Parameter,[Overall or Focus],Frequency, TargetType [Target Type],Target,[Average Till Date],[Todays Actual],[Max Points],
[Points Earned Today],[Generation Date],[Last Transaction Date]
From #tmpOutput Order By [ID]
End

OvernOut:
Drop Table #tmpCatGroup
Drop Table #tmpDStype
Drop Table #tmpSalesman
Drop Table #tmpInvoice
Drop Table #tmpPM
Drop Table #tmpInvDateWise
Drop Table #tmpOutput
Drop table #tmpDistinctPMDS
Drop table #tDSTgtZeroInv
Drop table #TmpFocusItems
Drop Table #tmpMinQtyInvItems
Drop Table #tmpPM_TLC
Drop Table #tmpPM1_TLC
Drop Table #tmpInvDateWise_TLC
Drop Table #DSPMSalesman_TLC
Drop Table #tmpPM_NOA
Drop Table #tmpPM1_NOA
Drop Table #tmpInvDateWise_NOA
Drop Table #DSPMSalesman_NOA
Drop Table #tmpOutletAchieve
Drop Table #tmpGateUOB
Drop Table #tmpGateDays
Drop Table #tmpUOB
Drop Table #tmpPM_GateUOB_Data
Drop Table #tmpDependGateDays

End
