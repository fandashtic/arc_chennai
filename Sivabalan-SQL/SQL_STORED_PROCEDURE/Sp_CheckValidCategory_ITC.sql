Create Procedure Sp_CheckValidCategory_ITC
(
 @Category NVarChar(510),
 @SubCategory NVarChar(510)
)
As
Declare @CategoryID As Integer
Declare @SubCategoryID As Integer
Declare @ParentID As Integer
Declare @Result As Integer
If Isnull(@Category,'') = '%All' or IsNull(@SubCategory,'') = '%All'
	Begin
		Set @Result = 0
	End
Else
	Begin
		If IsNull(@Category,'') <> N'' And IsNull(@SubCategory,'') = N''
		Begin
			Select @CategoryID = Count(CategoryID) From ItemCategories Where Category_Name = @Category And [Level] In (Select Min(LevelNo) From CategoryLevelInfo)
			If IsNull(@CategoryID,0) = 0 Set @Result = 1
		End
		Else If IsNull(@Category,'') = N'' And IsNull(@SubCategory,'') <> N'' 
		Begin
			Select @CategoryID = Count(CategoryID) From ItemCategories Where Category_Name = @SubCategory And [Level] In (Select Max(LevelNo) From CategoryLevelInfo)
			If IsNull(@CategoryID,0) = 0 Set @Result = 1
		End
		Else If IsNull(@Category,'') <> N'' And IsNull(@SubCategory,'') <> N'' 
		Begin
			Select @CategoryID = CategoryID From ItemCategories Where Category_Name = @Category And [Level] In (Select Min(LevelNo) From CategoryLevelInfo)
			Select @SubCategoryID = CategoryID,@ParentID = ParentID From ItemCategories Where Category_Name = @SubCategory And [Level] In (Select Max(LevelNo) From CategoryLevelInfo)
			If IsNull(@CategoryID,0) = 0
				Set @Result = 1
			Else If IsNull(@CategoryID,0) <> IsNull(@ParentID,0)
				Set @Result = 1
		End
	End		
Select IsNull(@Result,0)
