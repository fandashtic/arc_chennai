CREATE Function sp_acc_getaccountbalance(@accountid integer,@CurrentDate datetime)    
Returns Decimal(18,6)    
As    
Begin    
DECLARE @openingvalue decimal(18,6)    
DECLARE @balance decimal(18,6)   
Declare @TempCurrentDate datetime  
    
Set @CurrentDate =dbo.stripdatefromtime(@CurrentDate)    
Set @TempCurrentDate = DateAdd(s,0-1,DateAdd(d,1,@CurrentDate))    
     
if not exists (select top 1 OpeningValue from accountopeningbalance where [AccountID]=@accountid and OpeningDate = @CurrentDate)     
begin    
 Select @openingvalue = isNull(OpeningBalance,0) from AccountsMaster    
 where AccountID=@accountID and isnull([Active],0)=1     
end    
else    
begin    
 select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance    
 where [AccountID]=@accountid and OpeningDate = @CurrentDate  
end    
     
select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster    
where [TransactionDate] between @CurrentDate and @TempCurrentDate and [GeneralJournal].AccountID = @accountid and     
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)     
and [AccountsMaster].[Active]=1 and isnull(status,0) <> 128 and isnull(status,0) <> 192    
and [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]    
    
return  (isnull(@openingvalue,0) + isnull(@balance,0))    
End 
