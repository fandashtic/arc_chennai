CREATE Procedure sp_compare_prop (@ID int, @CategoryID int)
As
If exists (Select PropertyName From CategoryPropReceived Where ItemID = @ID And
PropertyName Not In (Select Properties.Property_Name From Category_Properties, Properties
Where Category_Properties.PropertyID = Properties.PropertyID And
Category_Properties.CategoryID = @CategoryID))
Begin
	Select 0
End
Else
Begin
	If exists (Select Properties.Property_Name From Category_Properties, Properties
	Where Category_Properties.PropertyID = Properties.PropertyID And
	Category_Properties.CategoryID = @CategoryID And 
	Property_Name Not In (Select PropertyName From CategoryPropReceived 
	Where ItemID = @ID))
	Begin
		Select 0
	End
	Else
		Select 1
End

