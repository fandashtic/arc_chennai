-- exec sp_acc_accountopeningbalanceupdation_AccWise 'Mar 13 2008 12:00:00:000AM', '1'
create Procedure sp_acc_accountopeningbalanceupdation_AccWise (@LastUpdated Datetime, @ACCOUNTID int)  
/* Procedure to update daily opening balance */  
As  

-- Declare @LastUpdated Datetime
-- Declare @ACCOUNTID int
-- Set @LastUpdated  = 'Mar 13 2008 12:00:00:000AM'
-- set @ACCOUNTID = '1'
  
Declare @LastBalance Decimal(18,6)  
Declare @CurrentBalance Decimal(18,6)  
Declare @OpeningBalance Decimal(18,6)  
--Declare @AccountID Int  
  
Declare @ToDatePair DateTime  

--if Opening Details Updated fir the given date exit proc
if Exists(Select * from AccountOpeningBalance Where OpeningDate =  DateAdd(dd,1,@LastUpdated) And AccountID = @ACCOUNTID)    
		goto ExitProc

Set @ToDatePair=DateAdd(s,0-1,DateAdd(dd,1,@LastUpdated))  

--SET DATEFORMAT DMY  
 --get the openingvalue from the AccountOpeningBalance table for each AccountID of lastupdated date  
 Set @LastBalance=0  
 If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@LastUpdated and AccountID=@AccountID)  
 Begin  
  Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1  
 End  
    
 set @LastBalance= isnull(@LastBalance,0) + isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@LastUpdated and AccountID=@AccountID),0)  
 --get the current balance from the generalJournal table for each AccountID of the last updated date   
 Select @CurrentBalance= isnull(sum(Debit-Credit),0) from GeneralJournal where   
 (TransactionDate between @LastUpdated and @ToDatePair)  
 and AccountID=@AccountID and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)  
 and isnull(status,0) <> 128 and isnull(status,0) <> 192  
 --Insert the OpeningBalance + Current balance of the last date as Opening Balance  
 -- for the next date in AccountOpeningBalance table.  
 Set @OpeningBalance=isnull(@LastBalance,0)+isnull(@CurrentBalance,0)  
 --dont insert if openingbalance of that account is 0  
 --If @OpeningBalance<>0  
 --Begin  
  Insert into AccountOpeningBalance (AccountID,OpeningDate,OpeningValue) Values (@AccountID,DateAdd(day,1,@LastUpdated),@OpeningBalance)  
 --End  

ExitProc:

