CREATE PROCEDURE sp_Insert_QuotationUniversal(@QuotationID INT,
					      @MarginFrom Decimal(18,6),
					      @MarginTo Decimal(18,6),
					      @Discount Decimal(18,6))
AS
INSERT INTO [QuotationUniversal](QuotationID, MarginFrom, MarginTo, Discount) 
VALUES(@QuotationID, @MarginFrom, @MarginTo, @Discount)



