
CREATE PROCEDURE sp_consolidate_grn_abstract(@CLIENT_ID int,
					    @GRN_ID int,
					    @GRN_DATE datetime,
					    @CREATION_TIME datetime,
					    @VENDORID nvarchar(20),
					    @GRN_STATUS int,
					    @DOCUMENT_ID int,
					    @PONumbers nvarchar(255),
					    @NewBillID int)
AS
DECLARE @OLD_ID int
DECLARE @VENDOR_ID nvarchar(15)

SELECT @VENDOR_ID = VendorID FROM Vendors WHERE AlternateCode = @VENDORID 
Or VendorID = @VENDORID
UPDATE  GRNAbstract SET GRNDate = @GRN_DATE, CreationTime = @CREATION_TIME,
	VendorID = @VENDOR_ID, GRNStatus = @GRN_STATUS, DocumentID = @DOCUMENT_ID, PONumbers = @PONumbers, NewBillID = @NewBillID
WHERE   OriginalGRN = @GRN_ID AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO GRNAbstract(OriginalGRN, GRNDate, CreationTime, ClientID, VendorID, GRNStatus, DocumentID, PONumbers, NewBillID)
	VALUES(@GRN_ID, @GRN_DATE, @CREATION_TIME, @CLIENT_ID, @VENDOR_ID, @GRN_STATUS, @DOCUMENT_ID, @PONumbers, @NewBillID)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = GRNID FROM GRNAbstract WHERE OriginalGRN = @GRN_ID
	Delete GRNDetail WHERE GRNID = @OLD_ID
	SELECT @OLD_ID
END

