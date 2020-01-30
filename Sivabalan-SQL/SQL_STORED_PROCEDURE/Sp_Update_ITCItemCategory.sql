CREATE procedure Sp_Update_ITCItemCategory(@ItemCode varchar(30),@CatName varchar(510))
as
begin
	Declare @CatID int
	if Exists (Select Product_Code from Items where Product_Code = @ItemCode)
	Begin
		if Exists (Select CategoryID from ItemCategories where Category_Name = @CatName)
		Begin
			Select @CatID = IsNull(CategoryID,0) from ItemCategories where Category_Name = @CatName
			If Not Exists (Select CategoryID from ItemCategories where ParentID = @CatID)
			Begin
				Update Items Set CategoryID=@CatID where Product_Code=@ItemCode
				Select 4
			End
			Else
			Begin
				Select 3
			End
		End
		Else
		Begin
			Select 2
		End
	End
	Else
	Begin
		Select 1
	End
end
