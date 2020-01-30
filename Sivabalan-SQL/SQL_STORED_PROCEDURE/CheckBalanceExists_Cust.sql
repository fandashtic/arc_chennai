Create PROCEDURE CheckBalanceExists_Cust (@Custid nvarchar(15),@ret varchar(10) Output)  
as  
Begin   
declare @return varchar(100)   
declare @accid varchar(100)  
declare @nChequeInHand decimal(18,6)  
declare @bal decimal(18,6)  
  
Create table #Acctbl (accid nvarchar(100))  
insert into #Acctbl  
exec sp_acc_getaccountid @Custid,1  
select @accid=accid from #Acctbl  
  
Create table #Fapartytbl (bal1 decimal(18,6))  
insert into #Fapartytbl  
exec sp_acc_FAPartyChqsinhand @accid  
select @nChequeInHand=bal1 from #Fapartytbl  
  
Create table #CashAccounttbl (bal2 decimal(18,6))  
insert into #CashAccounttbl  
exec sp_acc_loadcashaccount @accid,0  
select @bal=bal2 from #CashAccounttbl   
if @nChequeInHand <> 0 or @bal <> 0   
  begin   
  set @return ='True'   
  end   
else   
 begin   
 set @return ='False'   
 end  
Select @ret= @return  
  
drop table #Acctbl  
drop table #Fapartytbl  
drop table #CashAccounttbl  
End   

