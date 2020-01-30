CREATE procedure sp_acc_list_Others_DebitNote(@OthersID Int,    
        @FromDate datetime,    
        @ToDate datetime)    
as    
If @OthersID=0    
Begin    
 select DocumentID, DocumentDate, AccountsMaster.AccountID, AccountsMaster.AccountName, NoteValue,    
 DebitID,    
 case       
 When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)      
 When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then ''
 when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)      
 when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)      
 when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)      
 Else ''        
 end,DocumentReference    
 from DebitNote, AccountsMaster    
 where DocumentDate between @FromDate and @ToDate and    
 AccountsMaster.AccountID = DebitNote.Others    
 order by AccountsMaster.AccountName,AccountsMaster.AccountID, DocumentDate    
End    
Else    
Begin    
 select DocumentID, DocumentDate, AccountsMaster.AccountID, AccountsMaster.AccountName, NoteValue,    
 DebitID,    
 case       
 When Status & 64 <> 0 Then dbo.LookupDictionaryItem('Cancelled',Default)        
 When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then ''
 when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem('Amended',Default)      
 when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem('Amended',Default)      
 when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem('Amendment',Default)      
 Else ''        
 end,DocumentReference                
 from DebitNote, AccountsMaster    
 where AccountsMaster.AccountID like @OthersID and    
 DocumentDate between @FromDate and @ToDate and    
 AccountsMaster.AccountID = DebitNote.Others    
 order by AccountsMaster.AccountName,AccountsMaster.AccountID, DocumentDate    
End    
    
  




