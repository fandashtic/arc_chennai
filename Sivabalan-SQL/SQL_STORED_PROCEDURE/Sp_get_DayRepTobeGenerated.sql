CREATE Procedure Sp_get_DayRepTobeGenerated(@Curdate DateTime = NULL)
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

	Declare DayCursor Cursor For
		Select ReportDataID,ReportId, IsNull(AliasActionData, ''), IsNull(LatestDoc,0)
		From Reports_To_UpLoad
		Where Frequency=1

	Open DayCursor
	Fetch Next From DayCursor Into @Reportid,@Grepid,@AliasSP, @LastDoc
	While @@Fetch_Status=0 
	Begin
		Select @LUploadDate=dbo.Stripdatefromtime(DateAdd(d,1,LastUploadDate)), @GraceTime = IsNull(GracePeriod, 0) 
			From Reports_To_Upload 
			Where ReportID = @Grepid

		Select @DayCnt=DateDiff(d,@LUploadDate,@CurDate) + 1
		Set @TempDayCnt=@DayCnt	
		Set @TempFromDate=@LUploadDate
		Select @LUploadDate = LastUploadDate From Reports_To_Upload Where ReportID = @Grepid
		While (@TempDayCnt)> 0
		Begin
			If @GraceTime > 1 
				Set @GPFlag = -1 --Invalid grace period
			Else If ((Select DateDiff(d,@TempFromDate,@Curdate)) >= @GraceTime) And (@GraceTime <> 0)
				Set @GPFlag = 1	--Grace period reached
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
