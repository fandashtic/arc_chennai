CREATE Procedure Sp_Get_CustomisedWeeklyRepTobeGenerated_ITC(@Curdate DateTime = NULL,
	@UpdateLastInventory int = 0)
As
SET DATEFORMAT dmy
DECLARE @LUploadDate datetime
DECLARE @DayCnt integer
DECLARE @TempDayCnt integer
DECLARE @TempFromDate datetime
DECLARE @TempToDate datetime
DECLARE @Reportid int
DECLARE @Grepid int	
Declare @LastUploadDate datetime

--ITC wants reports to be generated upto previous day

set @Curdate = dateadd(d,-1,isnull(@CurDate,getdate()))
CREATE TABLE #RepTable (Repid int,FDate datetime,Tdate datetime,GRepid int)
SELECT @LUploadDate=dbo.stripdatefromtime(Dateadd(d,1,ReportUploadDate)) from Setup
Select @CurDate=dbo.stripdatefromtime(ISnull(@Curdate,getdate()))

SELECT @DayCnt=DateDiff(d,@LUploadDate,@CurDate)+1
SET @TempDayCnt=@DayCnt	
SET @TempFromDate=@LUploadDate              
--@LUploadDate = reportuploaddate
	DECLARE DayCursor CURSOR FOR
	SELECT ReportDataID,ReportId FROM Reports_To_UpLoad	WHERE Frequency=5
	OPEN DayCursor
	FETCH NEXT FROM DayCursor INTO @Reportid,@Grepid
	WHILE @@fetch_status=0 
	BEGIN
		SET @TempFromDate=@LUploadDate
		SET @TempToDate=@LUploadDate
		WHILE((@TempFromDate < = @CurDate)And (@TempToDate < = @CurDate))
		BEGIN
			SET @TempDayCnt=Day(@TempToDate)				
			SET DATEFORMAT DMY				
			if ((@TempDayCnt=13) OR (@TempDayCnt=20))
			BEGIN
				SET @TempFromDate=Dateadd(day,-6,@TempToDate)						
				INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@gRepid)
				set @LastUploadDate = @TempToDate
			END
			ELSE IF(@TempDayCnt=6)
			BEGIN
				SET @TempFromDate=Dateadd(day,-6,@TempToDate)
				IF DAY(@TempFromDate) = 30 
				BEGIN
					SET @TempFromDate=Dateadd(day,1,@TempFromDate)										
				END
				INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@gRepid)
				set @LastUploadDate = @TempToDate
			END
			ELSE IF(@TempDayCnt=Day(dbo.Get_Last_DayoftheMonth(@TempToDate)))----Last Day of the Month
			BEGIN
				SET @TempFromDate=Dateadd(day,21-Day(@TempToDate),@TempToDate)						
				IF DAY(@TempToDate) = 31 
				BEGIN
					INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,DATEADD(day,-1,@TempToDate),@gRepid)
					set @LastUploadDate = DATEADD(day,-1,@TempToDate)
				END
				ELSE
				BEGIN
					INSERT INTO #RepTable VALUES(@reportid,@TempFromDate,@TempToDate,@gRepid)
					set @LastUploadDate = @TempToDate
				END
			END
			SET @TempToDate=DateAdd(day,1,@TempToDate)   					
			SET @TempFromDate=DateAdd(day,1,@TempFromDate)   
		END
		FETCH NEXT FROM DayCursor INTO @Reportid,@Grepid
	END					
	CLOSE DayCursor
	DEALLOCATE DayCursor

if @UpdateLastInventory = 1
begin
	update setup set lastinventoryupload = @LastUploadDate
end

Select Repid,FDate,Tdate,ActionData,DetailCommand,ForwardParam,
"Parameter Id"=(Select ParameterId from Reports_to_Upload where ReportID=Grepid),
"DetailProcName"=Case Detailcommand When 0 Then N''
Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,
"Node"=(select reportname from Reports_to_Upload where ReportID=Grepid) ,
"ReportType"=4,"DayofMonthWeek"=0,"ReportID"=Grepid
From #Reptable,ReportData
Where ReportData.Action=1 and ReportData.ID=#RepTable.Repid

DROP TABLE #RepTable


