
CREATE PROCEDURE sp_update_SplCategory(@CATID INT, @ACTIVE INT)

AS

UPDATE Special_Category SET Active = @ACTIVE WHERE Special_Cat_Code = @CATID

