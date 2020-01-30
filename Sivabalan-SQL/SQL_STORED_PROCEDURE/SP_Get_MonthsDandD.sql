Create procedure SP_Get_MonthsDandD(@OptSelection int = 1)
AS
BEGIN
SET DATEFORMAT DMY

Declare @mindate datetime
Declare @maxdate datetime
Declare @tmpDate Datetime
Declare @LastDayClose Datetime
Declare @Diff int

Create Table #tmpMonth(MonthDesc nvarchar(100))

IF @OptSelection = 2
Begin
--	select @mindate='01/'+ cast(month(min(openingdate)) as varchar)+'/'+cast(year(min(openingdate)) as varchar) from setup
 
	Select @LastDayClose = LastInventoryUpload From Setup
	Set @MaxDate = @LastDayClose + 1
	Set @MaxDate = DateAdd(m,-1,'01/'+cast(month(@MaxDate) as varchar) +'/'+cast(year(@MaxDate)as varchar))

--	Select @Diff = DateDiff(m, @mindate, @MaxDate)

--	IF @Diff >= 6
--		Set @tmpDate = DateAdd(m,-5,@MaxDate)
--	Else
--		Set @tmpDate=@mindate

	Set @tmpDate = DateAdd(m,-11,@MaxDate)	

	While @tmpDate < = @maxdate
	BEGIN
		insert into #tmpMonth SELECT CONVERT(varchar(3), @tmpDate )+'-'
									+right(CONVERT(varchar(11), @tmpDate),2)
		set @tmpDate = dateadd(m,1,@tmpDate)
	END

	Select * from #tmpMonth
End
Else
Begin
	Select @LastDayClose = LastInventoryUpload From Setup
	
	SELECT CONVERT(varchar(3), @LastDayClose )+'-'+right(CONVERT(varchar(11), @LastDayClose),2)	
End	

Drop table #tmpMonth

END
