Create Proc SP_HHViewPostData
AS
BEGIN
Set Dateformat DMY
Declare @CurrentDate Datetime
Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

Declare @CatGroup nVarchar(1000)
Declare @DStype nVarchar(4000)
Declare @SalesName nVarchar(4000)
Declare @ReportType nVarchar(50)
Declare @DateOrMonth as nVarchar(25)
Declare @UptoWeek nVarchar(50)

Declare @Pmdate DateTime
Set @Pmdate = cast(Getdate() as DateTime)
set @ReportType = 'Monthly'

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
Set @DaycloseDate = (Select Convert(Nvarchar(10),LastInventoryUpload,103) From Setup)
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


Declare @PMProductID as int
Declare @Group_ID as Nvarchar(50)
Declare @PMProductName as Nvarchar(255)
Declare @SQL as Nvarchar(Max)

/* Business Achievement*/
Declare @ToTalSalesPercentage Decimal(18,6),@Target  as Decimal(18,6),@MaxPoints Decimal(18,6),@DayClosed Int

Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Declare @DateOrMonth1 as datetime--(10)
Declare @GGRRMonth as datetime
Truncate Table TmpPM

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode='ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Set @DtMonth = cast(@Pmdate as datetime)
Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')

Declare @GRNTOTAL nVarchar(50)
Declare @MAXPOINT_TOTAL nVarchar(50)

Declare @Groups nvarchar(1000),@PLevel Int,@Product_Code nvarchar(30),@Product_Code_view nvarchar(30),
@Product_Name nVarchar(255), @Target1 Int, @ValidFromDate Datetime, @ValidToDate Datetime,
@Parm Int, @SlabUOM nvarchar(100), @PM_Groups_ID Int

/* V_DS_Metrics_Abstract Start*/

Create Table #TempVal(ParamID Int,
[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[From Date] Datetime,
[To Date] Datetime,
Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
Target Decimal(18,6),
[Average Till Date] Decimal(18,6),
[Till date Actual] Decimal(18,6),
[Max Points] Decimal(18,6),
[Till Date Points Earned] Decimal(18,6),
[Todays Actual] Decimal(18,6),
[Points Earned Today] Decimal(18,6),
[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[ParameterTypeID] Int,
[FrequencyID] Int,TargetParameterType int)


Create Table #TmpViewOut (
[ValidFromDate] [datetime] NULL,
[ValidToDate] [datetime] NULL,
[SalesmanID] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Group_ID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PMProductID] [int] NULL,
[PmProductName] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parameter] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Target] [decimal](18, 6) NOT NULL,
[Acheived] [decimal](18, 6) NOT NULL,
[Till Date Points Earned] [decimal](18, 6) NOT NULL)

Create Table  #tmpCatGroup (GroupName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table  #tmpDStype   (DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table  #tmpSalesman (Salesman nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table  #tmpPM (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime,TargetParameterType int)

Create Table  #tmpPM1 (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime,TargetParameterType int)

Create Table  #tmpInvoice (InvoiceID Int,InvoiceDate Datetime,
SalesmanID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
SubCategory nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
Division nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
Company nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryGroup nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
Amount Decimal(18,6) ,InvoiceType Int,InvoiceDateWithTime Datetime,DSTypeID Int,Quantity Decimal(18,6),UOM1Qty Decimal(18,6),UOM2Qty Decimal(18,6) )

Create Table #tmpOutput ([ID] Int Identity(1,1),ParamID Int,[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetParameterType int)

Create Table #tmpOutputBA ([ID] Int Identity(1,1),[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
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

Create Table  #tmpInvDateWise (InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
PointsEarned Decimal(18,6))

Create Table  #tmpDistinctPMDS(RowID Int Identity(1,1),PMID Int,DSTypeID Int,SalesmanName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table  #TmpFocusItems (Product Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProLevel Int,Min_Qty Decimal(18,6),UOM Int)

Create Table  #tmpMinQtyInvItems (Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)


Create Table #TmpView (
SalesmanID Int NULL,
Group_ID [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PMProductID [int] NULL,
PMProductName [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SalesTarget [decimal](18, 6) NULL Default 0,
Achievement	[decimal](18, 6) NULL Default 0,
BillsCut [decimal](18, 6) NULL Default 0,
LinesCut [decimal](18, 6) NULL Default 0,
ValidFromDate  [datetime] NULL,
ValidToDate  [datetime] NULL)

Create Table  #tmpInvDateWise_BC  (InvoiceId int,InvoiceDate Datetime ,LinesOrBillsOrBA int,InvoiceDateWithTime Datetime)

Declare @InvalidID int


Insert Into #tmpCatGroup(GroupName) Values ('GR1,GR3')
Insert Into #tmpCatGroup(GroupName) Values ('GR1')
Insert Into #tmpCatGroup(GroupName) Values ('GR2')
Insert Into #tmpCatGroup(GroupName) Values ('GR3')

Insert into #tmpDStype
Select Distinct DSTypeValue From DSType_Master Where DSTypeCtlPos = 1

Insert into #tmpSalesman
Select Salesman_Name From Salesman

Select @TillDate = GetDate()
Select @RptGenerationDate = @TillDate

Declare @OCG int
Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'

Set @MonthFirstDate = (cast('01/' + cast(Month(@Pmdate) as Nvarchar) + '/' + cast(Year(@Pmdate)  as Nvarchar) as DateTime))
Set @TillDate  = (DateAdd(D,-1,DateAdd(m,1,(cast('01/' + cast(Month(@Pmdate) as Nvarchar) + '/' + cast(Year(@Pmdate)  as Nvarchar) as DateTime)))))

Set @MonthLastDate = @ToDate
If  (@TillDate > @MonthLastDate) Or (@TillDate < @MonthFirstDate)
Select @TillDate= @MonthLastDate

/* To Find Whether Day isclosed for the current month Last Day */
Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@MonthLastDate))
Select @DayClosed = 1
End

/* Last InvoiceDate taken */
Select @LastInvoiceDate = Max(InvoiceDate) From InvoiceAbstract
Where IsNull(Status,0) & 128 = 0 And InvoiceType in(1,3,4)


/* Filter the Invoices Which comes in between MonthFromDate And ReportGenerationdate(TillDate) */
Insert Into #tmpInvoice
Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
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

if @OCG=1
update #tmpInvoice set CategoryGroup = CGDiv.CategoryGroup From #tmpInvoice I, tblCGDivMapping CGDiv where I.Division = CGDiv.Division

Update #tmpInvoice Set Invoicedate = dbo.StripTimeFromDate(Invoicedate)

Create Table #DSPMSalesman   (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
Insert into #DSPMSalesman (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 From tbl_merp_PMetric_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
where PMM.PMID in (select PMID From tbl_mERP_PMMaster Where Period =@Period )
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
Select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into DSPMSalesman
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
And isnull(PMTar.active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPM)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
And isnull(PMTar.active,0)=1
And PMTar.PMID = Master.PMID
And TMPDS.Salesmanid = PMTar.Salesmanid
And TMPDS.DSTypeValue = DSMast.DSTypeValue
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And TMPDS.Salesmanid not in (Select distinct salesmanid From #tmpPM)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And TMPDS.DSTypeValue = DSMast.DSTypeValue
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype DS,
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
--And Param.ParameterType not in (6,7)
And Param.ParameterType in (1,2,3,4,5) and isnull(Param.TargetParameterType,0) = 0
And SM.Salesmanid in ( Select Distinct Salesmanid From #DSPMSalesman)
And SM.Salesman_Name In (Select Distinct Salesman From #tmpSalesman)
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
,(select distinct SalesmanID,DStypeID from (
Select Distinct SalesmanID as SalesmanID, DSTypeID  as DSTypeID From DSType_Details Where DSTypeCtlPos = 1
union
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

Declare @TargetParameterType integer

Declare Cur_Counter Cursor For
Select Rowid From #tmpPM
Open Cur_Counter
Fetch next From Cur_Counter Into @Counter
While @@Fetch_Status = 0
Begin

Delete From #tmpInvDateWise
Delete From #tmpMinQtyInvItems

Select @TillDateActual = 0 ,@TillDatePointsEarned = 0,@NoOfDaysInvoiced=0,@SlabID=0,
@SLAB_EVERY = 0,@SLAB_VALUE =0 ,@ToDaysPointsEarned = 0,@ToTalSalesPercentage =0,
@Target  =0,@MaxPoints=0,@TodaysActual=0,@TillDateActualSales = 0,
@TodaysActualSales = 0,@DSTypeID=0

Select @ParamType = ParameterType,@Frequency = Frequency , @isFocusParam  = isFocusParam,
@CGGroups = isNull(CGGroups,''),@SalesmanID = salesmanID,@Level = Prod_Level,
@ParamID = ParamID,@FocusID = FocusID,@DSTypeID = DSTypeCode, @TargetParameterType = TargetParameterType From #tmpPM Where RowID = @Counter

Delete From #TmpFocusItems
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
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced ,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate
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
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=@TodaysPointsEarned,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTranDate = @LastInvoiceDate
Where RowID = @Counter

End
End /* End of Datewise InvoiceDetails */
End /*End of Lines Cut */


If @ParamType = 2 /* Bills Cut */
Begin


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
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
Else If @ReportType = 'Daily'
/* When Parameter Frequency is Monthly And the Report generated for daily then Todays points cannot be calculated */
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,	NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday=0,AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced ,
Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate
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
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
Else if @ReportType = 'Daily'
UpDate #tmpPM Set TillDateActual = @TillDateActual,TillDatePointsEarned = 0,NoOfDaysInvoiced = @NoOfDaysInvoiced,
ToDaysActual = @TodaysActual,PointsEarnedToday = @TodaysPointsEarned,
AverageTillDate = Cast(@TillDateActual as Decimal(18,6))/@NoOfDaysInvoiced , Target = 0 ,MaxPoints = 0,GenerationDate = @RptGenerationDate,
LastTranDate = @LastInvoiceDate
Where RowID = @Counter
End
End /* End of Datewise InvoiceDetails */
Delete from #tmpInvDateWise_BC
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

If isnull(@TargetParameterType,0) = 0
Begin
If (Select Count(InvoiceDate) From #tmpInvDateWise) >= 1
Begin
If @Frequency = 2 /* Monthly */
Begin
Select @Target = isNull(Target,0), @MaxPoints = case When Target > 0 Then isNull(MaxPoints,0) Else 0 End From tbl_mERP_PMetric_TargetDefn
Where ParamID = @ParamID
And Active = 1
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
End
Else
Begin
Select @ToTalSalesPercentage  = @TillDateActualSales
Select @SlabID = SlabID, @SLAB_EVERY = SLAB_EVERY_QTY,@SLAB_VALUE = SLAB_VALUE
From tbl_mERP_PMParamSlab Where
ParamID = @ParamID And SLAB_GIVEN_AS = 2
And @ToTalSalesPercentage Between SLAB_START And SLAB_END
Select @TillDatePointsEarned = 0
End
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
Select @Target = isNull(Target,0), @MaxPoints = isNull(MaxPoints,0) From tbl_mERP_PMetric_TargetDefn
Where ParamID = @ParamID
And Active = 1
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
End /* DateWise InvoiceDetails */
End
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

End /* Absolute Parameter */
End /*End Of target Defined*/
End /* Business Achievement Ends*/
Fetch next From Cur_Counter into @Counter
End /* End of While */
Close Cur_Counter
Deallocate Cur_Counter

/*To Insert DSType And Param info From PMetric_TargetDefn table for Salesman having Target with nil Invoices*/
Create Table  #tDSTgtZeroInv (TGT_PMID Int, TGT_DSTYPEID Int, TGT_PARAMID Int, TGT_SMID int, TGT_TARGETVAL Decimal(18,6), TGT_MAXPOINT Decimal(18,6),
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
--And PMP.ParameterType not in (6,7)
And PMP.ParameterType in (1,2,3,4,5)
And Tdf.SALESMANID in (Select salesmanid From salesman where salesman_name in(Select Salesman From #tmpSalesman))
Fetch next From Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
End
Close Cur_TgtPMLst
Deallocate Cur_TgtPMLst

Update #tmpPM Set GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate

Insert Into #tmpDistinctPMDS(PMID,DSTypeID,SalesmanName)
Select Distinct PMID,DSTypeID,Salesman_Name From #tmpPM
Union
/*Fetch Non existing PM And DS information*/
Select Distinct TGT_PMID,TGT_DSTYPEID, SM.Salesman_Name From #tDSTgtZeroInv tDST, Salesman SM,
tbl_mERP_PMDSType PMDST
Where SM.SalesManID = tDST.TGT_SMID
And PMDST.PMID = tDST.TGT_PMID
And PMDST.DSTypeID=tDST.TGT_DSTYPEID
And PMDST.DSType in (Select DStype From #tmpDStype)

Update #tmpPM Set GenerationDate = @RptGenerationDate

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

Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
From #tmpPM Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName

Insert Into #TempVal
Select Distinct ParamID,@WDCode as 'WDCode' ,@WDDest as 'WDDest',Salesman_Name as 'DSName',DSType  as 'DS Type',PMCode as 'Performance Metrics Code',PMDescription as 'Description',Replace(CGGroups,',','|') [Category Group],@FromDate [From Date],Convert(nVarchar(10), @ToDate, 103) [To Date],
(Case ParameterType When 1 Then N'Lines Cut' When 2 Then N'Bills Cut' When 3 Then N'Business Achievement' When 4 then 'Go Green OBJ' When 5 Then 'Reduce Red OBJ' End) 'Parameter',
isFocusParam 'Overall or Focus',(Case Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End) 'Frequency',
(Case ParameterType
When 3 Then (Case
When (Frequency = 2 And @ReportType = 'Daily') Then Cast(isNull(Target,0)/25. as decimal(18,6))
Else Cast(isNull(Target,0) as Decimal(18,6))
End)
When 4 Then Cast(isNull(Target,0) as Decimal(18,6))
When 5 Then Cast(isNull(Target,0) as Decimal(18,6))
Else NULL End) Target,
AverageTillDate [Average Till Date],TillDateActual [Till date Actual],(Case ParameterType When 3 Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End) [Max Points],
(Case ParameterType When 3 Then
(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)[Till Date Points Earned],
ToDaysActual [Todays Actual],
(Case ParameterType When 3 Then
(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
Else (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End) [Points Earned Today],
Convert(nVarchar(10),GenerationDate,103) + N' ' + Convert(nVarchar(8),GenerationDate,108) [Generation Date],
Convert(nVarchar(10),LastTranDate,103) + N' ' + Convert(nVarchar(8),LastTranDate,108) [Last Transaction Date],
(Case ParameterType When 1 Then 2 When 2 Then 1 When 3 Then 3 When 4 Then 4 When 5 Then 5 End) 'ParameterTypeID',Frequency 'FrequencyID'
,TargetParameterType
From #tmpPM ,tbl_mERP_PMParamType ParamType
Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
And ParamType.ID = ParameterType and ParamType.ParamType not in ('Go Green OBJ','Reduce Red OBJ','TOTAL LINES CUT','NUMERIC OUTLET ACH')

Insert Into #tmpOutput(ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
[Last Transaction Date],TargetParameterType)
Select ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
[Last Transaction Date],TargetParameterType
From #TempVal Order by [Performance Metrics Code],[DS Type],DSName,ParameterTypeID,FrequencyID Asc

Delete From #TempVal

/*Insert Empty data for Salesman with Nil invoices for Business Achievment Param*/
Insert Into #tmpOutputBA([WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
[From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
[Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date], [Last Transaction Date])
Select @WDCode ,@WDDest,SM.Salesman_Name,DST.DSType,PM.PMCode,PM.Description,Replace(PM.CGGroups,',','|'),
@FromDate,@ToDate, N'Business Achievement', tDStgt.TGT_ISFOCUSPARAM,
(Case tDStgt.TGT_FREQUENCY When 1 Then N'Daily' When 2 Then N'Monthly' End),
(Case TGT_PARAMTYPE When 3 Then (Case When (TGT_FREQUENCY = 2 And @ReportType = 'Daily') Then Cast(isNull(TGT_TARGETVAL,0)/25. as decimal(18,6)) Else Cast(isNull(TGT_TARGETVAL,0) as Decimal(18,6)) End) Else NULL End),
NULL,NULL,Cast(IsNull(TGT_PARAMMAX,0) as Decimal(18,6)), NULL, NULL,NULL,
Convert(nVarchar(10),@RptGenerationDate,103) + N' ' + Convert(nVarchar(8),@RptGenerationDate,108),
Convert(nVarchar(10),@LastInvoiceDate,103) + N' ' + Convert(nVarchar(8),@LastInvoiceDate,108)
From #tDSTgtZeroInv tDStgt, tbl_mERP_PMMaster PM, tbl_mERP_PMDSType DST, SalesMan SM
Where PM.PMID = tDStgt.TGT_PMID
And DST.DSTypeID = tDStgt.TGT_DSTypeID
And SM.SalesmanID = tDStgt.TGT_SMID
And DST.DSType in (Select DSType From #tmpDStype)
And PM.PMID = @PMID And DST.DSTypeID = @PMDSTypeID And SM.Salesman_Name = @SalesmanName
Order By PM.PMCode,DST.DSType,SM.Salesman_Name

Update A set a.Target=b.target,
A.[Average Till Date] = B.[Average Till Date],
A.[Till date Actual] = B.[Till date Actual],
A.[Max Points] =B.[Max Points],
A.[Till Date Points Earned]= B.[Till Date Points Earned],
A.[Todays Actual] = B.[Todays Actual],
A.[Points Earned Today] = B.[Points Earned Today]
From #tmpOutputBA B,#tmpOutput A where a.[Performance Metrics Code]=b.[Performance Metrics Code] And a.[Overall or Focus] = B.[Overall or Focus] And
a.Parameter = b.parameter And a.dsname=b.dsname And a.Parameter='Business Achievement'  And A. [DS Type] = B.[DS Type] and isnull(A.TargetParameterType,0) = 0
And a.[Category Group]=b.[Category Group]

Update #tmpOutput Set [Max Points] = 0 Where isnull(Target,0) = 0 And  [WDCode] <> 'Max Points Total:'
delete From #tmpOutputBA

Fetch next From Cur_Counter2 Into @Counter

End
Close Cur_Counter2
Deallocate Cur_Counter2

Update T1  Set T1.DSID = T2.Cnt  from #tmpOutput T1,(Select SalesMan_Name, SalesManId as Cnt  From Salesman) T2 Where T1.DSName = T2.SalesMan_Name
Update 	#tmpOutput set Target = 0 Where isnull(Target,0) = 0 And Parameter = 'Business Achievement'

Insert Into #TmpViewOut (ValidFromDate,ValidToDate,SalesmanID,Group_ID,PMProductID,PMProductName,Parameter,Target,Acheived,[Till Date Points Earned])
Select @MonthFirstDate [From Date],@TillDate [To Date],cast(DSID as Nvarchar(10)) DSID ,[Category Group],ParamID,
[Overall or Focus],Parameter,Isnull(Target,0) Target,Isnull([Till date Actual],0) [Till date Actual], isnull([Till Date Points Earned],0) [Till Date Points Earned]
From #tmpOutput

Insert Into #TmpView (SalesManid,Group_ID,PMProductID,PMProductName,ValidFromDate,ValidToDate)
select Distinct SalesManid,Group_ID,PMProductID,PMProductName,ValidFromDate,ValidToDate From #TmpViewOut
Where SalesManid In (Select dd.salesmanID From DSType_Details dd, DSType_Master dm
Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes' And Isnull(dd.salesmanID,0) <> 0)
Order By SalesManid,Group_ID,PMProductID,PMProductName

Update T set T.SalesTarget = isnull(T1.Target,0) , T.Achievement = Isnull(T1.Acheived,0) From #TmpView T, #TmpViewOut T1
Where T1.SalesManid = T.SalesManid And T1.Group_ID = T.Group_ID And T1.PMProductID = T.PMProductID And T1.PMProductName = T.PMProductName
And T1.Parameter = 'Business Achievement'

Update T set T.LinesCut = Isnull(T1.[Till Date Points Earned],0) From #TmpView T, #TmpViewOut T1
Where T1.SalesManid = T.SalesManid And T1.Group_ID = T.Group_ID And T1.PMProductID = T.PMProductID And T1.PMProductName = T.PMProductName
And T1.Parameter = 'Lines Cut'

Update T set T.BillsCut = Isnull(T1.[Till Date Points Earned],0) From #TmpView T, #TmpViewOut T1
Where T1.SalesManid = T.SalesManid And T1.Group_ID = T.Group_ID And T1.PMProductID = T.PMProductID And T1.PMProductName = T.PMProductName
And T1.Parameter = 'Bills Cut'

Insert into TmpPM
Select * from #TmpView

Drop Table #tmpPM
Drop Table #tmpPM1
Drop Table #tmpInvoice
Drop Table #tmpOutput
Drop Table #tmpOutputBA
Drop Table #tmpInvDateWise
Drop Table #tmpInvDateWise_BC
Drop Table #tmpDistinctPMDS
Drop Table #TmpFocusItems
Drop Table #tmpMinQtyInvItems
Drop Table #DSPMSalesman
Drop Table #TmpView
/* V_DS_Metrics_Abstract End */

/*V_DS_Metrics_Detail Start */
Truncate Table TmpPMDetail
Create Table #TmpView1 (
SalesmanID Int NULL,
Group_ID [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PMProductID [int] NULL,
[Level] [int] NULL,
Product_Code [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Create Table #TmpAbstract(
SalesmanID [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Group_ID [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PMProductID [int] NULL,
PMProductName [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
SalesTarget [decimal](18, 6) NULL Default 0,
Achievement	[decimal](18, 6) NULL Default 0,
BillsCut [decimal](18, 6) NULL Default 0,
LinesCut [decimal](18, 6) NULL Default 0,
ValidFromDate  [datetime] NULL,
ValidToDate  [datetime] NULL)

Insert Into #TmpAbstract
Select SalesmanID,Group_ID,PMProductID,PMProductName,SalesTarget,Achievement,BillsCut,LinesCut,ValidFromDate,ValidToDate From TmpPM
--select * from FN_GetPMAbstractForView()

Create Table  #TmpDetail (
Product_Code [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Product_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CategoryID [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
LevelofProduct [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Create Table #TempPMCategoryList (
Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
LevelofProduct Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #ViewItems (Item_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Item_Name  Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Item_Description Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert Into #ViewItems (Item_Code,Item_Name,Item_Description) Select Distinct Item_Code,Item_Name,Item_Description From V_Item_Master

Declare @cluParamID Cursor
Set @cluParamID = Cursor for
Select Distinct PMProductID,SalesmanID,Group_ID,PMProductName from #TmpAbstract
Open @cluParamID
Fetch Next from @cluParamID into @PMProductID,@SalesmanID,@Group_ID,@PMProductName
While @@fetch_status =0
Begin

Delete From #TempPMCategoryList

Insert Into #TempPMCategoryList (Product_Code,CategoryID,LevelofProduct)
Select (Case When PMF.ProdCat_Code = 'All' Then 'Overall' Else PMF.ProdCat_Code End),Null,PMF.ProdCat_Level From tbl_mERP_PMParamFocus PMF Where PMF.ParamID = @PMProductID And Isnull(PMF.ProdCat_Code,'') <> ''

Update #TempPMCategoryList set CategoryID = 'Overall' Where Product_Code = 'Overall'

Update T set T.CategoryID = IC.CategoryID From #TempPMCategoryList T, ItemCategories IC
Where Isnull(T.CategoryID,'') = '' and T.Product_Code = IC.Category_Name

Update T set T.CategoryID = I.Product_Code From #TempPMCategoryList T, Items I
Where Isnull(T.CategoryID,'') = '' and T.Product_Code = I.Product_Code

Insert Into #TmpDetail(Product_Code,Product_Name,CategoryID,LevelofProduct)
select * from #TempPMCategoryList

Insert into #TmpView1 (SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name)
Select @SalesmanID,@Group_ID,@PMProductID,LevelofProduct,CategoryID,Product_Code From #TmpDetail

Update T set T.Product_Name = (Case When Isnull(IC.Description,'') <> '' Then IC.Description Else IC.Category_Name End)
From #TmpView1 T, ItemCategories IC
Where T.Product_Code = IC.CategoryID and T.Product_Name <> 'Overall' And T.Level <> 5

Update T set T.Product_Name = (Case When Isnull(I.Item_Description,'') <> '' Then I.Item_Description Else I.Item_Name End)
From #TmpView1 T, #ViewItems I
Where T.Product_Code = I.Item_Code and T.Product_Name <> 'Overall' And T.Level = 5
Delete From #TmpView1 Where Level = 5 and Product_Code Not In (select Distinct Item_Code from #ViewItems)

Delete From #TmpDetail
Fetch Next from @cluParamID into @PMProductID,@SalesmanID,@Group_ID,@PMProductName
End
Close @cluParamID
Deallocate @cluParamID
Delete From #ViewItems
insert into TmpPMDetail (SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name)
select SalesmanID,Group_ID,PMProductID,[Level],Product_Code,Product_Name From  #TmpView1
Drop Table #TmpAbstract
Drop Table #TmpDetail
DRop Table #TempPMCategoryList
Drop Table #ViewItems
Drop Table #TmpView1

/*V_DS_Metrics_Detail End  */

/*V_DS_Metrics Start */

--Truncate Table TmpPMGroups
--
--Create Table  #DSMetrics ([SalesmanID] Int, [Group_ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    [Level] Int, [Product_Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    [Product_Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    [SalesTarget] Decimal(18,6) Default(0), [Achievement] Decimal(18,6) Default(0),
--    [BillsCut] Decimal(18,6) Default(0), [LinesCut] Decimal(18,6) Default(0),
--    [ValidFromDate] Datetime, [ValidToDate] Datetime)
--
--Create Table  #PM_Groups (ID Int Identity (1,1), SalesmanID Int,
--    Groups nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, PLevel Int,
--    Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Product_Code_view nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Product_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Target Int, ValidFromDate Datetime, ValidToDate Datetime,
--    Parm Int, Frequency Int)
--
--Create Table  #PM (PM_Groups_ID Int, SalesmanID Int, PLevel Int,
--    Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Product_Code_view nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Product_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
--    Target Int, ValidFromDate Datetime, ValidToDate Datetime,
--    Parm Int, Frequency Int, CtgGroup nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
--
--Create Table  #Itm (CategoryGroup nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
--					 DivName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, DivID int,
--					 SubCName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, SubCatID int,
--					 MktName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, MktSKUID int,
--					 Product_Code nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)
--
--Create Table  #I (SalesmanId Int, InvoiceId Int, InvoiceType Int, InvoiceDate Datetime,
--    ItemCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, NetAmount Decimal(18, 5))
--
--
--Select @fromDate = dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate())))
--    , @ToDate = GetDate()
--
--Create Table  #tmpHHSM  (SalesmanID int)
--Insert into #tmpHHSM
--Select dd.salesmanID From DSType_Details dd, DSType_Master dm
--Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes'
--
--Insert Into #Itm
--Select CG.CategoryGroup, ItcDiv.Category_Name DivName, ItcDiv.CategoryID DivID,
--ItcSubC.Category_Name SubCName, ItcSubC.CategoryID SubCatID,
--ItcMkt.Category_Name MktName, ItcMkt.CategoryID MktSKUID,
--Itm.Product_Code
--From ItemCategories ItcDiv
--Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId
--Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId
--Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId
--Join tblcgdivmapping CG on ItcDiv.Category_Name = CG.Division
--
--Insert Into #I
--Select Ia.SalesmanId, Ia.InvoiceId, InvoiceType, [InvoiceDate] = convert(datetime, convert(varchar(10), Ia.InvoiceDate, 103), 103),
--[ItemCode] = idt.Product_Code,
--[NetAmount] = Sum((Case When ia.InvoiceType = 4 Then -1 Else 1 End) * idt.Amount)
--From InvoiceAbstract ia, InvoiceDetail idt,
--DSType_Details Dd, DSType_Master dm
--Where ia.InvoiceID = idt.InvoiceID
----And ia.InvoiceType In (1, 3, 4) And (IsNull(ia.Status, 0) & 192) = 0
--And ia.InvoiceDate Between @FromDate And @ToDate
--And	((ia.InvoiceType in(1, 3) and isnull(ia.Status,0) & 128 = 0)
--		OR (ia.InvoiceType = 4 and isnull(ia.Status,0) & 32 = 0 and isnull(ia.Status,0) & 128 = 0))
--And ia.SalesmanID = Dd.SalesmanID and dd.DSTypeID = dm.DSTypeID
--And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes'
--Group by Ia.SalesmanId, Ia.InvoiceId, InvoiceType, convert(datetime, convert(varchar(10), Ia.InvoiceDate, 103), 103),
--Idt.Product_Code
--
--Insert Into #PM_Groups
--Select [SalesmanID] = sl.SalesManID, [Groups] = pmm.CGGroups, [PLevel] = pmpf.ProdCat_Level,
--[Product_Code] = Case When pmpf.ProdCat_Level = 0 Then 'Overall' Else pmpf.ProdCat_Code End,
--[Product_Code_view] = Case When pmpf.ProdCat_Level = 0 Then 'Overall'
--                    When pmpf.ProdCat_Level = 5 Then pmpf.ProdCat_Code
--                    Else IsNull((Select Cast(CategoryID As nVarchar) From ItemCategories Where Category_Name = pmpf.ProdCat_Code), '')
--				 End,
--[Product_Name] = Case When pmpf.ProdCat_Level = 0 Then 'Overall'
--                    When pmpf.ProdCat_Level = 5 Then IsNull((Select ProductName From Items Where Product_Code = pmpf.ProdCat_Code), '')
--                    Else pmpf.ProdCat_Code
--                 End,
--[Target] = IsNull((Case When pmp.ParameterType = 1 Or pmp.ParameterType = 2 Then 0 Else
--(Select top 1 Target From tbl_mERP_PMetric_TargetDefn Where ParamID = pmp.ParamID and SalesmanID=sl.SalesmanID and active = 1) End), 0),
--[ValidFromDate] = dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate()))),
--[ValidToDate] = dbo.StripDateFromtime(DateAdd(SS, -1, DateAdd(MM, 1, dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate())))))),
--[Parm] = pmp.ParamID,
--[Frequency] = pmp.Frequency
--From tbl_mERP_PMMaster pmm, tbl_mERP_PMDSType pmds,
--DSType_Details dd, DSType_Master dm,
--Salesman sl, tbl_mERP_PMParam pmp,
--tbl_mERP_PMParamFocus pmpf, #tmpHHSM hhsm
--Where pmm.pmid = pmds.pmid And pmm.Active=1
--And	dd.DSTypeID = dm.DsTypeID
--And dd.SalesmanID = sl.SalesmanID And sl.Active = 1
--And dm.DSTypeValue = pmds.DSType And dm.DSTypeCtlPos = 1
--And pmp.ParamID = pmpf.ParamID And pmp.DSTypeID = pmds.DSTypeID
--And pmm.Period = Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())
--And sl.SalesmanID = hhsm.SalesmanID
--
--DECLARE CurCtg CURSOR FOR
--Select Id, SalesmanID, Groups, PLevel, Product_Code, Product_Code_view, Product_Name, Target, ValidFromDate, ValidToDate, Parm, Frequency
--from #PM_Groups
--
--OPEN CurCtg
--FETCH FROM CurCtg Into @PM_Groups_ID, @SalesmanID, @Groups, @PLevel, @Product_Code, @Product_Code_view, @Product_Name,
--    @Target1, @ValidFromDate, @ValidToDate, @Parm, @Frequency
--While @@fetch_status = 0
--Begin
--    If @PLevel = 0
--        Insert Into #PM
--        select @PM_Groups_ID, @SalesmanID, @PLevel, @Product_Code, @Product_Code_view, @Product_Name, @Target1,
--            @ValidFromDate, @ValidToDate, @Parm, @Frequency, * from dbo.sp_SplitIn2Rows(@Groups, '|' )
--    Else
--        Insert Into #PM
--        select @PM_Groups_ID, @SalesmanID, @PLevel, @Product_Code, @Product_Code_view, @Product_Name, @Target1,
--            @ValidFromDate, @ValidToDate, @Parm, @Frequency, ''
--    FETCH FROM CurCtg Into @PM_Groups_ID, @SalesmanID, @Groups, @PLevel, @Product_Code, @Product_Code_view,
--        @Product_Name, @Target1, @ValidFromDate, @ValidToDate, @Parm, @Frequency
--End
--Close CurCtg
--DeAllocate CurCtg
--
----select * from #PM_Groups order by 1;select * from @PM order by 1;
--Declare @Achievement Table ( Id Int, Netamount Decimal(18, 6))
--Insert Into @Achievement
--Select pm_groups_Id, sum( Netamount) Netamount From #PM pm
--Join ( Select paramId From tbl_mERP_PMParamSlab where Slab_uom = 'percentage'
--        group by paramId ) pmps on pm.parm = pmps.paramId
--Join #I I on pm.SalesmanID = I.SalesmanID
--Join #Itm Itm on I.Itemcode = Itm.product_code
--Where
--    ( Case when pm.plevel = 0 then pm.CtgGroup
--		when pm.plevel = 5 then pm.product_code
--        when ( pm.plevel = 2 or pm.plevel = 3 or pm.plevel = 4) then pm.product_code_view
--      end)
--    =
--    ( Case when pm.plevel = 0 then Itm.CategoryGroup
--        when pm.plevel = 2 then Cast(Itm.DivID as nVarchar(10))
--        when pm.plevel = 3 then Cast(Itm.SubCatID as nVarchar(10))
--        when pm.plevel = 4 then Cast(Itm.MktSKUID as nVarchar(10))
--        when pm.plevel = 5 then Itm.Product_Code
--      End)
--group by pm_groups_Id
--
--Declare @PreResult table(pm_Groups_ID int, InvoiceDate DateTime, InvoiceID int, ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
--Insert into @PreResult
--Select pm.pm_groups_Id, I.InvoiceDate, I.InvoiceId, I.ItemCode
--From #PM pm
--    Join #I I on pm.SalesmanID = I.SalesmanID
--    Join #Itm Itm on Itm.product_code  = I.Itemcode
--where
--	I.InvoiceType in (1,3) and
--    (Case when pm.plevel = 0 then pm.CtgGroup
--		when pm.plevel = 5 then pm.product_code
--        when ( pm.plevel = 2 or pm.plevel = 3 or pm.plevel = 4) then pm.product_code_view
--     end)
--    =
--    ( Case when pm.plevel = 0 then Itm.CategoryGroup
--        when pm.plevel = 2 then Cast(Itm.DivID as nVarchar(10))
--        when pm.plevel = 3 then Cast(Itm.SubCatID as nVarchar(10))
--        when pm.plevel = 4 then Cast(Itm.MktSKUID as nVarchar(10))
--        when pm.plevel = 5 then Itm.Product_Code
--      End)
--    group by pm_groups_Id, I.InvoiceId, I.InvoiceDate , I.ItemCode
--
------Bills Cut - Frequency = 2
--Declare @BillsCount_Fre2 Table (pm_groups_Id Int, BillsCount Int )
--Insert Into @BillsCount_Fre2
--Select pm_groups_Id, count(*) BillsCount
--From (Select distinct pr.pm_groups_Id, pr.InvoiceId From @PreResult pr) tmp group by pm_groups_Id
--
--Declare @BillsCut_Fre2 Table ( Id Int, BillsCut Decimal(18, 6) )
--Insert Into @BillsCut_Fre2
--Select pmg.Id,
--	sum((Case when Slab.Slab_Every_QTY = 0
--    		then Slab.SLAB_VALUE
--		    else ((BCF2.BillsCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE))
--	    End))
--From #PM_Groups pmg
--	Join @BillsCount_Fre2 BCF2 on pmg.Id = BCF2.pm_groups_Id and pmg.frequency = 2
--	Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'BC'
--Where
--    BCF2.BillsCount Between Slab.SLAB_START  And Slab.SLAB_END
--group by pmg.Id
--
------Bills Cut - Frequency = 1
--Declare @BillsCount_Fre1_Datewise Table (pm_groups_Id Int, InvoiceDate datetime, BillsCount Int )
--Insert Into @BillsCount_Fre1_Datewise
--Select pm_groups_Id, InvoiceDate, count(*) BillsCount
--From (Select Distinct pr.pm_groups_Id, pr.InvoiceId, pr.InvoiceDate From @PreResult pr)tmp group by pm_groups_Id, InvoiceDate
--
--Declare @BillsCut_Fre1 Table ( Id Int, BillsCut decimal(18, 6) )
--Insert Into @BillsCut_Fre1
--Select Id, sum(BillsCount) from
--(   Select pmg.Id,
--	    (Case when Slab.Slab_Every_QTY = 0
--		    then Slab.SLAB_VALUE
--		    else ((BFD.BillsCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE))
--	     End) BillsCount
--    From #PM_Groups pmg
--		Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'BC' and pmg.frequency = 1
--		Join @BillsCount_Fre1_Datewise BFD on pmg.Id = BFD.pm_groups_Id
--	Where
--		BFD.BillsCount Between Slab.SLAB_START And Slab.SLAB_END
--) tmp group by Id
--
------Lines Cut - Frequency = 2
--Declare @LinesCount_Fre2 Table ( pm_groups_Id Int, LinesCount Int )
--Insert Into @LinesCount_Fre2
--Select pm_groups_Id, count(*) LinesCount
--From (Select distinct pr.pm_groups_Id, pr.InvoiceId, pr.ItemCode From @PreResult pr) tmp group by pm_groups_Id
--
--Declare @LinesCut_Fre2 Table ( Id Int, LinesCut decimal(18, 6) )
--Insert Into @LinesCut_Fre2
--Select pmg.Id,
--    sum(Case when Slab.Slab_Every_QTY = 0
--    		then Slab.SLAB_VALUE
--	    	else ((LCF2.LinesCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE))
--	    End)
--From #PM_Groups pmg
--	Join @LinesCount_Fre2 LCF2 on pmg.Id = LCF2.pm_groups_Id and pmg.frequency = 2
--	Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'LC'
--Where
--    LCF2.LinesCount Between Slab.SLAB_START And Slab.SLAB_END
--group by pmg.Id
--
------Lines Cut - Frequency = 1
--Declare @LinesCount_Fre1_Datewise Table (pm_groups_Id Int, InvoiceDate datetime, LinesCount Int )
--Insert Into @LinesCount_Fre1_Datewise
--Select pm_groups_Id, InvoiceDate, count(*) LinesCount
--From (Select pr.pm_groups_Id, pr.ItemCode, pr.InvoiceID, pr.InvoiceDate From @PreResult pr)tmp group by pm_groups_Id, InvoiceDate
--
--Declare @LinesCut_Fre1 Table ( Id Int, LinesCut decimal(18, 6)  )
--Insert Into @LinesCut_Fre1
--Select Id, sum(LinesCount) from
--(   Select pmg.Id,
--	    (Case when Slab.Slab_Every_QTY = 0
--		    then Slab.SLAB_VALUE
--		    else ((LFD.LinesCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE))
--	     End) LinesCount
--    From #PM_Groups pmg
--    Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'LC' and pmg.frequency = 1
--    Join @LinesCount_Fre1_Datewise LFD on pmg.Id = LFD.pm_groups_Id
--	where
--        LFD.LinesCount Between Slab.SLAB_START And Slab.SLAB_END
--) tmp group by Id
--
--Insert InTo #DSMetrics
--Select SalesmanID, Groups, PLevel, Product_Code_view, Product_Name, sum(Target) as Target,
--sum(IsNull( Achievement.Netamount, 0 )) Achievement,
--sum(IsNull( BCF2.Billscut, 0 ) + IsNull( BCF1.Billscut, 0 )) as Billscut,
--sum(IsNull( LCF2.Linescut, 0 ) + IsNull( LCF1.Linescut, 0 )) as LInescut,
--ValidFromDate, ValidToDate
--from #PM_Groups pmg
--Left outer Join @Achievement Achievement on pmg.Id = Achievement.Id
--Left outer Join @BillsCut_Fre2 BCF2 on pmg.Id = BCF2.Id and pmg.frequency = 2
--Left outer Join @BillsCut_Fre1 BCF1 on pmg.Id = BCF1.Id and pmg.frequency = 1
--Left outer Join @LinesCut_Fre2 LCF2 on pmg.Id = LCF2.Id and pmg.frequency = 2
--Left outer Join @LinesCut_Fre1 LCF1 on pmg.Id = LCF1.Id and pmg.frequency = 1
--Group By SalesmanID, Groups, PLevel, Product_Code_view, Product_Name, ValidFromDate, ValidToDate
--
--
--insert into TmpPMGroups (SalesmanID,Group_ID,[Level],[Product_Code],[Product_Name],[SalesTarget],[Achievement],[BillsCut],[LinesCut],[ValidFromDate],[ValidToDate])
--select SalesmanID,Group_ID,[Level],[Product_Code],[Product_Name],[SalesTarget],[Achievement],[BillsCut],[LinesCut],[ValidFromDate],[ValidToDate] From #DSMetrics
--
--
--Drop table #DSMetrics
--Drop Table #PM_Groups
--Drop Table #PM
--Drop Table #Itm
--Drop Table #I
--Drop Table #tmpHHSM

/*V_DS_Metrics End */

/* V_SD_PM mERP_FN_PointsforGGDR_View  Start */

------	Create Table #Output  (DSID int,ConvertedOutlets decimal(18,6),Points decimal(18,6),Parameter Nvarchar(255))
------	Create Table  #tmpHHSM1  (Salesmanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------	Insert into #tmpHHSM1
------	Select S.salesman_Name From DSType_Details dd, DSType_Master dm,Salesman S
------	Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes'
------	And DD.SalesmanID=S.SalesmanID
------	And isnull(S.Active,0)=1
------	And isnull(Dm.Active,0)=1
------
------	Declare @Salesman Nvarchar(255)
------	Declare @F_Salesman Nvarchar(255)
------
------    Declare Cur Cursor For
------    Select SalesManName from #tmpHHSM1
------    Open Cur
------    Fetch next from Cur Into @Salesman
------    While @@Fetch_Status = 0
------	Begin
------		If Isnull(@F_Salesman,'') <> ''
------		Begin
------			Set @F_Salesman = Isnull(@F_Salesman,'') + cast(@Delimeter as Nvarchar) + Isnull(@Salesman,'')
------		End
------		Else
------		Begin
------			Set @F_Salesman = Isnull(@Salesman,'')
------		End
------	Fetch next from Cur into @Salesman
------	End
------	Close Cur
------    Deallocate Cur
------
------	Set @F_Salesman = Isnull(@F_Salesman,'%')
------
------	Set @CatGroup = '%'
------	Set @DStype = '%'
------	Set @SalesName = @F_Salesman
------	Set @ReportType = 'Monthly'
------	Set @DateOrMonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())
------	Set @UptoWeek = 'Week4'
------	select @GGRRMonth = dbo.striptimefromdate(getdate())
------
------	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
------	Select Top 1 @WDCode = RegisteredOwner From Setup
------
------	If @CompaniesToUploadCode='ITC001'
------	 Set @WDDest= @WDCode
------	Else
------	Begin
------	 Set @WDDest= @WDCode
------	 Set @WDCode= @CompaniesToUploadCode
------	End
------
------
------
--------	Set @GRNTOTAL = dbo.LookupDictionaryItem(N'Total:', Default)
--------	Set @MAXPOINT_TOTAL = dbo.LookupDictionaryItem(N'Max Points Total:', Default)
------	Set @GRNTOTAL = 'Total:'
------	Set @MAXPOINT_TOTAL = 'Max Points Total:'
------
------
------	Create Table  #tmpCatGroup1(GroupName nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
------	Create Table  #tmpDStype1  (DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------	Create Table  #tmpSalesman1(Salesman nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------	Create Table  #TempVal1 (
------	ParamID Int,
------	[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[From Date] Datetime,
------	[To Date] Datetime,
------	Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Target Decimal(18,6),
------	[Average Till Date] Decimal(18,6),
------	[Till date Actual] Decimal(18,6),
------	[Max Points] Decimal(18,6),
------	[Till Date Points Earned] Decimal(18,6),
------	[Todays Actual] Decimal(18,6),
------	[Points Earned Today] Decimal(18,6),
------	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	ParameterTypeID Int,
------	FrequencyID Int)
------
------	Create Table  #tmpPM2 (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
------	Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
------	DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
------	isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
------	TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
------	Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
------	ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)
------
------	Create Table  #tmpPM21 (RowID Int Identity(1,1),PMID Int,SalesmanID Int,
------	Salesman_Name nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,DSTypeID Int,
------	DSTypeCode Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	PMDescription nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	CGGroups nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	ParameterType Int,Frequency Int,ParamID Int,Prod_Level Int,
------	isFocusParam nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	FocusID Int,DS_MaxPoints Decimal(18,6),Param_MaxPoints  Decimal(18,6),
------	TillDateActual Decimal(18,6),NoOfDaysInvoiced Int,AverageTillDate Decimal(18,6),
------	Target Decimal(18,6),MaxPoints Decimal(18,6),TillDatePointsEarned Decimal(18,6),
------	ToDaysActual Decimal(18,6),PointsEarnedToday Decimal(18,6),GenerationDate Datetime,LastTranDate Datetime)
------
------	Create Table  #tmpInvoice1  (InvoiceID Int,InvoiceDate Datetime,
------	SalesmanID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Product_Code nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	MarketSKU nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	SubCategory nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Division nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Company nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	CategoryGroup nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Amount Decimal(18,6) ,InvoiceType Int,InvoiceDateWithTime Datetime,DSTypeID Int,Quantity Decimal(18,6),UOM1Qty Decimal(18,6),UOM2Qty Decimal(18,6) )
------
------	Create Table  #TmpOutput2 ([ID] Int Identity(1,1),ParamID Int,[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	DSID Int,
------	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Target Decimal(18,6),[Average Till Date] Decimal(18,6),
------	[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
------	[Till Date Points Earned] Decimal(18,6),
------	[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
------	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------	Create Table  #TmpOutput2BA1 ([ID] Int Identity(1,1),[WDCode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[WDDest] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	DSID Int,
------	DSName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[DS Type] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Performance Metrics Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Description nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Category Group] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[From Date] Datetime,[To Date] Datetime,Parameter nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Overall or Focus] nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Frequency nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	Target Decimal(18,6),[Average Till Date] Decimal(18,6),
------	[Till date Actual] Decimal(18,6),[Max Points] Decimal(18,6),
------	[Till Date Points Earned] Decimal(18,6),
------	[Todays Actual] Decimal(18,6),[Points Earned Today] Decimal(18,6),
------	[Generation Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------	[Last Transaction Date] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------	Create Table  #tmpInvDateWise1 (InvoiceDate Datetime,LinesOrBillsOrBA Decimal(18,6),InvoiceDateWithTime Datetime,
------								SalesPercentage Decimal(18,6),SlabID Int,Slab_Every Int,Slab_Value Decimal(18,6),
------								PointsEarned Decimal(18,6))
------
------	Create Table  #tmpDistinctPMDS1  (RowID Int Identity(1,1),PMID Int,DSTypeID Int,SalesmanName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------	Create Table  #TmpFocusItems1    (Product Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProLevel Int,Min_Qty Decimal(18,6),UOM Int)
------	Create Table  #tmpMinQtyInvItems1(Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
------			Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
------			MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
------			Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)
------
------
------
------	If @CatGroup = N'%' Or @CatGroup = N''
------	Begin
------		Insert Into #tmpCatGroup1(GroupName) Values ('GR1,GR3')
------		Insert Into #tmpCatGroup1(GroupName) Values ('GR1')
------		Insert Into #tmpCatGroup1(GroupName) Values ('GR2')
------		Insert Into #tmpCatGroup1(GroupName) Values ('GR3')
------	End
------
------	If @DSType = N'' Or @DSType = N'%'
------	Begin
------		Insert into #tmpDStype1
------		Select Distinct DSTypeValue From DSType_Master Where DSTypeCtlPos = 1
------	End
------
------
------	If @SalesName = N'%' Or @SalesName = N''
------	Begin
------		Insert into #tmpSalesman1
------		Select Salesman_Name From Salesman
------	End
------
------	Select @TillDate = GetDate()
------	Select @RptGenerationDate = @TillDate
------
------
------
------	If @ReportType = N'Monthly'
------	Begin
------		/* Will be given in MM/YYYY Format */
------		If @DateOrMonth = '' Or @DateOrMonth = '%'
------			Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
------		Else if  Len(@DateOrMonth) > 7
------			Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
------		Else if isDate(Cast(('01' + '/' + @DateOrMonth) as nVarchar(15))) = 0
------			Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)
------		Else
------			Set @Month = Cast(@DateOrMonth as nVarchar(7))
------
------		Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
------		Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')
------
------		Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
------		Set @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
------		If @UptoWeek = N'Week 1'
------			Begin
------					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(DD, 7,  @FromDate))))
------			End
------		Else If @UptoWeek =  N'Week 2'
------			Begin
------					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 14,  @FromDate))))
------			End
------		Else If @UptoWeek =  N'Week 3'
------			Begin
------					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(dd, 21,  @FromDate))))
------			End
------		Else If @UptoWeek =  N'Week 4' or @UptoWeek = N'' Or @UptoWeek = N'%'
------			Begin
------					Set @ToDate =  (Select DATEADD(s,-1,(DateAdd(MM, +1,  @DtMonth))))
------			End
------		If @ToDate > Convert(nVarchar(10), Getdate(), 103)
------			Begin
------				Set @ToDate = Convert(nVarchar(10), Getdate(), 103)
------			End
------
------		Set @MonthLastDate = @ToDate
------		Select @MonthFirstDate = @FromDate
------	End
------
------
------	If  (@TillDate > @MonthLastDate) Or (@TillDate < @MonthFirstDate)
------		Select @TillDate= @MonthLastDate
------
------	/* To Find Whether Day isclosed for the current month Last Day */
------	Select @DayClosed = 0
------	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
------	Begin
------		If @ReportType = N'Monthly'
------		Begin
------			If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(@MonthLastDate))
------			Select @DayClosed = 1
------		End
------	End
------
------	/* Last InvoiceDate taken */
------	Select @LastInvoiceDate = Max(InvoiceDate) From InvoiceAbstract
------	Where 	IsNull(Status,0) & 128 = 0	And InvoiceType in(1,3,4)
------
------	/* Filter the Invoices Which comes in between MonthFromDate And ReportGenerationdate(TillDate) */
--------	If @OCG=0
--------	Begin
------
------	/* Added by Soumya */
------		Select @MonthFirstDate = dbo.StripTimeFromDate(@MonthFirstDate)
------		Select @TillDate= dateadd(s,86399,dbo.StripTimeFromDate(@TillDate))
------	/* End of Addition */
------
------
------/* Removed by Soumya
------	Insert Into #tmpInvoice1
------	Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
------			 IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
------			 IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
------			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
------			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
------	From
------		InvoiceAbstract IA,InvoiceDetail Ide,Items I
------		,ItemCategories IC,ItemCategories IC1,
------		ItemCategories IC2,ItemCategories IC3,
------		tblcgdivmapping CGDiv,Salesman SM
------	Where
------		( IsNull(IA.Status,0) & 128 = 0)
------		And dbo.StripTimeFromDate(IA.InvoiceDate) Between @MonthFirstDate And @TillDate
------		And IA.InvoiceType in(1,3,4)
------		And IA.InvoiceID = Ide.InvoiceID
------		And Ide.Product_Code = I.Product_Code
------		And I.CategoryID = IC.CategoryID
------		And IC.ParentID = IC1.CategoryID
------		And IC1.ParentID = IC2.CategoryID
------		And IC2.ParentID = IC3.CategoryID
------		And IC2.Category_Name = CGDiv.Division
------		And IA.SalesmanID = SM.SalesmanID
------*/
------
------/* Added by Soumya */
------
------	Insert Into #tmpInvoice1
------	Select   IA.InvoiceID,IA.InvoiceDate,SM.SalesmanID,Ide.Product_Code,IC.Category_Name, IC1.Category_Name,
------			 IC2.Category_Name,IC3.Category_Name,CGDiv.CategoryGroup,isNull(Ide.Amount,0),IA.InvoiceType,
------			 IA.InvoiceDate,isNull(IA.DSTypeID,0),Isnull(Ide.Quantity,0),
------			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom1_Conversion,1)) as Decimal(18,6)),
------			 Cast((Isnull(Ide.Quantity,0)/Isnull(I.Uom2_Conversion,1)) as Decimal(18,6))
------	From
------		InvoiceAbstract IA,InvoiceDetail Ide,Items I
------		,ItemCategories IC,ItemCategories IC1,
------		ItemCategories IC2,ItemCategories IC3,
------		tblcgdivmapping CGDiv,Salesman SM
------	Where
------		( IsNull(IA.Status,0) & 128 = 0)
------		And IA.InvoiceDate Between @MonthFirstDate And @TillDate
------		And IA.InvoiceType in(1,3,4)
------		And IA.InvoiceID = Ide.InvoiceID
------		And Ide.Product_Code = I.Product_Code
------		And I.CategoryID = IC.CategoryID
------		And IC.ParentID = IC1.CategoryID
------		And IC1.ParentID = IC2.CategoryID
------		And IC2.ParentID = IC3.CategoryID
------		And IC2.Category_Name = CGDiv.Division
------		And IA.SalesmanID = SM.SalesmanID
------
------/* End of Addition*/
------
------
------
------	if @OCG=1
------	update #tmpInvoice1 set CategoryGroup = CGDiv.CategoryGroup From #tmpInvoice1 I, tblCGDivMapping CGDiv where I.Division = CGDiv.Division
------
------	-- Removed by Soumya -- Update #tmpInvoice1 Set Invoicedate = dbo.StripTimeFromDate(Invoicedate)
------
------
------	Create Table  #DSPMSalesman1 (SalesManid Int ,Salesman_Name Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,PMID Int,DSTypeValue Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CurrentdsType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,TargetStatus int, SalesStatus Int)
------	Insert into #DSPMSalesman1 (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
------	select Distinct PMM.SAlesmanid,SAlesman_name,PMM.PMID,DST.DSType,Null,0,0 from tbl_merp_PMetric_TargetDefn PMM, tbl_mERP_PMDSType DST,Salesman S
------	where PMM.PMID in (select PMID from tbl_mERP_PMMaster Where Period =@Period )
------	And PMM.Active = 1 and PMM.PMDSTypeid = DST.DSTypeid
------	And PMM.Salesmanid = S.Salesmanid
------
------	If @OCG=1
------	BEGIN
------		Insert into #DSPMSalesman1 (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
------		select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman1
------		from DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
------		(select PMID from tbl_mERP_PMMaster Where Period =@Period ) T Where
------			 T.PMID = PMDS.PMID
------		And  PMDS.DsType = DT.DSTypeValue
------		And DT.DSTYPEID = D.DSTYPEID
------		And S.SalesManid = D.SalesManid  and DT.DSTypectlpos =1
------		And TDF.PMID = T.PMID
------		And TDF.Target > 0
------		ANd TDF.Active = 1
------		--AND isnull(DT.Active,0)=1
------		--AND isnull(DT.OCGType,0)=1
------	END
------	ELSE
------	BEGIN
------		Insert into #DSPMSalesman1 (SalesManid,Salesman_Name,PMID,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
------		select Distinct S.SalesManid,S.Salesman_Name,T.PMID,DT.DSTypeValue,Null,0,0 --into #DSPMSalesman1
------		from DSType_Details D,DSType_Master DT, Salesman S, tbl_mERP_PMDSType PMDS, tbl_merp_PMetric_TargetDefn TDF,
------		(select PMID from tbl_mERP_PMMaster Where Period =@Period ) T Where
------			 T.PMID = PMDS.PMID
------		And  PMDS.DsType = DT.DSTypeValue
------		And DT.DSTYPEID = D.DSTYPEID
------		And S.SalesManid = D.SalesManid  and DT.DSTypectlpos =1
------		And TDF.PMID = T.PMID
------		And TDF.Target > 0
------		ANd TDF.Active = 1
------	END
------
------	If @OCG=1
------	BEGIN
------		Insert into #DSPMSalesman1 (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
------		Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 from #tmpInvoice1 I, DSType_Master DT, Salesman S
------		Where I.SalesManid not in (select Distinct SalesManid from #DSPMSalesman1) And Amount > 0
------		And DT.DSTYPEID = I.DSTYPEID
------		And I.SalesManid = S.SalesManid
------		and DT.DSTypectlpos =1
------	END
------	ELSE
------	Begin
------		Insert into #DSPMSalesman1 (SalesManid,Salesman_Name,DSTypeValue,CurrentdsType,TargetStatus,SalesStatus)
------		Select Distinct I.SalesManid,S.Salesman_Name,DT.DSTypeValue,Null,0,0 from #tmpInvoice1 I, DSType_Master DT, Salesman S
------		Where I.SalesManid not in (select Distinct SalesManid from #DSPMSalesman1) And Amount > 0
------		And DT.DSTYPEID = I.DSTYPEID
------		And I.SalesManid = S.SalesManid
------		and DT.DSTypectlpos =1
------	END
------
------	/* For OCG*/
------	If @OCG=0
------	Begin
------		Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman1 T1, (select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1 ) T
------		Where T1.Salesmanid = T.Salesmanid
------	End
------	Else
------	Begin
------		Update T1 set T1.CurrentdsType = T.CNT From #DSPMSalesman1 T1, (select Distinct Salesmanid, DSTypeValue CNT From DSType_Master TM,DSType_Details DD Where DD.DSTypeID = TM.DSTypeid And DD.DSTypectlpos =1 ) T
------		Where T1.Salesmanid = T.Salesmanid
------	End
------
------	update #DSPMSalesman1 set TargetStatus = 1 where Salesmanid in (select Distinct Salesmanid from tbl_merp_PMetric_TargetDefn where Target > 0 and Active = 1
------	and PMId in (select Distinct PMID from tbl_mERP_PMMaster Where Period =@Period))
------	update #DSPMSalesman1 set SalesStatus = 1 where Salesmanid in (select Distinct Salesmanid from #tmpInvoice1 Where Salesmanid not in (select Salesmanid from #DSPMSalesman1 Where TargetStatus = 1))
------	Update #DSPMSalesman1 set DSTypeValue = CurrentdsType
------	Update #DSPMSalesman1 set SalesStatus = 1 Where DSTypeValue = CurrentdsType and TargetStatus = 1
------
------	IF @OCG=0
------	Begin
------		/* Filter the PM based on the report parameter selected */
------		Insert Into #tmpPM2(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,--FocusID,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
------			,tbl_mERP_PMParamFocus ParamFocus
------			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice1) DSDet
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And DSDet.DSTypeID = DSMast.DSTypeID
------			And SM.SalesmanID = DSDet.SalesmanID
------			And SM.Salesman_Name In(Select Salesman From #tmpSalesman1)
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------	End
------	ELSE
------	BEGIN
------		/* Filter the PM based on the report parameter selected */
------		Insert Into #tmpPM2(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,Case When (ParamFocus.PMProductName) = 'ALL' then 'OverAll' else (ParamFocus.PMProductName) end 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
------			,tbl_mERP_PMParamFocus ParamFocus
------			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice1) DSDet
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And DSDet.DSTypeID = DSMast.DSTypeID
------			And SM.SalesmanID = DSDet.SalesmanID
------			And SM.Salesman_Name In(Select Salesman From #tmpSalesman1)
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------	END
------	/*If there is no sales for a salesman, then if that salesman alone is selected then, report is generating blank
------	but if all salesman is selected then that salesman is coming with blank row. So we addressed that issue by creating empty row when that
------	particular salesman is selected*/
------	If @OCG=0
------	Begin
------		Insert Into #tmpPM2(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
------			tbl_mERP_PMParamFocus ParamFocus
------			,(select Distinct PMID,Salesmanid,DSTypeValue from #DSPMSalesman1) TMPDS
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And SM.SalesmanID = PMTar.SalesmanID
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------			And PMTar.Target > 0
------			And PMTar.PMID = Master.PMID
------			And TMPDS.Salesmanid = PMTar.Salesmanid
------			And TMPDS.DSTypeValue = DSMast.DSTypeValue
------			and TMPDS.Salesmanid not in (select distinct salesmanid from #tmpPM2)
------	END
------	ELSE
------	BEGIN
------		Insert Into #tmpPM2(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param,tbl_merp_PMetric_TargetDefn PMTar,
------			tbl_mERP_PMParamFocus ParamFocus
------			,(select Distinct PMID,Salesmanid,DSTypeValue from #DSPMSalesman1) TMPDS
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And SM.SalesmanID = PMTar.SalesmanID
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------			And PMTar.Target > 0
------			And PMTar.PMID = Master.PMID
------			And TMPDS.Salesmanid = PMTar.Salesmanid
------			And TMPDS.DSTypeValue = DSMast.DSTypeValue
------			and TMPDS.Salesmanid not in (select distinct salesmanid from #tmpPM2)
------	END
------	If @OCG=0
------	Begin
------		Insert Into #tmpPM21(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
------			,tbl_mERP_PMParamFocus ParamFocus
------			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice1) DSDet
------			,(select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue from #DSPMSalesman1 Where SalesStatus = 1) TMPDS
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And SM.Salesman_Name  = TMPDS.Salesman_Name
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------			And TMPDS.DSTypeValue = DSMast.DSTypeValue
------			And SM.Salesmanid in ( select Distinct Salesmanid from #DSPMSalesman1)
------	END
------	ELSE
------	BEGIN
------		Insert Into #tmpPM21(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,
------		ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,
------		DS_MaxPoints,Param_MaxPoints)
------		Select Distinct Master.PMID ,SM.SalesmanID ,SM.Salesman_Name,DStype.DSTypeID,DSMast.DSTypeID, DStype.DSType ,Master.PMCode,Master.Description,
------		Replace(Master.CGGroups,'|',','),Param.ParameterType,Param.Frequency,
------		Param.ParamID,ProdCat_Level,(ParamFocus.PMProductName) 'isFocusParam',
------		isNull(DSType.MaxPoints,0) 'DS_MaxPoints',isNull(Param.MaxPoints,0) 'Param_MaxPoints'
------		From
------			tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,#tmpDStype1 DS,
------			Salesman SM,DSType_Master DSMast,tbl_mERP_PMParam Param
------			,tbl_mERP_PMParamFocus ParamFocus
------			,(Select Distinct SalesmanID,DSTypeID From #tmpInvoice1) DSDet
------			,(select Distinct PMID,Salesmanid,Salesman_Name,DSTypeValue from #DSPMSalesman1 Where SalesStatus = 1) TMPDS
------		Where
------			Master.Period = @Period
------			And Master.Active = 1
------			And Master.PMID = DSType.PMID
------			And DStype.DSType = DS.DStype
------			And	Replace(Master.CGGroups,'|',',') In (Select Distinct GroupName From #tmpCatGroup1)
------			And DSMast.DSTypeValue = DStype.DSType
------			And DSMast.DSTypeCtlPos = 1
------			And SM.Salesman_Name  = TMPDS.Salesman_Name
------			And Param.DSTypeID = DSType.DSTypeID
------			And Param.ParamID  = ParamFocus.ParamID
------			And TMPDS.DSTypeValue = DSMast.DSTypeValue
------			And SM.Salesmanid in ( select Distinct Salesmanid from #DSPMSalesman1)
------	END
------
------	Declare @tmpPM2ID int
------    Declare Cur_PM1 Cursor For
------    Select PMID,SalesManID,DSType from #tmpPM21
------    Open Cur_PM1
------    Fetch next from Cur_PM1 Into @tmpPM2ID,@tmpDSID,@DSTYPEValue
------    While @@Fetch_Status = 0
------	Begin
------			If not exists (select * from #tmpPM2 where PMID=@tmpPM2ID and Salesmanid = @tmpDSID And DSType = @DSTYPEValue)
------				Begin
------				insert into #tmpPM2(PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints)
------				select Distinct PMID,SalesmanID,Salesman_Name,DSTypeID,DSTypeCode,DSType,PMCode,PMDescription,CGGroups,ParameterType,Frequency,ParamID,Prod_Level,isFocusParam,FocusID,DS_MaxPoints,Param_MaxPoints from #tmpPM21 where PMID=@tmpPM2ID and Salesmanid = @tmpDSID And DSTYPE = @DSTYPEValue
------				end
------			Fetch next from Cur_PM1 into @tmpPM2ID,@tmpDSID ,@DSTYPEValue
------	End
------	Close Cur_PM1
------    Deallocate Cur_PM1
------
------
------    /*To Insert DSType and Param info from PMetric_TargetDefn table for Salesman having Target with nil Invoices*/
------    Create Table  #tDSTgtZeroInv1 (TGT_PMID Int, TGT_DSTYPEID Int, TGT_PARAMID Int, TGT_SMID int, TGT_TARGETVAL Decimal(18,6), TGT_MAXPOINT Decimal(18,6),
------                                 TGT_FREQUENCY Int, TGT_ISFOCUSPARAM nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS, TGT_PARAMMAX Decimal(18,6), TGT_PARAMTYPE Int)
------   -- Declare @TGTPMID Int, @TGTDSTYPEID Int, @TGTPARAMID Int
------    Declare Cur_TgtPMLst Cursor For
------    Select Distinct PMID, PMDSTYPEID, PARAMID from tbl_merp_PMetric_TargetDefn where Active = 1 And PMID in (Select Distinct PMID from #tmpPM2)
------    Open Cur_TgtPMLst
------    Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
------    While @@Fetch_Status = 0
------    Begin
------      Insert into #tDSTgtZeroInv1(TGT_PMID, TGT_DSTYPEID, TGT_PARAMID, TGT_SMID, TGT_TARGETVAL, TGT_MAXPOINT, TGT_FREQUENCY, TGT_ISFOCUSPARAM, TGT_PARAMTYPE, TGT_PARAMMAX)
------      Select Tdf.PMID, Tdf.PMDSTYPEID, Tdf.PARAMID, Tdf.SALESMANID, Tdf.TARGET, Tdf.MAXPOINTS, PMP.FREQUENCY,
------     (PMFocus.PMProductName),PMP.ParameterType, PMP.MaxPoints
------      From tbl_merp_PMetric_TargetDefn Tdf, tbl_mERP_PMParam PMP, tbl_mERP_PMParamFocus PMFocus
------      Where Tdf.ACTIVE= 1 And Tdf.PMID = @TGTPMID And Tdf.PMDSTYPEID = @TGTDSTYPEID And Tdf.PARAMID = @TGTPARAMID
------        And Tdf.SALESMANID not in (Select Distinct SalesmanID from #tmpPM2 Where PMID = @TGTPMID And DSTypeID = @TGTDSTYPEID And PARAMID = @TGTPARAMID And isNull(AverageTillDate,0) <> 0)
------        And PMP.ParamID = Tdf.ParamID
------        And PMP.ParamID = PMFocus.ParamID
------		and Tdf.SALESMANID in (select salesmanid from salesman where salesman_name in(select Salesman from #tmpSalesman1))
------      Fetch next from Cur_TgtPMLst into @TGTPMID, @TGTDSTYPEID, @TGTPARAMID
------    End
------    Close Cur_TgtPMLst
------    Deallocate Cur_TgtPMLst
------
------	Update #tmpPM2 Set GenerationDate = @RptGenerationDate,LastTranDate = @LastInvoiceDate
------
------	Insert Into #tmpDistinctPMDS1(PMID,DSTypeID,SalesmanName)
------	Select Distinct PMID,DSTypeID,Salesman_Name From #tmpPM2
------    Union
------
------    Select Distinct TGT_PMID,TGT_DSTYPEID, SM.Salesman_Name From #tDSTgtZeroInv1 tDST, Salesman SM,
------	tbl_mERP_PMDSType PMDST
------    Where SM.SalesManID = tDST.TGT_SMID
------	AND PMDST.PMID = tDST.TGT_PMID
------	AND PMDST.DSTypeID=tDST.TGT_DSTYPEID
------	AND PMDST.DSType in (Select DStype from #tmpDStype1)
------
------
------	Update #tmpPM2 Set GenerationDate = @RptGenerationDate
------
------	/* To Add Subtotal and GrandTotal Row Begins */
------	Select @PMMaxCount = 0
------    Declare Cur_Counter2 Cursor For
------    Select Rowid from #tmpDistinctPMDS1 order by PMID,SalesmanName
------    Open Cur_Counter2
------    Fetch next from Cur_Counter2 Into @Counter
------    While @@Fetch_Status = 0
------	Begin
------
------		Select @PMID = 0,@PMDSTypeID = 0,@MaxPoints=0,@TillDatePointsEarned=0,@ToDaysPointsEarned=0,@SalesmanName=''
------		Select @PMID = PMID ,@PMDSTypeID = DSTypeID,@SalesmanName=SalesmanName From #tmpDistinctPMDS1 Where RowID = @Counter
------
------		Select @MaxPoints = Cast(Max(DS_Maxpoints) as Decimal(18,6)) ,@TillDatePointsEarned = Sum(isNull(TillDatePointsEarned,0)) ,
------		@ToDaysPointsEarned = Sum(isNull(PointsEarnedToday,0))
------		From #tmpPM2 Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
------
------		Insert Into #TempVal1
------		Select Distinct ParamID,@WDCode as 'WDCode' ,@WDDest as 'WDDest',Salesman_Name as 'DSName',DSType  as 'DS Type',PMCode as 'Performance Metrics Code',PMDescription as 'Description',Replace(CGGroups,',','|') [Category Group],@FromDate [From Date],Convert(nVarchar(10), @ToDate, 103) [To Date],
------		  (Case ParameterType When 1 Then N'Lines Cut' When 2 Then N'Bills Cut' When 3 Then N'Business Achievement' When 4 then 'Go Green OBJ' When 5 Then 'Reduce Red OBJ' End) 'Parameter',
------		  isFocusParam 'Overall or Focus',(Case Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End) 'Frequency',
------		  (Case ParameterType When 3 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then Cast(isNull(Target,0)/25. as decimal(18,6)) Else Cast(isNull(Target,0) as Decimal(18,6)) End) Else NULL End) Target,
------		  AverageTillDate [Average Till Date],TillDateActual [Till date Actual],(Case ParameterType When 3 Then Cast(isNull(MaxPoints,0) as Decimal(18,6)) Else NULL End) [Max Points],
------		  (Case ParameterType When 3 Then
------							(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(TillDatePointsEarned,0) as decimal(18,6)) End) End)
------							Else Cast(isNull(TillDatePointsEarned,0) as Decimal(18,6)) End)[Till Date Points Earned],
------	      ToDaysActual [Todays Actual],
------		  (Case ParameterType When 3 Then
------							(Case @DayClosed When 0 Then NULL When 1 Then (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End)
------							Else (Case When (Frequency = 2 And @ReportType = 'Daily') Then NULL Else Cast(isNull(PointsEarnedToday,0) as Decimal(18,6)) End) End) [Points Earned Today],
------		  GenerationDate [Generation Date],
------		  LastTrandate [Last Transaction Date],
--------		  Convert(nVarchar(10),GenerationDate,103) + N' ' + Convert(nVarchar(8),GenerationDate,108) [Generation Date],
--------		  Convert(nVarchar(10),LastTrandate,103) + N' ' + Convert(nVarchar(8),LastTrandate,108) [Last Transaction Date],
------		  (Case ParameterType When 1 Then 2 When 2 Then 1 When 3 Then 3 When 4 Then 4 When 5 Then 5 End) 'ParameterTypeID',Frequency 'FrequencyID'
------
------		From #tmpPM2 ,tbl_mERP_PMParamType ParamType
------		Where PMID = @PMID And DSTypeID = @PMDSTypeID And Salesman_Name = @SalesmanName
------		  And ParamType.ID = ParameterType
------
------        Insert Into #TmpOutput2(ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
------          [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
------		  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
------		  [Last Transaction Date])
------		Select ParamID,[WDCode],[WDDest],DSName,[DS Type],[Performance Metrics Code],Description,[Category Group],
------          [From Date],[To Date],Parameter,[Overall or Focus],Frequency,Target,[Average Till Date],[Till date Actual],
------		  [Max Points],[Till Date Points Earned],[Todays Actual],[Points Earned Today],[Generation Date],
------		  [Last Transaction Date]
------		From #TempVal1 Order by [Performance Metrics Code],[DS Type],DSName,ParameterTypeID,FrequencyID Asc
------
------		Delete From #TempVal1
------
------    Fetch next from Cur_Counter2 Into @Counter
------	End
------    Close Cur_Counter2
------    Deallocate Cur_Counter2
------
------	Update T1  Set T1.DSID = T2.Cnt  from #TmpOutput2 T1,(Select SalesMan_Name, SalesManId as Cnt  from Salesman) T2 Where T1.DSName = T2.SalesMan_Name
------	Update 	#TmpOutput2 set Target = 0 Where isnull(Target,0) = 0 and Parameter = 'Business Achievement'
------
------/* GGDR Process Start :*/
------	If @ReportType = 'Monthly'
------	Begin
------		Create Table  #TmpGGDRDSData (
------				DSID Int,
------				DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Create Table  #TmpGGDRAbstract (
------			[DS ID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
------			[CustomerID] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
------			ProdDenfID Int,
------			CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,
------			[Status] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
------			[Current Status] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
------
------		Create Table  #RedOBJData  (DSID Int,
------				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Create Table  #GreenOBJData  (DSID Int,
------				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Create Table  #TmpGGDRDSPointsData (
------				Paramid Int,
------				DSID Int,
------				DSName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				Parameter Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				TillDateActual Decimal(18,6),
------				SlabFrom Decimal(18,6),
------				SlabTo Decimal(18,6),
------				ForEvery Decimal(18,6),
------				PointValue Decimal(18,6))
------
------		Delete From #TmpGGDRAbstract
------		Insert Into #TmpGGDRAbstract
------		Select * from dbo.mERP_FN_TargetsforGGDR_View()
------
------		Delete From #TmpGGDRAbstract Where [Status] = [Current Status]
------
------		Insert Into #RedOBJData
------		Select Distinct [DS ID],CategoryGroup,[CustomerID] From #TmpGGDRAbstract Where [Status] = 'Red'
------
------		Insert Into #GreenOBJData
------		Select Distinct [DS ID],CategoryGroup,[CustomerID] From #TmpGGDRAbstract Where [Status] = 'Eligible for Green'
------
------		Update Red set Red.CategoryGroup = (Case When Isnull(@OCG,0) = 1 Then Left(Red.CategoryGroup,3) Else Red.CategoryGroup End) from #RedOBJData Red
------		Update Red set Red.CategoryGroup = Case When Red.CategoryGroup = 'GR3' Then 'GR1' Else Red.CategoryGroup End from #RedOBJData Red
------
------		Update T Set T.[Till date Actual] = T1.Cnt
------		From #TmpOutput2 T, (select Distinct DSID,CategoryGroup,Count(Distinct CustomerID) Cnt from #RedOBJData Group By DSID,CategoryGroup) T1
------		Where T.DSID = T1.DSID
------		And Replace(T.[Category Group],'|',',')  like  '%' +  T1.CategoryGroup + '%'
------		And T.Parameter = 'Reduce Red OBJ'
------
------		Update Green set Green.CategoryGroup = Case When Isnull(@OCG,0) = 1 Then Left(Green.CategoryGroup,3) Else Green.CategoryGroup End from #GreenOBJData Green
------		update Green set Green.CategoryGroup = Case When Green.CategoryGroup = 'GR3' Then 'GR1' Else Green.CategoryGroup End from #GreenOBJData Green
------
------		Update T Set T.[Till date Actual] = T1.Cnt
------		From #TmpOutput2 T, (select Distinct DSID,CategoryGroup,Count(Distinct CustomerID) Cnt from #GreenOBJData Group By DSID,CategoryGroup) T1
------		Where T.DSID = T1.DSID
------		And Replace(T.[Category Group],'|',',')  like  '%' +  T1.CategoryGroup + '%'
------		And T.Parameter = 'Go Green OBJ'
------
------	/* Points Calculation Start: */
--------		If (Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >= dbo.StripTimeFromDate(DateAdd(d,-1,DateAdd(m,1,Cast(('01/' + cast(@DateOrMonth as nvarchar)) as dateTime))))
------		Begin
------			Insert Into #TmpGGDRDSPointsData (ParamID,DSID,DSname,DSType,Parameter,TilldateActual)
------			Select ParamID,DSID,DSname,[DS Type],Parameter,[Till date Actual] From #TmpOutput2 Where Parameter In ('Go Green OBJ','Reduce Red OBJ') And Isnull([Till date Actual] ,0) > 0
------
------			Declare @GGDRParamID as Int
------			Declare @GGDRTilldateActual as Decimal(18,6)
------
------			Declare Cur_GGDRPoints Cursor for
------			Select ParamID,TilldateActual From #TmpGGDRDSPointsData
------			Open Cur_GGDRPoints
------			Fetch from Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
------			While @@fetch_status =0
------				Begin
------					Update T Set T.SlabFrom = T1.Slab_Start,
------								 T.SlabTo = T1.Slab_End,
------								 T.ForEvery = T1.Slab_Every_Qty,
------								 T.PointValue = T1.Slab_Value From #TmpGGDRDSPointsData T,
------					(select ParamID,Slab_Start,Slab_End,Slab_Every_Qty,Slab_Value From tbl_mERP_PMParamSlab Where ParamID = @GGDRParamID and @GGDRTilldateActual Between Slab_Start and Slab_End) T1
------					Where T.paramID = T1.ParamID
------
------					Fetch Next from Cur_GGDRPoints into @GGDRParamID,@GGDRTilldateActual
------				End
------			Close Cur_GGDRPoints
------			Deallocate Cur_GGDRPoints
------
------			Update T Set T.[Till Date Points Earned] = T1.NetPoints from #TmpOutput2 T,
------			(select ParamID,DSID,DSname,DSType,Parameter,TilldateActual,
------			((Cast(TilldateActual/
------				(Case
------					When isnull(ForEvery,0) = 0 Then 1
------					Else isnull(ForEvery,0)
------					End) as Int)) * PointValue
------				) NetPoints
------			From #TmpGGDRDSPointsData) T1
------			Where T.ParamID = T1.ParamID
------			And T.DSID = T1.DSID
------			And T.DSName = T1.DSName
------			And T.[DS Type] = T1.DSType
------			And T.Parameter = T1.Parameter
------			And T.[Till date Actual] = T1.TilldateActual
------		End
------	/* Points Calculation End. */
------
------		Declare @OCGFlag as int
------		Declare @TmpGGDRCust as Table (DSID Int,DSType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CustomerID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CategoryGroup nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				status nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
------				, CatGrp_Green nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
------		set @OCGFlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')
------
------		Insert Into @TmpGGDRCust
------		Select Distinct T.DSID,T.[DS Type],B.CustomerId,G.PMCatGroup ,G.OutletStatus
------		, Case When Isnull(@OCGFlag,0) = 0 Then CatGrouP Else OCG End
------		From Beat_salesman B,#TmpOutput2 T,GGDROutlet G
------		Where B.SalesmanId = T.DSID And T.Parameter In ('Go Green OBJ','Reduce Red OBJ')
------		And isnull(B.CustomerId,'') <> ''
------		And B.CustomerId = G.OutletID
------		And Isnull(G.Active,0) = 1
------		And @GGRRMonth Between G.ReportFromdate and G.ReportTodate
------		--And cast(('01-' + @DateOrMonth) as DateTime) Between cast(('01-' + G.Fromdate) as DateTime) and cast(('01-' + G.Todate) as DateTime)
------
------		Create Table #GreenTarget (DSID Int,DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
------				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Create Table #FinalTarget (DSID Int,DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Cnt int,
------				CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
------				PMCatGrp Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Insert into #GreenTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
------		Select DSID,DSType, CustomerId, CatGrp_Green, CategoryGroup From @TmpGGDRCust
------				Where Status = 'EG'
------				Group By DSID,DSType,CustomerId, CatGrp_Green, CategoryGroup
------
------		Create Table  #tmpDSCG (DSID Int, CategoryGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
------
------		Insert into #tmpDSCG(DSID, CategoryGroup)
------		Select SalesmanID,GroupName from dbo.fn_CG_View_PM()
------
------		Insert into #FinalTarget(DSID, DSType, CustomerID, CategoryGroup, PMCatGrp)
------		Select a.DSID, a.DSType, a.CustomerID, a.CategoryGroup, a.PMCatGrp From #GreenTarget a, #tmpDSCG b
------		Where a.DSID = b.DSID and a.CategoryGroup = b.CategoryGroup
------
------		Declare @Tar_DSID as Int
------		Declare @Tar_DSType as Nvarchar(255)
------		Declare @Tar_CatGroup as Nvarchar(255)
------
------		Declare Cur_GGDRtarget Cursor for
------		Select DSId,[DS Type],[Category Group] From #TmpOutput2 Where Parameter In ('Go Green OBJ','Reduce Red OBJ')
------		Open Cur_GGDRtarget
------		Fetch from Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
------		While @@fetch_status =0
------			Begin
------
------				Update T Set T.Target = T1.Cnt From #TmpOutput2 T,
------				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
------				Where Status = 'R' and DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = @Tar_CatGroup
------				Group By DSID,DSType)T1
------				Where T.DSID = T1.DSID
------				And T.[DS Type] = T1.DSType
------				And T.DSID = @Tar_DSID
------				And T.[DS Type] = @Tar_DSType
------				And T.[Category Group] = @Tar_CatGroup
------				And T.Parameter In ('Reduce Red OBJ')
------
--------				Update T Set T.Target = T1.Cnt From #TmpOutput2 T,
--------				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From @TmpGGDRCust
--------				Where Status = 'EG' and DSId = @Tar_DSID And DStype = @Tar_DSType And CategoryGroup = @Tar_CatGroup
--------				Group By DSID,DSType)T1
--------				Where T.DSID = T1.DSID
--------				And T.[DS Type] = T1.DSType
--------				And T.DSID = @Tar_DSID
--------				And T.[DS Type] = @Tar_DSType
--------				And T.[Category Group] = @Tar_CatGroup
--------				And T.Parameter In ('Go Green OBJ')
------
------
------				Update T Set T.Target = T1.Cnt From #TmpOutput2 T,
------				(Select DSID,DSType,Count(Distinct CustomerId) Cnt From #FinalTarget
------				Where DSId = @Tar_DSID And DStype = @Tar_DSType And PMCatGrp = @Tar_CatGroup
------				Group By DSID,DSType)T1
------				Where T.DSID = T1.DSID
------				And T.[DS Type] = T1.DSType
------				And T.DSID = @Tar_DSID
------				And T.[DS Type] = @Tar_DSType
------				And T.[Category Group] = @Tar_CatGroup
------				And T.Parameter In ('Go Green OBJ')
------
------				Fetch Next from Cur_GGDRtarget into @Tar_DSID,@Tar_DSType,@Tar_CatGroup
------			End
------		Close Cur_GGDRtarget
------		Deallocate Cur_GGDRtarget
------
------		Delete From #TmpGGDRDSData
------		Delete From #TmpGGDRAbstract
------		Delete From #TmpGGDRDSPointsData
------		Delete From #GreenTarget
------		Delete From #tmpDSCG
------		Delete From #FinalTarget
------	End
------/* GGDR Process End.*/
------
------	Delete From #TmpOutput2 Where Isnull([Performance Metrics Code],'') = ''
------	Delete From #TmpOutput2 Where Parameter Not In ('Go Green OBJ','Reduce Red OBJ')
------
------	Insert Into #Output
------	Select Distinct DSID,Sum(Isnull([Till date Actual],0)),Sum(Isnull([Till Date Points Earned],0)),
------	(Case When Parameter = 'Go Green OBJ' Then 'Green' When Parameter = 'Reduce Red OBJ' Then 'Red' End )
------	From #TmpOutput2 T,(select Distinct S.SalesmanID from dstype_details DD,dstype_master DM,Salesman S where DD.dstypectlpos = 2
------	And DM.DSTypeValue = 'Yes'
------	And DM.Active = 1
------	And DM.DStypeID = DD.DStypeID
------	And S.Active = 1
------	And S.SalesmanID = DD.SalesmanID) S
------	Where T.DSID = S.SalesmanID
------	Group By DSID,Parameter
------
------	Drop Table #tmpHHSM1
------	Drop Table #tmpCatGroup1
------	Drop Table #tmpDStype1
------	Drop Table #tmpSalesman1
------	Drop Table #TempVal1
------	Drop Table #tmpPM2
------	Drop Table #tmpPM21
------	Drop Table #tmpInvoice1
------	Drop Table #TmpOutput2
------	Drop Table #TmpOutput2BA1
------	Drop Table #tmpInvDateWise1
------	Drop Table #tmpDistinctPMDS1
------	Drop Table #TmpFocusItems1
------	Drop Table #tmpMinQtyInvItems1
------	Drop Table #DSPMSalesman1
------	Drop Table #TmpGGDRDSData
------	Drop Table #TmpGGDRAbstract
------	Drop Table #TmpGGDRDSPointsData
------	Drop Table #GreenTarget
------	Drop Table #tmpDSCG
------	Drop Table #FinalTarget
------
------
------/* V_SD_PM mERP_FN_PointsforGGDR_View  End  */
------
------/*V_SD_PM Start */
------
Truncate table tmpDSPMSalesman

Create Table #TmpOutput1 (SalesmanID int,SDObjective nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,TotalOutlets Decimal(18,6),ConvertedOutlets Decimal(18,6),Points decimal(18,6))
Select @OCG = Isnull(Flag,0) From tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS'
select @DateOrMonth1 = dbo.striptimefromdate(getdate())--Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())

Create Table #GGDR_DSTypeCustomer (SalesmanId Int,CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, GGDRCatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,OutletStatus Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #SalesManCatGroup (SalesmanId Int,CatGroup Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Insert Into #SalesManCatGroup (SalesmanId,CatGroup)
Select Distinct DT.SalesmanID,G.GroupName
from DSType_Details DT, tbl_mERP_DSTypeCGMapping M,ProductCategoryGroupAbstract G
Where Isnull(DT.DSTypeCtlPos,0) = 1
And DT.DStypeID = M.DSTypeID
And Isnull(M.Active,0) = 1
And G.GroupID = M.GroupID
And Isnull(G.Active,0) = 1

Insert Into #GGDR_DSTypeCustomer (SalesManID,CustomerID,GGDRCatGroup,OutletStatus)
Select Distinct B.SalesmanID,G.OutletID,(Case When @OCG = 0 Then G.CatGroup Else G.OCG End),G.OutletStatus
From GGDROutlet G,Beat_salesman B,#SalesManCatGroup S
Where isnull(B.CustomerId,'') <> ''
And B.CustomerId = G.OutletID
And Isnull(G.Active,0) = 1
And @DateOrMonth1 between G.ReportFromDate and G.ReportToDate
And B.SalesmanID = S.SalesmanID
And (Case When @OCG = 0 Then G.CatGroup Else G.OCG End) = S.CatGroup
And Isnull(G.flag,'')!='WS'

--Insert into #TmpOutput1
--Select DSID,Isnull(Parameter,0),0,Isnull(ConvertedOutlets,0),Isnull(Points,0) From #Output

Insert into #TmpOutput1
Select DSID,Isnull(Parameter,0),0,Isnull(ConvertedOutlets,0),Isnull(Points,0) From dbo.mERP_FN_PointsforBLOCKBUSTER_View()


Update T set T.TotalOutlets = T1.Cnt From #TmpOutput1 T,
(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
From #TmpOutput1 T,#GGDR_DSTypeCustomer G
Where G.SalesmanId = T.SalesmanID
And G.OutletStatus = 'R'
Group By T.SalesmanID) T1
Where T.SalesmanID = T1.SalesmanID
And T.SDObjective = 'Red'

Update T set T.TotalOutlets = T1.Cnt From #TmpOutput1 T,
(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
From #TmpOutput1 T,#GGDR_DSTypeCustomer G
Where G.SalesmanId = T.SalesmanID
And G.OutletStatus = 'EG'
Group By T.SalesmanID) T1
Where T.SalesmanID = T1.SalesmanID
And T.SDObjective = 'Green'

Update T set T.TotalOutlets = T1.Cnt From #TmpOutput1 T,
(Select Distinct T.SalesmanID,Count(Distinct G.CustomerId) Cnt
From #TmpOutput1 T,#GGDR_DSTypeCustomer G
Where G.SalesmanId = T.SalesmanID
And G.OutletStatus = 'EG'
Group By T.SalesmanID) T1
Where T.SalesmanID = T1.SalesmanID
And T.SDObjective = 'Blockbuster'


insert into tmpDSPMSalesman (SalesmanID,SDObjective,TotalOutlets,ConvertedOutlets,Points)
Select SalesmanID,SDObjective,TotalOutlets,ConvertedOutlets,Points From #TmpOutput1 where SDObjective <> '0'


Drop Table #TmpOutput1
Drop Table #GGDR_DSTypeCustomer
Drop Table #SalesManCatGroup
--Drop Table #Output


-- View logic changes done


Declare @GGDRmonth Nvarchar(10)
Set @GGDRmonth=Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())

Create Table #DSType(SalesmanID int, DSTypeID int, DSTypeValue nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #FinalData(CategoryGroup nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSID int,
CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, ProdDefnID Int,
Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Target Decimal(18,6), Actual Decimal(18,6))

Insert Into #DSType(SalesmanID, DSTypeID, DSTypeValue)
Select DS.SalesManID as DSID,DSTM.DSTypeID as DSTID,DSTM.DSTypeValue
From Salesman DS, DSType_Master DSTM, DSType_Details DSTD
Where DSTM.Active = 1 and DSTM.DSTypeID = DSTD.DSTypeID and
DSTD.SalesManID = DS.SalesManID and
DS.Active = 1
and DSTD.SalesManID in (Select SalesManID from DSType_Details where salesmanID=DSTD.SalesManID and DSTYpeID =
(Select Top 1 DSTYpeID from DSType_Master where DSTypeName='Handheld DS' and DSTypeValue='Yes') )
and DSTM.DSTypeName <> 'Handheld DS'

Insert Into #FinalData(CategoryGroup, DSID, CustomerID, ProdDefnID, Product_Code, Target, Actual)
Select PMCategory, DSID, CustomerID, ProdDefnID, D_ProductCode, D_Target, D_Actual
From GGRRFinalData GD, #DSType DS
Where Cast('01-' + [Month] as dateTime) = Cast('01-'+ @GGDRmonth as DateTime)
and GD.DSID = DS.SalesmanID
and GD.DSType = DS.DSTypeValue
and Isnull(GD.flag,'') = 'WS'

Insert Into tmpDSPMSalesman (SalesmanID,SDObjective,TotalOutlets,ConvertedOutlets,Points)
Select DSID SalesmanID,
Case When CategoryGroup = 'GR1|GR3' Then 'WinnerFood' When CategoryGroup = 'GR2' Then 'WinnerPCP' End as SDObjective,
Count(*) TotalOutlets, SUM(Case When Actual - Target >=0 Then 1 Else 0 End) as  ConvertedOutlets, 0 as Points
From #FinalData
Group By DSID, CategoryGroup
Order By DSID

Drop Table #DSType
Drop Table #FinalData

/*V_SD_PM End */

/* V_DailySKU Changed  For V_Item_Master Changes - Start*/
Truncate Table Tmp_SKUOPT_DailySKU

Create Table  #tempMarketSKU (MKTSKU nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int,Flag nvarchar(1)  COLLATE SQL_Latin1_General_CP1_CI_AS,customerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,OverallSOH decimal(18,6),SKU nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)

insert into #tempMarketSKU (MKTSKU,customerID,Flag,SKU)
select distinct MarketSKU,customerID,
Case When
(max(Case When Type = 'MAIN' Then 0
When Type='HM' Then 1
else 0 end))= 0 Then 'M' else 'H'
End,
SKU from tbl_SKUOpt_Monthly where isnull(status,0)=1
Group by MarketSKU,customerID,SKU


/* updating category ID*/
update M set CategoryID=IC.CategoryID from #tempMarketSKU M, Itemcategories IC
Where IC.Category_Name=M.MKTSKU
and isnull(IC.active,0)=1

insert into Tmp_SKUOPT_DailySKU (CategoryID,Flag,customerID,ProductCode)
select M.CategoryID,Flag,customerID,I.Product_Code Product_Code from #tempMarketSKU M,Items I
Where M.CategoryID=I.CategoryID
And M.SKU=I.Product_code
And isnull(i.active,0)=1
Drop Table #tempMarketSKU
/* V_DailySKU Changed  For V_Item_Master Changes - End*/


/* V_Invoice changes*/

Create Table #TmpInvAbsDet(InvoiceID int, InvoiceDate Datetime, DocumentID nvarchar(255) ,
DocReference nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, NetValue Decimal(18,6),
CustomerID nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, BeatID int, SalesmanID int,
Status int, InvoiceType int, CreationTime Datetime, CancelDate Datetime,
SONumber  nvarchar(510) Collate SQL_Latin1_General_CP1_CI_AS,
Product_Code nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18,6),
SalePrice Decimal(18,6), Amount Decimal(18,6),GSTFlag int)

Insert into #TmpInvAbsDet
Select InvAbs.InvoiceID, InvAbs.InvoiceDate,
--InvAbs.DocumentID,
Case IsNULL(InvAbs.GSTFlag ,0)
When 0 then Cast(InvAbs.DocumentID as nvarchar)
Else
IsNULL(InvAbs.GSTFullDocID,'')
End,
InvAbs.DocReference, InvAbs.NetValue,
InvAbs.CustomerID, InvAbs.BeatID, InvAbs.SalesmanID, InvAbs.Status, InvAbs.InvoiceType, InvAbs.CreationTime,
InvAbs.CancelDate, InvAbs.SONumber, InvDet.Product_Code, InvDet.Quantity, InvDet.SalePrice, InvDet.Amount,isnull(InvAbs.GSTFlag,0)
From InvoiceAbstract InvAbs, InvoiceDetail InvDet
Where
InvAbs.InvoiceDate between DateAdd(m,-3,Getdate()) and getdate()
And InvAbs.InvoiceType in (1,3)
And InvAbs.InvoiceID = InvDet.InvoiceID

Create Table #tmpOrdDet(ORDERNUMBER nvarchar(100) Collate SQL_Latin1_General_CP1_CI_AS, SALEORDERID int)

Insert Into #tmpOrdDet
Select Distinct ORDERNUMBER, SALEORDERID From Order_Details Where IsNull(SALEORDERID, 0) <> 0

Truncate Table Tmp_VInvoice

Insert Into Tmp_VInvoice(InvoiceDate, InvoiceID, DocumentID, DocumentReference, Order_ID, OrderReference, InvoiceAmount, CustomerID,
BeatID, SalesmanID, ItemCode, Quantity_in_Base_UOM, Quantity_in_UOM1, Quantity_in_UOM2, Price_in_Base_UOM,
Price_in_UOM1, Price_in_UOM2, Value, Status, Modified_Date)
SELECT Tmp.InvoiceDate, Tmp.InvoiceID,
Case IsNULL(Tmp.GSTFlag ,0)
When 0 then Isnull(Prefix, '') + Cast (Tmp.DocumentID as nvarchar)
Else
Tmp.DocumentID
End,
--Isnull(Prefix, '') + Cast (Tmp.DocumentID as nvarchar),
Tmp.DocReference ,
"Order_ID" = Isnull(Ord.ORDERNUMBER, ''),
Isnull(S.DocumentReference, ''),
Tmp.NetValue,
Tmp.CustomerID, Tmp.BeatID, Tmp.SalesmanID,
Tmp.Product_Code, Tmp.Quantity,
(case  when Isnull(UOM1_Conversion, 0) = 0 then 0 else Tmp.Quantity / UOM1_Conversion end),
(case  when Isnull(UOM2_Conversion, 0) = 0 then 0 else Tmp.Quantity / UOM2_Conversion end),
SalePrice, SalePrice * isnull(UOM1_Conversion, 0),	SalePrice * isnull(Items.UOM2_Conversion,0), Amount ,
"Status" =
(case when (isnull(Tmp.Status,0) & 128 ) = 0 and Tmp.Invoicetype = 1 then 1
when  (isnull(Tmp.Status,0) & 128 ) <> 0 or
(isnull(Tmp.Status,0) & 64 ) <> 0 then 3
when  (isnull(Tmp.Status,0) & 128 ) = 0 and Tmp.Invoicetype = 3 then 2
end),
"Date"  =
(case when  (isnull(Tmp.Status,0) & 64 ) <> 0	then Tmp.canceldate
else Tmp.CreationTime end)
FROM  #TmpInvAbsDet Tmp
Inner Join Items On Tmp.Product_code = Items.Product_code
Left Outer Join SoAbstract S On S.SoNumber = Cast(Isnull(Tmp.SONumber, '0') as int)
Left Outer Join #tmpOrdDet Ord on Ord.SALEORDERID = Isnull(Tmp.SONumber, 0)
Left Outer Join VoucherPrefix On VoucherPrefix.TranID =
(Case 	when Tmp.InvoiceType = 1 then  'INVOICE'
when Tmp.InvoiceType = 3 then 'INVOICE AMENDMENT'
when Tmp.InvoiceType = 2 then 'RETAIL INVOICE'
when Tmp.InvoiceType = 4 then 'SALES RETURN'
end)
and VoucherPrefix.TranID in ('INVOICE', 'RETAIL INVOICE', 'SALES RETURN', 'INVOICE AMENDMENT')
inner join
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=Tmp.Salesmanid

Drop Table #TmpInvAbsDet
Drop Table #tmpOrdDet

/* V_Invoice changes*/

/* V_Customer_Schemes Start*/

Truncate Table TmpNewCustomers
Create Table  #tempCustomers  (CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SchemeID Int, GroupID Int, QPS Int )

Insert into #tempCustomers
Select Distinct C.CustomerID, S.SchemeID, So.GroupID, So.QPS
From
tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,  tbl_mERP_SchemeChannel SC ,
tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList,tbl_Merp_OlclassMapping OLM,
tbl_merp_Olclass OL,Customer C
Where
S.Active = 1 And
C.ACTIVE = 1 AND
OLM.Active = 1 And
S.SchemeType Not In (3,5) and S.Active = 1
and dbo.StripTimeFromDate(Getdate()) Between S.ActiveFrom and S.ActiveTo
and IsNull(S.schemestatus, 0) In ( 0, 1, 2 ) And
C.CustomerID = OLM.CustomerID And
OLM.OLClassID = OL.ID And
S.SchemeID = SO.SchemeID And
(SO.OutletID = C.CustomerID Or SO.OutletID = N'All')
And S.SchemeID = SC.SchemeID And
SC.GroupID = SO.GroupID And
(SC.Channel = OL.Channel_Type_Desc Or SC.Channel = N'All')  And
S.SchemeID = SOLC.SchemeID And
SOLC.GroupID = SO.GroupID And
(SOLC.OutLetClass = OL.Outlet_Type_Desc Or SOLC.OutLetClass = N'All')  And
S.SchemeID = SLList.SchemeID And
SLList.GroupID = SO.GroupID And
(SLList.LoyaltyName = OL.SubOutlet_Type_Desc Or SLList.LoyaltyName = N'All')
Group By S.SchemeID,SO.GroupID,C.CustomerID,So.QPS

Insert Into TmpNewCustomers (SchemeID,CustomerID,AllotedAmount)
select distinct cast(SubGrp.GroupId as varchar(5))+cast(CSO.SchemeID+10000 as varchar(25)), CSO.CustomerID ,0
from #tempCustomers CSO,
tbl_mERP_SchemeSubGroup SubGrp Where SubGrp.SubGroupID = CSO.GroupID And SubGrp.SchemeID = CSO.SchemeID

Drop Table #tempCustomers

/* V_Customer_Schemes End*/

/* V_DSTypeCategoryMapping Start */

Declare @OCGFlag_DSMap int
Set @OCGFlag_DSMap = (Select Top 1 isnull(Flag,0) From tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS')

Create Table #TmpDSTypeMap(SalesmanID int, DSTypeCode nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, DSTypeID int,
DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Flag int)

Truncate Table TmpDSTypeCategoryMap

IF @OCGFlag_DSMap = 1
Begin
Insert Into #TmpDSTypeMap(SalesmanID, DSTypeCode, DSTypeID, DSType, Flag)
Select DD.SalesmanID, DM.DstypeCode, DM.DSTypeID, DM.DSTypeValue, DM.Flag
From DSType_Details DD
Inner Join DSType_Master DM On DD.DSTypeID = DM.DSTypeID and isnull(DM.Flag,0) <> 0
Inner Join Salesman S On S.SalesmanID = DD.SalesmanID
Where DD.Dstypectlpos = 1 And Isnull(DD.SalesmanID,0) <> 0
And isnull(S.Active,0) <> 0 And isnull(OCGType,0) = 1
And DD.SalesmanID In
(Select DD1.SalesmanID From DSType_Details DD1
Inner Join DSType_Master DM1 On DD1.DSTypeID = DM1.DSTypeID
And DM1.DSTypeName = 'Handheld DS' And DM1.DSTypeValue = 'Yes' )

Insert Into TmpDSTypeCategoryMap(DSID, DSType, SKUCode, PortFolio, Flag)
Select Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU, isnull(Map.PortFolio,'') PortFolio, Tmp.Flag From #TmpDSTypeMap Tmp
Inner Join OCG_DSTypeCategoryMap Map On Tmp.DSTypeID = Map.DSTypeID
Inner Join DSTypeWiseSKU SKU On SKU.CatMapID = Map.ID
Order By Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU

End

ELSE
Begin
Insert Into #TmpDSTypeMap(SalesmanID, DSTypeCode, DSTypeID, DSType, Flag)
Select DD.SalesmanID, DM.DstypeCode, DM.DSTypeID, DM.DSTypeValue, DM.Flag
From DSType_Details DD
Inner Join DSType_Master DM On DD.DSTypeID = DM.DSTypeID and isnull(DM.Flag,0) <> 0
Inner Join Salesman S On S.SalesmanID = DD.SalesmanID
Where DD.Dstypectlpos = 1 And Isnull(DD.SalesmanID,0) <> 0 And isnull(S.Active,0) <> 0
And DD.SalesmanID In
(Select DD1.SalesmanID From DSType_Details DD1
Inner Join DSType_Master DM1 On DD1.DSTypeID = DM1.DSTypeID
And DM1.DSTypeName = 'Handheld DS' And DM1.DSTypeValue = 'Yes' )

Insert Into TmpDSTypeCategoryMap(DSID, DSType, SKUCode, PortFolio, Flag)
Select Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU, isnull(Map.PortFolio,'') PortFolio, Tmp.Flag From #TmpDSTypeMap Tmp
Inner Join DSTypeCGCategoryMap Map	On Tmp.DSTypeID = Map.DSTypeID
Inner Join DSTypeWiseSKU SKU On SKU.CatMapID = Map.ID
Order By Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU

End

Drop Table #TmpDSTypeMap

/* V_DSTypeCategoryMapping End */

/*V_SD_OutletFlag_ProdDtl Start*/

----IF Not Exists(Select 'x' From SysObjects Where Name = 'Output_SD_OutletFlag_ProdDtl' and XType = 'U')
----BEGIN
----Create Table Output_SD_OutletFlag_ProdDtl(
----	ProdDefnID Int,
----	Products nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
----	Product_code nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
----	CategoryID Int)
----END

Truncate Table Output_SD_OutletFlag_ProdDtl

Create Table #tmpOPPrdDtl(
ProdDefnID Int,
Products nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
Product_code nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int)

Create Table #curProddefnidProdDtl (ProdDefnID int)

Create Table #TmpCatGroupProdDtl (ProdDefnId int, GroupName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Declare @OCGGlag As Int
Set @OCGGlag = (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS')

Create Table #HHDSProdDtl  (SalesmanID int,CustomerID nvarchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert into #HHDSProdDtl
Select S.SalesmanID,C.CustomerID From
Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
Where
DM.DSTypeCTLPos = 2 And
DD.DSTypeCTLPos = 2 And
isnull(B.Active,0) = 1 And
isnull(Dm.Active,0)=1 And
isnull(C.Active,0) = 1 And
DM.DSTypeValue = 'Yes' And
DD.SalesmanID =S.SalesmanID And
S.SalesmanId = BS.SalesmanId And
dd.DSTypeID = dm.DSTypeID And
C.CustomerID = BS.CustomerID And
isnull(S.Active,0) = 1 And
B.BeatId = BS.BeatId

Declare @GGDRMonth_ProdDtl as DateTime
Set @GGDRMonth_ProdDtl = dbo.striptimefromdate(getdate())

insert into #curProddefnidProdDtl (ProdDefnID)
Select Distinct ProdDefnId From GGDROutlet Where @GGDRMonth_ProdDtl between ReportFromdate and ReportTodate
And OutletID in (Select Distinct CustomerID From #HHDSProdDtl)

insert into #tmpOPPrdDtl(ProdDefnID,Products,Product_code)
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name=T.Division And
G.Products = T.Division And
G.ProdCatLevel=2 and
G.Products <> 'ALL'And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)
Union ALL
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name=T.SubCategory And
G.Products = T.SubCategory And
G.ProdCatLevel=3 and
G.Products <> 'ALL' And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)
Union ALL
select Distinct T.ProdDefnID,G.Products,T.Product_code from GGDRProduct G,TmpGGDRSKUDetails T,ItemCategories IC
Where G.ProdDefnId=T.ProdDefnId And
IC.Category_Name = T.MarketSKU And
G.Products = T.MarketSKU And
G.ProdCatLevel=4 and
G.Products <> 'ALL' And
isnull(IC.active,0)=1 and G.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)
UNION ALL
Select Distinct G.ProdDefnID,G.Products,G.Products from GGDRProduct G,Items I Where
G.Products =I.Product_code And
G.ProdCatLevel=5 and
G.Products <> 'ALL' And
Isnull(I.Active,0)=1 and G.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)

Insert Into #TmpCatGroupProdDtl(ProdDefnId,GroupName)
Select Distinct ProdDefnId,Isnull((Case When @OCGGlag = 0 Then CatGroup When @OCGGlag = 1 Then OCG End),'All')
From GGDROutlet Where ProdDefnID in (Select ProdDefnID from GGDRProduct where Products='ALL')
And @GGDRMonth_ProdDtl Between ReportFromdate and ReportTodate

insert into #tmpOPPrdDtl(ProdDefnID,Products,Product_code)
Select T.ProdDefnId,Temp.Division,Temp.Product_code from TmpGGDRSKUDetails Temp,#TmpCatGroupProdDtl T,Items I
Where T.ProdDefnId = Temp.ProdDefnId And
Temp.Product_code=I.Product_code And
T.GroupName=Temp.CategoryGroup And
Isnull(I.Active,0)=1 And
T.GroupName <> 'ALL' and Temp.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)

insert into #tmpOPPrdDtl(ProdDefnID,Products,Product_code)
Select T.ProdDefnId,Temp.Product_code,Temp.Product_code from TmpGGDRSKUDetails Temp,#TmpCatGroupProdDtl T,Items I
Where T.ProdDefnId = Temp.ProdDefnId And
Temp.Product_code=I.Product_code And
Isnull(I.Active,0)=1 And
T.GroupName = 'ALL' and Temp.ProdDefnID in (select ProdDefnID from #curProddefnidProdDtl)

Update T Set T.CategoryID=V.Category_ID from #tmpOPPrdDtl T,V_Category_Master V
Where T.Products=V.Category_Name

Insert into Output_SD_OutletFlag_ProdDtl
Select Distinct ProdDefnID,Products,Product_Code,CateGoryID From #tmpOPPrdDtl Order By ProdDefnID,Products,CateGoryID,Product_Code

Delete From Output_SD_OutletFlag_ProdDtl Where ProdDefnID Not in (Select Distinct ProdDefnID From #curProddefnidProdDtl)

Drop table #tmpOPPrdDtl
Drop Table #curProddefnidProdDtl
Drop Table #TmpCatGroupProdDtl
Drop Table #HHDSProdDtl



/*V_SD_OutletFlag_ProdDtl End*/
/* Insert date to confirm dataposting is done for view */
IF Not Exists(Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
Insert Into HHViewLog(Date) Values(GetDate())

End
