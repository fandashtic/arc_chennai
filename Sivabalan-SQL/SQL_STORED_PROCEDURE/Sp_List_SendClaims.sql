CREATE PROCEDURE Sp_List_SendClaims(@VENDORID NVARCHAR(15), @FROMDATE DATETIME,      
    @TODATE DATETIME,@STATUS INT)      
AS

Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)

SELECT ClaimID, ClaimDate, Status = CASE Status & 32 WHEN 32 THEN @SENT ELSE @NOTSENT END, Vendors.Vendor_Name,ClaimsNote.DocumentID,ClaimsNote.DocumentID, Status,      
Balance, ClaimValue      
FROM ClaimsNote, Vendors      
WHERE ClaimsNote.VendorID LIKE @VENDORID      
AND ClaimsNote.VendorID = Vendors.VendorID      
--AND IsNull(claimsnote.Status,0) & 32 = 0    
AND Status & 128 = 0 AND Status & @STATUS = 0   
AND ClaimDate BETWEEN @FROMDATE AND @TODATE      
ORDER BY ClaimsNote.VendorID, ClaimsNote.ClaimDate      
    


