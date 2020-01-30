Create Function mERP_FN_V_SKUwiseSOQ()
	Returns @OutPut Table(SKUCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SOQ int)
AS
BEGIN

	Declare @CategoryName nvarchar(255)
	Declare @CategoryLevel int
	Declare @SOQ int

	Declare @tmpSKU Table (CategoryName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
				CategoryLevel int, SKUCode Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SOQ int)

	Declare @Cur Cursor
	Set @Cur = Cursor for
	Select CategoryName, CategoryLevel, SOQ From tbl_merp_CategorywiseSOQ Order By CategoryLevel Asc
	Open @Cur
	Fetch From @Cur Into @CategoryName,@CategoryLevel,@SOQ
	While @@Fetch_Status = 0
	Begin
		IF @CategoryLevel = 5
		Begin
			IF Not Exists(Select * From Items Where Product_Code = @CategoryName and Active = 1)
			Begin
				Goto SkipROW
			End
			IF Exists(Select * From @tmpSKU Where SKUCode = @CategoryName)
			Begin
				Update @tmpSKU Set SOQ = @SOQ Where SKUCode = @CategoryName
			End
			Else
			Begin
				Insert Into @tmpSKU (CategoryName,CategoryLevel,SKUCode,SOQ)
				Select @CategoryName,@CategoryLevel,@CategoryName,@SOQ
			End
		End

		IF @CategoryLevel = 4
		Begin
			IF Not Exists(Select * From ItemCategories Where Category_Name = @CategoryName And Level = 4)
			Begin
				Goto SkipROW
			End
			Update T Set T.SOQ = T1.SOQ From @tmpSKU T,
				(Select Distinct I.Product_Code, @SOQ SOQ
					From Items I, ItemCategories IC4 
					Where IC4.CategoryID = I.CategoryID And IC4.Category_Name = @CategoryName) T1
			Where T.SKUCode = T1.Product_Code				

			Insert Into @tmpSKU (CategoryName,CategoryLevel,SKUCode,SOQ)
			Select Distinct @CategoryName,@CategoryLevel,I.Product_Code,@SOQ
			From Items I, ItemCategories IC4 
			Where
				IC4.CategoryID = I.CategoryID 
				And IC4.Category_Name = @CategoryName
				And I.Product_Code Not in (Select Distinct SKUCode From @tmpSKU)
				and I.Active = 1
		End

		IF @CategoryLevel = 3
		Begin
			IF Not Exists(Select * From ItemCategories Where Category_Name = @CategoryName And Level = 3)
			Begin
				Goto SkipROW
			End

			Update T Set T.SOQ = T1.SOQ From @tmpSKU T,
				(Select Distinct I.Product_Code, @SOQ SOQ
				From Items I, ItemCategories IC4, ItemCategories IC3 
				Where IC4.CategoryID = I.CategoryID 
					And IC4.ParentID = IC3.CategoryID 
					And IC3.Category_Name = @CategoryName) T1
			Where T.SKUCode = T1.Product_Code			

			Insert Into @tmpSKU (CategoryName,CategoryLevel,SKUCode,SOQ)
			Select Distinct @CategoryName,@CategoryLevel,I.Product_Code,@SOQ
			From Items I, ItemCategories IC4, ItemCategories IC3 
			Where IC4.CategoryID = I.CategoryID 
				And IC4.ParentID = IC3.CategoryID 
				And IC3.Category_Name = @CategoryName
				And I.Product_Code Not in (Select Distinct SKUCode From @tmpSKU)
				and I.Active = 1
		End

		IF @CategoryLevel = 2
		Begin
			IF Not Exists(Select * From ItemCategories Where Category_Name = @CategoryName And Level = 2)
			Begin
				Goto SkipROW
			End
			Update T Set T.SOQ = T1.SOQ From @tmpSKU T,
			(Select Distinct I.Product_Code, @SOQ SOQ
			From Items I, ItemCategories IC4, ItemCategories IC3, ItemCategories IC2 
			Where IC4.CategoryID = I.CategoryID 
				And IC4.ParentID = IC3.CategoryID
				And IC3.ParentID = IC2.CategoryID 
				And IC2.Category_Name = @CategoryName) T1
			Where T.SKUCode = T1.Product_Code				

			Insert Into @tmpSKU (CategoryName,CategoryLevel,SKUCode,SOQ)
			Select Distinct @CategoryName,@CategoryLevel,I.Product_Code,@SOQ
			From Items I, ItemCategories IC4, ItemCategories IC3, ItemCategories IC2 
			Where IC4.CategoryID = I.CategoryID 
				And IC4.ParentID = IC3.CategoryID 
				And IC3.ParentID = IC2.CategoryID 
				And IC2.Category_Name = @CategoryName
				And I.Product_Code Not in (Select Distinct SKUCode From @tmpSKU)
				and I.Active = 1
		End

		SkipROW:
		Fetch Next From @Cur Into @CategoryName,@CategoryLevel,@SOQ
	End
	Close @Cur
	Deallocate @Cur

	Insert Into @OutPut(SKUCode, SOQ)
	Select SKUCode, SOQ From @tmpSKU

	Return
END
