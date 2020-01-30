
CREATE PROCEDURE sp_Save_DefineSchemeItems 
        (@SchemeID 	INT,
	 @Product_Code 	NVARCHAR (15),
         @OLDSCHEMEID INT)
AS
IF EXISTS (SELECT TOP 1 product_Code FROM ItemSchemes WHERE Product_Code = @Product_Code and schemeID=@OLDSCHEMEID)
	BEGIN
	EXEC sp_update_DefineSchemeItem @SCHEMEID,@PRODUCT_CODE,@OLDSCHEMEID
	END
ELSE
	BEGIN
	EXEC sp_insert_DefineSchemeItem @SCHEMEID,@PRODUCT_CODE
	END


