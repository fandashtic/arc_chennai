
Create Procedure sp_update_DefineSchemeItem
                 (@SCHEMEID INT,
                  @PRODUCT_CODE NVARCHAR (15),
                  @OLDSCHEMEID INT)

AS Update [ItemSchemes] 
SET SchemeID=@SCHEMEID where Product_Code=@PRODUCT_CODE and SchemeID=@OLDSCHEMEID


