Create Procedure dbo.sp_PMTargetAutoPostProcess @Flag int = 0
as
Begin

Set DateFormat DMY
Declare @SystemDate as DateTime
Declare @PMMonth as Nvarchar(25)
Declare @ClosedMonth as Nvarchar(25)
Declare @PMID as Int
Declare @DsTypeID as Int
Declare @ParamID as Int
Declare @FocusID as Int

Declare @PMetricID as Int
Declare @PMDSTypeID as Int
Declare @PMParamID as Int
Declare @PMFocusID as Int
Declare @SalesmanID as Int
Declare @TargetValue as Decimal(18,6)
Declare @Maxpoints as Decimal(18,6)
Declare @DSCGMapID as Int
Declare @PMTargetDefnID as Int
Declare @LogonUser as nVarchar(50)
Declare @GrowthPerc as Decimal(18,6)
Declare @ProposedTargetValue as Decimal(18,6)
Declare @Last3MonthsAverageSales as Decimal(18,6)
Declare @OriginalTarget as Decimal(18,6)

Declare @TempPMID as Table (PMID Int)

CREATE TABLE #TempDSTypeID (PMID Int,DSTypeID Int)

CREATE TABLE #TempPMInfo(
PMID Int Null,
DSTypeID Int Null,
ParamType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PramFocus nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
MaxPoints nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
ParamID int NULL,
ParamFocusLevel int NULL,
ParameterTypeid int NULL,
OrderBy int NULL)

CREATE TABLE #TempPMTargetInfo(
SalesManid Int Null,
SalesManName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
DSTypeValue nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Target Decimal(18,6),
MaxPoints nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PMID Int Null,
PMDSTypeid Int Null,
ParamID Int Null,
FocusSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
FocusID Int Null,
CGMapid Int Null,
TargetDefnID Int Null,
SalesValue Decimal(18,6),
GrowthPerc Decimal(18,6) Default 0,
ProposedTargetValue Decimal(18,6) Default 0,
LastUpdatedDate nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
AutoPostflag Int Default 0,
SaveFlag Int Default 0,
OriginalTarget Decimal(18,6) Default 0)

set @SystemDate = (select Top 1 LastInventoryUpload From SetUp)
Set @PMMonth =  Left(DateName(Month,@SystemDate),3) + '-' + Cast(Year(@SystemDate) as Nvarchar)
Set @ClosedMonth =  Left(DateName(Month,@SystemDate+1),3) + '-' + Cast(Year(@SystemDate+1) as Nvarchar)

IF @flag=1
BEGIN
--IF DAY(@SystemDate+1) = 1
--BEGIN
--	GOTO THEEND
--END

/* If Last day of the month is closed then it should not be processed */
IF Not Exists (Select 'x' from tbl_mERP_PMMaster Where PMID in(Select Distinct PMID From TmpPMRepost)
and Cast(cast('01-' as nvarchar(10))+Period as datetime)>=Cast(cast('01-' as nvarchar(10))+@ClosedMonth as datetime) and Active = 1)
BEGIN
GOTO THEEND
END
END
IF @flag=0
Begin
Insert Into @TempPMID (PMID)
select Distinct PMID from tbl_mERP_PMMaster Where Period in (@PMMonth) and Active = 1 and dbo.StripDateFromTime(Creationdate) <= @SystemDate and Isnull(AutoPost , 0) = 0
End
Else
Begin
Insert Into @TempPMID (PMID)
Select Distinct PMID from TmpPMRepost
End

Truncate Table #TempDSTypeID
Insert Into #TempDSTypeID (PMID,DSTypeID)
select Distinct PMID,DSTypeid from tbl_mERP_PMDSType Where PMID in (select Distinct PMID From @TempPMID)

If (Select Count(*) From #TempDSTypeID) = 0
Begin
Goto OUT
End

-- Loop 1 Start:

Declare @cluPMID Cursor
Set @cluPMID = Cursor for
select PMID,DSTypeid From #TempDSTypeID
Open @cluPMID
Fetch Next from @cluPMID into @PMID,@DsTypeID
While @@fetch_status =0
Begin
Truncate Table #TempPMInfo
Insert Into #TempPMInfo (ParamType ,PramFocus ,MaxPoints ,ParamID ,ParamFocusLevel ,ParameterTypeid,DsTypeID,OrderBy )
Select * from dbo.mERP_FN_get_DSPMetric_Params_AUTOPOST(@DsTypeID)

Update #TempPMInfo set PMID = @PMID , DsTypeID = @DsTypeID
Delete From #TempPMInfo Where ParameterTypeid <> 3

-- Loop 2 Start:

Declare @cluPMInfo Cursor
Set @cluPMInfo = Cursor for
select PMID,ParamID From #TempPMInfo
Open @cluPMInfo
Fetch Next from @cluPMInfo into @PMID,@ParamID
While @@fetch_status =0
Begin
Insert Into #TempPMTargetInfo (SalesManid,SalesManName,DSTypeValue,Target,MaxPoints,PMID,PMDSTypeid,ParamID,CGMapid,TargetDefnID,SalesValue,GrowthPerc,ProposedTargetValue,LastUpdatedDate,AutoPostflag,SaveFlag,OriginalTarget)
Select * from dbo.mERP_FN_get_DSPMetric_TargetDefn_AUTOPOST (@PMID,@ParamID,0)

Fetch Next from @cluPMInfo into @PMID,@ParamID
End
Close @cluPMInfo
Deallocate @cluPMInfo

-- Loop 2 End:

Fetch Next from @cluPMID into @PMID,@DsTypeID
End
Close @cluPMID
Deallocate @cluPMID

-- Loop 1 End:

Update #TempPMTargetInfo set AutoPostflag = 1 Where isnull(LastUpdatedDate ,'') <> '' and isnull(AutoPostflag,0) = 0
Delete From #TempPMTargetInfo Where isnull(AutoPostflag,0) = 1

If (Select Count(*) From #TempPMTargetInfo Where isnull(AutoPostflag,0) = 0 and Isnull(LastUpdatedDate ,'') = '') = 0
Begin
Goto OUT
End

-- Loop 3 Start:

Declare @cluFinelUpdate Cursor
Set @cluFinelUpdate = Cursor for
select PMID,PMDsTypeID,ParamID,SalesManid,Target,MaxPoints,CGMapid,TargetDefnID,SalesValue,'ITCUser',GrowthPerc,ProposedTargetValue,OriginalTarget From #TempPMTargetInfo Where Isnull(AutoPostFlag,0) = 0 and Isnull(LastUpdatedDate ,'') = ''
Open @cluFinelUpdate
Fetch Next from @cluFinelUpdate into @PMetricID ,@PMDSTypeID,@PMParamID,@SalesmanID,@TargetValue,@Maxpoints,@DSCGMapID,@PMTargetDefnID,@Last3MonthsAverageSales,@LogonUser,@GrowthPerc,@ProposedTargetValue,@OriginalTarget
While @@fetch_status =0
Begin
-- Finel Update:
If (Select isnull(flag,0) from Tbl_Merp_ConfigAbstract where screencode='PMOutletTarget')=0
BEGIN
set @TargetValue = @ProposedTargetValue
END
--			If Isnull(@TargetValue,0) > 0
--				Begin
--					select @PMetricID,@PMDSTypeID,@PMParamID,@PMFocusID,@SalesmanID,@TargetValue,@Maxpoints,@DSCGMapID,@PMTargetDefnID,@LogonUser ,@GrowthPerc,@ProposedTargetValue,@Last3MonthsAverageSales
Exec mERP_sp_Save_DSPMetric_TargetDefn @PMetricID,@PMDSTypeID,@PMParamID,@SalesmanID,@TargetValue,@Maxpoints,@DSCGMapID,@PMTargetDefnID,@LogonUser,@GrowthPerc,@ProposedTargetValue,@Last3MonthsAverageSales,@OriginalTarget
--				End

Fetch Next from @cluFinelUpdate into @PMetricID ,@PMDSTypeID,@PMParamID,@SalesmanID,@TargetValue,@Maxpoints,@DSCGMapID,@PMTargetDefnID,@Last3MonthsAverageSales,@LogonUser,@GrowthPerc,@ProposedTargetValue,@OriginalTarget
End
Close @cluFinelUpdate
Deallocate @cluFinelUpdate


-- Loop 3 End:

OUT:
Update tbl_mERP_PMMaster set AutoPost = 1 Where PMID in (select Distinct PMID From @TempPMID)
Drop Table #TempPMInfo
Drop Table #TempDSTypeID
Drop Table #TempPMTargetInfo
THEEND:
Truncate Table TmpPMRepost
End
