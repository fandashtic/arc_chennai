CREATE Procedure sp_ser_Cancel_Collection_Amendment(@CollectionID int)
as

DECLARE @ADJAMOUNT DECIMAL(18,6)      
DECLARE @DOCTYPE DECIMAL(18,6)      
DECLARE @DOCID INT      
DECLARE @STATUS INT      
Declare @Adjustment float      
      
DECLARE COLLECTION_CURSOR CURSOR STATIC FOR      
 SELECT collectiondetail.AdjustedAmount, collectiondetail.DocumentType, 
	collectiondetail.documentid, isnull(collections.status ,0), 
	IsNull(CollectionDetail.Adjustment, 0)      
 FROM collectiondetail 
 Inner Join collections On collections.documentid = collectiondetail.collectionid
 WHERE collectiondetail.collectionid = @CollectionID 
	and (isnull(collections.status,0) & 128) <> 0 
	and collectiondetail.DocumentType = 12
OPEN COLLECTION_CURSOR      
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment      
WHILE @@FETCH_STATUS = 0      
BEGIN      
	update ServiceInvoiceabstract set balance = balance +  @ADJAMOUNT + @Adjustment       
	where ServiceInvoiceid = dbo.sp_ser_gettrueval(@DOCID)      

	FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment      
END      
--update collections set status = (isnull(status,0) | 128), Balance = 0       
--where collections.documentid = @collectionid      
CLOSE COLLECTION_CURSOR       
DEALLOCATE COLLECTION_CURSOR     
/* 
	Assumption: 
	1. Colletion is Amended in previous sp
	2. THis procedure handles Doc type 12 (Service invoice) only 
*/  


