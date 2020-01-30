
CREATE PROCEDURE sp_get_recpos(	@CUSTOMER NVARCHAR(15),
				@FROMDATE DATETIME,
				@TODATE DATETIME)

AS

SELECT Customer.CustomerID, Customer.Company_Name, PONumber, PODate, Value, POReference, DocumentID,
RequiredDate, POPrefix, Status FROM POAbstractReceived, Customer
WHERE 	POAbstractReceived.CustomerID LIKE @CUSTOMER AND
	POAbstractReceived.PODate BETWEEN @FROMDATE AND @TODATE AND
	POAbstractReceived.CustomerID = Customer.CustomerID
ORDER BY Customer.Company_Name, POAbstractReceived.PODate




