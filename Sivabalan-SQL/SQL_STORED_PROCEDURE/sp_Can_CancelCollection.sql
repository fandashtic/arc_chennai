CREATE Procedure sp_Can_CancelCollection (@CollectionID Int)
As
--This check is to verify whether the current selected collectionid has
--been already adjusted in any other collection transaction.
If Exists(Select CollectionID From Collections, CollectionDetail 
Where Collections.DocumentID = CollectionDetail.CollectionID And
CollectionDetail.DocumentId = @CollectionID And 
CollectionDetail.DocumentType = 3 And
IsNull(Collections.Status, 0) & 128 = 0) 
Begin
	Select 0
End
Else 
Begin
	Select 1
-- 	Select Case When Collections.Balance = Collections.Value Then 1 Else 0 End
-- 	From Collections Where DocumentID = @CollectionID And 
-- 	IsNull(Collections.Status, 0) & 128 = 0
End




