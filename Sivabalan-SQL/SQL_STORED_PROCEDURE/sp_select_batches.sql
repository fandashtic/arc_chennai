
CREATE PROCEDURE sp_select_batches(@PRODUCT_CODE nvarchar(15))
AS
SELECT Product_Code, ProductName, N'', Purchase_Price ,Sale_Price 
FROM Items WHERE Product_Code = @PRODUCT_CODE


