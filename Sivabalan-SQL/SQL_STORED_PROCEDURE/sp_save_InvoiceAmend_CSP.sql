
CREATE Procedure sp_save_InvoiceAmend_CSP(@INVOICE_ID int,
				      @ITEM_CODE NVARCHAR(15),
				      @BATCH_NUMBER NVARCHAR(255), 
				      @SALE_PRICE Decimal(18,6), 
				      @REQUIRED_QUANTITY Decimal(18,6),
				      @SALE_TAX Decimal(18,6),
				      @DISCOUNT_PER Decimal(18,6), 
				      @DISCOUNT_AMOUNT Decimal(18,6),
				      @AMOUNT Decimal(18,6), 	
				      @TRACK_BATCHES int,
				      @BATCH_PRICE Decimal(18,6),
				      @STOCK Decimal(18,6))
AS

        INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number , Quantity, SalePrice, 
	TaxCode, DiscountPercentage, DiscountValue, Amount) 
	VALUES (@INVOICE_ID, @ITEM_CODE, 0, @BATCH_NUMBER, @REQUIRED_QUANTITY, @SALE_PRICE,
        @SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT)


