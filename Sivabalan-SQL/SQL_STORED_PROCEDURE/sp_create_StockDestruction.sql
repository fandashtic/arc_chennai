CREATE PROCEDURE sp_create_StockDestruction  
   	(@VoucherPrefix nvarchar(50),
	@DocumentDate DateTime,
	@ClaimID Integer,
	@ClaimRef nvarchar(50),
	@userID nvarchar(50))  
AS  
DECLARE @DocumentID int  
  
SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 31  
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 31  
  
INSERT INTO   
StockDestructionAbstract(DocumentID ,
VoucherPrefix,
DocumentDate,
ClaimID,
ClaimReference,
UserID)  
VALUES    
(@DocumentID,
@VoucherPrefix,
@DocumentDate, 
@ClaimID, 
@ClaimRef, 
@userID) 
Update ClaimsNote Set Status = IsNull(Status, 0) | 1 where ClaimID in ( @ClaimID )
SELECT @@IDENTITY, @DocumentID  
  


