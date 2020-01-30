CREATE procedure sp_view_Rec_CollectionDetail(@CollectionID as int)    
as    
select "CollectionID" =OriginalID, "PaymentDate" =PaymentDate, "DocumentValue" =DocumentValue,"AdjustedAmount" = AdjustedAmount, "DocumentType" =DocumentType,     
"ExtraCollection" =ExtraCollection, "DocRef" =DocRef, "Adjustment" =Adjustment, "DocumentID" =DocumentID    
from CollectionDetailreceived    
where CollectionID = @CollectionID  
  

