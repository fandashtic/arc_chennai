Create procedure mERP_SP_Get_PayoutMonths
AS
BEGIN
SET DATEFORMAT DMY

Declare @mindate datetime
Declare @maxdate datetime
Declare @tmpDate Datetime

Create Table #tmpMonth(MonthDesc nvarchar(100))

--instead of showing from Payout period, we are showing from first transaction date
--select @mindate=min(payoutperiodfrom) from tbl_merp_schemepayoutperiod where isnull(active,0)=1
--select @maxdate=max(payoutperiodfrom) from tbl_merp_schemepayoutperiod where isnull(active,0)=1
--To handle More than one entry in Setup Table
select @mindate='01/'+ cast(month(min(openingdate)) as varchar)+'/'+cast(year(min(openingdate)) as varchar) from setup
select @maxdate='01/'+cast(month(getdate()) as varchar) +'/'+cast(year(getdate())as varchar)
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
