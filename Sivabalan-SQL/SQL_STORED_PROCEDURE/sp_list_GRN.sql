CREATE PROCEDURE sp_list_GRN(@VENDOR NVARCHAR(15), 
			     @FROMDATE DATETIME,
			     @TODATE DATETIME)

AS

SELECT GRNID, GRNDate, Vendors.Vendor_Name, GRNAbstract.VendorID, GRNStatus, DocumentID, 
DocumentReference,DocSerialType
FROM GRNAbstract, Vendors 
WHERE GRNAbstract.VendorID LIKE @VENDOR 
AND GRNAbstract.VendorID = Vendors.VendorID
AND GRNDate BETWEEN @FROMDATE AND @TODATE
ORDER BY Vendors.Vendor_Name, GRNDate, GRNID


