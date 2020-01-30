CREATE Procedure sp_acc_prn_loadpettycash(@paymentid integer)
As
Select [Payments].[DocumentID],[Payments].[DocumentDate],[Payments].[Value],
'Others'=[Payments].[ExpenseAccount],[AccountsMaster].[AccountName],'Remarks'=[Narration],
[Payments].[FullDocID] from Payments,AccountsMaster
where [DocumentID]= @paymentid 
and [Payments].[ExpenseAccount]= [AccountsMaster].[AccountID]
