CREATE procedure sp_acc_loadaccountbalance(@AccountID integer)    
as    
DECLARE @OpeningValue Decimal(18,6),@CurrentDate DateTime    
DECLARE @Balance Decimal(18,6)    
DECLARE @TempCurrentDate datetime                      
    
SET DateFormat DMY    
-- -- SET @CurrentDate=dbo.stripdatefromtime(GetDate())    
SET @CurrentDate=dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
SET @TempCurrentDate=DateAdd(s,0-1,DateAdd(dd,1,@CurrentDate))                      
     
If NOT Exists (Select top 1 OpeningValue from AccountOpeningBalance where [AccountID]=@AccountID And OpeningDate=@CurrentDate)     
Begin    
 Select @OpeningValue = IsNULL(OpeningBalance,0) from AccountsMaster    
 where AccountID=@AccountID And IsNULL([Active],0)=1     
End    
Else    
Begin    
 Select @OpeningValue=IsNULL(OpeningValue,0) from AccountOpeningBalance    
 where [AccountID]=@AccountID And OpeningDate=@CurrentDate    
End    
     
Select @Balance = Sum(IsNULL(Debit,0)-IsNULL(Credit,0)) from GeneralJournal,AccountsMaster    
where [TransactionDate] Between @CurrentDate And @TempCurrentDate And [GeneralJournal].AccountID = @AccountID   
And DocumentType NOT IN (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)  
And [AccountsMaster].[Active]=1 And IsNULL(status,0) <> 128 And IsNULL(status,0) <> 192    
And [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]    
    
Select  IsNULL(@OpeningValue,0) + IsNULL(@Balance,0) 

