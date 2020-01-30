
CREATE PROCEDURE sp_consolidate_tax(@TAX nvarchar(50),
				    @PERCENTAGE Decimal(18,6),
				    @ACTIVE int,
				    @CST_PERCENTAGE Decimal(18,6))
AS
IF NOT EXISTS (SELECT Tax_Code FROM Tax WHERE Tax_Description = @TAX)
BEGIN
Insert Tax(Tax_Description, Percentage, Active, CST_Percentage)
VALUES(@TAX, @PERCENTAGE, @ACTIVE, @CST_PERCENTAGE)
END

