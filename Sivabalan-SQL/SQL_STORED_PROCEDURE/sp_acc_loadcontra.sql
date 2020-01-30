CREATE procedure sp_acc_loadcontra(@accountid integer,@fromdate datetime,@todate datetime,@mode integer)    
as     
DECLARE @CASH integer    
DECLARE @ALLACCOUNTS integer    
DECLARE @SPECIFICACCOUNT integer    
    
SET @CASH = 3    
SET @ALLACCOUNTS = 1    
SET @SPECIFICACCOUNT = 2    
    
set dateformat dmy    
    
if @mode = @ALLACCOUNTS    
begin    
 select DepositID,FullDocID,DepositDate,TransactionType,Value,Status    
 from Deposits where dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
 and Transactiontype<>5     
end    
else if @mode =@SPECIFICACCOUNT    
begin    
 if @accountid = @CASH     
 begin    
  select DepositID,FullDocID,DepositDate,TransactionType,Value,Status    
  from Deposits where dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
  and Transactiontype <> 5 and Transactiontype <> 6  
 end    
 else    
 begin    
  select DepositID,FullDocID,DepositDate,TransactionType,Value,Status    
  from Deposits where [AccountID] = @accountid and dbo.stripdatefromtime([DepositDate]) between @fromdate and @todate    
  and Transactiontype <> 5     
 end    
end    

