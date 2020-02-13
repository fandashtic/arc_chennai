--select dbo.fn_Arc_GetSalesmanCategory(5)
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetSalesmanCategory')
BEGIN
    DROP FUNCTION [fn_Arc_GetSalesmanCategory]
END
GO
CREATE  FUNCTION fn_Arc_GetSalesmanCategory(@SalesmanId Int)    
RETURNS NVarchar(255)    
As    
Begin    
	Declare @SalesmanCategoryName as Nvarchar(255)
	Set @SalesmanCategoryName = (select Top 1 SalesmanCategoryName from SalesmanCategory Where SalesmanCategoryId = (select SalesmanCategoryId FROM Salesman WITH (NOLOCK) Where SalesmanID = @SalesmanId))
	RETURN ISNULL(@SalesmanCategoryName , '--')   
End    
GO