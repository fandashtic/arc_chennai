
CREATE PROCEDURE sp_consolidate_Claim_abstract(@CLIENT_ID int,
					       @CLAIMSID int,
  					       @CLAIMDATE datetime,
					       @CREATIONDATE datetime,
					       @VENDOR_ID nvarchar(15),
					       @CLAIMTYPE int,
					       @STATUS int,
					       @DocumentID int,
					       @ClaimValue Decimal(18,6),
					       @SettlementType int,
					       @SettlementValue Decimal(18,6),
					       @DocumentReference nvarchar(50))
AS
DECLARE @OLD_ID int
DECLARE @VENDORID nvarchar(15)
SELECT @VENDORID = VendorID FROM Vendors WHERE AlternateCode = @VENDOR_ID
UPDATE ClaimsNote SET ClaimDate = @CLAIMDATE, CreationDate = @CREATIONDATE, VendorID = @VENDORID, 
ClaimType = @CLAIMTYPE, Status = @STATUS, DocumentID = @DocumentID,
ClaimValue = @ClaimValue, SettlementType = @SettlementType,
SettlementValue = @SettlementValue, DocumentReference = @DocumentReference
WHERE OriginalClaim = @CLAIMSID AND Client_ID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO ClaimsNote (OriginalClaim, ClaimDate, CreationDate, VendorID, ClaimType,
	Status, DocumentID, ClaimValue, SettlementType, SettlementValue, DocumentReference)
	VALUES(@CLAIMSID, @CLAIMDATE, @CREATIONDATE, @VENDORID, @CLAIMTYPE, @STATUS,
	@DocumentID, @ClaimValue, @SettlementType, @SettlementValue, @DocumentReference)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = ClaimID FROM ClaimsNote WHERE OriginalClaim = @CLAIMSID
	Delete ClaimsDetail WHERE ClaimID = @OLD_ID
	SELECT @OLD_ID 
END

