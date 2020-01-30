CREATE PROCEDURE sp_consolidate_so_detail(@SONumber INT, 
		@ForumCode nvarchar(15),
		@BatchNumber nvarchar(128),
		@Quantity Decimal(18,6), 
		@Pending Decimal(18,6),
		@SalePrice Decimal(18,6),
		@SaleTax Decimal(18,6),
		@TaxCode2 Decimal(18,6),
		@Discount Decimal(18,6),
		@TaxSuffered Decimal(18,6))
AS
Declare @ProductCode nvarchar(20)

Select @ProductCode = Product_Code From Items Where Alias = @ForumCode
INSERT INTO 
SODetail  	(SONumber, 
		Product_Code, 
		Batch_Number,
		Quantity, 
		Pending,
		SalePrice,
		SaleTax,
		TaxCode2,
		Discount,
		TaxSuffered)
VALUES		
		(@SONumber, 
		@ProductCode, 
		@BatchNumber,
		@Quantity, 
		@Pending, 
		@SalePrice,
		@SaleTax,
		@TaxCode2,
		@Discount,
		@TaxSuffered)
