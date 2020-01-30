CREATE Procedure sp_Get_Cat_Info (@ID Int)
As
Declare @ParentID Int
Declare @CategoryID Int
Declare @InsertProp Int

Select @ParentID = CategoryID From ItemCategories 
Where Category_Name = (Select IsNull(ParentCategory, N'') From ItemsReceivedDetail
Where ID = @ID)

Select @CategoryID = CategoryID From ItemCategories 
Where Category_Name = (Select CategoryName From ItemsReceivedDetail Where ID = @ID)

If IsNull(@CategoryID, 0) <> 0
Begin
	If exists (Select PropertyName From CategoryPropReceived Where ItemID = @ID And
	PropertyName Not In (Select Properties.Property_Name From Category_Properties, Properties
	Where Category_Properties.PropertyID = Properties.PropertyID And
	Category_Properties.CategoryID = @CategoryID))
	Begin
		Set @InsertProp = 0
	End
	Else
	Begin
		If exists (Select Properties.Property_Name From Category_Properties, Properties
		Where Category_Properties.PropertyID = Properties.PropertyID And
		Category_Properties.CategoryID = @CategoryID And 
		Property_Name Not In (Select PropertyName From CategoryPropReceived 
		Where ItemID = @ID))
		Begin
			Set @InsertProp = 0
		End
		Else
			Set @InsertProp = 1
	End
End
Else 
	Set @InsertProp = 0
Select CategoryName, CategoryDesc, IsNull(@ParentID, 0), TrackInventory, PriceOption,
@CategoryID, @InsertProp
From ItemsReceivedDetail Where ID = @ID
