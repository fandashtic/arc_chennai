CREATE procedure sp_acc_prn_cus_pettycashDetail (@PettyCashId Int)
As
Create table #PettyCashDetail
(
	AccountName nVarchar(255),
	Amount Decimal(18,6)
)

If (Select Isnull(AccountMode,0) from Payments where documentid = @PettyCashId) = 0
Begin
	Insert into #PettyCashDetail
	Select AccountsMaster.AccountName as 'AccountName' , value as 'Amount'
	from Payments,AccountsMaster
	Where payments.documentid = @PettyCashId
	and payments.ExpenseAccount = AccountsMaster.AccountID
End
Else
Begin
	Insert into #PettyCashDetail
	Select AccountsMaster.AccountName as 'AccountName' , Amount
	from paymentexpense,AccountsMaster
	Where paymentexpense.PaymentID = @PettyCashId
	and paymentexpense.AccountID = AccountsMaster.AccountID
End

Select 
"Account Name" = AccountName,
"Amount" = Amount
From #PettyCashDetail

Drop table #PettyCashDetail

