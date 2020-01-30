CREATE FUNCTION fn_NLevelCategory(@CategoryID INT,@Level integer)  
RETURNS nVARCHAR(100)  
AS  
BEGIN  
	DECLARE @ParentId As Int  
	DECLARE @CatDesc As nVarchar(100)  
	Declare @CurLevel As integer   
    
 	select @ParentId = Parentid, @CatDesc = Category_Name,@CurLevel=Level from Itemcategories where Categoryid = @CategoryId  
	while @ParentId <> 0   
	BEGIN   
		If(@Level<>0)  
			IF(@Level=@Curlevel) Select @parentID=0    
		SELECT @CatDesc = Category_Name, @ParentId = ParentID,@CurLevel=Level FROM ItemCategories   
		WHERE CategoryID = @ParentId   
	END  
RETURN(@CatDesc)  
END  

