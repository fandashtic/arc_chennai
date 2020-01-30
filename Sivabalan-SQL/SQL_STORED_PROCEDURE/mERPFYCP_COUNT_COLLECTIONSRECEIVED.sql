CREATE PROCEDURE mERPFYCP_COUNT_COLLECTIONSRECEIVED ( @yearenddate datetime )
AS
SELECT Count(*) FROM CollectionsReceived WHERE (IsNull(Status, 0) & 128) = 0 and DocumentDate <= @yearenddate
