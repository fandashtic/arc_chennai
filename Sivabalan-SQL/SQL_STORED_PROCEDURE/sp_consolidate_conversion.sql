
CREATE PROCEDURE sp_consolidate_conversion(@CONVERSIONUNIT nvarchar(50))
AS
IF NOT EXISTS (SELECT ConversionID FROM ConversionTable WHERE ConversionUnit = @CONVERSIONUNIT)
BEGIN
Insert ConversionTable(ConversionUnit)
VALUES(@CONVERSIONUNIT)
END

