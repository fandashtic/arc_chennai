CREATE FUNCTION [dbo].[Fn_Get_CurrentAchievementVal](@Customerid Nvarchar(255),@Invoicedate Datetime)  
RETURNS Nvarchar(2000)
AS      
BEGIN
	Declare @Period as Nvarchar(25)
	Declare @TotalAchieved as decimal(18,2)
	Declare @date as DateTime
	Declare @Trandate as DateTime
	Declare @Values as Decimal(18,2)
	Declare @SQL as Nvarchar(2000)
	Declare @Fromdate as DateTime
	Set @SQL = Null
	Set @Trandate = (select dbo.stripTimeFromdate(Transactiondate) from setup)
	/* Since same customer can be active in more than one period, below changes are made
	Now we consider only latest period */
	Declare @Periods Table(DatePeriod datetime)
	Declare @MaxPeriod nvarchar(25)
	Insert into @Periods
	select DateAdd(M,+1,cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) as [Period] from LP_ScoreDetail 
					Where Customerid = @Customerid And Active = 1 group by Customerid,Period

	select @Fromdate = max(Dateperiod) from @Periods
	/* To get the latest Score Month*/
	Set @MaxPeriod= CONVERT(VARCHAR(7), dateadd(m,-1,@Fromdate), 126)

	if Exists (select * from LP_ScoreDetail Where 
	@Invoicedate >= dbo.stripTimeFromdate(@Fromdate) and 
	@Invoicedate <= dbo.stripTimeFromdate(GraceDate) and 
	dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and 
	@Trandate >= dbo.stripTimeFromdate(@Fromdate) and 
	Customerid = @Customerid  And 
	Active = 1)
		Begin
--			set @Period = (Select Distinct Period from LP_AchievementDetail Where Active = 1)
			
			select @Period = (Right(Period,2) + '/' +  Left(Period,4)) from LP_ScoreDetail 
			Where Customerid = @Customerid  
			And Active = 1
			--And Period = @Period
			And Period=@MaxPeriod
			group by Customerid,Period

			Set @Values = (select Sum(PointsEarned) from LP_ScoreDetail Where Customerid = @Customerid 
			and Active = 1 -- and Period = @Period
			And Period=@MaxPeriod
			and [Type] = 'CLBAL')

			Set @SQL = ('Closing Points as on ' 
			+ @Period + 
			' : ' + cast(cast(Round(@Values ,0)as Int) as nvarchar(50)))
		End

	RETURN @SQL
END
