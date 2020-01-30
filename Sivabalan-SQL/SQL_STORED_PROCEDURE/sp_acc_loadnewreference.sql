CREATE procedure sp_acc_loadnewreference(@AccountID Int)  
as  
Declare @Prefix nvarchar(20)  
  
Select @Prefix = Prefix  
from VoucherPrefix where TranID =N'MANUAL JOURNAL'  
  
Select 'DocumentID' = @Prefix + Cast(DocumentID as nvarchar(20)),  
ReferenceNo,DocumentDate,Amount,Balance,NewRefID,'DocType'=Case When PrefixType=1 Then 8 Else 9 End,PrefixType,Remarks from ManualJournal  
where AccountID = @AccountID  
and isnull(Status,0) <> 192 and isnull(Status,0) <> 128  
and isnull(Balance ,0) <> 0 
