
CREATE PROCEDURE sp_update_schemesale(@PRODUCT_CODE nvarchar(15),
			    @QUANTITY Decimal(18,6),
			    @FREE Decimal(18,6),
			    @VALUE Decimal(18,6),
			    @COST Decimal(18,6),
			    @TYPE int)
AS
Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type)
Values(@PRODUCT_CODE, @QUANTITY, @FREE, @VALUE, @COST, @TYPE)


