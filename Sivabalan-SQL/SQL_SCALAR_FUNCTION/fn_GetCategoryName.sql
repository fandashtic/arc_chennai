
CREATE FUNCTION fn_GetCategoryName(@CategoryID int)  
RETURNS nVARCHAR(100)  
AS  
BEGIN  
	DECLARE @CatDesc As nVarchar(100)  
	Select @CatDesc = Category_Name From ItemCategories Where CategoryID = @CategoryID
	RETURN(@CatDesc)  
END  


