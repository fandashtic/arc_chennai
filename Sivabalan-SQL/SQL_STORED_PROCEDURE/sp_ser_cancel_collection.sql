CREATE procedure sp_ser_cancel_collection(@CollectionID int)
as 
DECLARE @ADJAMOUNT DECIMAL(18,6)
DECLARE @DOCTYPE DECIMAL(18,6)
DECLARE @DOCID INT
DECLARE @STATUS INT
Declare @Adjustment float
Declare @DocumentValue float
Declare @DocDate Datetime
Declare @OriginalID Varchar(50)
Declare @Customer Varchar(20)
Declare @PartyType Int
Declare @Value float
Declare @Ref Varchar(255)
Declare @GetDate Datetime

Select @Customer = CustomerID From Collections Where DocumentID = @CollectionID
Set @PartyType = 0
DECLARE COLLECTION_CURSOR CURSOR STATIC FOR
SELECT  collectiondetail.AdjustedAmount,  collectiondetail.DocumentType,  
	collectiondetail.documentid, isnull(collections.status ,0), 
	IsNull(CollectionDetail.Adjustment, 0), CollectionDetail.DocumentDate, 
	OriginalID, DocumentValue
	FROM collectiondetail
	Inner Join collections On collections.documentid = collectiondetail.collectionid
	WHERE collectiondetail.collectionid = @CollectionID 
	and (isnull(collections.status,0) & 192) <> 0 
	and collectiondetail.DocumentType = 12

	--Already Collection Status Closed in previous procedure 
	--(isnull(collections.status,0) & 64)  
OPEN COLLECTION_CURSOR
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT, @DOCTYPE, @DOCID, @STATUS, @Adjustment,
@DocDate, @OriginalID, @DocumentValue

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @DOCTYPE = 12 -- Service Invoice 
	Begin
		If exists (Select ServiceInvoiceID From ServiceInvoiceAbstract Where ServiceInvoiceID = @DOCID)
		Begin
			update Serviceinvoiceabstract set balance = balance + @ADJAMOUNT + @Adjustment 
			where ServiceInvoiceID = @DOCID
		End
		Else /* Raise debite note */
		Begin
			Set @Value = @ADJAMOUNT + @Adjustment
			Set @Ref = @OriginalID + ',' + Cast(@DocDate As Varchar) + ',' + Cast(@DocumentValue As Varchar)
			Set @GetDate = GetDate()
			exec sp_ser_insert_DebitNote @PartyType, @Customer, @Value, @GetDate, @Ref, 0, @OriginalID
		End
	End
	FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment,
	@DocDate, @OriginalID, @DocumentValue
END
--update collections set status = (isnull(status,0) | 192), Balance = 0 
--where collections.documentid = @collectionid
CLOSE COLLECTION_CURSOR 
DEALLOCATE COLLECTION_CURSOR 
/*  
	Copied from ERP Forum 
	Procedure to update service invoice only 
	If Serviceinvoice fails Debit note will be created
*/




