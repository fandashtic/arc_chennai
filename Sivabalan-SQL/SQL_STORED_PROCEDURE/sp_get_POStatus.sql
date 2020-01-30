
CREATE PROCEDURE sp_get_POStatus(@PONUMBER INT)

AS

SELECT PODate, VendorID, RequiredDate, Value, BillingAddress, ShippingAddress,
Status, CreditTerm FROM POAbstract WHERE PONumber = @PONUMBER

