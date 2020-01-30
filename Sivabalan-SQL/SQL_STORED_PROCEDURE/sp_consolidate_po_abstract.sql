
CREATE PROCEDURE sp_consolidate_po_abstract(@CLIENT_ID int,
						     @PONUMBER int,
						     @PODATE datetime,
						     @REQUIRED_DATE datetime,
						     @CREATION_TIME datetime,
						     @VENDORID nvarchar(20),
						     @VALUE Decimal(18,6),
						     @BILLING_ADDRESS nvarchar(255),
						     @SHIPPING_ADDRESS nvarchar(255),
						     @CREDIT_TERM int,
						     @PO_REFERENCE int, 
						     @DocumentID int,
						     @DocumentReference int,
						     @STATUS int,
						     @NEWGRNID int,
						     @REMARKS nvarchar(255))
AS
DECLARE @VENDOR_ID nvarchar(15)

SELECT @VENDOR_ID = VendorID FROM Vendors WHERE AlternateCode = @VENDORID
UPDATE  POAbstract SET PODate = @PODATE, RequiredDate = @REQUIRED_DATE, 
CreationTime = @CREATION_TIME, VendorID = @VENDOR_ID, Value = @VALUE, 
BillingAddress = @BILLING_ADDRESS, ShippingAddress = @SHIPPING_ADDRESS, 
CreditTerm = @CREDIT_TERM, POReference = @PO_REFERENCE, DocumentID = @DocumentID, 
DocumentReference = @DocumentReference, Status = @STATUS, NewGRNID = @NEWGRNID, 
Remarks = @Remarks
WHERE OriginalPO = @PONUMBER AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO POAbstract(OriginalPO, PODate, RequiredDate, CreationTime, ClientID, 
	VendorID, Value, BillingAddress, ShippingAddress, CreditTerm, POReference, 
	DocumentID, DocumentReference, Status, NewGRNID, Remarks)
	VALUES(@PONUMBER, @PODATE, @REQUIRED_DATE, @CREATION_TIME, @CLIENT_ID, 
	@VENDOR_ID, @VALUE, @BILLING_ADDRESS, @SHIPPING_ADDRESS, @CREDIT_TERM, 
	@PO_REFERENCE, @DocumentID, @DocumentReference, @STATUS, @NEWGRNID, @REMARKS)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT PONumber FROM POAbstract WHERE OriginalPO = @PONUMBER
END

