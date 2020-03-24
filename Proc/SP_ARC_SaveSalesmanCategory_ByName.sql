--EXEC SP_ARC_SaveSalesmanCategory_ByName @SalesManId = 0, @SalesmanCategoryName = ''
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_SaveSalesmanCategory_ByName')
BEGIN
    DROP PROC SP_ARC_SaveSalesmanCategory_ByName
END
GO
Create Proc SP_ARC_SaveSalesmanCategory_ByName(@SalesManId int, @SalesmanCategoryName Nvarchar(255))  
AS  
BEGIN 
	Declare @SalesmanCategoryId AS INT

	SET @SalesmanCategoryId = (select TOP 1 SalesmanCategoryId from SalesmanCategory WITH (NOLOCK) WHERE LOWER(SalesmanCategoryName) = LOWER(@SalesmanCategoryName))

	IF(ISNULL(@SalesmanCategoryId, 0) > 0 AND ISNULL(@SalesManId, 0) > 0)
	BEGIN		
		UPDATE Salesman SET SalesmanCategoryId = @SalesmanCategoryId WHERE SalesManId = @SalesManId
	END
END
GO
