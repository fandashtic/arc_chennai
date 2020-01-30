
CREATE PROCEDURE spr_list_tax
AS

Declare @ACTIVE As NVarchar(50)
Declare @INACTIVE As NVarchar(50) 
Set @ACTIVE = dbo.LookupDictionaryItem(N'Active',Default)
Set @INACTIVE = dbo.LookupDictionaryItem(N'Inactive',Default)

SELECT Tax_Code, "Description" = Tax_Description, "LST" = Percentage, "CST" = CST_Percentage,
	"Status" = case Active
	WHEN 1 THEN @ACTIVE 
	ELSE @INACTIVE
	END
FROM Tax

