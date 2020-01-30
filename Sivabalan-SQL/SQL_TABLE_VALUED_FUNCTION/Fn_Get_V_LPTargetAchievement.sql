CREATE FUNCTION Fn_Get_V_LPTargetAchievement()  
RETURNS @V_LPTargetAchievement TABLE (  
	[CustomerId] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS ,
	[LastDayclosedate] dateTime,
	[SeqNo] Int,
	[ProductDesc] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Target] Decimal(18,6) Default(0),
	[Achievement] Decimal(18,6) Default(0))
AS      
BEGIN
Declare @Trandate as DateTime
Set @Trandate = (select dbo.stripTimeFromdate(Transactiondate) from setup)
DECLARE @Temp table (Customerid nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Period nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ProductScope nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_Type Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SequenceNo Int,TargetVal Decimal(18,6) ,OldAchievedval Decimal(18,6),NewAchievedval Decimal(18,6), Achievement Decimal(18,6),LastDayclose DateTime)
DECLARE @NewTemp table (Customerid nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Period nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, ProductScope nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Program_Type Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SequenceNo Int,TargetVal Decimal(18,6) ,OldAchievedval Decimal(18,6),NewAchievedval Decimal(18,6), Achievement Decimal(18,6),LastDayclose DateTime,PeriodDate dateTime)
Insert Into @Temp select Distinct LP_AchievementDetail.Customerid,Period,ProductScope,Program_Type,LP_AchievementDetail.SequenceNo, sum(TargetVal),Sum(Achievedval),0,0,Null 
From LP_AchievementDetail,Customer C Where 
C.CustomerID = LP_AchievementDetail.CustomerID
And isnull(C.active,0)=1
And LP_AchievementDetail.Active = 1 And dbo.stripTimeFromdate(@Trandate) Between dbo.stripTimeFromdate(LP_AchievementDetail.TargetFrom) And dbo.stripTimeFromdate(LP_AchievementDetail.TargetTo) And dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and dbo.stripTimeFromdate(@Trandate) >= dbo.stripTimeFromdate(AchievedTo + 1) Group By LP_AchievementDetail.Customerid,Period,ProductScope,Program_Type,LP_AchievementDetail.SequenceNo

insert Into @NewTemp
select *,cast((Period + '-01') as DateTime) From @temp

Delete a From @NewTemp a, (Select Max(PeriodDate) as Pdate, CustomerID, Program_Type, ProductScope From @NewTemp 
							Group By CustomerID, Program_Type, ProductScope Having Count(*) > 1
							) b
Where a.CustomerID = b.CustomerID and a.Program_Type = b.Program_Type and a.ProductScope = b.ProductScope
	and (a.PeriodDate <> b.PDate)

--WITH cte AS (SELECT ROW_NUMBER() OVER (PARTITION BY CustomerID,ProductScope,Program_Type ORDER BY (PeriodDate)) RN FROM   @NewTemp)
--Delete FROM cte WHERE  RN = 1

	Declare @Customerid as nvarchar(50)
	Declare @Period as nvarchar(50)
	Declare @ProductScope as nvarchar(50)
	Declare @Program_Type as nvarchar(255)
	Declare @NewAchievement as Decimal (18,6)
	Declare @cur Cursor 
	Set @cur = Cursor for
	select Distinct CustomerID,Period,ProductScope,Program_Type from @NewTemp
	Open @cur
	Fetch Next from @cur into @Customerid,@Period,@ProductScope,@Program_Type
	While @@fetch_status =0
		Begin
			Set @NewAchievement = isnull((select Sum(Achieved) From LPCustomerScore Where Customerid = @Customerid and Period = @Period and ProductScope = @ProductScope And Program_Type = @Program_Type And dbo.stripTimeFromdate(DayClose) > 
						(select dbo.stripTimeFromdate(Max(AchievedTo)) From LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and  Period = @Period And Program_Type = @Program_Type)),0)
			Update @NewTemp set NewAchievedval = @NewAchievement Where Customerid = @Customerid and Period = @Period and ProductScope = @ProductScope And Program_Type = @Program_Type
			Update @NewTemp set Achievement = (isnull(OldAchievedval,0) + Isnull(NewAchievedval,0)) Where Customerid = @Customerid and Period = @Period and ProductScope = @ProductScope And Program_Type = @Program_Type
			Fetch Next from @cur into @Customerid,@Period,@ProductScope,@Program_Type
		End
	Close @cur
	Deallocate @cur
	--Update @NewTemp set LastDayclose = (select dbo.stripTimeFromdate(LastInventoryUpload) from setup)

	Update @NewTemp set LastDayclose = (Select Top 1 dbo.stripTimeFromdate(DayCloseDate) From DayCloseModules Where Module = 'Loyalty Program')
	Insert into @V_LPTargetAchievement 	select Distinct Customerid, LastDayclose,SequenceNo,ProductScope,TargetVal,Achievement from @NewTemp
RETURN
END 
