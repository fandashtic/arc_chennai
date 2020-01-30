CREATE FUNCTION [dbo].[Fn_Get_CurrentAchievementVal_ClosingPoints](@Customerid Nvarchar(255),@Invoicedate Datetime,@Flag Int)
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

Declare @MaxDate_Tar as datetime
Declare @MaxPeriod_Tar as nvarchar(25)
Select @MaxDate_Tar = Max(Cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid
Set @MaxPeriod_Tar = CONVERT(VARCHAR(7), @MaxDate_Tar, 126)

IF Exists(Select * From LP_AchievementDetail Where CustomerID = @Customerid and isnull([Print], -1) = -1 and Period = @MaxPeriod_Tar)
Begin

IF Exists (Select * From LP_ScoreDetail Where
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
End
Else
IF Exists(Select * From LP_AchievementDetail Where CustomerID = @Customerid and isnull([Print], -1) = 1 and Period = @MaxPeriod_Tar)
Begin

Declare @Period_Tar as Nvarchar(25)
Declare @ProgramType_Tar as Nvarchar(255)
Declare @Percentage_Tar as decimal(18,2)
Declare @Print_Tar as Nvarchar(25)
Declare @date_Tar as DateTime
Declare @AchievedTo_Tar as DateTime
Declare @OldVal_Tar as Decimal(18,2)
Declare @NewVal_Tar as Decimal(18,2)
Declare @TotalAchievement_Tar as Decimal(18,2)
Declare @Target_Tar as Decimal(18,2)

Declare @Balance_Tar as Decimal(18,2)
Declare @ProductScope_Tar as nvarchar(100)
Declare @Label_Tar as nvarchar(25)

IF Exists (Select * From LP_AchievementDetail Where dbo.stripTimeFromdate(@Invoicedate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Invoicedate) <= dbo.stripTimeFromdate(GraceDate) and dbo.stripTimeFromdate(@Trandate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 1)
Begin
--					Select @MaxDate=Max(Cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid and isnull(PrintLabel, -1) = 2
--					Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

Select Top 1 @Period_Tar = Period,@ProgramType_Tar = Isnull(Program_Type,'') , @ProductScope_Tar = isnull(ProductScope,''),
@Label_Tar = isnull(Label,'')
From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid and Period =@MaxPeriod_Tar and isnull([Print], -1) = 1

Select @OldVal_Tar = Sum(Isnull(AchievedVal,0)),@Target_Tar = Sum(Isnull(TargetVal,0)),@AchievedTo_Tar = dbo.StripTimeFromDate(Max(AchievedTo))
From LP_AchievementDetail
Where Customerid = @Customerid
And Active = 1
And Period = @Period_Tar
And Isnull(Program_Type,'') = @ProgramType_Tar
And Isnull(ProductScope,'') = @ProductScope_Tar
And isnull([Print], -1) = 1
Group By Customerid,Period

IF @Trandate <= (Select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period = @Period_Tar and isnull([Print], -1) = 1)
Begin
Set @date_Tar = (Select dbo.stripTimeFromdate(lastinventoryupload) From Setup)
End
Else If @Trandate >= (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 1) and @Trandate <= (select dbo.stripTimeFromdate(max(GraceDate)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period = @Period_Tar and isnull([Print], -1) = 1)
Begin
Set @date_Tar = (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 1)
End

Select @NewVal_Tar = Sum(Isnull(Achieved,0)) From LPCustomerScore
Where CustomerID = @Customerid
And Period = @Period_Tar
And Isnull(Program_Type,'') = @ProgramType_Tar
And Isnull(ProductScope,'') = @ProductScope_Tar
And dbo.stripTimeFromdate(DayClose) > dbo.stripTimeFromdate(@AchievedTo_Tar)

Set @TotalAchievement_Tar = (isnull(@OldVal_Tar,0) + Isnull(@NewVal_Tar,0))
Set @Balance_Tar = isnull(@Target_Tar, 0) - isnull(@TotalAchievement_Tar,0)

If Isnull(@Flag,0) = 0
Begin
Set @SQL = @Label_Tar +':'
End
If Isnull(@Flag,0) = 1
Begin
Set @SQL = 'Target:' + Cast(Cast(Round(@Target_Tar,0) as Int) as nvarchar(50))
End
If Isnull(@Flag,0) = 2
Begin
Set @SQL = 'Ach:' + Cast(Cast(Round(@TotalAchievement_Tar ,0)as Int) as nvarchar(50))
End
If Isnull(@Flag,0) = 3
Begin
Set @SQL = 'Balance:' + Cast(Cast(Round(@Balance_Tar ,0)as Int) as nvarchar(50))
End

End
End
--Select @SQL
RETURN @SQL
END
