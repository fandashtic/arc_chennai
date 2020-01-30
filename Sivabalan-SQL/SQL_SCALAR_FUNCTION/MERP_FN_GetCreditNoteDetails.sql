CREATE Function MERP_FN_GetCreditNoteDetails(@InvoiceID Int)
Returns nVarchar(4000)
As
Begin
Declare @MaxCount as int
Declare @NCounter as Int
Declare @CrInfo as nVarchar(4000)
Declare @CrDescription as nVarchar(100)
Declare @CrNoteValue as nVarchar(100)
Declare @CrNoteAdjValue as nVarchar(100)
Declare @CrBalanceValue as nVarchar(100)
Declare @CrNoteTotal as Decimal(18, 2)
Declare @CrAdjTotal as Decimal(18, 2)
Declare @CrBalTotal as Decimal(18, 2)

Set @CrNoteTotal = 0
Set @CrAdjTotal = 0
Set @CrBalTotal = 0

DECLARE @CreditNoteDetails Table([ID] Int Identity(1,1),
[Cr.Note Description] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Cr.Note Value] Decimal(18, 2),
[Cr.Note Adjusted Value] Decimal(18, 2),
[Cr.Note Balance Value] Decimal(18, 2))

Insert InTo @CreditNoteDetails
Select "Cr.Note Description" = cr.Memo,
"Cr.Note Value" = cr.NoteValue,
"Cr.Note Adjusted Value" = col.AdjustedAmount,
"Cr.Note Balance Value" = cr.Balance
From CollectionDetail col, CreditNote cr
Where col.DocumentID = cr.CreditID And
col.DocumentType = 2 And
col.CollectionID In (Select PaymentDetails From InvoiceAbstract
Where InvoiceID = @InvoiceID)

Select @MaxCount = @@Identity
Set @NCounter = 1

Set @CrInfo = '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + 'Description' + Space(20 - Len('Description')) + '|' +
'Value' + Space(10 - Len('Value')) + '|' +
'Adj Value' + Space(10 - Len('Adj Value')) + '|' +
'Bal Value' + Space(10 - Len('Bal Value')) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

While @NCounter <= @MaxCount
Begin

Select @CrDescription = Cast([Cr.Note Description] As nVarchar) + Space(20 - Len(Cast([Cr.Note Description] As nVarchar))) ,
@CrNoteValue = Cast([Cr.Note Value] As nVarchar) + Space(10 - Len(Cast([Cr.Note Value] As nVarchar))),
@CrNoteAdjValue = Cast([Cr.Note Adjusted Value] As nVarchar) + Space(10 - Len(Cast([Cr.Note Adjusted Value] As nVarchar))),
@CrBalanceValue = Cast([Cr.Note Balance Value] As nVarchar) + Space(10 - Len(Cast([Cr.Note Balance Value] As nVarchar)))
From @CreditNoteDetails
Where ID = @NCounter

Set @CrInfo = @CrInfo + '|' + @CrDescription + '|' + @CrNoteValue + '|' + @CrNoteAdjValue + '|' +
@CrBalanceValue + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

Set @CrNoteTotal = @CrNoteTotal + Cast(@CrNoteValue As Decimal(18, 2))
Set @CrAdjTotal = @CrAdjTotal + Cast(@CrNoteAdjValue As Decimal(18, 2))
Set @CrBalTotal = @CrBalTotal + Cast(@CrBalanceValue As Decimal(18, 2))

Set @NCounter = @NCounter + 1
End

Set @CrInfo = @CrInfo + '|' + 'Total' + Space(20 - Len('Total')) + '|' +
Cast(@CrNoteTotal As nVarchar) + Space(10 - Len(Cast(@CrNoteTotal As nVarchar))) + '|' +
Cast(@CrAdjTotal As nVarchar) + Space(10 - Len(Cast(@CrAdjTotal As nVarchar))) + '|' +
Cast(@CrBalTotal As nVarchar) + Space(10 - Len(Cast(@CrBalTotal As nVarchar))) + '|' +
Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

Return @CrInfo

End
