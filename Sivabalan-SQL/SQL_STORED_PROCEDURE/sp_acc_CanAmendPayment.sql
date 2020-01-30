CREATE Procedure sp_acc_CanAmendPayment(@DocID as Int)  
As  
Declare @PaymentCount Int  
Declare @JournalCount Int   
Declare @AmendmentCount Int  
Declare @ClosedCount Int  
Declare @IsFromBillCount Int
  
Select @ClosedCount = Count(DocumentID) from Payments Where DocumentID = @DocID And  
IsNull(Status,0) & 64 <> 0  
Select @AmendmentCount = Count(DocumentID) from Payments Where DocumentID = @DocID And  
IsNull(Status, 0) & 128 <> 0  
  
Select @PaymentCount = Count(PaymentID)  
from PaymentDetail,Payments  
where PaymentDetail.DocumentID = @DocID and DocumentType = 3 and   
Payments.DocumentID = PaymentDetail.PaymentID and  
IsNull(Payments.Status,0) & 64 = 0 And IsNull(Payments.Status,0) & 128 = 0  
  
Select @JournalCount = count(TransactionID)   
from GeneralJournal where DocumentReference = @DocID  
and DocumentType = 62 and isnull(Status,0)<> 128   
and isnull(Status,0)<> 192  
  
Select @IsFromBillCount = Count(BillID) from BillAbstract Where IsNULL(FAPaymentID,0) = @DocID

If (@PaymentCount > 0) or (@JournalCount > 0) Or (@AmendmentCount > 0) Or (@ClosedCount > 0)  Or (@IsFromBillCount > 0)
Begin  
 Select 1  
End  
Else  
Begin  
 Select 0  
End  

