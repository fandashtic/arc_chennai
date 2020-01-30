CREATE PROCEDURE SP_SER_INSERT_PERSONNELITEM
(
@PersonnelID nvarchar(50),
@CategoryID int,
@ProductCode nvarchar(15))
AS
INSERT INTO Personnel_Item_Category
(PersonnelId,CategoryId,Product_code)
VALUES
(@PersonnelID, 
 @CategoryID, 
 @ProductCode)

