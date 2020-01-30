
CREATE PROCEDURE sp_Save_DefineSchemeItems_ex
        (	@Product_Code  NVARCHAR (15),  
		@OldProduct_Code nvarchar(15),
		@SchemeID  INT,  
	        @OLDSCHEMEID INT)  
AS  
IF EXISTS (SELECT TOP 1 product_Code FROM ItemSchemes WHERE 
	Product_Code = @OldProduct_Code and schemeID=@OLDSCHEMEID)  
 BEGIN  
	Update [ItemSchemes] 
	SET SchemeID=@SCHEMEID , Product_code = @Product_code where 
	Product_Code=@OLDPRODUCT_CODE and SchemeID=@OLDSCHEMEID
 END  
ELSE  
 BEGIN  
 EXEC sp_insert_DefineSchemeItem @SCHEMEID,@PRODUCT_CODE  
 END  


