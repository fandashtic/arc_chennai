CREATE PROCEDURE sp_Amend_PO (@PONumber Int,@OldPONumber Int,@OldDocID Int,@OldDocRef nvarchar(255))        
as        
Begin       
	Update POAbstract set Status = (isnull(status,0) | 136) where PONumber = @OldPONumber
	Update POAbstract set Status = IsNull(Status,0) | 8 where PONumber = @PONumber
	Update POAbstract set POIDReference=@OldPONumber,DocumentID=@OldDocID,DocumentReference=@OldDocRef
	Where PONumber=@PONumber 
End
