Create Function sp_acc_getaccountbalance_ITC(@accountid integer,@CurrentDate datetime,@SysDate Datetime)          
Returns Decimal(18,6)          
As          
Begin          
DECLARE @openingvalue decimal(18,6)          
DECLARE @balance decimal(18,6)         
Declare @TempCurrentDate datetime        
Declare @MaxDate as Datetime          
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
If @CurrentDate > dbo.stripdatefromtime(@SysDate)    
begin    
 Set @MaxDate = (select max(OpeningDate) from accountopeningbalance)          
-- where [AccountID]=@accountid)    
      
 select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance          
 where [AccountID]=@accountid and OpeningDate = @MaxDate    
     
    Set @TempCurrentDate = DateAdd(s,0-1,DateAdd(d,1,@MaxDate))    
 select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster          
 where   
[GeneralJournal].AccountID = @accountid 
And [AccountsMaster].[AccountID]  = @accountid          
And [AccountsMaster].[Active]=1   
And isnull(status,0) <> 128 and isnull(status,0) <> 192          
And [TransactionDate] between @MaxDate and  @TempCurrentDate           
And documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)  
end    
else    
Begin    
 select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster          
 where   
[GeneralJournal].AccountID = @accountid  
And [AccountsMaster].[AccountID] = @accountid          
And [AccountsMaster].[Active]=1  
And isnull(status,0) <> 128 and isnull(status,0) <> 192          
And [TransactionDate] between @CurrentDate and @TempCurrentDate  
And documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)           
End          
return  (isnull(@openingvalue,0) + isnull(@balance,0))          
End       
