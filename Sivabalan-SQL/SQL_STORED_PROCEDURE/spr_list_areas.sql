
CREATE PROCEDURE spr_list_areas
AS
SELECT AreaID, Area, "Status" = case Active
		     WHEN 1 THEN "Active"
		     ELSE "Inactive"
		     END
FROM Areas


