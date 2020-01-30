CREATE PROCEDURE sp_Cancel_Collection_for_Amendment(@CollectionID int)      
as       
DECLARE @ADJAMOUNT Decimal(18,6)      
DECLARE @DOCTYPE Decimal(18,6)      
DECLARE @DOCID INT      
DECLARE @STATUS INT      
Declare @Adjustment Decimal(18,6)      
      
DECLARE COLLECTION_CURSOR CURSOR STATIC FOR      
SELECT  collectiondetail.AdjustedAmount ,  collectiondetail.DocumentType ,  collectiondetail.documentid,       
 isnull(collections.status ,0), Abs(IsNull(CollectionDetail.Adjustment, 0))      
 FROM   collectiondetail, collections WHERE collectiondetail.collectionid = @CollectionID       
 and  collections.documentid = collectiondetail.collectionid      
 and (isnull(collections.status,0) & 64) = 0      
OPEN COLLECTION_CURSOR      
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment      
WHILE @@FETCH_STATUS = 0      
BEGIN      
      
IF @DOCTYPE = 1  -- sales return       
Begin      
 update invoiceabstract set balance = balance +  @ADJAMOUNT + @Adjustment       
 where invoiceid = dbo.gettrueval(@DOCID)      
End      
IF @DOCTYPE = 2 -- Credit Note       
Begin      
 update creditnote set balance = balance + @ADJAMOUNT + @Adjustment       
 where creditid = dbo.gettrueval(@DOCID)      
End      
IF @DOCTYPE = 3 -- Collection      
Begin      
 update collections set balance = balance + @ADJAMOUNT + @Adjustment       
 where documentid = dbo.gettrueval(@DOCID)      
End      
IF @DOCTYPE = 4 or @DOCTYPE = 6 or @DOCTYPE = 7-- Invoice & Invoice amendment      
Begin      
 update invoiceabstract set balance = balance +  @ADJAMOUNT  + @Adjustment       
 where invoiceid = dbo.gettrueval(@DOCID)      
End      
IF @DOCTYPE = 5-- debit note      
Begin      
 update debitnote set balance = balance + @ADJAMOUNT  + @Adjustment       
 where debitid = dbo.gettrueval(@DOCID)      
End      
FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment      
END      
update collections set status = (isnull(status,0) | 128), Balance = 0       
where collections.documentid = @collectionid      
CLOSE COLLECTION_CURSOR       
DEALLOCATE COLLECTION_CURSOR       



