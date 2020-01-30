
CREATE PROCEDURE sp_Create_Stock_Request(@RequestDate DATETIME,   
  @warehouseID NVARCHAR(15),   
  @RequiredDate DATETIME,   
  @Value Decimal(18,6),   
  @BillingAddress NVARCHAR(255),  
  @ShippingAddress NVARCHAR(255),  
  @Status INT,  
  @CreditTerm INT)  
AS  
DECLARE @DocumentID int  
DECLARE @STK_REQ_Prefix nvarchar(20)
BEGIN TRAN  
if (select count(*) from documentnumbers where doctype = 22) = 0   
begin  
 insert documentnumbers values(22,0,Null)  
  
end   
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 22  
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 22  
COMMIT TRAN  
select @STK_REQ_Prefix = Prefix from voucherprefix  where Tranid = 'STOCK REQUEST'
INSERT INTO   
stock_request_abstract (Stock_Req_Date,   
  warehouseID,   
  RequiredDate,   
  Value,   
  BillingAddress,  
  ShippingAddress,  
  Status,  
  CreditTerm,  
  DocumentID,STK_REQ_Prefix)  
VALUES    
  (@RequestDate,   
  @warehouseID,   
  @RequiredDate,   
  @Value,   
  @BillingAddress,  
  @ShippingAddress,  
  @Status,  
  @CreditTerm,  
  @DocumentID, @STK_REQ_Prefix)  
SELECT @@IDENTITY, @DocumentID  


