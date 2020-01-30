
CREATE PROCEDURE sp_drop_category_properties(@CATEGORYID int)
AS
DELETE Category_Properties WHERE CategoryID = @CATEGORYID

