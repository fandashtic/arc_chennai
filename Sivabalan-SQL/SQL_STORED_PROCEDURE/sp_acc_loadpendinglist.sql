CREATE procedure [dbo].[sp_acc_loadpendinglist](@transactionid integer,@AccountID Int)
as
Begin
	DECLARE @transactiondate datetime
	DECLARE @debit decimal(18,6)
	DECLARE @credit decimal(18,6)
	DECLARE @documenttype integer
	DECLARE @documentreference integer

	DECLARE @prefix nvarchar(10) 

	select 'Document Type' = dbo.GetOriginalID_GST(DocumentReference,DocumentType),TransactionDate,
	dbo.returndescription(DocumentType),case when Debit = 0 then credit else 0 end,
	case when Credit = 0 then debit else 0 end,DocumentReference,DocumentType,AccountID,'',''
	from GeneralJournal where TransactionID = @transactionid 
	and AccountID = @AccountID
	and DocumentType not in (26,36,37,39)
End
