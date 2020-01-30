CREATE Function MERP_FN_GetCreditNoteDetails_Windows_GST(@InvoiceID Int,@Type Int)
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

Declare @CharCrNoteTotal as nVarchar(100)
Declare @CharCrAdjTotal as nVarchar(100)
Declare @CharCrBalTotal as nVarchar(100)

Declare @Result as nVarchar(4000)

Set @CrNoteTotal = 0
Set @CrAdjTotal = 0
Set @CrBalTotal = 0

DECLARE @CreditNoteDetails Table([ID] Int Identity(1,1),
[Cr.Note Description] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Cr.Note Value] Decimal(18, 2),
[Cr.Note Adjusted Value] Decimal(18, 2),
[Cr.Note Balance Value] Decimal(18, 2))

Insert InTo @CreditNoteDetails
Select
"Cr.Note Description" = Case When isnull(Memo,'')='' then 'Credit Note (' + OriginalID + ')'  else Memo End	,
--"Cr.Note Description" = cr.Memo,
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

--Set @CrInfo = '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
--'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

--Set @CrInfo = @CrInfo + '|' + 'Description' + Space(20 - Len('Description')) + '|' +
--'Value' + Space(10 - Len('Value')) + '|' +
--'Adj Value' + Space(10 - Len('Adj Value')) + '|' +
--'Bal Value' + Space(10 - Len('Bal Value')) + '|' + Char(13) + Char(10)

-- Set @CrInfo = @CrInfo + '|' + Replicate('-', 20) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
--'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

Set @CrInfo = '|' + Replicate('-', 15) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + 'Description' + Space(15 - Len('Description')) + '|' +
'Value' + Space(10 - Len('Value')) + '|' +
'Adj Value' + Space(10 - Len('Adj Value')) + '|' +
'Bal Value' + Space(10 - Len('Bal Value')) + '|' + Char(13) + Char(10)

Set @CrInfo = @CrInfo + '|' + Replicate('-', 15) + '|' + Replicate('-', 10) + '|' + Replicate('-', 10) +
'|' + Replicate('-', 10) + '|' + Char(13) + Char(10)


DECLARE @TmpAdj  Table(CreditNoteDesc nVarchar(25),[Value] nVarchar(20),[AdjValue] nVarchar(20),[Balance Value] nVarchar(20))

While @NCounter <= @MaxCount
Begin
--Select 1
Select @CrDescription = Cast([Cr.Note Description] As nVarchar(25)) ,
@CrNoteValue = Cast([Cr.Note Value] As nVarchar) ,
@CrNoteAdjValue = Cast([Cr.Note Adjusted Value] As nVarchar) ,
@CrBalanceValue = Cast([Cr.Note Balance Value] As nVarchar)
From @CreditNoteDetails
Where ID = @NCounter


Insert Into @TmpAdj Values(Ltrim(Rtrim(@CrDescription)),ltrim(Rtrim(@CrNoteValue)),ltrim(Rtrim(@CrNoteAdjValue)),ltrim(Rtrim(@CrBalanceValue)))


Set @CrNoteTotal = @CrNoteTotal + Cast(@CrNoteValue As Decimal(18, 2))
Set @CrAdjTotal = @CrAdjTotal + Cast(@CrNoteAdjValue As Decimal(18, 2))
Set @CrBalTotal = @CrBalTotal + Cast(@CrBalanceValue As Decimal(18, 2))

Set @NCounter = @NCounter + 1

End

Set @CharCrNoteTotal =  Cast(@CrNoteTotal as nVarchar)
Set @CharCrAdjTotal = Cast(@CrAdjTotal as nVarchar)
Set @CharCrBalTotal = Cast(@CrBalTotal as nVarchar)



Set @Result = ''
If @Type = 1
Begin
--Select  @Result = @Result + '|' + Cast(CreditNoteDesc as Nvarchar(20)) + Replicate(' ',25 - Len(Cast([CreditNoteDesc] As nVarchar)))  From  @TmpAdj
Select  @Result = @Result + '|' + Cast(CreditNoteDesc as Nvarchar(18)) + Replicate(' ',21 - Len(Cast([CreditNoteDesc] As nVarchar(18))))  From  @TmpAdj

End
Else If @Type = 2
Select  @Result = @Result +  '|' + Replicate('  ',10 - Len(Substring(Cast([Value] As nVarchar), 1, 10))) + Substring(Cast([Value] as Nvarchar(10)), 1, 10)   From  @TmpAdj
Else If @Type = 3
Select  @Result = @Result + '|' + Replicate('  ',10 - Len(Substring(Cast([AdjValue] As nVarchar), 1, 10))) + Substring(Cast([AdjValue] as Nvarchar(10)), 1, 10)   From  @TmpAdj
Else If @Type = 4
Select  @Result = @Result + '|' + Replicate('  ',10 - Len(Substring(Cast([Balance Value] As nVarchar), 1, 10))) + Substring(Cast([Balance Value] as Nvarchar(10)), 1, 10)   From  @TmpAdj
Else If @Type = 5
Begin
Select  @Result = @Result + '|' +Replicate('  ',10 - Len(Substring(Cast(@CharCrNoteTotal As nVarchar), 1, 10))) + substring(Cast(@CharCrNoteTotal as Nvarchar(10)), 1, 10)
+	Replicate('   ',1) + '|' + Replicate('  ',10 - Len(Substring(Cast(@CharCrAdjTotal As nVarchar), 1, 10))) + Substring(Cast(@CharCrAdjTotal as Nvarchar(20)), 1, 10)
+	Replicate('   ',1) +	'|' + Replicate('  ',10 - Len(Substring(Cast(@CharCrBalTotal As nVarchar), 1, 10))) + Substring(Cast(@CharCrBalTotal as Nvarchar(20)), 1, 10)
End


Return @Result

End

