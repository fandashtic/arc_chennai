
CREATE PROCEDURE sp_consolidate_dispatch_abstract(@CLIENT_ID int,
					    @DISPATCH_ID int,
					    @DISPATCH_DATE datetime,
					    @CREATION_TIME datetime,
					    @CUSTOMERID nvarchar(15),
					    @BILLING_ADDRESS nvarchar(255),
					    @SHIPPING_ADDRESS nvarchar(255),
					    @REF_NUMBER nvarchar(50),
					    @NEW_REF_NUMBER nvarchar(255),
					    @STATUS int,
					    @DOCUMENT_ID int,
					    @NEW_INVOICE_ID int)
AS
DECLARE @OLD_ID int
DECLARE @CUSTOMER_ID nvarchar(15)

SELECT @CUSTOMER_ID = CustomerID FROM Customer WHERE AlternateCode = @CUSTOMERID
UPDATE  DispatchAbstract SET DispatchDate = @DISPATCH_DATE, CreationTime = @CREATION_TIME,
	CustomerID = @CUSTOMER_ID, BillingAddress = @BILLING_ADDRESS, ShippingAddress = @SHIPPING_ADDRESS, 
	Status = @STATUS, RefNumber = @REF_NUMBER, NewRefNumber = @NEW_REF_NUMBER, 
	DocumentID = @DOCUMENT_ID, NewInvoiceID = @NEW_INVOICE_ID
WHERE   OriginalDispatch = @DISPATCH_ID AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO DispatchAbstract(OriginalDispatch, DispatchDate, CreationTime, ClientID, CustomerID, BillingAddress, ShippingAddress, Status, RefNumber, NewRefNumber, DocumentID, NewInvoiceID)
	VALUES(@DISPATCH_ID, @DISPATCH_DATE, @CREATION_TIME, @CLIENT_ID, @CUSTOMER_ID, @BILLING_ADDRESS, @SHIPPING_ADDRESS, @STATUS, @REF_NUMBER, @NEW_REF_NUMBER, @DOCUMENT_ID, @NEW_INVOICE_ID)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = DispatchID FROM DispatchAbstract WHERE OriginalDispatch = @DISPATCH_ID
	Delete DispatchDetail WHERE DispatchID = @OLD_ID
	SELECT @OLD_ID
END

