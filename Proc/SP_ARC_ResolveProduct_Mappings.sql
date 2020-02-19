--Exec SP_ARC_ResolveProduct_Mappings
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_ResolveProduct_Mappings')
BEGIN
    DROP PROC SP_ARC_ResolveProduct_Mappings
END
GO
CREATE PROCEDURE [dbo].SP_ARC_ResolveProduct_Mappings
AS
BEGIN
	--select * FROM V_ARC_Items With (NOLOCK)
	select * into #V_ARC_Items FROM V_ARC_Items With (NOLOCK) 

	Delete T FROM  Product_Mappings T With (NOLOCK) WHERE ISNULL(ItemFamily, 0) = 0
	--select * from #V_ARC_Items

	select I.Product_Code,
	ProductName = I.ProductName,
	CategoryGroup = (select Top 1 CategoryGroup FROM #V_ARC_Items WHERE Division = T.Division),
	Category = (select Top 1 Category FROM #V_ARC_Items WHERE Division = T.Division),
	ItemFamily = (select Top 1 ItemFamily FROM #V_ARC_Items WHERE Division = T.Division),
	ItemSubFamily = (select Top 1 ItemSubFamily FROM #V_ARC_Items WHERE Division = T.Division), 
	--ItemGroup = (select Top 1 ItemGroup FROM #V_ARC_Items WHERE Division = T.Division),
	T.Division
	INTO #Temp
	from Items I With (NOLOCK)
	JOIN #V_ARC_Items T With (NOLOCK) ON T.Product_Code = I.Product_Code
	WHERE I.Product_Code NOT IN (select Distinct Product_Code from Product_Mappings With (NOLOCK))

	Insert into Category(CategoryName)
	select Distinct Division from #V_ARC_Items where Division not in (select CategoryName from Category)

	DECLARE @ID INT
	DECLARE @Product_Code NVARCHAR(255)
	DECLARE @ProductName NVARCHAR(255)
	DECLARE @CategoryGroup NVARCHAR(255)
	DECLARE @Category NVARCHAR(255)
	DECLARE @ItemFamily NVARCHAR(255)
	DECLARE @ItemSubFamily NVARCHAR(255)
	DECLARE @ItemGroup NVARCHAR(255)
	SET @ID = 1

	WHILE (@ID <= (SELECT COUNT(Product_Code) FROM #Temp With (NOLOCK)))
	BEGIN
		SELECT TOP 1 @Product_Code = Product_Code, @ProductName = ProductName, @CategoryGroup = CategoryGroup, @Category = Category, @ItemFamily = ItemFamily, @ItemSubFamily = ItemSubFamily
		--, @ItemGroup = ItemGroup
		FROM #Temp
		PRINT @ItemFamily
		Exec dbo.ARC_Product_Mappings_Update @Product_Code, @ProductName, @CategoryGroup, @Category, @ItemFamily, @ItemSubFamily, @ItemGroup
		DELETE FROM #Temp WHERE Product_Code = @Product_Code
	END

	Drop table #V_ARC_Items
	Drop table #Temp
END
GO
