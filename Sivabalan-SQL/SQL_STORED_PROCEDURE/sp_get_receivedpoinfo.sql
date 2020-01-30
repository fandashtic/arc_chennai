CREATE Procedure sp_get_receivedpoinfo (@InvoiceID Int)
As
Declare @PORef nvarchar(128)
Declare @Start Int
Declare @CollectionInfo Int
Declare @AdjDocRef nvarchar(255)
Declare @InvDocID nvarchar(50)
Declare @OrigDocID nvarchar(100)
Declare @AdjAmount Decimal(18,6)

Select @PORef = NewReference, @CollectionInfo = IsNull(Cast(PaymentDetails As Int), 0),
@InvDocID = VoucherPrefix.Prefix + Cast(DocumentID As nvarchar)
From InvoiceAbstract, VoucherPrefix 
Where InvoiceID = @InvoiceID 
And VoucherPrefix.TranID = N'INVOICE'

Set @AdjDocRef = N''
Declare AdjRefNumber Cursor KeySet For
Select OriginalID, AdjustedAmount From CollectionDetail 
Where CollectionID = @CollectionInfo
And OriginalID <> @InvDocID

Open AdjRefNumber
Fetch From AdjRefNumber Into @OrigDocID, @AdjAmount
While @@Fetch_Status = 0
Begin
	Set @AdjDocRef = @AdjDocRef + N', ' + @OrigDocID + N':' + Cast(@AdjAmount As nvarchar)
	Fetch Next From AdjRefNumber Into @OrigDocID, @AdjAmount
End
If @AdjDocRef <> N''
	Set @AdjDocRef = SubString(@AdjDocRef, 2, Len(@AdjDocRef) - 1)
Set @Start = CharIndex(N',', @PORef)
If @Start = 0 
Begin
	Select Convert(nvarchar, Max(PODate), 101), @AdjDocRef From POAbstractReceived 
	Where DocumentID = dbo.GetTrueVal(@PORef)
End
Else
Begin
	Select N'', @AdjDocRef
End
Close AdjRefNumber
DeAllocate AdjRefNumber

