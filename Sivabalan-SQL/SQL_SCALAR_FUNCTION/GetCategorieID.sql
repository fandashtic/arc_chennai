Create Function GetCategorieID (@Category Varchar(2550))  
Returns Int
As
Begin
	Declare @CID Int
	Select @CID=CategoryID From ItemCategories Where Category_Name =@Category
	Return @CID
End
