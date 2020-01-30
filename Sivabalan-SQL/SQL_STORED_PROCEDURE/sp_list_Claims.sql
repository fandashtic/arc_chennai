
CREATE PROCEDURE sp_list_Claims(@VENDORID NVARCHAR(15), @FROMDATE DATETIME,
				@TODATE DATETIME)
AS
	SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, 
	Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue
	FROM ClaimsNote, Vendors
	WHERE ClaimsNote.VendorID LIKE @VENDORID
	AND ClaimsNote.VendorID = Vendors.VendorID
	AND ClaimDate BETWEEN @FROMDATE AND @TODATE
	AND ClaimType In (1,2,3)
	ORDER BY ClaimsNote.VendorID, ClaimsNote.ClaimDate

