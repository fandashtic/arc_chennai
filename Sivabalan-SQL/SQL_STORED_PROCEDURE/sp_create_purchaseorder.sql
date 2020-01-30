CREATE PROCEDURE sp_create_purchaseorder(@PODate DATETIME,     
  @VendorID NVARCHAR(15),     
  @RequiredDate DATETIME,     
  @Value Decimal(18,6),     
  @BillingAddress NVARCHAR(255),    
  @ShippingAddress NVARCHAR(255),    
  @Status INT,    
  @CreditTerm INT,  
  @DocRef NVARCHAR(255)=null,
  @DivisionId INT=0)    
 AS    
DECLARE @DocumentID int    
    
BEGIN TRAN    
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 1    
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 1    
COMMIT TRAN    
    
INSERT INTO     
POABSTRACT (PODate,     
  VendorID,     
  RequiredDate,     
  Value,     
  BillingAddress,    
  ShippingAddress,    
  Status,    
  CreditTerm,    
  DocumentID,  
  DocRef,
  BrandID)    
VALUES      
  (@PODate,     
  @VendorID,     
  @RequiredDate,     
  @Value,     
  @BillingAddress,    
  @ShippingAddress,    
  @Status,    
  @CreditTerm,    
  @DocumentID,  
  @DocRef,
  @DivisionId)    
SELECT @@IDENTITY, @DocumentID    


