CREATE Procedure [dbo].[sp_acc_loadpettycashdetail](@paymentid integer,@Detail Int = 0)
As
If @Detail = 0
Begin
	select [Payments].[DocumentID],[Payments].[DocumentDate],[Payments].[Value],
	'Others'=[Payments].[ExpenseAccount],
	'Remarks'=IsNULL(Narration,N''),[Payments].[FullDocID],
	Isnull(AccountMode,0) as 'AccountMode',
	'Type' = 
		Case
			When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5) or Isnull(Others,0) = 4 then 0
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then 1
		End,
	'Party Name' = 
		Case 
			When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 Then AccountsMaster.AccountName
			else ''
		End,
	'PartyID' = Isnull(Others,0),
 'AccountName' = dbo.getAccountName(Payments.ExpenseAccount)
	from 
	Payments
	Left Join AccountsMaster on Payments.[Others] =[AccountsMaster].[AccountID]
	--Payments,AccountsMaster
	where [DocumentID]= @paymentid 
	--and [Payments].[Others] *=[AccountsMaster].[AccountID]
End
Else
Begin
	If (Select Isnull(AccountMode,0) from Payments where documentid = @paymentid) = 0
	Begin
		Select AccountsMaster.AccountName as 'AccountName' , value as 'Amount',
		payments.ExpenseAccount as 'AccountID' from Payments,AccountsMaster
		Where payments.documentid = @paymentid
		and payments.ExpenseAccount = AccountsMaster.AccountID
	End
	Else
	Begin
		Select AccountsMaster.AccountName as 'AccountName' , Amount,
		paymentexpense.AccountID as 'AccountID' from paymentexpense,AccountsMaster
		Where paymentexpense.PaymentID = @paymentid
		and paymentexpense.AccountID = AccountsMaster.AccountID
	End
End
