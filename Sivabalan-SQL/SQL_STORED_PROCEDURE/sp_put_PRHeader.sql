
create proc sp_put_PRHeader 
( @VendorID nvarchar(15), @BillID int , @AdjustmentDate datetime, @DocumentID int, @ForumId nvarchar(50), @Value Decimal(18,6), @Balance Decimal(18,6), @Status int)
as

INSERT INTO AdjustmentReturnAbstract_Received
(  VendorID, BillID, AdjustmentDate, DocumentID, ForumId, Value, Balance, Status )
VALUES
(  @VendorID, @BillID, @AdjustmentDate, @DocumentID, @ForumId, @Value, @Balance, @Status)
SELECT @@IDENTITY

