

CREATE proc sp_update_returned_sales(@BATCHCODE int, @QUANTITY Decimal(18,6))
as
UPDATE batch_products set Quantity = Quantity + @QUANTITY
where Batch_Code = @BATCHCODE



