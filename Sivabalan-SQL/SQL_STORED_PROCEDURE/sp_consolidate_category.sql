
CREATE PROCEDURE sp_consolidate_category(@CATEGORY NVARCHAR(50),
					 @DESCRIPTION NVARCHAR(255),
					 @PARENT NVARCHAR(50),
					 @TRACK_INVERNTORY int,
					 @PRICE_OPTION int,
					 @ACTIVE int)
AS
DECLARE @PARENTID int
IF NOT EXISTS (SELECT CategoryID FROM ItemCategories WHERE Category_Name = @CATEGORY)
BEGIN
Select @PARENTID = CategoryID FROM ItemCategories WHERE Category_Name = @PARENT
INSERT INTO ItemCategories(Category_Name, Description, ParentID, Track_Inventory, Price_Option, Active)
VALUES(@CATEGORY, @DESCRIPTION, @PARENTID, @TRACK_INVERNTORY, @PRICE_OPTION, @ACTIVE)
END

