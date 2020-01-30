CREATE Procedure sp_validateParamDailyOrderRpt( @ParamValuelist nvarchar(4000))
As
Set DateFormat dmy

Select Identity(int, 1, 1) Idnt, Itemvalue Parameter Into #tmpParam from dbo.sp_SplitIn2Rows ( @ParamValuelist, '|')
If 
	(select Parameter from #tmpParam where Idnt = 1 ) <> 'All Salesman' or
	(select Parameter from #tmpParam where Idnt = 2 ) <> 'All SalesmanType' or
	(select Parameter from #tmpParam where Idnt = 3 ) <> 'All Customer Type' or
	(select Parameter from #tmpParam where Idnt = 4 ) <> 'All Customer' or
	(select Parameter from #tmpParam where Idnt = 5 ) <> 'Division' or
	(select Parameter from #tmpParam where Idnt = 6 ) <> 'All Category' or
    (select Parameter from #tmpParam where Idnt = 7 ) <> 'Base UOM' or
    (select Parameter from #tmpParam where Idnt = 8 ) <> 'Detail' or
    (select Parameter from #tmpParam where Idnt = 9 ) <> 'No' or
    ( Convert(varchar(10), (select Parameter from #tmpParam where Idnt = 10), 103) <> Convert(varchar(10), (select Parameter from #tmpParam where Idnt = 11), 103) ) or
    ( Datediff(dd, Convert(datetime, (select Parameter from #tmpParam where Idnt = 10), 103) , Convert(datetime, (select Parameter from #tmpParam where Idnt = 11), 103) ) < 0 )
    Select 0
Else
    Select 1
