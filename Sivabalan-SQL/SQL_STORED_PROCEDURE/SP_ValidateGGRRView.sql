CREATE Procedure SP_ValidateGGRRView
AS
BEGIN

--		Create Table #tmpDates(AllDate Datetime)
--		DECLARE @DateFrom smalldatetime, @DateTo smalldatetime;
--		SELECT @DateFrom=DATEADD(month, DATEDIFF(month, 0, LastInventoryupload), 0)  From Setup
--		SELECT @DateTo=LastInventoryupload From Setup;

		
--		WITH T(date)
--		AS
--		( 
--		SELECT @DateFrom 
--		UNION ALL
--		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
--		)
--		insert into #tmpDates(AllDate)
--		SELECT date FROM T OPTION (MAXRECURSION 32767);
--
--		Create Table #Result(PDate Datetime)
--
--		Insert into #Result(PDate)
--		Select AllDate from #tmpDates where AllDate not in
--		(select DayCloseDate from DayCloseTracker where module ='GGDRView' and DaycloseDate>=@DateFrom) 	


--		If (select count(*) from #Result)>0
--		BEGIN
--			Select 1,min(PDate),(Select max(AllDate) from #tmpDates) from #Result
--		END
--		ELSE
--		BEGIN
--			Select 0
--		END
		
		DECLARE @Date datetime
		Select @Date=LastInventoryupload From Setup
		if not exists (select 'x' from DayCloseTracker where module ='GGDRView' and DaycloseDate=@Date)
		BEGIN
			Select 1,@Date,@Date
		END
		ELSE
		BEGIN
			Select 0
		END
 	
		
--		Drop Table #tmpDates
--		Drop Table #Result
END
