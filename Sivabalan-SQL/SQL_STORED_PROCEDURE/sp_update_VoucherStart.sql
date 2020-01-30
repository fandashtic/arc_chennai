Create Procedure sp_update_VoucherStart(@DocumentID int,  
     @VoucherStart int)  
As  

If Isnull(@DocumentID,0) = 101 Or Isnull(@DocumentID,0) = 102 Or Isnull(@DocumentID,0) = 103 Or Isnull(@DocumentID,0) = 105 Or Isnull(@DocumentID,0) = 106 Or Isnull(@DocumentID,0) = 107
	Begin
		Goto SKip
	End
Else
	Begin
		Update DocumentNumbers Set VoucherStart = @VoucherStart, DocumentID = @VoucherStart  
		Where DocType = @DocumentID  
	End
SKip:
