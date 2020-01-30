CREATE Procedure Sp_Get_MonthlyOtherReptobeGenerated(@Curdate DateTime = NULL)
As
	Create Table #temp1 (Reportid int,GenFromDate datetime,GenToDate datetime, LastUploadDate DateTime, DayWeek int,Grepid int, AliasSP nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,GPFlag Int, LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
	   


	Declare @LUploadDate datetime
	Declare @value int
	Declare @getNextDate datetime
	Declare @FirstFromDate datetime
	Declare @FirstToDate datetime
	Declare @TempFromDate datetime
	Declare @TempToDate datetime
	Declare @repid int
	Declare @Grepid int
	Declare @i int
	Declare @GraceTime Int
	Declare @GPFlag Int
	Declare @AliasSP nVarchar(100)
	Declare @LastDoc Int
	Declare @LastFromDate DateTime
	Declare @LastToDate DateTime
	Declare @LatestDocument nVarchar(10)

	Set DateFormat DMY

	
	
	Select @CurDate=Cast(dbo.stripdatefromtime(ISnull(@Curdate,getdate())) as nvarchar)
	Declare MonthCursor Cursor for 
	Select ReportDataID,DayOfMonthWeek,ReportId, IsNull(AliasActionData, ''),IsNull(LatestDoc,0)
	From tbl_mERP_OtherReportsUpload
	Where Frequency = 2 
	Open MonthCursor
	Fetch next from MonthCursor Into @Repid,@Value,@Grepid,@AliasSP, @LastDoc
	While @@Fetch_status=0	
	Begin
		Select @LUploadDate=Cast(dbo.stripdatefromtime(Dateadd(d,1,LastUploadDate)) As nvarchar) From tbl_mERP_OtherReportsUpload Where ReportID = @Grepid
		If @Value >Day(@LUploadDate)
		begin        
			Set @getNextDate =Cast(Cast(@value as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@LUploadDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@LUploadDate)as nvarchar) as datetime)
			Set @getNextDate =DateAdd(d,1,DateAdd(m, -1,@getNextDate))
		end
		Else
		begin
			If @Value =Day(@LUploadDate)
			begin
				Set @getNextDate =Cast(Cast(@value as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@LUploadDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@LUploadDate)as nvarchar) as datetime)
	     		Set @getNextDate =Cast(Cast(Day(@getNextDate)as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@getNextDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@getNextDate)as nvarchar) as datetime)
			end 		
			Else	
			begin
	     		Set @getNextDate =Cast(Cast(@value as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@LUploadDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@LUploadDate)as nvarchar) as datetime)
	     		Set @getNextDate =DateAdd(d,0,@getNextDate)
	     		Set @getNextDate =Cast(Cast(Day(@getNextDate)as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@getNextDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@getNextDate)as nvarchar) as datetime)
			end
		end
		Set @FirstFromDate = @getNextDate
		Set @FirstToDate=DateAdd(m,1,@FirstFromDate)
		Set @FirstToDate =Cast(Cast(@Value as nvarchar) + Cast(N'-' as nvarchar) + Cast(Month(@FirstToDate) as nvarchar) + CAst(N'-' as nvarchar) + Cast(Year(@FirstToDate)as nvarchar) as datetime)
		Set @FirstToDate=DateAdd(d,-1,@FirsttoDate)
		
		IF (@FirstToDate <= @CurDate)
		Begin
			Select @LUploadDate = LastUploadDate From tbl_mERP_OtherReportsUpload Where ReportID = @Grepid
			Set @TempFromDate=@FirstFromDate
       		Set @TempToDate=@FirstToDate
			Set @i=1
			While(@i > 0)
			Begin
				If(@TempFromDate < @CurDate) and (@TempToDate < @CurDate)
				Begin
					Select @GraceTime = GracePeriod From tbl_mERP_OtherReportsUpload Where ReportId = @Grepid		
					If @GraceTime > 30 
						Set @GPFlag = -1 --Invalid grace period
					Else If ((Select DateDiff(d,@TempToDate,@CurDate)) >= @GraceTime )
						Set @GPFlag = 1 --Grace Period reached
					Else
						Set @GPFlag = 0 --Grace period not reached
					
					If @LastDoc <> 1
					Begin
						Set @LatestDocument = N'No'
						Insert Into #temp1 Values(@Repid,@TempFromDate,@TempToDate,@LUploadDate,@Value,@Grepid,@AliasSP,@GPFlag,@LatestDocument)
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
				Set @TempToDate=DateAdd(d,-1,DateAdd(m,1,@TempFromDate))
			End		
		End
			If @LastDoc = 1 And IsNull(@LastFromDate,'') <> '' And IsNull(@LastToDate,'') <> ''
			Insert Into #temp1 Values(@Repid,@LastFromDate,@LastToDate,@LUploadDate,@Value,@Grepid,@AliasSP,@GPFlag,@LatestDocument)

			Fetch next from MonthCursor Into @Repid,@Value,@Grepid,@AliasSP, @LastDoc
	End
	Close MonthCursor
	Deallocate MonthCursor

Declare @tblReportUpload as Table (      
	tRptDataID  int,       
	tRptID   Int,       
	tReportType  Int,       
	tReportFrom  DateTime,       
	tReportTo  DateTime,       
	tLastUpload  DateTime,       
	tActionData  nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,       
	tDetailCommand Int,       
	tForwardParam Int,       
	tParamID  Int,       
	DetailProcName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,   
	ReportName  nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,      
	LatestDoc  nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,      
		GPFlag   Int,      
		RepGenSeq  Int)



	Select Reportid,Grepid,2,GenFromDate,GenToDate,LastUploadDate,
	"ActionData" = Case When IsNull(AliasSP,'') = '' Then ActionData Else AliasSP End,
	DetailCommand,ForwardParam,
	"Parameter ID"=(Select ParameterId from tbl_mERP_OtherReportsUpload where ReportID=Grepid),
	"DetailProcName"=Case Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,
	Node,LatestDoc,GPFlag
	From #temp1,ReportData
	Where ReportData.Action=1 and ReportData.ID=#temp1.Reportid

	Drop Table #temp1
