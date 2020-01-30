
CREATE procedure sp_acc_prn_collectiondetail(@CollectionID as int)
as
select OriginalID, DocumentDate, DocumentValue, AdjustedAmount, DocumentType, 
ExtraCollection, DocRef
from CollectionDetail
where CollectionID = @CollectionID



