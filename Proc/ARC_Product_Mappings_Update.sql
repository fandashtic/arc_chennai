--Exec ARC_Product_Mappings_Update '43','Cl Refresh Taste10BE','GR4','CG','CIG','CIGARETTE ',''
--SELECT * FROM Product_Mappings P WITH (NOLOCK) WHERE P.Product_Code = '43'
--SELECT top 1 * FROM TransactionByDay P WITH (NOLOCK) WHERE P.Product_Code = '43'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Product_Mappings_Update')
BEGIN
	DROP PROC ARC_Product_Mappings_Update
END
GO
CREATE procedure [dbo].ARC_Product_Mappings_Update (@Product_Code NVARCHAR(255), @ProductName NVARCHAR(255), @CategoryGroup NVARCHAR(255), @Category NVARCHAR(255), @ItemFamily NVARCHAR(255), @ItemSubFamily NVARCHAR(255), @ItemGroup NVARCHAR(255))
As
Begin
	Declare @CategoryGroupId INT
	Declare @CategoryId INT
	Declare @ItemFamilyId INT
	Declare @ItemSubFamilyId INT
	Declare @ItemGroupId INT

	Select @CategoryGroupId = ISNULL(CategoryGroupId, 0) From CategoryGroups With (NOLOCK) WHERE CategoryGroupName = @CategoryGroup
	Select @CategoryId = ISNULL(CategoryId, 0) From Category With (NOLOCK) WHERE CategoryName = @Category
	Select @ItemFamilyId = ISNULL(ItemFamilyId, 0) From ItemFamily With (NOLOCK) WHERE ItemFamilyName = @ItemFamily
	Select @ItemSubFamilyId = ISNULL(ItemSubFamilyId, 0) From ItemSubFamily With (NOLOCK) WHERE ItemSubFamilyName = @ItemSubFamily
	Select @ItemGroupId = ISNULL(ItemGroupId, 0) From ItemGroup With (NOLOCK) WHERE ItemGroupName = @ItemGroup

	IF NOT EXISTS(SELECT TOP 1 1 FROM Product_Mappings WITH (NOLOCK) WHERE Product_Code = @Product_Code)
	BEGIN
		Insert Into Product_Mappings(Product_Code, ProductName, CategoryGroup, Category, ItemFamily, ItemSubFamily, ItemGroup)
		Select @Product_Code, @ProductName, @CategoryGroupId, @CategoryId, @ItemFamilyId, @ItemSubFamilyId, @ItemGroupId
	END
	ELSE
	BEGIN
		Update P
		SET 
			P.ProductName = @ProductName,
			P.CategoryGroup = @CategoryGroupId,
			P.Category = @CategoryId,
			P.ItemFamily = @ItemFamilyId,
			P.ItemSubFamily = @ItemSubFamilyId,
			P.ItemGroup = @ItemGroupId
		FROM Product_Mappings P WITH (NOLOCK) WHERE P.Product_Code = @Product_Code
	END
	IF EXISTS(SELECT TOP 1 1 FROM TransactionByDay WITH (NOLOCK) WHERE Product_Code = @Product_Code)
	BEGIN
		Update P
		SET 		
			P.CategoryGroup = dbo.fn_Arc_GetCategoryGroup(@CategoryGroupId), 
			P.Category = dbo.fn_Arc_GetCategory(@CategoryId), 
			P.ItemFamily = dbo.fn_Arc_GetItemFamily(@ItemFamilyId), 
			P.ItemSubFamily = dbo.fn_Arc_GetItemSubFamily(@ItemSubFamilyId), 
			P.ItemGroup = dbo.fn_Arc_GetItemGroup(@ItemGroupId)
		FROM TransactionByDay P WITH (NOLOCK) WHERE P.Product_Code = @Product_Code
	END
END
GO



