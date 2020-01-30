Create Procedure sp_acc_get_CurrentPaymentID (@Position Int,@CurPaymentID int = 0)
As
Declare @PETTY_CASH int 
set @PETTY_CASH =4      
If @Position = 1 /* Last FA Payment ID*/
Begin
	Select Top 1 DocumentID From 
	Payments where (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
	and isnull(others,0) <> @PETTY_CASH
	Order By DocumentID Desc
End
Else if @Position = 2 /* Previous FA PaymentID */
Begin
	Select Top 1 DocumentID From Payments Where DocumentID < @CurPaymentID  
	and (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
	and isnull(others,0) <> @PETTY_CASH
	Order By DocumentID Desc  
End
Else if @Position = 3 /* Next FA PaymentID */
Begin
   	Select Top 1 DocumentID From Payments Where DocumentID > @CurPaymentID  
   	and (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
	and isnull(others,0) <> @PETTY_CASH
   	Order By DocumentID  
End





