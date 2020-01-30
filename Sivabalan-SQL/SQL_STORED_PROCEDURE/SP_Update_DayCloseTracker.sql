Create Procedure SP_Update_DayCloseTracker @FromDate Datetime,@Todate Datetime,@module nvarchar(100)
AS
BEGIN
	Set Dateformat DMY
	If @FromDate <= @Todate
	BEGIN
		Create Table #tmpDates(AllDate Datetime);
		WITH T(date)
		AS
		( 
		SELECT @FromDate 
		UNION ALL
		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @Todate
		)
		insert into #tmpDates(AllDate)
		SELECT date FROM T OPTION (MAXRECURSION 32767);
		
		Delete from DayCloseTracker Where Dbo.StripdateFromtime(DayCloseDate)in (select AllDate from #tmpDates)
		And Module=@module

		Insert into DayCloseTracker(DayCloseDate,Module,Status)
		Select AllDate,@module,0 from #tmpDates
		Drop Table #tmpDates
	END	

	
END
