CREATE PROCEDURE Spr_get_StockOutAbstract      
(      
 @DocFromDate DateTime,      
 @DocToDate DateTime      
)      
AS      
BEGIN   
 Declare @VoucherPrefix nvarchar(15)
--  Select @VoucherPrefix = Prefix From Voucherprefix Where TranID='STOCK OUT'
 SELECT StockOutID, "DocumentID" = DocumentID, "Document Type" = DocumentType, "Document Reference" = DocumentReference, "Document Date" = DocumentDate    
 FROM StockOutAbstract      
 WHERE DocumentDate BETWEEN @DocFromDate AND @DocToDate      
END    

