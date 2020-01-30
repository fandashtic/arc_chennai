CREATE Procedure Sp_Get_CumulativeWeeklyRepTobeGenerated(@Curdate DateTime = NULL,@UpdateLastInventory int = 0)
As

	SET DATEFORMAT dmy
	DECLARE @LUploadDate datetime
	DECLARE @DayCnt integer
	DECLARE @TempDayCnt integer
	DECLARE @TempFromDate datetime
	DECLARE @TempToDate datetime
	DECLARE @Reportid int
	DECLARE @Grepid int	
	Declare @AliasSP nVarChar(100)
	Declare @LastUploadDate datetime
	Declare @GraceTime Int
	Declare @GPFlag Int
	Declare @LastDoc Int
	Declare @LastFromDate DateTime
	Declare @LastToDate DateTime
	Declare @LatestDocument nVarchar(10)
	
	CREATE TABLE #RepTable (Repid int,FDate datetime,Tdate datetime, LUDate DateTime, GRepid int,AliasSP nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, GPFlag Int, LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
	--SELECT @LUploadDate=dbo.stripdatefromtime(Dateadd(d,1,LastUploadDate)) From  Reports_To_Upload Where ReportName = N'Sales Position Report'--Setup
	Select @CurDate=dbo.stripdatefromtime(ISnull(@Curdate,getdate()))


	DECLARE DayCursor CURSOR FOR
	SELECT ReportDataID,ReportId, IsNull(AliasActionData,''), IsNull(LatestDoc,0) FROM Reports_To_UpLoad	WHERE Frequency=5
	OPEN DayCursor
	FETCH NEXT FROM DayCursor INTO @Reportid,@Grepid, @AliasSP, @LastDoc
	WHILE @@fetch_status=0 
	BEGIN
		SELECT @LUploadDate=dbo.stripdatefromtime(Dateadd(d,1,LastUploadDate)) From  Reports_To_Upload Where ReportID = @Grepid--Setup
		SELECT @DayCnt=DateDiff(d,@LUploadDate,@CurDate)+1
		SET @TempDayCnt=@DayCnt	
		SET @TempFromDate=@LUploadDate
		SET @TempToDate=@LUploadDate
		Select @LUploadDate = LastUploadDate From Reports_To_Upload Where ReportID = @Grepid
		WHILE((@TempFromDate < = @CurDate)And (@TempToDate < = @CurDate))
		BEGIN
			SET @TempDayCnt=Day(@TempToDate)				

			SET DATEFORMAT DMY				
			Select @GraceTime = GracePeriod From Reports_To_Upload Where ReportId = @Grepid		
			If @GraceTime > 6 
				 	Set @GPFlag = -1 --Invalid grace period
			Else If ((Select DateDiff(d,@TempToDate,@Curdate)) >= @GraceTime )
					Set @GPFlag = 1 --Grace time reached 
			Else
					Set @GPFlag = 0 --Grace period exists
			
			If @LastDoc = 1 
				Set @LatestDocument = N'Yes'
			Else
				Set @LatestDocument = N'No'

			IF((@TempDayCnt=7) OR (@TempDayCnt=14) OR (@TempDayCnt=21))
			BEGIN
				SET @TempFromDate= Cast(('1-' + Cast(Month(@TempToDate) As nVarChar) + '-' + Cast(Year(@TempToDate) As nVarChar)) As DateTime)
--'01'Dateadd(day,-6,@TempToDate)						
				If @LastDoc <> 1
				Begin
					INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate
					Set @LastToDate = @TempToDate
				End
			END
			ELSE IF(@TempDayCnt=Day(dbo.Get_Last_DayoftheMonth(@TempToDate)))----Last Day of the Month
			BEGIN	
				SET @TempFromDate= Cast(('1-' + Cast(Month(@TempToDate) As nVarChar) + '-' + Cast(Year(@TempToDate) As nVarChar)) As DateTime)
--Dateadd(day,22-Day(@TempToDate),@TempToDate)						
				If @LastDoc <> 1
				Begin
					INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate
					Set @LastToDate = @TempToDate
				End
			END
			SET @TempToDate=DateAdd(day,1,@TempToDate)   					
			SET @TempFromDate=DateAdd(day,1,@TempFromDate)   

		END
		If (@LastToDate + @Grepid) > = @Curdate 
			Begin
				Set @GPFlag = 1 --Grace time reached
			End
		Else
				Set @GPFlag = @GPFlag 
				
		If @LastDoc = 1 And IsNull(@LastFromDate,'') <> '' And IsNull(@LastToDate,'') <> ''
			INSERT INTO #RepTable VALUES(@reportid,@LastFromDate,@LastToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)

		FETCH NEXT FROM DayCursor INTO @Reportid,@Grepid, @AliasSP, @LastDoc
	END					
	CLOSE DayCursor
	DEALLOCATE DayCursor
		
	If @UpdateLastInventory = 1
	Begin
		Update Setup Set LastInventoryUpload = @LastUploadDate
	End

	Select Repid,FDate,Tdate, LUDate,
	"ActionData" = Case When IsNull(AliasSP,'') = '' Then ActionData Else AliasSP End,
	DetailCommand,ForwardParam,
	"Parameter Id"=(Select ParameterId from Reports_to_Upload where ReportID=Grepid),
	"DetailProcName"=Case Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,
	Node,"ReportType"=5,"DayofMonthWeek"=0,"ReportID"=Grepid, GPFlag, "LatestDocument" = LatestDoc
	From #Reptable,ReportData
	Where ReportData.Action=1 and ReportData.ID=#RepTable.Repid

	DROP TABLE #RepTable

