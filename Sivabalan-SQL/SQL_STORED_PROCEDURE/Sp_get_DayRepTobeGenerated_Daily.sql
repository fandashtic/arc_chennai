CREATE Procedure Sp_get_DayRepTobeGenerated_Daily(@Curdate DateTime = NULL)
As
Set DateFormat DMY
Declare @LUploadDate DateTime
Create Table #RepTable (Repid int,FDate datetime,Tdate datetime,LUDate DateTime,GRepid int, AliasSP nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, GPFlag Int, LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
Select @CurDate=dbo.stripdatefromtime(Isnull(@Curdate,GetDate()))

Declare @DayCnt integer
Declare @TempDayCnt integer
Declare @TempFromDate datetime
Declare @TempToDate datetime
Declare @Reportid int
Declare @Grepid int
Declare @GPFlag Int
Declare @GraceTime Int
Declare @AliasSP nVarchar(100)
Declare @LastDoc Int
Declare @LatestDocument nVarchar(10)
Declare @LastFromDate DateTime
Declare @LastToDate DateTime
Declare @DayClose DateTime
Declare @TempDate DateTime

Declare @RptCondition int
select  @RptCondition= isnull(value,0) from tbl_merp_configdetail where screencode ='PMSTDT01'
Select @DayClose = dbo.striptimefromdate(isnull(LastinventoryUpload,getdate())) from setup
/* Eventhough Sales Data is daily report, it should not upload in Day End report. It has to be uploaded thro' ARU only*/
Declare DayCursor Cursor For
Select ReportDataID,ReportId, IsNull(AliasActionData, ''), IsNull(LatestDoc,0)
From Reports_To_UpLoad
Where Frequency=1 And (ReportName<>'Sales Data' And ReportName<>'Sales Return and Godown Damage Report'
And ReportName<>'GGRR Target Daily Report' And ReportName<>'Audit Log Report')
--	and reportdataID <>1161
--  union
--  Select ReportDataID,ReportId, IsNull(AliasActionData, ''), IsNull(LatestDoc,0)
--  From Reports_To_UpLoad
--  Where Frequency=1 and reportdataID = 1161
--  And day(@Curdate) <= @RptCondition
--  And year(@Curdate) = year(getdate())
--  And month(@Curdate) = month(getdate())

Open DayCursor
Fetch Next From DayCursor Into @Reportid,@Grepid,@AliasSP, @LastDoc
While @@Fetch_Status=0
Begin

Select @LUploadDate=case when dbo.Stripdatefromtime(LastUploadDate) = dbo.Stripdatefromtime(getdate())
then dbo.Stripdatefromtime(LastUploadDate) else
dbo.Stripdatefromtime(DateAdd(d,1,LastUploadDate))end, @GraceTime = IsNull(GracePeriod, 0)
From Reports_To_Upload
Where ReportID = @Grepid

--  Select @DayCnt=DateDiff(d,@LUploadDate,@CurDate) + 1
--  select @DayCnt
--Since Daily reports needs to be uploaded daily, below condition is changed

--if @DayCnt < 0
--Set @TempDayCnt=@DayCnt
--else
Set @TempDayCnt=1
--Set @TempDayCnt=@DayCnt
--Set @TempFromDate=@LUploadDate
set @TempFromDate = @Curdate

Select @LUploadDate = dbo.striptimefromdate(LastUploadDate) From Reports_To_Upload Where ReportID = @Grepid
While (@TempDayCnt)> 0
Begin
If @GraceTime > 1
Set @GPFlag = -1 --Invalid grace period
Else If ((Select DateDiff(d,@TempFromDate,@Curdate)) >= @GraceTime) And (@GraceTime <> 0)
Set @GPFlag = 1 --Grace period reached
Else
Set @GPFlag = 0 --Grace period exists

If @LastDoc <> 1
Begin
Set @LatestDocument = N'No'
Insert Into #RepTable Values(@reportid,@TempFromDate,@TempFromDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)

End
Else
Begin
Set @LatestDocument = N'Yes'
Set @LastFromDate = @TempFromDate
Set @LastToDate = @TempFromDate
End
Set @TempFromDate=DateAdd(d,1,@TempFromDate)
Set @TempDayCnt=@TempDayCnt -1
End
If @LastDoc = 1 And IsNull(@LastFromDate,'') <> '' And IsNull(@LastToDate,'') <> ''
Insert Into #RepTable Values(@reportid,@LastFromDate,@LastToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
Fetch next from DayCursor into @Reportid,@Grepid,@AliasSP, @LastDoc
End
Close DayCursor
Deallocate DayCursor
--End


Select Repid,FDate,Tdate,LUDate,
"ActionData" = Case When IsNull(AliasSP,'') = '' Then ActionData Else AliasSP End,
DetailCommand,ForwardParam,
"Parameter Id"=(Select ParameterId from Reports_to_Upload where ReportID=Grepid),
"DetailProcName"=Case Detailcommand When 0 Then N''
Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,
Node,"ReportType"=1,"DayofMonthWeek"=0,"ReportID"=Grepid, "GPFlag" = GPFlag, "LatestDocument" = LatestDoc
From #Reptable,ReportData
Where ReportData.Action=1 and ReportData.ID=#RepTable.Repid

Drop table  #Reptable
