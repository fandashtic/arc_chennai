
CREATE PROCEDURE sp_insert_item_properties(@ITEM_CODE nvarchar(15),
					   @PROPERTYID int,
					   @VALUE nvarchar(255))
AS
INSERT INTO Item_Properties(Product_Code, PropertyID, Value)
VALUES(@ITEM_CODE, @PROPERTYID, @VALUE)


