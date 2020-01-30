
CREATE PROCEDURE sp_get_RecPOInfo
AS
SELECT PONumber, PODate, POReference, Customer.Company_Name,
POAbstractReceived.CustomerID, Value, CreationTime, DocumentID, POPrefix
FROM POAbstractReceived, Customer
WHERE Status = 0 
AND POAbstractReceived.CustomerID = Customer.CustomerID
ORDER BY Customer.Company_Name, PODate

