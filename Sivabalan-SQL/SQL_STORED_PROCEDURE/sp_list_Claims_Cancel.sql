CREATE PROCEDURE sp_list_Claims_Cancel (@VENDORID NVARCHAR(15), @FROMDATE DATETIME,
				@TODATE DATETIME)
AS
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, 
Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue
FROM ClaimsNote, Vendors
WHERE ClaimsNote.VendorID LIKE @VENDORID
AND ClaimsNote.VendorID = Vendors.VendorID
AND ClaimDate BETWEEN @FROMDATE AND @TODATE
AND ClaimsNote.Status & 192 = 0
AND Isnull(Status, 0) & 1 = 0 
And IsNull(ClaimRFA, 0) = 0
And ClaimType In(1,3)
union
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, 
Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue
FROM ClaimsNote, Vendors
WHERE ClaimsNote.VendorID LIKE @VENDORID
AND ClaimsNote.VendorID = Vendors.VendorID
AND ClaimDate BETWEEN @FROMDATE AND @TODATE
AND ClaimsNote.Status & 192 = 0
AND Isnull(Status, 0) & 1 = 0 
And IsNull(ClaimRFA, 0) = 0
And ClaimType In(2)
And ClaimID not in (select distinct claimID from DandDAbstract)
ORDER BY ClaimsNote.VendorID, ClaimsNote.ClaimDate
