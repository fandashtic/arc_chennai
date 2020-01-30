CREATE FUNCTION fn_FirstLevelCategory(@CategoryID INT)
RETURNS nvarchar(100)
AS
BEGIN
DECLARE @ParentId As Int
DECLARE @CatDesc As nvarchar(100)

        select @ParentId = Parentid, @CatDesc = Category_Name from Itemcategories where Categoryid = @CategoryId
        while @ParentId <> 0 
        BEGIN 
		SELECT @CatDesc = Category_Name, @ParentId = ParentID FROM ItemCategories 
                WHERE CategoryID = @ParentId 
        END
RETURN(@CatDesc)
END



