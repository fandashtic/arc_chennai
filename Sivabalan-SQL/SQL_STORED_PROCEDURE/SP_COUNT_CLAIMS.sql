CREATE PROCEDURE SP_COUNT_CLAIMS
AS
SELECT Count(*) FROM claimsnotereceived WHERE (IsNull(Status, 0) & 128) = 0  


