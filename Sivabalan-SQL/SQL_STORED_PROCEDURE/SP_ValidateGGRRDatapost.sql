CREATE Procedure SP_ValidateGGRRDatapost
AS
BEGIN
	/* If there is any data with incomplete posting redo the posting from that date */
	If exists(Select 'x' From GGRRDayCloseLog where Status <> 2)
	BEGIN
		/* If FYCP is done then no need to check the GGRR Log*/
		If (select isnull(FYCPStatus,0) from Setup)=0
		BEGIN
			Select 1,min(DayCloseDate) as DayCloseDate From GGRRDayCloseLog where Status <> 2
		END
		ELSE
		BEGIN
			Select 0
		END
	END	
	Else
	BEGIN
		Set dateformat DMY
		Create Table #tmpDates(AllDate Datetime)
		Create Table #Result(PDate Datetime)
		DECLARE @DateFrom smalldatetime, @DateTo smalldatetime;
		Declare @LastInventoryUpload Datetime
		Select @LastInventoryUpload=dbo.stripdatefromtime(LastInventoryUpload) from Setup		
		SELECT @DateFrom=DATEADD(m,0,DATEADD(mm, DATEDIFF(m,0,@LastInventoryUpload), 0))
		Select top 1 @DateTo=@LastInventoryUpload;
		WITH T(date)
		AS
		( 
		SELECT @DateFrom 
		UNION ALL
		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
		)
		insert into #tmpDates(AllDate)
		SELECT date FROM T OPTION (MAXRECURSION 32767);
		Insert into #Result(PDate)
		Select AllDate from #tmpDates where AllDate not in
		(select DayCloseDate from GGRRDaycloseLog) 	
		
		/* If FYCP is done then no need to check the GGRR Log*/
		If (select isnull(FYCPStatus,0) from Setup)=0
		BEGIN
			/* If there is any missing dates then do repost*/
			IF exists(select 'x' from #Result)
			BEGIN
				Select 1,Min(PDate) from #Result
			END
			ELSE
			BEGIN
				/* No Issue, can proceed for day close */
				Select 0
			END
		END
		ELSE
		BEGIN
			Select 0
		END
		Drop Table #tmpDates
		Drop Table #Result
	END
END
