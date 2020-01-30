CREATE Procedure sp_acc_rpt_pettycashdetail (@PettyCashID Int,@Count Int = 0)
AS
If @Count = 0
Begin
	If (Select Isnull(AccountMode,0) from Payments where documentid = @PettyCashID) = 0
	Begin
		Select AccountsMaster.AccountName as 'AccountName' , value as 'Amount',
		5 from Payments,AccountsMaster
		Where payments.documentid = @PettyCashID
		and payments.ExpenseAccount = AccountsMaster.AccountID
	End
	Else
	Begin
		Select AccountsMaster.AccountName as 'AccountName' , Amount as 'Amount',
		5 from paymentexpense,AccountsMaster
		Where paymentexpense.PaymentID = @PettyCashID
		and paymentexpense.AccountID = AccountsMaster.AccountID
	End
End
Else
Begin
	If (Select Isnull(AccountMode,0) from Payments where documentid = @PettyCashID) = 0
	Begin
		Select 1
	End
	Else
	Begin
		Select count(*) from paymentexpense
		Where paymentexpense.PaymentID = @PettyCashID
	End
End

