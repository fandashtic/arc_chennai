CREATE Procedure sp_get_payment_adjustment (@VendorID nvarchar(20))  
As  
Select 1, VoucherPrefix.Prefix + Cast(AdjustmentReturnAbstract.DocumentID As nvarchar),  
AdjustmentReturnAbstract.AdjustmentDate, AdjustmentReturnAbstract.AdjustmentID,  
AdjustmentReturnAbstract.Balance, AdjustmentReturnAbstract.Total_Value, Null  
From AdjustmentReturnAbstract, VoucherPrefix  
Where AdjustmentReturnAbstract.VendorID = @VendorID And  
AdjustmentReturnAbstract.Balance > 0 And  
IsNull(AdjustmentReturnAbstract.Status, 0) & 64 = 0 And  
IsNull(AdjustmentReturnAbstract.Status, 0) & 128 = 0 And  
VoucherPrefix.TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'  
  
Union  
  
Select 2, VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),  
DocumentDate, DebitID, Balance, NoteValue, DocRef  
From DebitNote, VoucherPrefix  
Where DebitNote.VendorID = @VendorID And  
Balance > 0 And  
VoucherPrefix.TranID = 'DEBIT NOTE'  
  
Union  
  
Select 3, FullDocID, DocumentDate, DocumentID, Balance, Value, Null  
From Payments  
Where Payments.VendorID = @VendorID And  
Balance > 0 And IsNull(Status, 0) & 128 = 0  
  
Union  
  
Select 6, VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),  
ClaimDate, ClaimID, Balance, ClaimValue, DocumentReference  
From ClaimsNote, VoucherPrefix  
Where ClaimsNote.VendorID = @VendorID And  
IsNull(Balance, 0) > 0 And  
VoucherPrefix.TranID = 'CLAIMS NOTE'  
  


