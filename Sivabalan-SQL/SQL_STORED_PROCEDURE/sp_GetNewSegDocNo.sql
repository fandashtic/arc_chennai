

CREATE procedure sp_GetNewSegDocNo    
As    
Declare @DocumentID int    
Begin Tran    
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 66  
Select @DocumentID = DocumentID - 1 From DocumentNumbers where DocType =66     
Commit Tran    
Select @DocumentID    
  
