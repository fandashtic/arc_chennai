CREATE PROCEDURE sp_ListProperties(@CATEGORYID int)
AS
SELECT "Property ID" = Properties.PropertyId, 
"Property Name" = Properties.Property_Name 
FROM Category_Properties, Properties 
WHERE Category_Properties.CategoryID = @CATEGORYID AND 
Properties.PropertyID = Category_Properties.PropertyID
