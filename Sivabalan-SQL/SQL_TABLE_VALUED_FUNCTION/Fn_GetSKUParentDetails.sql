Create Function Fn_GetSKUParentDetails(@Product Nvarchar(255),@Level Int)
Returns
@tmpOUT table (
	Product_code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SubCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	MarketSKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
AS
BEGIN

	Declare @tmp table (
		Product_code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Category Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SubCategory Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		MarketSKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @Level = 5
	Begin
		Insert Into @tmp
		select Distinct I.Product_code,IC2.Category_Name Category,IC3.Category_Name SubCategory,IC4.Category_Name MarketSKU
		from Items I ,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2
		where IC4.categoryid = i.categoryid 
		And IC4.ParentId = IC3.categoryid 
		And IC3.ParentId = IC2.categoryid 
	End

Else If @Level <> 5
	Begin
		Insert Into @tmp
		select Distinct I.Product_Code,IC2.Category_Name Category,IC3.Category_Name SubCategory,IC4.Category_Name MarketSKU
		from ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, Items I
		where IC4.ParentId = IC3.categoryid 
		And IC3.ParentId = IC2.categoryid 
		And I.CategoryID = IC4.categoryid
	End

		If @Level = 5
			Begin
				Insert Into @tmpOUT(Product_code,Category,SubCategory,MarketSKU) 
				Select Distinct Product_code,Category,SubCategory,MarketSKU From @tmp Where Product_code = @Product
			End

		If @Level = 4
			Begin
				Insert Into @tmpOUT(Product_code,Category,SubCategory,MarketSKU) 
				Select Distinct Product_code,Category,SubCategory,MarketSKU From @tmp Where MarketSKU = @Product
			End

		If @Level = 3
			Begin
				Insert Into @tmpOUT(Product_code,Category,SubCategory,MarketSKU) 
				Select Distinct Product_code,Category,SubCategory,MarketSKU From @tmp Where SubCategory = @Product
			End

		If @Level = 2
			Begin
				Insert Into @tmpOUT(Product_code,Category,SubCategory,MarketSKU) 
				Select Distinct Product_code,Category,SubCategory,MarketSKU From @tmp Where Category = @Product
			End
	Return 
End
