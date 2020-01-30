CREATE PROCEDURE spr_list_Claims_by_Vendor(@VENDORID nvarchar(4000),    
        @FROMDATE DATETIME,     
        @TODATE DATETIME)    
    
AS    
    
Declare @EXPIRED NVarchar(50)    
Declare @BREAKAGE NVarchar(50)    
Declare @MISCELL NVarchar(50)    
Declare @SCHEME NVarchar(50)    
Declare @ADJUSTMENT NVarchar(50)    
Declare @INVOICESCHEME NVarchar(50)    
Declare @FREEREPL NVarchar(50)    
Declare @PAYMENTADJ NVarchar(50)    
    
    
Set @EXPIRED = dbo.LookupDictionaryItem(N'Expired', Default)    
Set @BREAKAGE = dbo.LookupDictionaryItem(N'Breakage', Default)    
Set @MISCELL = dbo.LookupDictionaryItem(N'Miscellaneous', Default)    
Set @SCHEME = dbo.LookupDictionaryItem(N'Schemes', Default)    
Set @ADJUSTMENT = dbo.LookupDictionaryItem(N'Adjustment', Default)    
Set @INVOICESCHEME = dbo.LookupDictionaryItem(N'Invoice Schemes', Default)    
Set @FREEREPL = dbo.LookupDictionaryItem(N'Free Replacement', Default)    
Set @PAYMENTADJ = dbo.LookupDictionaryItem(N'Payment Adjustment', Default)    
    
    
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create Table #TmpVendor (Vendor nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
If @VENDORID = N'%'    
 Insert Into #TmpVendor Select Vendor_Name From Vendors    
Else    
 Insert Into #TmpVendor Select * From DBO.sp_SplitIn2Rows(@VENDORID,@Delimeter)    
    
SELECT ClaimID, "Claim ID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),     
"Claim Date" = ClaimDate, "Claim Type" = CASE ClaimType    
WHEN 1 THEN @EXPIRED    
WHEN 2 THEN @BREAKAGE    
WHEN 3 THEN @MISCELL    
WHEN 4 then @SCHEME    
WHEN 6 THEN @INVOICESCHEME    
When 5 Then @ADJUSTMENT    
Else N''    
END, "VendorID" = ClaimsNote.VendorID,     
"Vendor Name" = Vendors.Vendor_Name,     
"Value" = ClaimValue, "Settlement Type" =     
case SettlementType    
When 1 then    
@FREEREPL    
When 2 then    
@PAYMENTADJ    
Else    
N''    
End,    
"Settlement Date" = SettlementDate,    
"Settlement Value" = SettlementValue, "Doc Ref" = DocumentReference    
FROM ClaimsNote, Vendors, VoucherPrefix    
WHERE ClaimDate BETWEEN @FROMDATE AND @TODATE    
AND ClaimsNote.VendorID = Vendors.VendorID    
AND Vendors.Vendor_Name In (Select Vendor COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpVendor)    
AND VoucherPrefix.TranID = N'CLAIMS NOTE'    
AND (Isnull(Status, 0) & 192) <> 192
ORDER BY ClaimDate, ClaimID, Vendors.Vendor_Name    
    
Drop Table #TmpVendor   

