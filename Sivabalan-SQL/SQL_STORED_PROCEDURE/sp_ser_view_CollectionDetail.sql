Create procedure sp_ser_view_CollectionDetail(@CollectionID as int)    
as    
select "OriginalID" = OriginalID, "DocumentDate" = DocumentDate, "DocumentValue" = DocumentValue,  
"AdjustedAmount" = AdjustedAmount, "DocumentTypeID" = DocumentType, "Addl Adj Value" = ExtraCollection,  
"DocRef" = DocRef, "Adjustment" = Adjustment, "DocumentID" = DocumentID,
"DocumentType" = case convert(numeric,DocumentType)  
 when 2 then 'Credit Note'  
 when 3 then 'Collections'  
 when 5 then 'Debit Note'  
 end
from CollectionDetail    
where CollectionID = @CollectionID

/* 
 when 1 then 'Sales Return'    
 when 4 then 'Invoice'   */

