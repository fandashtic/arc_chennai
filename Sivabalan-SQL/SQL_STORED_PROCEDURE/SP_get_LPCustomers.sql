Create Procedure SP_get_LPCustomers @BeatID nvarchar(4000)
AS
BEGIN
	Declare @Delimeter as Char(1)   
	declare @Achievementflag as int
	Declare @Scoreflag as int

	Set @Delimeter=','    
	Declare @tmpBeat Table (BeatID int)
	Insert into @tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatID,@Delimeter)  

	Select @Achievementflag = count(*) from LP_AchievementDetail where isnull(active,0)=1
	Select @Scoreflag = count(*) from LP_Scoredetail where isnull(active,0)=1

	Declare @TransactionDate as Datetime
	select top 1 @TransactionDate = isnull(dbo.stripdatefromtime(Transactiondate),getdate()) from setup

	/* Both Achievement and Score are there*/
	if isnull(@Achievementflag,0) > 0 and isnull(@Scoreflag,0) > 0
    BEGIN
		Select distinct C.Company_name from Customer C, Beat_salesman BS
		where C.CustomerID = BS.CustomerID and 
		(C.CustomerID in (Select CustomerID from LP_Scoredetail where isnull(active,0)=1 and 
		@TransactionDate <= dbo.stripTimeFromdate(GraceDate) and @TransactionDate >= dbo.stripTimeFromdate(DateAdd(m,+1,'01/' + Right(Period,2) + '/' + Left(Period,4))))
		or C.CustomerID in (Select CustomerID from lp_achievementdetail where isnull(active,0)=1 
		and @TransactionDate < = (isnull(dbo.stripTimeFromdate(GraceDate),getdate())) and @TransactionDate > isnull(dbo.stripTimeFromdate(achievedTo),getdate())))And
		isnull(C.Active,0)=1 and 
		BS.BeatID in (select BeatID from @tmpBeat)
	END
	/* Achievement is there but score is not there*/
	Else IF isnull(@Achievementflag,0) > 0 and isnull(@Scoreflag,0) = 0
	BEGIN
		Select distinct C.Company_name from Customer C, Beat_salesman BS
		where C.CustomerID = BS.CustomerID and 
		C.CustomerID in (Select CustomerID from lp_achievementdetail where isnull(active,0)=1 
		and @TransactionDate < = (isnull(dbo.stripTimeFromdate(GraceDate),getdate())) 
		and @TransactionDate > isnull(dbo.stripTimeFromdate(achievedTo),getdate()))And
		isnull(C.Active,0)=1 and 
		BS.BeatID in (select BeatID from @tmpBeat)
	END
	/* Achievement is not there but score is there*/
	Else IF isnull(@Achievementflag,0) = 0 and isnull(@Scoreflag,0) > 0
	BEGIN
		Select distinct C.Company_name from Customer C, Beat_salesman BS
		where C.CustomerID = BS.CustomerID and 
		C.CustomerID in (Select CustomerID from LP_Scoredetail where isnull(active,0)=1 and @TransactionDate <= dbo.stripTimeFromdate(GraceDate) 
		and @TransactionDate >= dbo.stripTimeFromdate(DateAdd(m,+1,'01/' + Right(Period,2) + '/' + Left(Period,4))))
		And isnull(C.Active,0)=1 and 
		BS.BeatID in (select BeatID from @tmpBeat)
	END
END
