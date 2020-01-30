Create PROCEDURE sp_set_itemprice(@PRODUCT_CODE nvarchar(15), @SALE_PRICE Decimal(18,6), @PTR Decimal(18,6), @ECP Decimal(18,6), @SPECIAL_PRICE Decimal(18,6), @PFM Decimal(18,6) = 0, @MRPPerPack Decimal(18,6) = 0)  
AS  
UPDATE Items SET Sale_Price = @ECP, PTS = @SALE_PRICE, PTR = @PTR, ECP = @ECP, Company_Price = @SPECIAL_PRICE, PFM = @PFM, MRPPerPack = @MRPPerPack 
WHERE Product_Code = @PRODUCT_CODE  and @SALE_PRICE > 0
