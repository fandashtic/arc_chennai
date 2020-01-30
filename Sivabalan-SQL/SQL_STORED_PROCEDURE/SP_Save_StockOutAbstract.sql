CREATE PROCEDURE SP_Save_StockOutAbstract        
(        
 @DocumentType nvarchar(100),        
 @DocumentReference nvarchar(120),        
 @DocumentDate DateTime        
)        
As              
BEGIN      
 DECLARE @DocumentID int, @VoucherPrefix nvarchar(100)        
 SET @VoucherPrefix = (Select Prefix From VoucherPrefix Where TranID='STOCK OUT')
 BEGIN TRAN              
 UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 34              
 SELECT @DocumentID = DocumentID-1 FROM DocumentNumbers WHERE DocType = 34              
 COMMIT TRAN         
 INSERT INTO StockOutAbstract         
 ( DocumentType,        
   DocumentReference,        
   DocumentID,        
   DocumentDate        
 )VALUES        
 (        
   @DocumentType,        
   @DocumentReference,        
   @VoucherPrefix + CAST(@DocumentID as nvarchar(20)),
   @DocumentDate        
 )        
 SELECT @@Identity, @VoucherPrefix         
END      

