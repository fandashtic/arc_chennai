
CREATE PROCEDURE sp_get_ItemsForUpload(@CATEGORYID INT)
AS
SELECT Product_Code, ProductName FROM Items 
WHERE CategoryID = @CATEGORYID

