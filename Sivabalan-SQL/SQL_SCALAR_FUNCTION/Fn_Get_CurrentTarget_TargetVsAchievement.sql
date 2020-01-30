CREATE FUNCTION [dbo].[Fn_Get_CurrentTarget_TargetVsAchievement](@Customerid Nvarchar(255),@Invoicedate Datetime,@Flag Int)
RETURNS Nvarchar(2000)
AS
BEGIN
Declare @Period as Nvarchar(25)
Declare @ProgramType as Nvarchar(255)
Declare @Percentage as decimal(18,2)
Declare @Print as Nvarchar(25)
Declare @date as DateTime
Declare @AchievedTo as DateTime
Declare @OldVal as Decimal(18,2)
Declare @NewVal as Decimal(18,2)
Declare @TotalAchievement as Decimal(18,2)
Declare @SQL as Nvarchar(2000)
Declare @Target as Decimal(18,2)
Declare @Trandate as DateTime
Declare @MaxDate as datetime
Declare @MaxPeriod as nvarchar(25)
Set @Trandate = (select dbo.stripTimeFromdate(Transactiondate) from setup)
Set @SQL = Null

Declare @Balance as Decimal(18,2)
Declare @ProductScope as nvarchar(100)
Declare @Label as nvarchar(25)

Select @MaxDate=Max(Cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid
Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

IF Exists(Select * From LP_AchievementDetail Where CustomerID = @Customerid and isnull([Print], -1) = -1 and Period = @MaxPeriod)
Begin

IF Exists (Select * From LP_AchievementDetail Where dbo.stripTimeFromdate(@Invoicedate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Invoicedate) <= dbo.stripTimeFromdate(GraceDate) and dbo.stripTimeFromdate(@Trandate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and Customerid = @Customerid and Active = 1)
Begin
--				Select @MaxDate=max(cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) From LP_AchievementDetail Where Active = 1 And Customerid = @Customerid
--				Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

Select Top 1 @Period = Period,@ProgramType = Isnull(Program_Type,'') From LP_AchievementDetail Where Active = 1 And Customerid = @Customerid and period =@MaxPeriod

Select @OldVal = sum(Isnull(AchievedVal,0)),@Target = sum(Isnull(TargetVal,0)),@AchievedTo = dbo.stripTimeFromdate(max(AchievedTo))
From LP_AchievementDetail
Where Customerid = @Customerid
And Active = 1
And Period = @Period
And Isnull(Program_Type,'') = @ProgramType
Group By Customerid,Period

IF @Trandate <= (Select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period = @Period)
Begin
Set @date = (Select dbo.stripTimeFromdate(lastinventoryupload) From Setup)
End
Else If @Trandate >= (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1) and @Trandate <= (select dbo.stripTimeFromdate(max(GraceDate)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period =@Period)
Begin
Set @date = (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1)
End

Select @NewVal = Sum(Isnull(Achieved,0)) From LPCustomerScore
Where Customerid = @Customerid
And Period = @Period
And Isnull(Program_Type,'') = @ProgramType
And dbo.stripTimeFromdate(DayClose) > dbo.stripTimeFromdate(@AchievedTo)

Set @TotalAchievement = (isnull(@OldVal,0) + Isnull(@NewVal,0))
IF isnull(@Target,0) > 0
Begin
Set @Percentage = Isnull(((@TotalAchievement / @Target) * 100),0)
Set @Print = (cast(@Percentage as nvarchar(50))+ '%')
End
Else
Set @Print = 'N/A'

Set @SQL = '|Tgt Vs Achv as on '
+ cast((Convert(Nvarchar(10),@date,103)) as nvarchar(50))+  ' : '
+ cast(cast(Round(@Target,0) as Int) as nvarchar(50)) + ' / ' + cast(cast(Round(@TotalAchievement ,0)as Int) as nvarchar(50))
+ ' (' + @Print + ')'
End
End
Else
Begin
IF Exists(Select * From LP_AchievementDetail Where CustomerID = @Customerid and isnull([Print], -1) = 2 and Period = @MaxPeriod)
Begin

IF Exists (Select * From LP_AchievementDetail Where dbo.stripTimeFromdate(@Invoicedate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Invoicedate) <= dbo.stripTimeFromdate(GraceDate) and dbo.stripTimeFromdate(@Trandate) > dbo.stripTimeFromdate(AchievedTo) and dbo.stripTimeFromdate(@Trandate) <= dbo.stripTimeFromdate(GraceDate) and Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 2)
Begin
--					Select @MaxDate=Max(Cast(('01/'+(Right(Period,2) + '/' +  Left(Period,4)))as DateTime)) From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid and isnull(PrintLabel, -1) = 2
--					Set @MaxPeriod= CONVERT(VARCHAR(7), @MaxDate, 126)

Select Top 1 @Period = Period,@ProgramType = Isnull(Program_Type,'') , @ProductScope = isnull(ProductScope,''),
@Label = isnull(Label,'')
From LP_AchievementDetail Where Active = 1 And CustomerID = @Customerid and Period =@MaxPeriod and isnull([Print], -1) = 2

Select @OldVal = Sum(Isnull(AchievedVal,0)),@Target = Sum(Isnull(TargetVal,0)),@AchievedTo = dbo.StripTimeFromDate(Max(AchievedTo))
From LP_AchievementDetail
Where Customerid = @Customerid
And Active = 1
And Period = @Period
And Isnull(Program_Type,'') = @ProgramType
And Isnull(ProductScope,'') = @ProductScope
And isnull([Print], -1) = 2
Group By Customerid,Period

IF @Trandate <= (Select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period = @Period and isnull([Print], -1) = 2)
Begin
Set @date = (Select dbo.stripTimeFromdate(lastinventoryupload) From Setup)
End
Else If @Trandate >= (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 2) and @Trandate <= (select dbo.stripTimeFromdate(max(GraceDate)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and period =@Period and isnull([Print], -1) = 2)
Begin
Set @date = (select dbo.stripTimeFromdate(Max(TargetTo)) from LP_AchievementDetail Where Customerid = @Customerid and Active = 1 and isnull([Print], -1) = 2)
End

Select @NewVal = Sum(Isnull(Achieved,0)) From LPCustomerScore
Where CustomerID = @Customerid
And Period = @Period
And Isnull(Program_Type,'') = @ProgramType
And Isnull(ProductScope,'') = @ProductScope
And dbo.stripTimeFromdate(DayClose) > dbo.stripTimeFromdate(@AchievedTo)

Set @TotalAchievement = (isnull(@OldVal,0) + Isnull(@NewVal,0))
Set @Balance = isnull(@Target, 0) - isnull(@TotalAchievement,0)

If Isnull(@Flag,0) = 0
Begin
Set @SQL = @Label+':'
End
If Isnull(@Flag,0) = 1
Begin
Set @SQL = 'Target:' + Cast(Cast(Round(@Target,0) as Int) as nvarchar(50))
End
If Isnull(@Flag,0) = 2
Begin
Set @SQL = 'Ach:' + Cast(Cast(Round(@TotalAchievement ,0)as Int) as nvarchar(50))
End
If Isnull(@Flag,0) = 3
Begin
Set @SQL = 'Balance:' + Cast(Cast(Round(@Balance ,0)as Int) as nvarchar(50))
End

--Set @SQL = @Label + ':Tgt/Achv/Bal:' + Cast(Cast(Round(@Target,0) as Int) as nvarchar(50))
--			+ '/' + Cast(Cast(Round(@TotalAchievement ,0)as Int) as nvarchar(50))
--			+ '/' + Cast(Cast(Round(@Balance ,0)as Int) as nvarchar(50))

End

End
End

--Select @SQL
RETURN @SQL
END
