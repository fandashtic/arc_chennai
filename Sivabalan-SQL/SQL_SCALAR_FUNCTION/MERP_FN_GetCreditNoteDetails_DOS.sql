CREATE Function MERP_FN_GetCreditNoteDetails_DOS(@InvoiceID Int)
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

Union All

Select "Cr.Note Description" = cr.Memo,
"Cr.Note Value" = cr.NoteValue,
"Cr.Note Adjusted Value" = col.AdjustedAmount,
"Cr.Note Balance Value" = cr.Balance
From CollectionDetail col, CreditNote cr
Where col.DocumentID = cr.CreditID And
col.DocumentType = 10 And
col.CollectionID In (Select PaymentDetails From InvoiceAbstract
Where InvoiceID = @InvoiceID)

Union All

Select
"Cr.Note Value"='Sales Return ('  + OriginalID + ')',
"Cr.Note Value" = Cast(CD.DocumentValue + IA.RoundOffAmount as Decimal(18,2)),
"Cr.Note Adjusted Value"= cast(CD.AdjustedAmount as Decimal(18,2)),
"Cr.Note Balance Value" = Cast(IA.Balance as decimal(18,2))
from CollectionDetail CD,InvoiceAbstract IA
Where
IA.InvoiceID=CD.DocumentID And
CD.DocumentType = 1 and
CollectionID In (Select PaymentDetails From InvoiceAbstract
Where InvoiceID = @InvoiceID)


Select @MaxCount = @@Identity
Set @NCounter = 1

--Set @CrInfo = '|' + Replicate('-', 30) + '|' + Replicate('-', 8) + '|' + Replicate('-', 8) +
--	'|' + Replicate('-', 8) + '|' + Char(13) + Char(10)

Set @CrInfo = '|' + space(19) + 'Credit Adjustments' + space(19) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + 'Description' + Space(29 - Len('Description')) + '|' +
'Value' + Space(8 - Len('Value')) + '|' +
'AdjVal' + Space(8 - Len('AdjVal')) + '|' +
'BalVal' + Space(8 - Len('BalVal')) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 56) +
'|' + Char(13) + Char(10)

While @NCounter <= @MaxCount
Begin

--Select @CrDescription = Cast([Cr.Note Description] As nVarchar) + Space(29 - Len(Cast([Cr.Note Description] As nVarchar))) ,
Select @CrDescription = Space(29 - Len(Left([Cr.Note Description],29))) + Left([Cr.Note Description],29) ,
@CrNoteValue = Space(8 - Len(Cast([Cr.Note Value] As nVarchar))) + Cast([Cr.Note Value] As nVarchar) ,
@CrNoteAdjValue = Space(8 - Len(Cast([Cr.Note Adjusted Value] As nVarchar))) + Cast([Cr.Note Adjusted Value] As nVarchar) ,
@CrBalanceValue = Space(8 - Len(Cast([Cr.Note Balance Value] As nVarchar))) + Cast([Cr.Note Balance Value] As nVarchar)
From @CreditNoteDetails
Where ID = @NCounter

--	Set @CrInfo = @CrInfo + '|' + @CrDescription + '|' + @CrNoteValue + '|' + @CrNoteAdjValue + '|' +
--		@CrBalanceValue + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + IsNull(@CrDescription,'') + '|' + isNull(@CrNoteValue,'') + '|' + isNull(@CrNoteAdjValue,'') + '|' +
isNull(@CrBalanceValue,'') + '|' + Char(13) + Char(10)

Set @CrNoteTotal = @CrNoteTotal + Cast(@CrNoteValue As Decimal(18, 2))
Set @CrAdjTotal = @CrAdjTotal + Cast(@CrNoteAdjValue As Decimal(18, 2))
Set @CrBalTotal = @CrBalTotal + Cast(@CrBalanceValue As Decimal(18, 2))

Set @NCounter = @NCounter + 1
End

Set @CrInfo = @CrInfo + '|' + Replicate('-', 56) +
'|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + 'Total' + Space(29 - Len('Total')) + '|' +
Space(8 - Len(Cast(@CrNoteTotal As nVarchar))) + Cast(@CrNoteTotal As nVarchar)  + '|' +
Space(8 - Len(Cast(@CrAdjTotal As nVarchar)))  + Cast(@CrAdjTotal As nVarchar)   + '|' +
Space(8 - Len(Cast(@CrBalTotal As nVarchar)))  + Cast(@CrBalTotal As nVarchar)   + '|' +
Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 56) +
'|' + Char(13) + Char(10)

Return @CrInfo

End
