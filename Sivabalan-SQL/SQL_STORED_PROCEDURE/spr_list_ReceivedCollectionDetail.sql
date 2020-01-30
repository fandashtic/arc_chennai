Create Procedure spr_list_ReceivedCollectionDetail(@CLAIMID INT)
as

Declare @SALESRETURN As NVarchar(50)
Declare @INVOICE As NVarchar(50)
Declare @CREDITNOTE As NVarchar(50)
Declare @COLLECTIONS As NVarchar(50)
Declare @DEBITNOTE As NVarchar(50)

Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @COLLECTIONS = dbo.LookupDictionaryItem(N'Collections', Default)
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)

Select OriginalID, "Document Type" = CASE DocumentType 
WHEN 1 THEN
@SALESRETURN
WHEN 2 THEN
@CREDITNOTE
WHEN 3 THEN
@COLLECTIONS
WHEN 4 THEN
@INVOICE
WHEN 5 THEN
@DEBITNOTE
END, "Payment Date" = PaymentDate, "Adjusted Amount" = AdjustedAmount,
"Document Value" = DocumentValue, "Extra Collection" = ExtraCollection,
Adjustment, DocRef
FROM CollectionDetailReceived, Items
where CollectionDetailReceived.CollectionID=@CLAIMID


