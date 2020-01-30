Create Procedure mERP_SP_rsisfirstofmonth (@DateFrom datetime,@DateTo datetime)
AS
BEGIN
Set dateformat dmy
Create Table #tmpDates(AllDate Datetime);

WITH T(date)
AS
( 
SELECT @DateFrom 
UNION ALL
SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < @DateTo
)
insert into #tmpDates(AllDate)
SELECT date FROM T OPTION (MAXRECURSION 32767);
if exists(select'x' from #tmpDates where Alldate = dbo.stripdatefromtime((DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,Alldate)+1,0)))))
Select 1
else
Select 0
Drop Table #tmpDates
END
