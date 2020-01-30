CREATE PROCEDURE sp_CollectionDetailReceived        
(@CollectionID nvarchar(20), @DocumentID INT, @OriginalID nvarchar(50), @DocumentType INT,
@PaymentDate DateTime, @AdjustedAmount Decimal(18,6), @DocumentValue Decimal(18,6), 
@ExtraCollection Decimal(18,6), @Adjustment Decimal(18,6), @DocRef nvarchar(256), @Discount Decimal(18,6))
AS        
INSERT INTO CollectionDetailReceived        
(CollectionID, DocumentID, OriginalID, DocumentType, PaymentDate, AdjustedAmount,
DocumentValue, ExtraCollection, Adjustment, DocRef, Discount)
VALUES        
(@CollectionID , @DocumentID , @OriginalID, @DocumentType, @PaymentDate, @AdjustedAmount, @DocumentValue,
@ExtraCollection, @Adjustment, @DocRef, @Discount)




