Create Function fn_GetLevelName(@CatID As Integer,@Level As Integer)
Returns nVarchar(250)
As
Begin
	Declare @Continue as Integer
	Declare @Lev as Integer
	Declare @Category as nVarchar(250)
	Declare @CategoryID AS Integer
	Set @Continue = 1
	While @Continue >=  1
	Begin
		Select @CategoryID = CategoryID,@Category = Category_Name ,@Lev = Level From ItemCategories Where CategoryID = 
		(Select ParentID From ItemCategories Where CategoryID = @CatID)
		If @Lev = @Level Set @Continue = 0
		Set @CatID = @CategoryID 
	End
	Return @Category
End
