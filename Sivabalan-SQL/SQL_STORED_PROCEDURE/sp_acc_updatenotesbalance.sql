CREATE procedure sp_acc_updatenotesbalance(@DocumentID Int,  
@DocumentType Int,@AdjustedAmount Decimal(18,6),@Mode int)  
as  
Declare @DEBIT_NOTE Int  
Declare @CREDIT_NOTE Int  
Declare @ADD Int  
Declare @CANCEL Int  
Declare @AMEND Int  
  
Set @DEBIT_NOTE = 5  
Set @CREDIT_NOTE = 2  
  
Set @ADD = 1  
Set @AMEND = 2  
Set @CANCEL = 3  
  
If @Mode = @ADD Or @Mode = @AMEND  
Begin  
 If @DocumentType = @DEBIT_NOTE   
 Begin  
  update DebitNote set Balance = Balance - @AdjustedAmount  
  where DebitID = @DocumentID  
 end  
 Else If @DocumentType = @CREDIT_NOTE  
 Begin  
  update CreditNote set Balance = Balance - @AdjustedAmount  
  where CreditID = @DocumentID  
 End  
End  
Else If @Mode = @CANCEL   
Begin  
 If @DocumentType = @DEBIT_NOTE   
 Begin  
  update DebitNote set Balance = Balance + @AdjustedAmount  
  where DebitID = @DocumentID  
 end  
 Else If @DocumentType = @CREDIT_NOTE  
 Begin  
  update CreditNote set Balance = Balance + @AdjustedAmount  
  where CreditID = @DocumentID  
 End  
End 
