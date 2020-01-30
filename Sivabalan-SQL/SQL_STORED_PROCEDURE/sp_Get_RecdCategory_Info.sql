CREATE Procedure sp_Get_RecdCategory_Info (@CategoryID Int)
As
Declare @ParentID Int
Declare @NewCategoryID Int
Declare @InsertProp Int

Select @ParentID = CategoryID From ItemCategories 
Where Category_Name = (Select IsNull(Parent, N'') From CategoryReceived
Where ID = @CategoryID)

Select @NewCategoryID = CategoryID From ItemCategories 
Where Category_Name = (Select CategoryName From CategoryReceived Where ID = @CategoryID)

If IsNull(@NewCategoryID, 0) <> 0
Begin
	If exists (Select PropertyName From CategoryPropertyReceived 
	Where CategoryID = @CategoryID And
	PropertyName Not In (Select Properties.Property_Name From Category_Properties, Properties
	Where Category_Properties.PropertyID = Properties.PropertyID And
	Category_Properties.CategoryID = @NewCategoryID))
	Begin
		Set @InsertProp = 0
	End
	Else
	Begin
		If exists (Select Properties.Property_Name From Category_Properties, Properties
		Where Category_Properties.PropertyID = Properties.PropertyID And
		Category_Properties.CategoryID = @NewCategoryID And 
		Property_Name Not In (Select PropertyName From CategoryPropertyReceived 
		Where CategoryID = @CategoryID))
		Begin
			Set @InsertProp = 0
		End
		Else
			Set @InsertProp = 1
	End
End
Else 
	Set @InsertProp = 0
Select CategoryName, Description, IsNull(@ParentID, 0), TrackInventory, PriceOption,
@NewCategoryID, @InsertProp
From CategoryReceived Where ID = @CategoryID

