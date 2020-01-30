CREATE Procedure Sp_Acc_Prn_Cus_MJDetail (@MJId Int)
As
Declare @Prefix nVarchar(250)
select 
"Debit/Credit" =
Case
	When [GeneralJournal].[Debit] > 0 then dbo.LookupDictionaryItem('Dr',Default)
	Else dbo.LookupDictionaryItem('Cr',Default)
End,
"Account Name" = Dbo.GetAccountName([GeneralJournal].[AccountID]),
"Journal Type" =
Case
	When [GeneralJournal].[DocumentReference] = 0 Then dbo.LookupDictionaryItem('On Account',Default)
	When [GeneralJournal].[DocumentReference] = 1 Then dbo.LookupDictionaryItem('New Reference',Default)
	When [GeneralJournal].[DocumentReference] = 2 Then dbo.LookupDictionaryItem('Old Reference',Default)
End,
"Debit" = [GeneralJournal].[Debit],
"Credit" = [GeneralJournal].[Credit],
"Reference" = 
case 
	When [GeneralJournal].[DocumentReference] = 1 Then
		Isnull((Select ReferenceNo from ManualJournal where TransactionID = GeneralJournal.TransactionID
		and AccountID = GeneralJournal.AccountID),N'')
	Else ''
End,
"Remarks" =
case 
	When [GeneralJournal].[DocumentReference] = 1 Then
		Isnull((Select Remarks from ManualJournal where TransactionID = GeneralJournal.TransactionID
		and AccountID = GeneralJournal.AccountID),N'')
	Else ''
End
From 
[GeneralJournal]
where 
[DocumentType] in (26,37)
and TransactionID = @MJId


