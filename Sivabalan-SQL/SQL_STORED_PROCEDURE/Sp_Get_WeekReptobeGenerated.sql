CREATE Procedure Sp_Get_WeekReptobeGenerated(@Curdate DateTime = NULL)
As
	Set dateFirst 7
	Declare @LUploadDate datetime
	Declare @value int
	Declare @getNextDate datetime
	Declare @FirstFromDate datetime
	Declare @FirstToDate datetime
	Declare @TempFromDate datetime
	Declare @TempToDate datetime
	Declare @repid int
	Declare @i integer
	Declare @LUploadTempDate datetime
	Declare @Grepid int
	Declare @GraceTime Int 
	Declare @GPFlag Int
	Declare @AliasSP nVarchar(100)
	Declare @LastDoc Int
	Declare @LastFromDate DateTime
	Declare @LastToDate DateTime
	Declare @LatestDocument nVarchar(10)

	Set DateFormat DMY

	Create Table #temp1 (Reportid int,GenFromDate datetime,GenToDate datetime,LastUploadDate DateTime,DayWeek int,Grepid int,AliasSP nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,GPFlag Int, LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS )
	--Select @LUploadDate=Cast(dbo.stripdatefromtime(dateadd(d,1,ReportUploadDate)) As nvarchar) From Setup
	Select @CurDate=Cast(dbo.stripdatefromtime(Isnull(@Curdate,getdate())) as nvarchar)

	Declare MonthCursor Cursor for 
		Select ReportDataID,Isnull(DayOfMonthWeek,0),ReportID, IsNull(AliasActionData, ''), IsNull(LatestDoc,0)
		From Reports_To_UpLoad
		Where Frequency=3 

	Open MonthCursor
	Fetch next from MonthCursor Into @Repid,@Value,@Grepid, @AliasSP, @LastDoc

	While @@Fetch_Status=0	
	Begin
		Select @LUploadDate=dbo.Stripdatefromtime(DateAdd(d,1,LastUploadDate)), @GraceTime = IsNull(GracePeriod, 0) 
			From Reports_To_Upload 
			Where ReportID = @Grepid

		If @Value >DatePart(dw,@LuploadDate)
		Begin
			Set @LUploadTempDate=DateAdd(d,(@Value-DatePart(dw,@LuploadDate)),@LupLoadDate)
			Set @getNextDate =DateAdd(d,0,DateAdd(d,-7,@LUploadTempDate))
		End
		Else
		Begin	
			If @Value =DatePart(dw,@LuploadDate)
		Begin
			Set @getNextDate =@LUploadDate
			Set @getNextDate =Cast(Cast(Day(@getNextDate)as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@getNextDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@getNextDate)as nvarchar) as datetime)
		End
		Else			
		Begin
			Set @LUploadTempDate=DateAdd(d,(@Value-DatePart(dw,@LuploadDate)),@LupLoadDate)
			Set @getNextDate =@LUploadTempDate
			Set @getNextDate =Cast(Cast(Day(@getNextDate)as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@getNextDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@getNextDate)as nvarchar) as datetime)
		End
		End
		Set @FirstFromDate = @getNextDate
		Set @FirstToDate=DateAdd(d,-1,DateAdd(d,7,@FirstFromDate))

		IF (@FirstToDate <=@CurDate)
		Begin
			Select @LuploadDate = LastUploadDate From Reports_To_Upload Where ReportID = @Grepid
			Set @TempFromDate=@FirstFromDate
   			Set @TempToDate=@FirstToDate
			Set @i=1
			While(@i > 0)
			Begin
				If(@TempFromDate < @CurDate) and (@TempToDate <=@CurDate)
				Begin
					Select @GraceTime = GracePeriod From Reports_To_Upload Where ReportId = @Grepid		
					If @GraceTime > 6 
				 		Set @GPFlag = -1 --Invalid grace period
					Else If ((Select DateDiff(d,@TempToDate,@CurDate)) >= @GraceTime )
						Set @GPFlag = 1 --Grace period reached
					Else
						Set @GPFlag = 0 --Grace period not reached
					If @LastDoc <> 1
					Begin
						Set @LatestDocument = N'No'
						Insert Into #temp1 Values(@Repid,@TempFromDate,@TempToDate,@LuploadDate,@Value,@Grepid, @AliasSP,@GPFlag,@LatestDocument)
					End
					Else
					Begin
						Set @LatestDocument = N'Yes'
						Set @LastFromDate = @TempFromDate
						Set @LastToDate = @TempToDate
					End
					Set @i=1	
				End
				Else
				   Begin
					   Set @i=0				
				   End	
				Set @TempFromDate=DateAdd(d,1,@TempTodate) 	
				Set @TempToDate=DateAdd(d,-1,DateAdd(d,7,@TempFromDate))
			End		
		End
		If @LastDoc = 1 And IsNull(@LastFromDate,'') <> '' And IsNull(@LastToDate,'') <> ''
		Insert Into #temp1 Values(@Repid,@LastFromDate,@LastToDate,@LuploadDate,@Value,@Grepid, @AliasSP,@GPFlag,@LatestDocument)

		Fetch next from MonthCursor Into @Repid,@Value,@Grepid, @AliasSP, @LastDoc
	End
	Close MonthCursor
	Deallocate MonthCursor

	Select Reportid,GenFromDate,GenToDate,LastUploadDate,
	"ActionData" = Case When IsNull(AliasSP,'') = '' Then ActionData Else AliasSP End,
	DetailCommand,ForwardParam,
	"Parameter ID"=(Select ParameterId from Reports_to_Upload where ReportID=Grepid),
	"DetailProcName"=Case Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,
	Node,"Frequency"=3,"DayOfMonthWeek"=DayWeek,"GenReportID"=Grepid, GPFlag, "LatestDocument" = LatestDoc
	From #temp1,ReportData
	Where ReportData.Action=1 and ReportData.ID=#temp1.Reportid

	drop table #temp1
