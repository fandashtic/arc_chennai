
CREATE PROCEDURE sp_update_SpecialCategory(@CATEGORYID INT, @SCHEMEID INT)
AS
UPDATE Special_Category SET SchemeID = @SCHEMEID WHERE Special_Cat_Code = @CATEGORYID



