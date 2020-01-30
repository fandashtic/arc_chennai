CREATE Procedure sp_acc_view_FACollectionDetail(@CollectionID as int)
As
Select OriginalID, DocumentDate, DocumentValue, AdjustedAmount, DocumentType, 
ExtraCollection, DocRef,Adjustment,dbo.sp_acc_Get_AdjustedCollectionNarration(DocumentType,DocumentID) from CollectionDetail where CollectionID = @CollectionID
