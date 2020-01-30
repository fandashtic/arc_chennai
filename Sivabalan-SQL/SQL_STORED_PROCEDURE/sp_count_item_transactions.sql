
CREATE PROCEDURE sp_count_item_transactions(@ITEM_CODE nvarchar(15))
AS
IF EXISTS (SELECT TOP 1 Product_Code FROM PODetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM SODetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM GRNDetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM DispatchDetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM DispatchDetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM BillDetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM ClaimsDetail WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM StockAdjustment WHERE Product_Code = @ITEM_CODE) or 
   EXISTS (SELECT TOP 1 Product_Code FROM AdjustmentReturnDetail WHERE Product_Code = @ITEM_CODE) 
	SELECT 1 
ELSE
	SELECT 0


