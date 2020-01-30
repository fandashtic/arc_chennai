
CREATE PROCEDURE sp_get_opening_qty_value(@PRODUCT_CODE nvarchar(15), @DATE datetime)
AS
SELECT Opening_Quantity as OpenBalanceQty, Opening_Value as OpenBalanceValue
FROM OpeningDetails
WHERE Opening_Date = @DATE AND Product_Code = @PRODUCT_CODE


