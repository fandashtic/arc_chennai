CREATE PROCEDURE sp_Amend_payment (@PaymentID Int, @OldPaymentID nvarchar(25),@OldDocID int)        
as        
Begin       
    
  Update Payments set Status = (isnull(status,0) | 128) where DocumentID = @OldDocID
  Update Payments set RefDocID = @OldDocID, DocRef = @OldPaymentID where DocumentID = @PaymentID        
End
