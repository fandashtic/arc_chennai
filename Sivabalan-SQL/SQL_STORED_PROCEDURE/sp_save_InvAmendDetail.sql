
CREATE PROCEDURE sp_save_InvAmendDetail(@INV_ID INT, @PRODUCT_CODE NVARCHAR(15),
@BATCH_NUMBER NVARCHAR(255), @QUANTITY Decimal(18,6), @SALEPRICE Decimal(18,6),
@TAXCODE Decimal(18,6), @DISPER Decimal(18,6), @DISVALUE Decimal(18,6), @AMOUNT Decimal(18,6))

AS

INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Number,
Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount)
VALUES (@INV_ID, @PRODUCT_CODE, @BATCH_NUMBER, @QUANTITY,
@SALEPRICE, @TAXCODE, @DISPER, @DISVALUE, @AMOUNT)


