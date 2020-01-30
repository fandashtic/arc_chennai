Create Procedure mERP_sp_ProcessOLTPM (@RecID Int,@ReProcess Int = 0)
As
Begin
Begin Try
/* Error Validation: */
Set DateFormat DMY

Declare @SystemDate as DateTime
Declare @PMMonth as Nvarchar(25)
Declare @IsDatapostRequired int
Declare @ClosedMonth as Nvarchar(25)

Declare @ResetLogFromDate As Datetime
Declare @ResetLogToDate datetime

Create Table #TmpPMCode (RecdDocID Int,PMCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,Existing Int)
Create Table #TmpTargetValidation (RecdDocID Int,PMCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,PMID Int)
Create Table #TmpCustomer (RecdID Int,CustomerID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
Create Table #PMID (PMCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,CPM_PMID Int)

Create Table #TmpPMOLT (
PMCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
DSTypeID Int,
ParameterID Int,
OutletID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Target Decimal(18,6),
OCG NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CG NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

Create Table #TmpDSType (RecdID Int,PMCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,CPM_PMID Int,CPM_DSTypeID Int,CPM_ParamID Int)

Create Table #PMOLT(
ID int,
RecdDocID Int,
PMCode Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CPM_PMID Int Null,
PMID Int Null,
R_DStypeID Int NULL,
DSTypeID Int Null,
R_ParameterID Int NULL,
ParameterID Int NULL,
OutletID Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
Target Decimal(18,6) NULL,
OCG Nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
CG Nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
/* 1. Check PMCode Exists Or Not: */

/* For Reprocess, If Reprocess 1 Then Reset the Process Status = 0*/
If Isnull(@ReProcess,0) = 1
Begin
Update Recd_PMOLT Set Status = 0,ModifiedDate = Getdate() Where Isnull(Status,0)= 3
And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)
End

If Isnull(@ReProcess,0) = 0
Begin
Insert Into #TmpPMCode (RecdDocID,PMCode,Existing)
Select Distinct RecdDocID,PMCode,0 From Recd_PMOLT Where RecdDocID = @RecID And
PMCode Not in (Select Distinct PMCode From tbl_mERP_PMMaster)

Insert Into #TmpPMCode (RecdDocID,PMCode,Existing)
Select Distinct RecdDocID,PMCode,1 From Recd_PMOLT Where RecdDocID = @RecID And
PMCode Not in (Select Distinct PMCode From tbl_mERP_PMMaster Where Isnull(Active,0) = 1)
And PMCode Not in (Select Distinct PMCode From #TmpPMCode)
End
Else
Begin
Insert Into #TmpPMCode (RecdDocID,PMCode,Existing)
Select Distinct RecdDocID,PMCode,0 From Recd_PMOLT Where Isnull(Status,0) = 0
And PMCode Not in (Select Distinct PMCode From tbl_mERP_PMMaster)
And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)

Insert Into #TmpPMCode (RecdDocID,PMCode,Existing)
Select Distinct RecdDocID,PMCode,1 From Recd_PMOLT Where Isnull(Status,0) = 0
And PMCode Not in (Select Distinct PMCode From tbl_mERP_PMMaster Where Isnull(Active,0) = 1)
And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)
And PMCode Not in (Select Distinct PMCode From #TmpPMCode)
End

/* Status "3" is Pendig For Next Process : */

Declare @PMCode as Nvarchar(255)
Declare @szPMCodeError as Nvarchar(255)
Declare @P_RecdDocID As Int
Declare @Existing As Int

If Isnull(@ReProcess,0) = 0
Begin
Declare Cur_ErrorPMCode Cursor for
Select Distinct RecdDocID,PMCode,Existing From #TmpPMCode
Open Cur_ErrorPMCode
Fetch from Cur_ErrorPMCode into @P_RecdDocID,@PMCode,@Existing
While @@fetch_status =0
Begin
Set @szPMCodeError = ''
If Isnull(@Existing,0) = 1
Begin
Set @szPMCodeError = 'PMCode : ' + @PMCode + ' is not Active.'
End
Else If Isnull(@Existing,0) = 0
Begin
Set @szPMCodeError = 'PMCode : ' + @PMCode + ' is to be processed.'
End
Exec mERP_sp_Update_OLTPMErrorStatus @P_RecdDocID, @szPMCodeError
Fetch Next from Cur_ErrorPMCode into @P_RecdDocID,@PMCode,@Existing
End
Close Cur_ErrorPMCode
Deallocate Cur_ErrorPMCode

Update Recd_PMOLT Set Status = 3,ModifiedDate = Getdate() Where PMCode in (Select Distinct PMCode From #TmpPMCode) And RecdDocID = @RecID
End
Else
Begin
Update Recd_PMOLT Set Status = 3,ModifiedDate = Getdate() Where PMCode in (Select Distinct PMCode From #TmpPMCode)
And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)
End

/* Check Any data available for Process... */
If Isnull(@ReProcess,0) = 0
Begin
If Not Exists(Select Top 1 'x' From Recd_PMOLT Where Isnull(Status,0) = 0 And RecdDocID = @RecID)
Begin
Update RecdDoc_PMOLT set Status = 1 Where ID = @RecID
Goto OUT
End
End
Else
Begin
If Not Exists(Select Top 1 'x' From Recd_PMOLT Where Isnull(Status,0) = 0 And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1))
Begin
Goto OUT
End
End



/* Check already Target saved or not for the received PMCode */
/* If Already Target saved or Grace day closed then no need to process the Outlet targer for the PMCode. */
If Exists(select Top 1 'x' From tbl_Merp_ConfigAbstract Where ScreenCode = 'PMOutletTarget' And Isnull(Flag,0) = 1)
Begin
set @SystemDate = (select Top 1 LastInventoryUpload From SetUp)
Set @PMMonth =  Left(DateName(Month,@SystemDate),3) + '-' + Cast(Year(@SystemDate) as Nvarchar)
Set @ClosedMonth =  Left(DateName(Month,@SystemDate+1),3) + '-' + Cast(Year(@SystemDate+1) as Nvarchar)

/* As per ITC, PM Target should be saved whenever it is received, it is handled.*/
If Isnull(@ReProcess,0) = 0
Begin
Insert Into #TmpTargetValidation (RecdDocID,PMCode,PMID)
Select Distinct R.RecdDocID,R.PMCode,P.PMID From Recd_PMOLT R, tbl_mERP_PMMaster P--, tbl_mERP_PMetric_TargetDefn PT
Where Isnull(R.Status,0) = 0
and R.RecdDocID = @RecID
And R.PMCode = P.PMCode
And Isnull(P.Active,0) = 1
And Cast(cast('01-' as nvarchar(10))+P.Period as datetime)>=Cast(cast('01-' as nvarchar(10))+@PMMonth as datetime)
--And PT.PMID = P.PMID
End
Else
Begin
Insert Into #TmpTargetValidation (RecdDocID,PMCode,PMID)
Select Distinct R.RecdDocID,R.PMCode,P.PMID From Recd_PMOLT R, tbl_mERP_PMMaster P--, tbl_mERP_PMetric_TargetDefn PT
Where Isnull(R.Status,0) = 0
and R.RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)
And R.PMCode = P.PMCode
And Isnull(P.Active,0) = 1
And Cast(cast('01-' as nvarchar(10))+P.Period as datetime)>=Cast(cast('01-' as nvarchar(10))+@PMMonth as datetime)
--And PT.PMID = P.PMID
End



Declare @T_RecdDocID as Int
Declare @P_PMCode as Nvarchar(255)
Declare @PMID int


Declare Cur_ErrorPMID Cursor for
Select Distinct RecdDocID,PMCode,PMID From #TmpTargetValidation
Open Cur_ErrorPMID
Fetch from Cur_ErrorPMID into @T_RecdDocID ,@P_PMCode,@PMID
While @@fetch_status =0
Begin

/* As per ITC, PM Target should be updated even when customer saved the target. */
--IF DAY(@SystemDate+1) <> 1

/* If Last day of the month is closed then it should not be processed */
IF Exists (Select 'x' from tbl_mERP_PMMaster where PMID=@PMID and Cast(cast('01-' as nvarchar(10))+Period as datetime)>=Cast(cast('01-' as nvarchar(10))+@ClosedMonth as datetime) and Active = 1)
BEGIN
IF Exists (Select 'x' from tbl_mERP_PMMaster where PMID=@PMID and Cast(cast('01-' as nvarchar(10))+Period as datetime)>=Cast(cast('01-' as nvarchar(10))+@PMMonth as datetime)
and Active = 1)
Begin
Delete from tbl_mERP_PMetric_TargetDefn where PMID=@PMID
insert into TmpPMRepost(PMID) Select @PMID
End
Update tbl_mERP_PMMaster set Autopost=0 where PMID=@PMID and Period =@PMMonth
and Active = 1 and dbo.StripDateFromTime(Creationdate) <= @SystemDate
END
ELSE
BEGIN
Set @szPMCodeError = ''
Set @szPMCodeError = 'Last day of the month is closed for the PM: ' + @P_PMCode
Exec mERP_sp_Update_OLTPMErrorStatus @T_RecdDocID, @szPMCodeError
Update X Set X.Status = 2,X.ModifiedDate = Getdate() From Recd_PMOLT X, #TmpTargetValidation T,tbl_mERP_PMMaster P
Where X.PMCode= T.PMCode And
T.PMCode=P.PMcode and
P.Period=@PMMonth And
X.RecdDocID = T.RecdDocID
END
Fetch Next from Cur_ErrorPMID into  @T_RecdDocID ,@P_PMCode,@PMID
End
Close Cur_ErrorPMID
Deallocate Cur_ErrorPMID

End

/* Validate Outlet */

If Isnull(@ReProcess,0) = 0
Begin
Insert Into #TmpCustomer (RecdID,CustomerID)
Select Distinct ID,OutletID From Recd_PMOLT Where RecdDocID = @RecID And Isnull(Status,0) = 0
And OutletID Not in (Select Distinct CustomerID From Customer Where Isnull(Active,0) = 1)
End
Else
Begin
Insert Into #TmpCustomer (RecdID,CustomerID)
Select Distinct ID,OutletID From Recd_PMOLT Where Isnull(Status,0) = 0
And OutletID Not in (Select Distinct CustomerID From Customer Where Isnull(Active,0) = 1)
And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1)
End

Declare @CustomerID as Nvarchar(255)
Declare @C_RecdID as Int

Declare Cur_ErrorCustomerID Cursor for
Select Distinct RecdID,CustomerID From #TmpCustomer
Open Cur_ErrorCustomerID
Fetch from Cur_ErrorCustomerID into @C_RecdID,@CustomerID
While @@fetch_status =0
Begin
Set @szPMCodeError = ''
Set @szPMCodeError = 'OutletID : ' + @CustomerID + ' is Not Available / Not Active.'
Exec mERP_sp_Update_OLTPMErrorStatus @C_RecdID, @szPMCodeError
Fetch Next from Cur_ErrorCustomerID into @C_RecdID,@CustomerID
End
Close Cur_ErrorCustomerID
Deallocate Cur_ErrorCustomerID

Update X Set X.Status = 2,X.ModifiedDate = Getdate() From Recd_PMOLT X, #TmpCustomer T
Where X.OutletID = T.CustomerID
And X.ID = T.RecdID

/* Check Any data available for Process... */
If Isnull(@ReProcess,0) = 0
Begin
If Not Exists(Select Top 1 'x' From Recd_PMOLT Where Isnull(Status,0) = 0 And RecdDocID = @RecID)
Begin
Update RecdDoc_PMOLT set Status = 1 Where ID = @RecID
Goto OUT
End
End
Else
Begin
If Not Exists(Select Top 1 'x' From Recd_PMOLT Where Isnull(Status,0) = 0 And RecdDocID Not In (Select Distinct ID From RecdDoc_PMOLT Where isnull(Status,0) = 1))
Begin
Goto OUT
End
End

/* Validate DSTypeID & PrameterID */

Insert Into #PMID (PMCode,CPM_PMID)
Select Distinct PMCode,CPM_PMID From tbl_mERP_PMMaster
Where isnull(Active,0) = 1 And PMCode in (Select Distinct PMCode From Recd_PMOLT Where isnull(Status,0) = 0)

Insert Into #TmpDSType (RecdID,PMCode,CPM_PMID,CPM_DSTypeID,CPM_ParamID)
Select Distinct L.ID,L.PMCode,T.CPM_PMID,L.DSTypeID,L.ParameterID From Recd_PMOLT L , #PMID T
Where isnull(L.Status,0) = 0
And L.PMCode = T.PMCode

Declare @DS_PMCode as Nvarchar(255)
Declare @DS_PMID as Int
Declare @DS_PMDSTypeID as Int
Declare @DS_PMParamID as Int
Declare @DS_RecdID As Int

Declare Cur_ErrorDSTypeID Cursor for
Select Distinct RecdID,PMCode,CPM_PMID,CPM_DSTypeID,CPM_ParamID From #TmpDSType
Open Cur_ErrorDSTypeID
Fetch from Cur_ErrorDSTypeID into @DS_RecdID,@DS_PMCode,@DS_PMID,@DS_PMDSTypeID,@DS_PMParamID
While @@fetch_status =0
Begin

/* Validate DSTypeID */
If Not Exists(Select Top 1 'x' From tbl_mERP_PMDSType Where CPM_PMID = @DS_PMID And CPM_DSTypeID = @DS_PMDSTypeID)
Begin

Set @szPMCodeError = ''
Set @szPMCodeError = 'DSTypeID : ' + Cast(@DS_PMDSTypeID as Nvarchar(255)) + ' is Not Mapped With PMCode : ' + @DS_PMCode + ' / Not Available.'
Exec mERP_sp_Update_OLTPMErrorStatus @DS_RecdID, @szPMCodeError
Update Recd_PMOLT Set Status = 2,ModifiedDate = Getdate() Where ID = @DS_RecdID And PMCode = @DS_PMCode And DSTypeID = @DS_PMDSTypeID And Isnull(Status,0) = 0
Goto NextID
End

/* Validate PrameterID */
/* ParameterType Should be "Business Achievement" (3) */
If Not Exists(Select Top 1 'x' From tbl_mERP_PMParam Where CPM_PMID = @DS_PMID And CPM_DSID = @DS_PMDSTypeID And CPM_ParamID = @DS_PMParamID And Isnull(ParameterType,0) = 3)
Begin

Set @szPMCodeError = ''
Set @szPMCodeError = 'ParameterID : ' + Cast(@DS_PMParamID as Nvarchar(255)) + ' is Not Mapped With PMCode : ' + @DS_PMCode + ' And DSTypeID : '+ Cast(@DS_PMDSTypeID as Nvarchar(255))+ ' / ParameterType Is not "Business Achievement" / Not Available.'
Exec mERP_sp_Update_OLTPMErrorStatus @DS_RecdID, @szPMCodeError
Update Recd_PMOLT Set Status = 2,ModifiedDate = Getdate() Where ID = @DS_RecdID And PMCode = @DS_PMCode And DSTypeID = @DS_PMDSTypeID And ParameterID = @DS_PMParamID And Isnull(Status,0) = 0
End
NextID:
Fetch Next from Cur_ErrorDSTypeID into @DS_RecdID,@DS_PMCode,@DS_PMID,@DS_PMDSTypeID,@DS_PMParamID
End
Close Cur_ErrorDSTypeID
Deallocate Cur_ErrorDSTypeID

/* No Need to Validate OCG / CG Columns */

/* Final */

Insert Into #PMOLT (ID,RecdDocID,PMCode,R_DStypeID,R_ParameterID,OutletID,Target,OCG,CG)
select ID,RecdDocID,PMCode,DStypeID,ParameterID,OutletID,Target,OCG,CG from Recd_PMOLT
Where Isnull(Status,0) = 0

Update X Set X.PMID = L.PMID,X.CPM_PMID = L.CPM_PMID From #PMOLT X, tbl_mERP_PMMaster L
Where X.PMCode = L.PMCode
And Isnull(L.Active,0) = 1

Update X Set X.DSTypeID = L.DSTypeID From #PMOLT X, tbl_mERP_PMDSType L
Where X.R_DStypeID = L.CPM_DSTypeID
And X.PMID = L.PMID
And X.CPM_PMID = L.CPM_PMID

Update X Set X.ParameterID = L.ParamID From #PMOLT X, tbl_mERP_PMParam L
Where X.R_DStypeID = L.CPM_DSID
And X.R_ParameterID = L.CPM_ParamID
And X.CPM_PMID = L.CPM_PMID
ANd X.DSTypeID = L.DSTypeID

/* Delete Existing Data Based on Received PMode. */

Delete From PMOutlet Where PMCode in (Select Distinct PMCode From #PMOLT)

Insert Into PMOutlet (ID,RecdDocID,PMCode,PMID,DStypeID,ParamID,OutletID,Target,OCG,CG)
Select ID,RecdDocID,PMCode,PMID,DStypeID,ParameterID,OutletID,Target,OCG,CG From #PMOLT

Update Recd_PMOLT Set Status = 1,ModifiedDate = Getdate() Where Isnull(Status,0) = 0

Update RecdDoc_PMOLT Set Status = 1 Where ID = @RecID


select @ResetLogFromDate =min(cast('01-'+Period as dateTime)) from tbl_merp_PMMaster where PMID in (select distinct PMID from #PMOLT)

select Top 1 @ResetLogToDate= dbo.stripdatefromtime(LastInventoryUpload) From SetUp
if @ResetLogFromDate <= @ResetLogToDate
Begin
exec SP_Update_DayCloseTracker @ResetLogFromDate,@ResetLogToDate,'OLTAchievement'
End
/* PM Target should be saved automatically is done*/
If Exists(select Top 1 'x' From tbl_Merp_ConfigAbstract Where ScreenCode = 'PMOutletTarget' And Isnull(Flag,0) = 1)
exec sp_PMTargetAutoPostProcess 1

End Try

/* If Error Then */
Begin Catch

Exec mERP_sp_Update_OLTPMErrorStatus @RecID, 'PMOutlet Process Get Failed.'
Update RecdDoc_PMOLT Set Status = 64 Where ID = @RecID
Goto OUT
End Catch

OUT:

Drop Table #TmpPMCode
Drop Table #TmpTargetValidation
Drop Table #TmpPMOLT
Drop Table #PMID
Drop Table #TmpDSType
Drop Table #PMOLT
End
