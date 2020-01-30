CREATE Procedure SP_ACC_CANCEL_ERPPAYMENTS(@PaymentID int,@UserName nvarchar(100) = N'')  
As  
Declare @DocID int  
Declare @Amount float  
Declare @DocType int  
Declare @Adjustment float  
Declare @OriginalID nVarchar(50)  
Declare @DocumentDate Datetime  
Declare @DocumentValue float  
Declare @CreateNew Int  
Declare @Vendor nVarchar(20)  
Declare @Value float  
Declare @Ref nVarchar(255)  
Declare @PartyType Int  
Declare @GetDate Datetime  
Declare @ExpenseAccount Int  
  
Set @ExpenseAccount = 15 -- Misellaneous account  
  
Set @PartyType = 1  
Select @Vendor = VendorID From Payments Where DocumentID = @PaymentID  
Declare GetAdjustedDocs Cursor Static For  
Select DocumentID, AdjustedAmount, DocumentType, Adjustment, DocumentDate,   
OriginalID, DocumentValue  
From PaymentDetail   
Where PaymentID = @PaymentID  
Open GetAdjustedDocs  
Fetch From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment, @DocumentDate,  
@OriginalID, @DocumentValue  
While @@Fetch_Status = 0  
Begin  
 Set @CreateNew  = 0  
 If @DocType = 1  
 Begin  
  If exists (Select AdjustmentID From AdjustmentReturnAbstract   
  Where AdjustmentID = @DocID)  
  Begin  
   Update AdjustmentReturnAbstract Set Balance = Balance + @Amount + @Adjustment  
   Where AdjustmentID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 1  
  End  
 End  
 Else If @DocType = 2  
 Begin  
  If exists (Select DebitID From DebitNote Where DebitID = @DocID)  
  Begin  
   Update DebitNote Set Balance = Balance + @Amount + @Adjustment  
   Where DebitID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 1  
  End  
 End  
 Else If @DocType = 3  
 Begin  
  If exists (Select DocumentID From Payments Where DocumentID = @DocID)  
  Begin  
   Update Payments Set Balance = Balance + @Amount + @Adjustment  
   Where DocumentID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 1  
  End  
 End  
 Else If @DocType = 4  
 Begin  
  If exists (Select BillID From BillAbstract Where BillID = @DocID)  
  Begin  
   Update BillAbstract Set Balance = Balance + @Amount + @Adjustment  
   Where BillID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 2  
  End  
 End  
 Else If @DocType = 5  
 Begin  
  If exists (Select CreditID From CreditNote Where CreditID = @DocID)  
  Begin  
   Update CreditNote Set Balance = Balance + @Amount + @Adjustment  
   Where CreditID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 2  
  End  
 End  
 Else If @DocType = 6  
 Begin  
  If exists (Select ClaimID From ClaimsNote Where ClaimID = @DocID)  
  Begin  
   Update ClaimsNote Set Balance = Balance + @Amount + @Adjustment  
   Where ClaimID = @DocID  
  End  
  Else  
  Begin  
   Set @CreateNew = 2  
  End  
 End  
 Set @Value = @Amount + @Adjustment  
 Set @Ref = @OriginalID + ',' + Cast(@DocumentDate As nVarchar) + ',' + Cast(@DocumentValue As nVarchar)  
 Set @GetDate = dbo.Sp_Acc_GetOperatingDate(getdate())  
 If @CreateNew = 1  
 Begin  
   exec sp_insert_DebitNote @PartyType, @Vendor, @Value, @GetDate, @Ref, 0, @OriginalID  
  Update DebitNote Set AccountID =@ExpenseAccount Where IsNull(DebitID,0)=@@Identity  
  --Exec sp_acc_gj_debitnote @@Identity  
 End  
 Else If @CreateNew = 2  
 Begin  
   exec sp_insert_CreditNote @PartyType, @Vendor, @Value, @GetDate, @Ref, @OriginalID  
  Update CreditNote Set AccountID =@ExpenseAccount Where IsNull(CreditID,0)=@@Identity  
  --Exec sp_acc_gj_creditnote @@Identity  
 End  
 Fetch Next From GetAdjustedDocs InTo @DocID, @Amount, @DocType, @Adjustment,   
 @DocumentDate, @OriginalID, @DocumentValue  
End  
Update Payments Set Status = IsNull(Status, 0) | 192, Balance = 0,CancelUserName=@UserName,CancelDate=GETDATE()   
Where DocumentID = @PaymentID  
Close GetAdjustedDocs  
DeAllocate GetAdjustedDocs  
--Revert Used cheque details in cheques table  
If Exists(Select Paymentmode From Payments Where DocumentID = @PaymentID and ((PaymentMode = 1 and Cheque_ID <> 0) or (PaymentMode = 2 and DDMode = 1 and Cheque_ID <> 0)))  
 Update Cheques Set UsedCheques = UsedCheques - 1 Where ChequeID = (Select ChequeID From Payments Where DocumentID = @PaymentID)  
