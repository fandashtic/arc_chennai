
CREATE PROCEDURE sp_list_PODocs(@VENDORID NVARCHAR(15), @FROMDATE DATETIME,
@TODATE DATETIME, @STATUS INT)

AS

Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)
SELECT PONumber, PODate, 
Status = CASE Status & 32 WHEN 32 THEN @SENT ELSE @NOTSENT END,
Vendors.Vendor_Name, POAbstract.VendorID, POAbstract.DocumentID
FROM POAbstract, Vendors 
WHERE POAbstract.VendorID LIKE @VENDORID 
AND Status & 128 = 0 AND Status & @STATUS = 0 
AND (PODate BETWEEN @FROMDATE AND @TODATE)
AND POAbstract.VendorID = Vendors.VendorID
ORDER BY Vendors.Vendor_Name, PODate

