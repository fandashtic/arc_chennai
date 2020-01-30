CREATE PROCEDURE sp_Amend_Collection (@CollectionID Int,     
    @OldCollectionID Int, @OldCollFullDocID nvarchar(50))        
as        
Update Collections set OriginalRef = @OldCollFullDocID, 
RefDocID = @OldCollectionID where DocumentID = @CollectionID 
