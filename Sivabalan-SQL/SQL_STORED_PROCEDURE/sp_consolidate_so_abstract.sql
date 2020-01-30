
CREATE PROCEDURE sp_consolidate_so_abstract(@CLIENT_ID int,
					    @SONUMBER int,
					    @SODATE datetime,
					    @DELIVERY_DATE datetime,
					    @CREATION_TIME datetime,
					    @CUSTOMERID nvarchar(15),
					    @VALUE Decimal(18,6),
					    @BILLING_ADDRESS nvarchar(255),
					    @SHIPPING_ADDRESS nvarchar(255),
					    @CREDIT_TERM nvarchar(50),
					    @PO_REFERENCE nvarchar(255),
					    @REF_NUMBER nvarchar(255),
					    @DocumentID int,
					    @PODocReference nvarchar(255),
					    @STATUS int,
					    @REMARKS nvarchar(255),
					    @SALESMAN nvarchar(255))
AS
DECLARE @CREDIT_ID int
DECLARE @OLD_ID int
DECLARE @CUSTOMER_ID nvarchar(15)
DECLARE @SALESMANID int

SELECT @CUSTOMER_ID = CustomerID FROM Customer WHERE AlternateCode = @CUSTOMERID
SELECT @CREDIT_ID = CreditID FROM CreditTerm WHERE Description = @CREDIT_TERM
SELECT @SALESMANID = SalesmanID FROM Salesman WHERE Salesman_Name = @SALESMAN
UPDATE  SOAbstract SET SODate = @SODATE, DeliveryDate = @DELIVERY_DATE, 
CreationTime = @CREATION_TIME, CustomerID = @CUSTOMER_ID, Value = @VALUE, 
BillingAddress = @BILLING_ADDRESS, ShippingAddress = @SHIPPING_ADDRESS, 
CreditTerm = @CREDIT_ID, POReference = @PO_REFERENCE, RefNumber = @REF_NUMBER, 
DocumentID = @DocumentID, PODocReference = @PODocReference, Status = @STATUS, 
Remarks = @REMARKS, SalesmanID = @SALESMANID
WHERE   OriginalSO = @SONUMBER AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO SOAbstract(OriginalSO, SODate, DeliveryDate, CreationTime, ClientID, 
	CustomerID, Value, BillingAddress, ShippingAddress, CreditTerm, POReference, 
	RefNumber, DocumentID, PODocReference, Status, Remarks, SalesmanID)
	VALUES(@SONUMBER, @SODATE, @DELIVERY_DATE, @CREATION_TIME, @CLIENT_ID, @CUSTOMER_ID, 
	@VALUE, @BILLING_ADDRESS, @SHIPPING_ADDRESS, @CREDIT_ID, @PO_REFERENCE, @REF_NUMBER, 
	@DocumentID, @PODocReference, @STATUS, @REMARKS, @SALESMANID)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = SONumber FROM SOAbstract WHERE OriginalSO = @SONUMBER
	Delete SODetail WHERE SONumber = @OLD_ID
	SELECT @OLD_ID
END

