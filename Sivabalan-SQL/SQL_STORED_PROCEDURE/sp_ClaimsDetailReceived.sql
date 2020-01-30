Create PROCEDURE sp_ClaimsDetailReceived      
(@detDocSerial as integer, @AdjustedAmount DECIMAL(18, 2), @ItemCode NVARCHAR(50), 
@Quantity DECIMAL(18,2),@Rate DECIMAL(18,2),@Batch NVARCHAR(50),@Expiry NVARCHAR(50)      
,@PurchasePrice DECIMAL(18,2),@Remarks NVARCHAR(255), @AdjustmentReason NVARCHAR(255), 
@ItemForumCode as nvarchar(20), @Serial Int)      
AS      
DECLARE @RECITEMCODE AS NVARCHAR(20)
SELECT  @RECITEMCODE = ISNULL(ITEMS.PRODUCT_CODE,N'') FROM ITEMS WHERE ITEMS.ALIAS = @ItemForumCode 
INSERT INTO ClaimsDetailReceived      
(DocSerial, Product_Code, Quantity, Rate, Batch, Expiry, PurchasePrice , Remarks , AdjustmentReason , AdjustedAmount,ForumCode, Serial)      
VALUES      
(@detDocSerial , @RECITEMCODE, @Quantity, @Rate, @Batch, @Expiry, @PurchasePrice , @Remarks , @AdjustmentReason , @AdjustedAmount, @ItemForumCode, @Serial ) 
