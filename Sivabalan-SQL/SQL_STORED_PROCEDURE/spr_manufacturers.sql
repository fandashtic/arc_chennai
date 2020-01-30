CREATE PROCEDURE spr_manufacturers(@FROMDATE datetime, @TODATE datetime, @CusType nVarchar(50))
AS
--@CusType is not used
SELECT "ManufacturerID" = ManufacturerID, "Manufacturer Name" = Manufacturer_Name 
FROM Manufacturer

