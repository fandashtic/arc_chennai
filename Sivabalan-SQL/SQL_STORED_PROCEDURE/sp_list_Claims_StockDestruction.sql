CREATE PROCEDURE sp_list_Claims_StockDestruction(@VENDORID NVARCHAR(15), @FROMDATE DATETIME,          
    @TODATE DATETIME)          
AS          
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, Status,          
Balance, ClaimValue          
FROM ClaimsNote, Vendors          
WHERE ClaimsNote.VendorID LIKE @VENDORID          
AND ClaimsNote.VendorID = Vendors.VendorID          
AND ClaimDate BETWEEN @FROMDATE AND @TODATE          
AND Isnull(Status, 0) & 129 = 0         
AND ClaimType in (1)      
ORDER BY ClaimsNote.VendorID, ClaimsNote.ClaimDate   
