CREATE procedure sp_acc_list_Others_DebitNote_DocLU (@FromDocID int,  
       @ToDocID int,@DocumentRef nvarchar(510)=N'')  
as  
If Len(@DocumentRef)=0   
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
 where (dbo.GetTrueVal(DocumentID) between @FromDocID and @ToDocID   
 OR (Case Isnumeric(DocumentReference) When 1 then Cast(DocumentReference as int)end) BETWEEN @FromDocID AND @ToDocID)    
 And AccountsMaster.AccountID = DebitNote.Others  
 order by AccountsMaster.AccountName, DocumentDate  
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
 When Memo <> N'' Then LTrim(Rtrim(Memo))      
 Else ''      
 end,DocumentReference           
 from DebitNote, AccountsMaster  
 where DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
 And (CAse ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
 When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) BETWEEN @FromDocID AND @ToDocID  
 And AccountsMaster.AccountID = DebitNote.Others  
 order by AccountsMaster.AccountName, DocumentDate  
End  
  




