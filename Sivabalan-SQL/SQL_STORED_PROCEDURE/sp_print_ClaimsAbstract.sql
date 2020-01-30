CREATE PROCEDURE sp_print_ClaimsAbstract(@CLAIMID INT)
AS
SELECT "Vendor" = Vendors.Vendor_Name, "VendorID" = ClaimsNote.VendorID,  
"Claim Date" = ClaimDate, "Address" = Address, 
"Claim No" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar), 
"Claim Type" = ClaimType,
"TIN Number" = TIN_Number,
"Claim Value" = ClaimValue
FROM Vendors, ClaimsNote, VoucherPrefix
WHERE ClaimsNote.ClaimID = @CLAIMID 
AND ClaimsNote.VendorID = Vendors.VendorID
AND VoucherPrefix.TranID = 'CLAIMS NOTE'


