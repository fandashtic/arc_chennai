CREATE PROCEDURE SP_GET_RECCOLLECTIONS
AS      
SELECT "CollectionID" = Coll.FullDocID, "CollectionDate" = Coll.DocumentDate, "DocSerial" = Coll.DocSerial, CUS.Company_Name,
CUS.CustomerID, Coll.Value, GETDATE(), NULL, Coll.FullDocID
FROM CollectionsReceived Coll, Customer CUS
WHERE Coll.CustomerID = CUS.CustomerID
AND (IsNull(Coll.Status, 0) & 128) = 0      
ORDER BY "CollectionDate"   
 

