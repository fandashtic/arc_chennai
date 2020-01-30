CREATE Procedure [dbo].[sp_acc_prn_cus_pettycashabstract](@paymentid integer)
As
select 
"Transaction ID" =[Payments].[FullDocID],
"Date" = [Payments].[DocumentDate],
"Amount Paid" = [Payments].[Value],
"Payment Type" =
	Case
		When (isnull(Others,0) =0 and Isnull(PaymentMode,0) = 5) or Isnull(Others,0) = 4 then dbo.LookupDictionaryItem('Payment for an Expense',Default)
		When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 then dbo.LookupDictionaryItem('Payment to Party for an Expense',Default)
	End,
"Party Name" = 
	Case 
		When Isnull(Others,0) > 0 and Isnull(PaymentMode,0) = 5 Then Isnull(AccountsMaster.AccountName,N'')
		else ''
	End,
"Remarks" = Narration,
"Account Name" = AccountName 
from Payments
Left Join AccountsMaster on [Payments].[Others] = [AccountsMaster].[AccountID]
--Payments,AccountsMaster
where [DocumentID]= @paymentid 
--and [Payments].[Others] *= [AccountsMaster].[AccountID]
