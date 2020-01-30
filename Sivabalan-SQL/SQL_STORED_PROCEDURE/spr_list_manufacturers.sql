
CREATE PROCEDURE spr_list_manufacturers
AS
SELECT ManufacturerID, "Manufacturer Name" = Manufacturer_Name, 
	"CreationDate" = CreationDate
FROM Manufacturer


