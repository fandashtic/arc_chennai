Create Procedure sp_Insert_CustProdCat (
					@CustomerID [nVarChar] (30),
					@CategoryID [int],
					@Active [Int],
					@AM [Int]
					)
As

If @AM = 2
Begin
	Delete From [CustomerProductCategory] Where [CustomerID] Like @CustomerID
End

Insert InTo [CustomerProductCategory] ([CustomerID], [CategoryID], [Active], 
	    [CreationDate]) Values (@CustomerID, @CategoryID, @Active, GetDate())

