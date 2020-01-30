
CREATE PROCEDURE spr_list_salesman
AS
SELECT SalesmanID, "Salesman" = Salesman_Name, Address, "Creation Date" = CreationDate,
	"Status" = case Active
	WHEN 1 THEN "Active"
	ELSE "Inactive"
	END
FROM Salesman
