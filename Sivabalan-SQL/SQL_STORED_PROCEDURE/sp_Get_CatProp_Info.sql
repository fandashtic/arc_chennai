Create Procedure sp_Get_CatProp_Info (@ID Int, @CategoryID Int)
As
Declare @PropertyID Int
Declare @PropertyName nvarchar(255)

--Declare ExistingProp Cursor KeySet For
--Select PropertyID From Properties Where
--Property_Name In (Select PropertyName From CategoryPropReceived Where
--ItemID = @ID)
--
--Open ExistingProp
--
--Fetch From ExistingProp Into @PropertyID
--While @@Fetch_Status = 0
--Begin
--	Insert Into Category_Properties Values(@CategoryID, @PropertyID)
--	Fetch Next From ExistingProp Into @PropertyID
--End
--Close ExistingProp
--DeAllocate ExistingProp

Declare NewProp Cursor KeySet For
Select PropertyName From CategoryPropReceived Where ItemID = @ID And
PropertyName Not In (Select Property_Name From Properties)

Open NewProp

Fetch From NewProp Into @PropertyName
While @@Fetch_Status = 0
Begin
	Insert Into Properties (Property_Name) Values (@PropertyName)
	Select @PropertyID = @@Identity
	Insert Into Category_Properties Values (@CategoryID, @PropertyID)
	Fetch Next From NewProp Into @PropertyName
End
Close NewProp
DeAllocate NewProp

