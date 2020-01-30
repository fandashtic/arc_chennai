Create Procedure Sp_Import_CustomerProductCategory_ITC
(
 @CustomerID NVarChar(30),
 @Mode Int = 0,
 @Category NVarChar(510) = N'',
 @SubCategory NVarChar(510) = N''
)
As
Declare @CategoryName NVarChar(510)
Declare @CategoryID Integer
Declare @SubCategoryID Integer
Declare @CntCategoryID Integer
Declare @SubCatCnt Integer
Declare @CustSubCatCnt Integer
Declare @ParentID Integer
Declare @ifExists Integer

Create Table #TempCategory(CategoryID Int,Status Int)

If @Mode = 1
	Delete From CustomerProductCategory Where CustomerID In (@CustomerID)
Else
	Begin
		If @Category = '%All' or @SubCategory = '%All'
		Begin
			Delete From CustomerProductCategory Where CustomerID In (@CustomerID)
			Insert Into CustomerProductCategory(CustomerID,CategoryID,Active)    
			Select @CustomerID,CategoryID,1 from ItemCategories 
			where [Level] = (Select Min(LevelNo) From CategoryLevelInfo)
			Insert Into CustomerProductCategory(CustomerID,CategoryID,Active)    
			Select @CustomerID,CategoryID,1 from ItemCategories 
			where [Level] = (Select Max(LevelNo) From CategoryLevelInfo)			
		End
		Else
		Begin
			If IsNull(@Category,'') <> N''
			Begin
				Select @CategoryID = CategoryID From ItemCategories Where Category_Name = @Category
				if not exists (Select CustomerID from CustomerProductCategory where CategoryID = @CategoryID and CustomerID = @CustomerID)
				Begin
					Insert Into CustomerProductCategory(CustomerID,CategoryID,Active)
					Values(@CustomerID,@CategoryID,1)
					Insert Into CustomerProductCategory(CustomerID,CategoryID,Active)  
					Select @CustomerID,CategoryID,1 from ItemCategories where parentID = @CategoryID
				End
			End
			Else
			Begin
				Select @SubCategoryID = CategoryID From ItemCategories Where Category_Name = @SubCategory
				Declare CategoryCursor Cursor Keyset For Select CategoryID From CustomerProductCategory Where CustomerID = @CustomerID
				Open CategoryCursor
				Fetch From CategoryCursor Into @CategoryID
				While @@Fetch_Status = 0    
				Begin
					Exec GetAllChildCategories_ITC @CategoryID
					Fetch Next From CategoryCursor Into @CategoryID
				End
				Close CategoryCursor
				DeAllocate CategoryCursor    
				Select @CntCategoryID = Count(CategoryID) From #TempCategory Where CategoryID = @SubCategoryID
				If @CntCategoryID <= 0
				Begin
					Insert Into CustomerProductCategory(CustomerID,CategoryID,Active) Values(@CustomerID,@SubCategoryID,1)
					Select @ParentID = ParentID from ItemCategories Where CategoryID = @SubCategoryID
					Select @SubCatCnt = Count(*) from ItemCategories 	Where ParentID = @ParentID
					Select @CustSubCatCnt = Count(*) from CustomerProductCategory where CustomerID = @CustomerID
					And CategoryID in (Select CategoryID From ItemCategories Where ParentID = @ParentID)
					Select @ifExists = Count(*) from CustomerProductCategory where CategoryID = @ParentID and CustomerID = @CustomerID
					If isNull(@SubCatCnt,0) > 0 and isNull(@CustSubCatCnt,0) > 0 and isNull(@SubCatCnt,0) = isNull(@CustSubCatCnt,0) and isNull(@ifExists,0) = 0
					Begin
						Insert Into CustomerProductCategory(CustomerID,CategoryID,Active) Values(@CustomerID,@ParentID,1)
					End
				End
			End
		End
	End
Drop Table #TempCategory
