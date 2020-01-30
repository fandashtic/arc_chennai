
CREATE PROCEDURE sp_get_recpos_DocLU (@DocIDFrom int, @DocIDTo int)

AS

SELECT Customer.CustomerID, Customer.Company_Name, PONumber, PODate, Value, 
POReference, DocumentID, RequiredDate, POPrefix, Status 
FROM POAbstractReceived, Customer
WHERE	POAbstractReceived.DocumentID BETWEEN @DocIDFrom AND @DocIDTo AND
	POAbstractReceived.CustomerID = Customer.CustomerID
ORDER BY Customer.Company_Name, POAbstractReceived.PODate

