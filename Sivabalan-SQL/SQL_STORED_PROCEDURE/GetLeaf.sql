CREATE PROCEDURE GetLeaf(@PARENTID int)
AS
DECLARE @CatID int

SELECT @CatID = Max(CategoryID) From ItemCategories Where ParentID = @ParentID
While @CatID Is Not Null
begin
	Select @CatID
	Exec GetLeaf @CatID
	SELECT @CatID = Max(CategoryID) From ItemCategories Where ParentID = @ParentID And CategoryID < @CatID
end
