
CREATE procedure sp_export_po(@PONUMBER int, @CUSTOMER nvarchar(15))
AS
DECLARE @NEW_PO int
INSERT INTO POAbstractReceived(PODate, CustomerID, RequiredDate, Value, BillingAddress, ShippingAddress, Status, POReference) 
SELECT PODate, @CUSTOMER, RequiredDate, Value, BillingAddress, ShippingAddress, 0, PONumber FROM POAbstract WHERE PONumber = @PONUMBER

SELECT @NEW_PO = @@IDENTITY

insert into PODetailReceived(PONumber, Product_Code, Quantity, PurchasePrice)
SELECT @NEW_PO, Product_Code, Quantity, PurchasePrice FROM PODetail WHERE PONumber = @PONUMBER





