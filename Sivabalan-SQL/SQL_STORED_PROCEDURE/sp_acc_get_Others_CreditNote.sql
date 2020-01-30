CREATE procedure sp_acc_get_Others_CreditNote(@DocumentID int)  
as  
select AccountsMaster.AccountID, AccountsMaster.AccountName, NoteValue, DocumentDate, Memo,   
DocumentID, DocRef,  
case     
When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)      
When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)    
when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)    
when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)    
Else ''      
end, Cancel_Memo,'Account' = dbo.getaccountname(isnull(CreditNote.AccountID,0)),DocumentReference,DocSerialType  
from CreditNote, AccountsMaster  
where CreditID = @DocumentID and  
AccountsMaster.AccountID = CreditNote.Others  
  


