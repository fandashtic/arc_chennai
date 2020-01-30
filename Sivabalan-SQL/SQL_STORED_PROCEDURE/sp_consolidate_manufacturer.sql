
CREATE PROCEDURE sp_consolidate_manufacturer(@MANUFACTURER nvarchar(50),
					     @ACTIVE int)
AS
IF NOT EXISTS (SELECT ManufacturerID FROM Manufacturer WHERE Manufacturer_Name = @MANUFACTURER)
BEGIN
Insert Manufacturer(Manufacturer_Name, Active)
VALUES(@MANUFACTURER, @ACTIVE)
END

