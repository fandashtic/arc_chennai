CREATE procedure sp_acc_con_rpt_companywiseGPNP   
(@NP integer,@fromdate datetime, @todate datetime,  
@Companies nvarchar(2000),@AccountMode integer,@Report nVarchar(255))    
as  
create table #FAConsolidationGPNP  
(  
 companyid nvarchar(50),  
 Debit decimal (18,6),  
 credit decimal (18,6),  
 colorinfo int  
)  
  
create table #FAConsolidationGPNPFinal  
(  
 Rownum Int IDENTITY (1,1),  
 companyid nvarchar(50),  
 Debit decimal (18,6),  
 credit decimal (18,6),  
 colorinfo int  
)  

Declare @TRADINGACCOUNT nVarchar(255),@BALANCESHEET nVarchar(255),@TRIALBALANCE nVarchar(255)    
Set @TRADINGACCOUNT=N'Trading - Profit & Loss A/C'    
Set @BALANCESHEET = N'Balance Sheet'    
Set @TRIALBALANCE = N'Trial Balance'    
  
insert into #FAConsolidationGPNP  
exec sp_acc_con_rpt_companywiseDetail 28, @fromdate, @todate, @Companies, 3, @Report  
/*
If C/L Stock is double clicked from Trading A/C , the A/C s inside shows a Credit value
If C/L Stock is double clicked from Balance Sheet -> Trading A/C , the A/C s inside 
shows a debit value..
So GP & NP Calculation is not possible,so if C/S is selected from Trading A/C from B/S ,
Pass th parameter as Trading A/C which will retreive the value in Credit Side
*/
if @Report = @BALANCESHEET
Begin
	insert into #FAConsolidationGPNP  
	exec sp_acc_con_rpt_companywiseDetail 55, @fromdate, @todate, @Companies, 3, @TRADINGACCOUNT  
End
Else
Begin
	insert into #FAConsolidationGPNP  
	exec sp_acc_con_rpt_companywiseDetail 55, @fromdate, @todate, @Companies, 3, @Report  
End
insert into #FAConsolidationGPNP  
exec sp_acc_con_rpt_companywiseDetail 26, @fromdate, @todate, @Companies, 3, @Report  
  
  
  
insert into #FAConsolidationGPNP  
exec sp_acc_con_rpt_companywiseDetail 54, @fromdate, @todate, @Companies, 3, @Report  
insert into #FAConsolidationGPNP  
exec sp_acc_con_rpt_companywiseDetail 27, @fromdate, @todate, @Companies, 3, @Report  
insert into #FAConsolidationGPNP  
exec sp_acc_con_rpt_companywiseDetail 24, @fromdate, @todate, @Companies, 3, @Report  
  
if @NP = 1   
Begin  
 insert into #FAConsolidationGPNP  
 exec sp_acc_con_rpt_companywiseDetail 31, @fromdate, @todate, @Companies, 3, @Report  
   
 insert into #FAConsolidationGPNP  
 exec sp_acc_con_rpt_companywiseDetail 25, @fromdate, @todate, @Companies, 3, @Report  
End  
  
insert into #FAConsolidationGPNPFinal  
select companyid,  
case   
 when sum(credit) - sum(debit) >= 0 then sum(credit) - sum(debit)   
 else 0   
end,  
case   
 when sum(credit) - sum(debit) < 0 then abs(sum(credit) - sum(debit))   
 else 0   
end,0  
from #FAConsolidationGPNP where colorinfo = 0 group by companyid  
  
insert into #FAConsolidationGPNPFinal  
select companyid,  
case   
 when sum(credit) - sum(debit) >= 0 then sum(credit) - sum(debit)   
 else 0   
end,  
case   
 when sum(credit) - sum(debit) < 0 then abs(sum(credit) - sum(debit))   
 else 0   
end,1  
from #FAConsolidationGPNP where colorinfo = 1 group by companyid  
  
select Companyid,Debit,Credit,Colorinfo from #FAConsolidationGPNPFinal  
  
drop table #FAConsolidationGPNP   
drop table #FAConsolidationGPNPFinal  


