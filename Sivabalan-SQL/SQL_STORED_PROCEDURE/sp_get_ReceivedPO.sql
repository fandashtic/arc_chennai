
CREATE PROCEDURE sp_get_ReceivedPO(@PONUMBER INT)

AS

SELECT PODate, Customer.Company_Name, RequiredDate, Value, 
POAbstractReceived.BillingAddress, POAbstractReceived.ShippingAddress,
POReference, POAbstractReceived.CustomerID, DocumentID, POPrefix 
FROM POAbstractReceived, Customer
WHERE PONumber = @PONUMBER 
AND POAbstractReceived.CustomerID = Customer.CustomerID AND POAbstractReceived.Status  = 0


