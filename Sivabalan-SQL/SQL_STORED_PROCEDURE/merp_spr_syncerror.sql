create procedure merp_spr_syncerror
(@FromDate Datetime,@Todate DateTime,@SalesmanID nvarchar(2000),@TransType nvarchar(50))
as
Declare @Delimeter as nChar(1)
Set @Delimeter=Char(15)

--Salesman Temp Table
Create table #tmpSalesMan(SalesManId int)
if @SalesmanID=N'%' or @SalesmanID = N'All Salesman'
	Insert into #tmpSalesMan select SalesmanId from SalesMan
Else
	Insert into #tmpSalesMan Select SalesmanId From SalesMan 
	Where SalesMan_Name In(select * from dbo.sp_SplitIn2Rows(@SalesmanID,@Delimeter))

--Transaction Temp Table
Create table #tmpTranType(TranType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @TransType=N'%' or @TransType=N'All Type'
	Insert into #tmpTranType select distinct TransactionType From SyncError
Else
Begin
	Insert into #tmpTranType select * from dbo.sp_SplitIn2Rows(@TransType,@Delimeter)
	update #tmpTranType Set TranType = case isnull(TranType,'') 
	when 'Sales Order' Then '1' 
	when 'Collection' Then '2'
	when 'Sales Return' Then '3'
	else '0' end
End
	

--Report data
select
"Message Date" = se.creationdate,
"Message Date" = se.creationdate,
"Salesman" = sm.Salesman_Name,
"Transaction ID" = isnull(se.transactionID,''),
"Transaction Type" = case isnull(se.transactiontype,'') 
when '1' Then 'Sales Order'
when '2' Then 'Collection'
when '3' Then 'Sales Return'
else 'Others'
end,
"Message Type" = isnull(se.msgtype,''),
"Message Action" = isnull(se.msgaction,''),
"Message Description" = isnull(se.msgdescription,'')
from syncerror se , salesman sm 
where 
se.creationdate between @FromDate and @Todate
and se.salesmanid = sm.salesmanid
and sm.salesmanID IN (select SalesManId From #tmpSalesMan)
and se.transactiontype IN (select TranType From #tmpTranType)
order by se.creationdate

drop table #tmpTranType
drop table #tmpSalesMan
