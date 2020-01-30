
Create Procedure sp_insert_DefineSchemeItem
                 (@SCHEMEID INT,
                  @PRODUCT_CODE NVARCHAR (15))
AS
INSERT ItemSchemes
                  (SchemeId,
                   Product_Code)
Values
                  (@SCHEMEID,
                   @PRODUCT_CODE)


