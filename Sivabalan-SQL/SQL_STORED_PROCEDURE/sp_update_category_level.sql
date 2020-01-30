
CREATE PROCEDURE sp_update_category_level(@CategoryID int)
AS
DECLARE @Parent int
DECLARE @Level int
DECLARE @OriginalID int

SET @Level = 1
SET @OriginalID = @CategoryID
OneLevelUp:
Select @Parent = IsNull(ParentID,0) From ItemCategories Where CategoryID = @CategoryID
If IsNull(@Parent,0) <> 0
Begin
	Set @Level = @Level + 1
	Set @CategoryID = @Parent
	Goto OneLevelUp
End
Update ItemCategories Set Level = @Level Where CategoryID = @OriginalID

