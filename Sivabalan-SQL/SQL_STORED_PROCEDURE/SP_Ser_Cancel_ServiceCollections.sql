Create PROCEDURE SP_Ser_Cancel_ServiceCollections (@CollectionID int)
as   
DECLARE @ADJAMOUNT Decimal(18,6)  
DECLARE @DOCTYPE Decimal(18,6)  
DECLARE @DOCID INT  
DECLARE @STATUS INT  
Declare @Adjustment Decimal(18,6)  
Declare @DocumentValue Decimal(18,6)  
Declare @DocDate Datetime  
Declare @OriginalID Varchar(50)  
Declare @Customer Varchar(20)  
Declare @CreateNew Int  
Declare @PartyType Int  
Declare @Value Decimal(18,6)  
Declare @Ref Varchar(255)  
Declare @GetDate Datetime  
  
Select @Customer = CustomerID From Collections Where DocumentID = @CollectionID  
Set @PartyType = 0  

DECLARE COLLECTION_CURSOR CURSOR STATIC FOR  
SELECT  collectiondetail.AdjustedAmount ,  collectiondetail.DocumentType,collectiondetail.documentid,
isnull(collections.status ,0), IsNull(CollectionDetail.Adjustment, 0),  
CollectionDetail.DocumentDate, OriginalID, DocumentValue
FROM collectiondetail, collections WHERE collectiondetail.collectionid = @CollectionID   
and  collections.documentid = collectiondetail.collectionid  
--and (isnull(collections.status,0) & 64) = 0  

OPEN COLLECTION_CURSOR  
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment,  
@DocDate, @OriginalID, @DocumentValue  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
Set @CreateNew  = 0  
IF @DOCTYPE = 2 -- Credit Note   
Begin  
	If exists (Select CreditID From CreditNote Where CreditID = dbo.sp_ser_GetTrueVal(@DOCID))
	Begin  
		update creditnote set balance = balance + @ADJAMOUNT + @Adjustment
   		where creditid = dbo.gettrueval(@DOCID)  
	End  
	Else  
	Begin  
		Set @CreateNew = 1  
	End
End 
Else IF @DOCTYPE = 3 -- Collection  
Begin  
	If exists(Select DocumentID From Collections Where DocumentID = dbo.sp_ser_GetTrueVal(@DOCID))
  	Begin  
   		update collections set balance = balance + @ADJAMOUNT + @Adjustment   
   		where documentid = dbo.gettrueval(@DOCID)  
  	End  
  	Else  
  	Begin  
   		Set @CreateNew = 1
  	End
End  

	Set @Value = @ADJAMOUNT + @Adjustment  
	Set @Ref = @OriginalID + ',' + Cast(@DocDate As Varchar) + ',' + Cast(@DocumentValue As Varchar)
	Set @GetDate = GetDate()  

	If @CreateNew = 1  
	Begin  
		exec sp_ser_insert_CreditNote @PartyType, @Customer, @Value, @GetDate, @Ref, @OriginalID
	End  
	Else If @CreateNew = 2  
	Begin  
   		exec sp_ser_insert_DebitNote @PartyType, @Customer, @Value, @GetDate, @Ref, 0, @OriginalID
	End  

FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment,  
@DocDate, @OriginalID, @DocumentValue  
END  
 
CLOSE COLLECTION_CURSOR   
DEALLOCATE COLLECTION_CURSOR

