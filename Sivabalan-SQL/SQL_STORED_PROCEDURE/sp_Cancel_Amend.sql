CREATE Procedure sp_Cancel_Amend(@PaymentID int)  
As  
Declare @DocID int  
Declare @Amount Decimal(18,6)  
Declare @DocType int  
Declare @Adjustment Decimal(18,6)  
  
Declare GetAdjustedDocs Cursor Static For  
Select DocumentID, AdjustedAmount, DocumentType, Adjustment From PaymentDetail   
Where PaymentID = @PaymentID  
Open GetAdjustedDocs  
Fetch From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment  
While @@Fetch_Status = 0  
Begin  
 If @DocType = 1  
 Begin  
   Update AdjustmentReturnAbstract Set Balance = Balance + @Amount + @Adjustment  
   Where AdjustmentID = @DocID  
 End  
 Else If @DocType = 2  
 Begin  
   Update DebitNote Set Balance = Balance + @Amount + @Adjustment  
   Where DebitID = @DocID  
 End  
 Else If @DocType = 3  
 Begin  
   Update Payments Set Balance = Balance + @Amount + @Adjustment  
   Where DocumentID = @DocID  
 End  
 Else If @DocType = 4  
 Begin  
   Update BillAbstract Set Balance = Balance + @Amount + @Adjustment  
   Where BillID = @DocID  
 End  
 Else If @DocType = 5  
 Begin  
   Update CreditNote Set Balance = Balance + @Amount + @Adjustment  
   Where CreditID = @DocID  
 End  
 Else If @DocType = 6
 Begin  
   Update ClaimsNote Set Balance = Balance + @Amount + @Adjustment  
   Where ClaimID = @DocID  
 End  
 Fetch Next From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment  
End  
Update Payments Set Status = IsNull(Status, 0) | 128, Balance = 0   
Where DocumentID = @PaymentID  
Close GetAdjustedDocs  
DeAllocate GetAdjustedDocs  
--Revert Used cheque details in cheques table  
If Exists(Select Paymentmode From Payments Where DocumentID = @PaymentID and (IsNull(PaymentMode,0) = 1 or (IsNull(PaymentMode,0) = 2 and DDMode = 1)))  
 Update Cheques Set UsedCheques = UsedCheques - 1 Where ChequeID = (Select ChequeID From Payments Where DocumentID = @PaymentID)  







