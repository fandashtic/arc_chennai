
CREATE PROCEDURE sp_Delete_SplItems(@CATEGORYID INT)

AS

DELETE FROM Special_Cat_Product WHERE Special_Cat_Code = @CATEGORYID

