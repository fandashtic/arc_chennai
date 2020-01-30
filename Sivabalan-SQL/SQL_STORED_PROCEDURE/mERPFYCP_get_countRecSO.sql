CREATE PROCEDURE mERPFYCP_get_countRecSO ( @yearenddate datetime )
AS
SELECT count(*) FROM SOAbstractReceived WHERE Status = 0 and sodate <= @yearenddate
