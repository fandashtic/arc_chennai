Create Procedure mERP_spr_PMTargetTracker(@ReportDate DateTime)
As
Begin
Set DateFormat DMY

Declare @Month nVarchar(25)
Declare @Period as nVarchar(8)
Declare @FromDate as DateTime
Declare @ToDate as Datetime
Declare @dtMonth Datetime
Declare @MonthLastDate Datetime
Declare @MonthFirstDate Datetime
Declare @TillDate as Datetime
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

Select @TillDate = GetDate()

/* Will be given in MM/YYYY Format */
Set @Month = Right((Convert(nVarchar(10), @ReportDate, 103)),7)

--Set @Month = Right((Convert(nVarchar(10), @ReportDate, 103)),7)

Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)
Select @Period = REPLACE(RIGHT(CONVERT(VARCHAR(11), @DtMonth, 106), 8), ' ', '-')
Select @FromDate = 	Convert(nVarchar(10), @DtMonth, 103)
Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DtMonth)+1,0))
Set @MonthLastDate = @ToDate
Select @MonthFirstDate = @FromDate

Create table #tmpPMInfo(
PMID Int,
DSTypeID Int,
PMDSTypeID Int,
DSType nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Period nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMCatGrp nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParamID Int,
ParamType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
ParamFocus nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Frequency nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
FocusID Int, TargetType int)

Create table #tmpTargetInfo(
DSTypeID Int,
DS_ID Int,
DS_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
PMID Int,
PMDSTypeID Int,
ParamID Int,
FocusID Int,
Target Decimal(18,6),
ProposedTargetValue Decimal(18,6),
UpdationDate DateTime,
CreationDate DateTime, TargetType int)

/*Getting Active PM Info*/
Insert into #tmpPMInfo
Select Master.PMID, DSMast.DSTypeID, DSType.DSTypeID PMDSTypeID, DStype.DSType, Master.PMCode,Master.Description as PMdesc,Master.Period, Master.CGGroups CategoryGroup,
Param.ParamID, ParamType.ParamType as Param, (Case When isNull(Param.isFocusParameter,0) = 0 Then 'OverAll' Else --ParamFocus.ProdCat_Code
ParamFocus.PMProductName End) 'OverAll_Focus',
(Case Param.Frequency When 1 Then N'Daily' When 2 Then N'Monthly' End)  Frequency,Null -- ParamFocus.FocusID
, isnull(Param.TargetParameterType,0) TargetType
From
tbl_mERP_PMMaster Master ,tbl_mERP_PMDSType DSType,
DSType_Master DSMast,tbl_mERP_PMParam Param,
tbl_mERP_PMParamFocus ParamFocus, tbl_mERP_PMParamType ParamType
Where
--(Master.Period = @Period) or
cast('01/' + Master.Period as datetime) > = cast('01/' + @Period as datetime)
and cast('01/' + Master.Period as datetime) < = dateadd(month,1,cast('01/' + @Period as datetime))
And Master.Active = 1
And Master.PMID = DSType.PMID
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And Param.ParameterType = 3
And ParamType.ID = Param.ParameterType
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And Param.ParamID = ParamFocus.ParamID

/*Getting Active/Latest Target Info*/
Insert into #tmpTargetInfo (DSTypeID, DS_ID, DS_Name, PMID,	PMDSTypeID,	ParamID, FocusID, ProposedTargetValue,Target, UpdationDate, TargetType)
Select Target.DSTypeID, SM.SalesManID, SM.SalesMan_Name, Target.PMID, Target.PMDSTypeID,Target.ParamID,Target.FocusID, Isnull(Target.ProposedTargetValue,0), Target.Target, Target.TargetDefnDate, 0
From tbl_mERP_PMetric_TargetDefn Target, SalesMan SM
Where Target.SalesmanID = SM.SalesmanID and Target.Active = 1
and Target.PMID in (Select Distinct PMID from #tmpPMInfo)
and ParamID in(Select Distinct ParamID from #tmpPMInfo Where isnull(TargetType,0) = 0)

/*Update Initial target Definition date*/
Update tmpTgt Set tmpTgt.CreationDate = Target.TargetDefnDate
From (Select T.PMID, T.PMDSTypeID, T.ParamID, T.FocusID, T.SalesmanID, Min(T.TargetDefnDate) TargetDefnDate
From tbl_mERP_PMetric_TargetDefn T, #tmpPMInfo PMInfo
Where T.PMID = PMInfo.PMID
Group by T.PMID, T.PMDSTypeID, T.ParamID, T.FocusID, T.SalesmanID) Target, #tmpTargetInfo tmpTgt
Where tmpTgt.PMID = Target.PMID and
tmpTgt.PMDSTypeID = Target.PMDSTypeID and
tmpTgt.ParamID = Target.PAramID and
--	tmpTgt.FocusID = Target.FocusID and
tmpTgt.DS_ID = Target.SalesmanID

/* New DS added for Absolute Parameter */
Insert into #tmpTargetInfo (DSTypeID, DS_ID, DS_Name, PMID,	PMDSTypeID,	ParamID, FocusID,ProposedTargetValue,
Target, UpdationDate, CreationDate, TargetType)
Select Distinct DSMast.DSTypeID, SM.SalesmanID, SM.Salesman_Name, Master.PMID, DStype.DSTypeID, Param.ParamID, 0, Max(Slab.SLAB_START) ProposedTargetValue,
Max(Slab.SLAB_START) Target, Master.CreationDate, Master.CreationDate, 1
From
tbl_mERP_PMMaster Master, tbl_mERP_PMDSType DSType,
Salesman SM, DSType_Master DSMast, tbl_mERP_PMParam Param
,tbl_mERP_PMParamFocus ParamFocus, tbl_mERP_PMParamSlab Slab
,(Select Distinct DS.SalesmanID as SalesmanID, DS.DSTypeID  as DSTypeID From DSType_Details DS
Inner Join Salesman S ON DS.SalesmanID = S.SalesmanID Where DS.DSTypeCtlPos = 1 and dbo.StripTimeFromDate(S.CreationDate) <= dbo.StripTimeFromDate(@ReportDate)
) DSDet
Where
Master.Period = @Period
And Master.Active = 1
And Master.PMID = DSType.PMID
And DSMast.DSTypeValue = DStype.DSType
And DSMast.DSTypeCtlPos = 1
And DSDet.DSTypeID = DSMast.DSTypeID
And SM.SalesmanID = DSDet.SalesmanID and SM.Active = 1
And Param.DSTypeID = DSType.DSTypeID
And Param.ParamID  = ParamFocus.ParamID
And Param.ParamID  = Slab.ParamID
And Param.ParameterType in (3) and isnull(Param.TargetParameterType,0) <> 0
Group By DSMast.DSTypeID, SM.SalesmanID, SM.Salesman_Name, Master.PMID, DStype.DSTypeID, Param.ParamID, Master.CreationDate


Select DISTINCT 1, @WDCode as WDCODE, @WDDest as WDDEST, @MonthFirstDate as FROMDATE, @MonthLastDate as TODATE,
Target.DS_ID, Target.DS_NAME DSNAME, PMInfo.DSType DS_TYPE, PMInfo.PMCode PERFORMANCE_METRICS_CODE,
PMInfo.PMDesc DESCRIPTION,PMInfo.Period as [MONTH],  PMInfo.PMCatGrp CATEGORY_GROUP, PMInfo.ParamType PARAMETER,
PMInfo.ParamFocus OVERALL_OR_FOCUS, PMInfo.FREQUENCY,
Case When isnull(Target.TargetType,0) = 0 Then 'Calculated' Else 'Absolute' End TargetType,
Isnull(target.ProposedTargetValue,0) AS 'Proposed Target Value', Target.TARGET,
Convert(nVarchar(10),Target.UpdationDate,103) + N' ' + Convert(nVarchar(8),Target.UpdationDate,108) as WD_UPDATION_DATE,
Convert(nVarchar(10),Target.CREATIONDATE,103) + N' ' + Convert(nVarchar(8),Target.CREATIONDATE,108) as TGT_CREATIONDATE
From #tmpPMInfo PMInfo,  #tmpTargetInfo Target
Where PMInfo.PMID = Target.PMID and
PMInfo.PMDSTypeID = Target.PMDSTypeID and
PMInfo.ParamID = Target.PAramID
--	 and PMInfo.FocusID = Target.FocusID
ORDER BY PMInfo.PMCode, PMInfo.DSType, Target.DS_NAME, Convert(nVarchar(10),Target.UpdationDate,103) + N' ' + Convert(nVarchar(8),Target.UpdationDate,108)

Drop table #tmpPMInfo
Drop table #tmpTargetInfo
End
