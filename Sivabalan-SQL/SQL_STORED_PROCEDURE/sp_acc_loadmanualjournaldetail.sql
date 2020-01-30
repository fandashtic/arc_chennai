





CREATE procedure sp_acc_loadmanualjournaldetail(@transactionid integer)
as
select [GeneralJournal].[TransactionID],[GeneralJournal].[TransactionDate],[GeneralJournal].[DocumentReference],
[GeneralJournal].[Debit],[GeneralJournal].[Credit],[GeneralJournal].[AccountID],[GeneralJournal].[Remarks],
[GeneralJournal].[DocumentType],[AccountsMaster].[AccountName] from generaljournal,AccountsMaster where [TransactionID]=@transactionid and [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID] order by [GeneralJournal].[TransactionID]






