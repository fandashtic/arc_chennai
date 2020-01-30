CREATE Procedure sp_acc_CanAmendCollection(@DocID as Int)                    
As                    
Declare @Count as Int                    
Declare @AmendedCount Int                    
Declare @ExpenseAccount Int    
                
Select @Count=Count(CollectionID) from CollectionDetail, Collections                     
where CollectionDetail.DocumentID = @DocID and DocumentType = 3 And     
Collections.DocumentID = CollectionDetail.CollectionID And     
((IsNull(Collections.Status,0) & 64 = 0) Or (IsNull(Collections.Status,0) & 128 = 0))                  
                    
If IsNull(@Count,0) = 0    
 Begin                
  Select @AmendedCount = Count(DocumentID) from collections Where DocumentID=@DocID                
  And ((IsNull(Collections.Status,0) & 128 <> 0) Or (IsNull(Collections.Status,0) & 1 <> 0))              
  If IsNull(@AmendedCount,0) = 0                
   Begin                  
    Select @ExpenseAccount = IsNull(ExpenseAccount,0) from Collections Where DocumentID = @DocID    
    If @ExpenseAccount = 0    
     Begin    
      Select Count(DocumentID) from collections Where DocumentID=@DocID and           
      Value <> Balance And (IsNull(Collections.Status,0) & 128 = 0) And                     
      (Select Count(CollectionID) From CollectionDetail Where CollectionID = Collections.DocumentID) = 0                    
     End    
    Else    
     Begin    
      Select @Count    
     End    
   End                
  Else                    
   Begin                
    Select @AmendedCount                
   End                
 End                
Else                    
 Begin                    
  Select @Count                    
 End                    

