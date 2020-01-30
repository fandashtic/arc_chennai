CREATE PROCEDURE sp_list_Claims_DocLU (@FromDocID int, @ToDocID int)
AS
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, 
Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue
FROM ClaimsNote, Vendors
WHERE ClaimsNote.VendorID = Vendors.VendorID
AND DocumentID BETWEEN @FromDocID AND @ToDocID
ORDER BY ClaimsNote.VendorID, ClaimsNote.ClaimDate
