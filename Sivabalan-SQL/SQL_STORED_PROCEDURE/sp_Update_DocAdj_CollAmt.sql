Create Procedure sp_Update_DocAdj_CollAmt(@CollectionID int)
As
Begin
Declare @TotDocAdj decimal(18,6),@DocID int, @DocType int, @AdjAmt decimal(18,6)
Declare @TotCollAmt decimal(18,6),@InvCount int

--Get the total credit adjustment for the collection
Select @TotDocAdj = IsNull(Sum(AdjustedAmount),0) From Collections cl, CollectionDetail cd
Where cl.DocumentID = @CollectionID And IsNull(cl.Status,0) & 128 = 0 And cl.DocumentID = cd.CollectionID
And cd.DocumentType in (1,2,3)

Select @TotCollAmt = IsNull(Sum(AdjustedAmount),0)-@TotDocAdj,@InvCount =Count(cd.CollectionID) From Collections cl, CollectionDetail cd
Where cl.DocumentID = @CollectionID And IsNull(cl.Status,0) & 128 = 0 And cl.DocumentID = cd.CollectionID
And cd.DocumentType in (4,5)
if @InvCount = 0
set @InvCount = 1
--If no credit adjustment is made then it is understood that adjusted amount is from the collected amount
If IsNull(@TotDocAdj,0) = 0
Begin
Update CollectionDetail Set DocAdjustAmount = 0, CollectedAmount = IsNull(AdjustedAmount,0)
Where CollectionID=@CollectionID And DocumentType in (4,5)
End
--If any adjustment is made then the following else part will be executed
Else
Begin
Declare TmpCursor Cursor For
Select DocumentID, DocumentType, AdjustedAmount From CollectionDetail
Where CollectionID = @CollectionID And DocumentType in (4,5)

Open TmpCursor

Fetch Next From TmpCursor into @DocID, @DocType, @AdjAmt

While (@@Fetch_Status = 0)
Begin
If IsNull(@TotDocAdj,0) = 0  and IsNull(@TotCollAmt,0) <> 0
Begin
Update CollectionDetail Set DocAdjustAmount = 0, CollectedAmount = IsNull(AdjustedAmount,0)
Where CollectionID=@CollectionID And DocumentID = @DocID And DocumentType = @DocType
End
Else If IsNull(@TotCollAmt,0) = 0  and IsNull(@TotDocAdj,0) <> 0
Begin
Update CollectionDetail Set DocAdjustAmount = IsNull(AdjustedAmount,0)   , CollectedAmount = 0
Where CollectionID=@CollectionID And DocumentID = @DocID And DocumentType = @DocType
End
Else --If IsNull(@TotDocAdj,0) >= IsNull(@TotCollAmt,0)
Begin
Update CollectionDetail Set DocAdjustAmount = @TotDocAdj/@InvCount, CollectedAmount = @TotCollAmt/@InvCount
Where CollectionID=@CollectionID And DocumentID = @DocID And DocumentType = @DocType
--    Set @TotDocAdj = (IsNull(@TotDocAdj,0) - IsNull(@AdjAmt,0))
End
Fetch Next From TmpCursor into @DocID, @DocType, @AdjAmt
End
Close TmpCursor
Deallocate TmpCursor
End

/* Special SKU Changes - CreditNote Table InvoiceID Updated*/
Declare @SplInvoiceid Int
If (Select COUNT(*) from CollectionDetail  CD Inner Join CreditNote C on CD.Documentid  = C.CreditID
where CD.CollectionID = @CollectionID And CD.DocumentType = 2
And C.FreeSKUFlag = 1) > 0
Begin
Select @SplInvoiceid = Invoiceid from InvoiceAbstract where PaymentDetails = @CollectionID
Update CD Set Invocieid = Isnull(@SplInvoiceid,0) From CreditNote  CD
Inner Join CollectionDetail C on CD.CreditID  = C.DocumentID
where C.CollectionID = @CollectionID And C.DocumentType = 2
And CD.FreeSKUFlag = 1
End


End
