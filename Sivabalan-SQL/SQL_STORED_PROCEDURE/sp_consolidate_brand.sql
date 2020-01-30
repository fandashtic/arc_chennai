
CREATE PROCEDURE sp_consolidate_brand(@BRAND nvarchar(50),
					     @MANUFACTURER nvarchar(50),
					     @ACTIVE int)
AS
DECLARE @MANUFACTURERID int
IF NOT EXISTS (SELECT BrandID FROM Brand WHERE BrandName = @Brand)
BEGIN
Select @MANUFACTURERID = ManufacturerID FROM Manufacturer WHERE Manufacturer_Name = @MANUFACTURER
Insert Brand(BrandName, ManufacturerID, Active)
VALUES(@BRAND, @MANUFACTURERID, @ACTIVE)
END

