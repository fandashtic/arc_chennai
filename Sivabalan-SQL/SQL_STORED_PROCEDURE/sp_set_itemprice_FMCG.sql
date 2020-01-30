CREATE PROCEDURE sp_set_itemprice_FMCG(@PRODUCT_CODE nvarchar(15), @SALE_PRICE Decimal(18,6),@PURCHASE_PRICE Decimal(18,6)=0)  
AS  
UPDATE Items SET Sale_Price = @SALE_PRICE,Purchase_Price = @PURCHASE_PRICE  WHERE Product_Code = @PRODUCT_CODE  


