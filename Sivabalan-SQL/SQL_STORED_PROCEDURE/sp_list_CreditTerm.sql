
CREATE PROCEDURE sp_list_CreditTerm(@CREDITID INT)

AS

SELECT Description, Type, Value, Active FROM CreditTerm 
WHERE CreditID = @CREDITID

