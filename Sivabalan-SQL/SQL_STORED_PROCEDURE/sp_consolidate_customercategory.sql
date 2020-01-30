
CREATE PROCEDURE sp_consolidate_customercategory(@CATEGORY nvarchar(50),
				    @ACTIVE int)
AS
IF NOT EXISTS (SELECT CategoryID FROM CustomerCategory WHERE CategoryName = @CATEGORY)
BEGIN
Insert CustomerCategory(CategoryName, Active)
VALUES(@CATEGORY, @ACTIVE)
END

