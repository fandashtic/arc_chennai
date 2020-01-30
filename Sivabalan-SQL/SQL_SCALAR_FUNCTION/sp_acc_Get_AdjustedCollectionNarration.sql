CREATE Function sp_acc_Get_AdjustedCollectionNarration(@DocType Int,@DocRef Int)
Returns nVarChar(2000)
As

Begin
DECLARE @Narration nVarchar(2000)
If @DocType = 2 /*Credit Note*/
Select @Narration = IsNULL(Memo,N'') from CreditNote Where CreditID = @DocRef
Else If @DocType = 5 /*Debit Note*/
Select @Narration = IsNULL(Memo,N'') from DebitNote Where DebitID = @DocRef
Else If @DocType = 3 /*Collections(Advance)*/
Select @Narration = IsNULL(Narration,N'') from Collections Where DocumentID = @DocRef
Else If @DocType = 7 /*Payments(Advance)*/
Select @Narration = IsNULL(Narration,N'') from Payments Where DocumentID = @DocRef
Else If @DocType = 6 /*APV*/
Select @Narration = IsNULL(APVRemarks,N'') from APVAbstract Where DocumentID = @DocRef
Else If @DocType = 4 /*ARV*/
Select @Narration = Cast(IsNULL(ARVRemarks,'') as nvarchar) from ARVAbstract Where DocumentID = @DocRef
Else If @DocType = 153 /*Service Invoice Outward*/
Select @Narration = Cast(IsNULL(ReferenceDescription,'') as nvarchar) From ServiceAbstract Where InvoiceID = @DocRef
Return @Narration
End

