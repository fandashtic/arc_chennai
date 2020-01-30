CREATE PROCEDURE sp_view_received_POAbstract(@PONo INT)
AS
Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)

Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed', Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed', Default)

SELECT PODate, RequiredDate, Customer.Company_Name, Value,
POAbstractReceived.BillingAddress, POAbstractReceived.ShippingAddress, 
N'', N'', 
POPrefix + CAST(POReference AS nvarchar), 
POPrefix + CAST(DocumentID AS nvarchar), 
CASE (POAbstractReceived.Status & 128)
WHEN 128 THEN
@PROCESSED
WHEN 0 THEN
@NOTPROCESSED
ELSE
@NOTPROCESSED
END,N'' DocRef, 
"Total Quantity" = Isnull((Select Sum(PODetailReceived.Quantity) from PODetailReceived Where PONumber = @PoNo),0)  
FROM POAbstractReceived, Customer
WHERE POAbstractReceived.PONumber = @PONo 
AND POAbstractReceived.CustomerID = Customer.CustomerID


