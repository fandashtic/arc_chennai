CREATE PROCEDURE spr_ser_manufacturers(@FROMDATE datetime, @TODATE datetime, @CusType nVarchar(50))
AS
SELECT "ManufacturerID" = ManufacturerID, "Manufacturer Name" = Manufacturer_Name 
FROM Manufacturer


