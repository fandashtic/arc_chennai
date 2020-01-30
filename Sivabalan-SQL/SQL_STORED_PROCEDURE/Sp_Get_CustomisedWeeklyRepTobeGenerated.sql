CREATE Procedure Sp_Get_CustomisedWeeklyRepTobeGenerated(@Curdate DateTime = NULL,@UpdateLastInventory int = 0)
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
	Declare @GUD DateTime

	CREATE TABLE #RepTable (Repid int,FDate datetime,Tdate datetime, LUDate DateTime, GRepid int,AliasSP nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, GPFlag Int, LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
	--SELECT @LUploadDate=dbo.stripdatefromtime(Dateadd(d,1,LastUploadDate)) From  Reports_To_Upload Where ReportName = N'Sales Position Report'--Setup
	Select @CurDate=dbo.stripdatefromtime(ISnull(@Curdate,getdate()))


	DECLARE DayCursor CURSOR FOR
	SELECT ReportDataID,ReportId, IsNull(AliasActionData,''), IsNull(LatestDoc,0) FROM Reports_To_UpLoad	WHERE Frequency=4
	OPEN DayCursor
	FETCH NEXT FROM DayCursor INTO @Reportid,@Grepid, @AliasSP, @LastDoc
	WHILE @@fetch_status=0 
	BEGIN
		SELECT @LUploadDate=dbo.stripdatefromtime(Dateadd(d,1,LastUploadDate)),@GUD=dbo.stripdatefromtime(Dateadd(d,1,GUD)) From  Reports_To_Upload Where ReportID = @Grepid--Setup
		SELECT @DayCnt=DateDiff(d,@LUploadDate,@CurDate)+1
		SET @TempDayCnt=@DayCnt	
		if (@Reportid =584)
		Begin
			SET @TempFromDate=(select case when @GUD <@LUploadDate then @GUD else @LUploaddate end)
			SET @TempToDate=@TempFromDate			
		End
		Else
		Begin
			SET @TempFromDate=@LUploadDate
			SET @TempToDate=@LUploadDate
		End
		--SPR should upload after grace period even after If it is uploaded with in the grace period
		if (@Reportid =584)
		Begin
			set @LUploadDate = (select case when GUD <LastUploadDate then GUD else LastUploadDate end from Reports_To_Upload Where ReportID = @Grepid)
		End
		Else		
		Begin
			Select @LUploadDate = LastUploadDate From Reports_To_Upload Where ReportID = @Grepid
		End
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

			IF((@TempDayCnt=7) OR (@TempDayCnt=14) OR (@TempDayCnt=21)) and (@Reportid <> 1031 and @Reportid <> 1350 and @Reportid <> 1385)
			BEGIN
				SET @TempFromDate=Dateadd(day,-6,@TempToDate)						
				If @LastDoc <> 1
				Begin
					If (@Reportid = 1004 ) 
					begin						
						if (@Curdate >= @TempTodate) and (Datediff(day,@TempToDate,@Curdate) >= 2)
							INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
						else if (@TempTodate < @Curdate) and (Datediff(day,@TempTodate,@Curdate) > 2)
							INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
					End
					else
						INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
					
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate
					Set @LastToDate = @TempToDate
				End
			END
			Else IF((@TempDayCnt=8) OR (@TempDayCnt=15) OR (@TempDayCnt=22)) and (@Reportid = 1031 or @Reportid = 1350 or @Reportid = 1385) -- AE Report to send only after weekly to date
			BEGIN
				SET @TempFromDate=Dateadd(day,-6,@TempToDate)						
				If @LastDoc <> 1
				Begin
					IF @LUploadDate < @TempToDate-1
						Begin
							INSERT INTO #RepTable VALUES(@reportid,@TempFromDate-1,@TempToDate-1,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
						End
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate 
					Set @LastToDate = @TempToDate -1
				End				
			END
			ELSE IF(@TempDayCnt=Day(dbo.Get_Last_DayoftheMonth(@TempToDate))) and (@Reportid <> 1031) and (@Reportid <> 1350) and (@Reportid <> 1385)----Last Day of the Month
			BEGIN	
				SET @TempFromDate=Dateadd(day,22-Day(@TempToDate),@TempToDate)						
				If @LastDoc <> 1
				Begin
					If (@Reportid = 1004 ) 
					begin						
						if (@Curdate >= @TempTodate) and (Datediff(day,@TempToDate,@Curdate) >= 2)
							INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
						else if (@TempTodate < @Curdate) and (Datediff(day,@TempTodate,@Curdate) > 2)
							INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
					End
					else		
						INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)						
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate
					Set @LastToDate = @TempToDate
				End
			END
			ELSE IF((@Curdate) >= (dbo.Get_Last_DayoftheMonth(@TempToDate)+1)) and (@TempDayCnt=Day(dbo.Get_Last_DayoftheMonth(@TempToDate))) and (@Reportid = 1031 Or @Reportid = 1350 Or @Reportid = 1385)----Last Day of the Month
			BEGIN	

				SET @TempFromDate=Dateadd(day,22-Day(@TempToDate),@TempToDate)
				If @LastDoc <> 1
				Begin
					IF @LUploadDate < @TempToDate
						Begin
							--INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate ,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)												
							IF (@Curdate) = (dbo.Get_Last_DayoftheMonth(@TempToDate)+1) And @Reportid = 1350
								INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate ,@LUploadDate,@gRepid,@AliasSP,0,@LatestDocument)																			
							ElSE
								INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate ,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
						End	
				End
				Else
				Begin
					Set @LastFromDate = @TempFromDate
					Set @LastToDate = @TempToDate
				End
			END
			--If (@Reportid = 1031)
			
			SET @TempToDate=DateAdd(day,1,@TempToDate)   					
			SET @TempFromDate=DateAdd(day,1,@TempFromDate)   
			
		END
			If @LastDoc = 1 And IsNull(@LastFromDate,'') <> '' And IsNull(@LastToDate,'') <> ''
			Begin
			Declare @GPeriod int
			
			select @GPeriod=isnull(graceperiod,0) from reports_to_upload where ReportDataID=@reportid
			if (@GPeriod > 0 )
			Begin
				if (datediff(d,dateadd(d,@Gperiod,@LastToDate),@CurDate))> 0
					set @GPFlag = 1									
			End
			--SPR should not upload after with in the grace period If it is uploaded already with in the grace period
			if (@Reportid =584 and @GPFlag = 0)
			Begin
				If exists (select * from Reports_To_Upload where ReportDataID=@ReportID and LastUploadDate>=@LastToDate)
					GoTo MoveNext
			End			

				INSERT INTO #RepTable VALUES(@reportid,@LastFromDate,@LastToDate,@LUploadDate,@gRepid,@AliasSP,@GPFlag,@LatestDocument)
			End
MoveNext:
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
	Else (Select Rep.Actiondata From Reportdata Rep Where 	Rep.ID=Reportdata.Detailcommand) end,
	Node,"ReportType"=4,"DayofMonthWeek"=0,"ReportID"=Grepid, GPFlag, 	"LatestDocument" = LatestDoc
	From #Reptable,ReportData
	Where ReportData.Action=1 and ReportData.ID=#RepTable.Repid

	DROP TABLE #RepTable

