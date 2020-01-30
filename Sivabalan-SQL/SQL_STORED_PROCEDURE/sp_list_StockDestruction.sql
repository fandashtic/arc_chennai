CREATE PROCEDURE sp_list_StockDestruction(@VENDORID NVARCHAR(15), @FROMDATE DATETIME,          
    @TODATE DATETIME)          
AS          
SELECT DocSerial, StockDestructionAbstract.DocumentDate, ClaimsNote.VendorID, Vendors.Vendor_Name, StockDestructionAbstract.DocumentID,
ClaimsNote.DocumentID, ClaimsNote.ClaimID, ClaimsNote.ClaimDate
FROM StockDestructionAbstract, Vendors, ClaimsNote          
WHERE ClaimsNote.VendorID LIKE @VENDORID          
AND ClaimsNote.VendorID = Vendors.VendorID          
AND StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
AND StockDestructionAbstract.DocumentDate BETWEEN @FROMDATE AND @TODATE          
AND ClaimType in (1,2)      
ORDER BY ClaimsNote.VendorID, StockDestructionAbstract.CreationDate    



