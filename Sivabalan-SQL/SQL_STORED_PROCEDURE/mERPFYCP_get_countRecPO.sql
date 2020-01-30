CREATE PROCEDURE mERPFYCP_get_countRecPO ( @yearenddate datetime )
AS
SELECT count(*) FROM POAbstractReceived WHERE Status = 0 and podate <= @yearenddate 
