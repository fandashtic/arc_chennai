CREATE Procedure sp_acc_rpt_daybooksummary(@fromdate datetime,@todate datetime)    
as    
Declare @documentdate datetime    
Declare @particular nvarchar(255)    
Declare @debit decimal(18,6)    
Declare @credit decimal(18,6)    
Declare @accountid int    
Declare @colorinfo int    
Declare @serialno int     
Declare @TOTAL nVARCHAR(10)    
Declare @ACCOUNT Int    
  
Declare @ToDatePair datetime  
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))  
  
Set @ACCOUNT =2    
Set @TOTAL = N'$'    
create table #TempSummary(DocumentDate datetime,Particular nvarchar(255),    
Debit decimal(18,6),Credit decimal(18,6),AccountID int,FromDate datetime,    
ToDate datetime,ColorInfo int)    
    
create table #TempSummary1(DocumentDate datetime,Particular nvarchar(255),    
Debit decimal(18,6),Credit decimal(18,6),AccountID int,FromDate datetime,    
ToDate datetime,SerialNo int identity not null, ColorInfo int)    
    
insert #TempSummary    
Select 'Document Date'= dbo.stripdatefromtime(TransactionDate),    
'Particular'= dbo.getaccountname(AccountID),    
'Debit' = case when sum(Debit - Credit) > 0 then abs(Sum(Debit - Credit)) else 0 end,    
'Credit' = case when sum(Debit - Credit) < 0 then abs(sum(Debit - Credit)) else 0 end,    
Max(GeneralJournal.AccountID),dbo.stripdatefromtime(TransactionDate),    
dbo.stripdatefromtime(TransactionDate),'ColorInfo'=@ACCOUNT     
from GeneralJournal where TransactionDate between @fromdate and @ToDatePair    
and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)    
    
and isnull(status,0) <> 128 and isnull(status,0) <> 192    
Group By dbo.stripdatefromtime(TransactionDate), dbo.getaccountname(AccountID)     
    
insert #TempSummary1    
select documentdate, 'Particular' = isnull(particular,N'$'), sum(debit),    
sum(credit),max(AccountID),documentdate,documentdate, max(ColorInfo)     
from #TempSummary group by documentdate, particular with rollup    
    
Update #TempSummary1    
set Colorinfo = 1,    
Particular = 'Total'    
where Particular = @TOTAL    
    
select @serialno = count(serialno)    
from #TempSummary1     
    
delete #TempSummary1 where SerialNo = @serialno    
    
select * from #TempSummary1 order by SerialNo    
drop table #TempSummary    
drop table #TempSummary1 
