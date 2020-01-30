CREATE procedure sp_acc_retrieveaccountlist(@documentid integer,@mode integer)
as
Declare @accountid integer

DECLARE @DEBITNOTE integer
DECLARE @CREDITNOTE integer
Declare @MULTIPLE Int

SET @DEBITNOTE =1
SET @CREDITNOTE =2

If @Mode = 1
Begin
	Select @Multiple = isnull(Accountmode,0) from DebitNote
	where DebitID = @DocumentID
End
Else
Begin
	Select @Multiple = isnull(Accountmode,0) from Creditnote
	where CreditID = @DocumentID
End
IF @mode = @DEBITNOTE 
begin
	If @Multiple = 0 
	Begin
		Select 'AccountID' = IsNull(DebitNote.AccountID,0),
		'AccountName' = Case When Isnull(DebitNote.AccountID,0) = 0 Then
		dbo.LookupDictionaryItem('Opening Balance Entry',Default)  Else dbo.getaccountname(DebitNote.AccountID) End,
		'NoteValue' = ISNULL(NoteValue,0)
		from DebitNote where DebitID = @documentid 
	End
	Else
	Begin
		Select 'AccountID' = IsNull(NoteDetail.AccountID,0) ,
		'AccountName' = dbo.getaccountname(NoteDetail.AccountID),
		'NoteValue' = isnull(Notedetail.notevalue,0)
		from NoteDetail where NoteID = @documentid and NoteType = 1
	End
end
ELSE IF @mode = @CREDITNOTE 
begin
	If @Multiple = 0 
	Begin
		Select 'AccountID' = IsNull(CreditNote.AccountID,0),
		'AccountName' = Case When IsNull(CreditNote.AccountID,0) = 0 Then
		dbo.LookupDictionaryItem('Opening Balance Entry',Default)  Else dbo.getaccountname(CreditNote.AccountID) End,
		'NoteValue' = ISNULL(NoteValue,0)
		from CreditNote where CreditID = @documentid
	End
	Else
	Begin
		Select 'AccountID' = IsNull(NoteDetail.AccountID,0),
		'AccountName' = dbo.getaccountname(NoteDetail.AccountID),
		'NoteValue' = isnull(Notedetail.notevalue,0)
		from NoteDetail where NoteID = @documentid and NoteType = 2
	End
end









