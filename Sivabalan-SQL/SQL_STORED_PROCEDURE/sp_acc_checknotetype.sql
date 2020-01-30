CREATE Procedure sp_acc_checknotetype(@Type Int,@DocumentID Int)      
as      
If @Type = 5      
Begin      
 Select 'AccountID' = IsNull(DebitNote.AccountID,0)      
 From DebitNote Where DebitID = @DocumentID      
 and IsNull(Status,0) <> 192      
End      
Else If @Type = 4      
Begin      
 Select 'AccountID' = IsNull(CreditNote.AccountID,0)      
 From CreditNote Where CreditID = @DocumentID      
 and IsNull(Status,0) <> 192      
End      
Else if @Type = 6       
Begin      
 Select 'AccountID' = IsNull(CreditNote.AccountID,0)      
 From CreditNote Where CreditID = @DocumentID      
     
End      
Else if @Type = 7
Begin    
 Select 'AccountID' = IsNull(DebitNote.AccountID,0)      
 From DebitNote Where DebitID = @DocumentID      
-- --  and IsNull(Status,0) not in ( 64,128)      
End    
Else if @Type = 9     
Begin      
 Select 'AccountID' = IsNull(CreditNote.AccountID,0)      
 From CreditNote Where CreditID = @DocumentID
 and IsNull(Status,0) <> 192        
End 
Else If @Type = 11      
Begin      
 Select 'AccountID' = IsNull(CreditNote.AccountID,0)      
 From CreditNote Where CreditID = @DocumentID      
 and IsNull(Status,0) <> 192      
End 
