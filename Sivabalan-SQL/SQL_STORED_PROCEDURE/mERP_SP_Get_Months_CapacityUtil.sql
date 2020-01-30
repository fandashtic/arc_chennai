Create procedure mERP_SP_Get_Months_CapacityUtil
AS
BEGIN
SET DATEFORMAT DMY
/*Similar logic like RFA screen*/
Declare @mindate datetime
Declare @maxdate datetime
Declare @tmpDate Datetime
Declare @LDM Datetime
Declare @LCD Datetime
Create Table #tmpMonth(MonthDesc nvarchar(100))

select @mindate='01/'+ cast(month(min(openingdate)) as varchar)+'/'+cast(year(min(openingdate)) as varchar) from setup

/*Last day of the close month */
SELECT @LDM = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,lastinventoryupload))),DATEADD(mm,1,lastinventoryupload)),103) from setup 

/* Day close Date */
Select @LCD = dbo.stripdatefromtime(lastinventoryupload) From Setup

/*If last day of the month is closed the consider the next month*/
If @LDM=@LCD
BEGIN
	Set @LCD =dateadd(d,1,@LCD)
	select @maxdate='01/'+cast(month(@LCD) as varchar) +'/'+cast(year(@LCD)as varchar)
END
ELSE
BEGIN
	select @maxdate='01/'+cast(month(lastinventoryupload) as varchar) +'/'+cast(year(lastinventoryupload)as varchar) From Setup
END
set @tmpDate=@mindate
while @tmpDate < = @maxdate
BEGIN
insert into #tmpMonth SELECT CONVERT(varchar(3), @tmpDate )+'-'
+right(CONVERT(varchar(11), @tmpDate),4)
set @tmpDate = dateadd(m,1,@tmpDate)
END
Select * from #tmpMonth
Drop table #tmpMonth
END
