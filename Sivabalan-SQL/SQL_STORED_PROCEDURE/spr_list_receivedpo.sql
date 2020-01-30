Create PROCEDURE [dbo].[spr_list_receivedpo](@FROMDATE datetime,
				     @TODATE datetime)
AS

Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)

Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed', Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed', Default)

SELECT PONumber, "PONumber" = POPrefix + CAST(DocumentID AS nvarchar), "PO Date" = PODate, 
"Required Date" = RequiredDate, Customer.Company_Name, Value, 
"Status" = case Status & 128 WHEN 0 THEN @NOTPROCESSED ELSE @PROCESSED END,
"Billing Address" = POAbstractReceived.BillingAddress, 
"Shipping Address" = POAbstractReceived.ShippingAddress
FROM POAbstractReceived
Left Outer Join Customer on POAbstractReceived.CustomerID = Customer.CustomerID
WHERE PODate BETWEEN @FROMDATE AND @TODATE 
	--AND POAbstractReceived.CustomerID *= Customer.CustomerID
