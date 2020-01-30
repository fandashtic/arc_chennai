CREATE PROCEDURE spr_list_Claims(@FROMDATE DATETIME, @TODATE DATETIME ,@CLAIMTYPE nvarchar(50))  
  
AS  

Declare @EXPIRED NVarchar(50)
Declare @DAMAGE NVarchar(50)
Declare @MISCELL NVarchar(50)
Declare @SCHEME NVarchar(50)
Declare @ADJUSTMENT NVarchar(50)
Declare @INVOICESCHEME NVarchar(50)
Declare @FREEREPL NVarchar(50)
Declare @PAYMENTADJ NVarchar(50)
Declare @CANCELLED NVarchar(50)
Declare @SETTLED NVarchar(50)
Declare @OPEN NVarchar(50)

Set @EXPIRED = dbo.LookupDictionaryItem(N'Expired', Default)
Set @DAMAGE = dbo.LookupDictionaryItem(N'Damaged', Default)
Set @MISCELL = dbo.LookupDictionaryItem(N'Miscellaneous', Default)
Set @SCHEME = dbo.LookupDictionaryItem(N'Schemes', Default)
Set @ADJUSTMENT = dbo.LookupDictionaryItem(N'Adjustments', Default)
Set @INVOICESCHEME = dbo.LookupDictionaryItem(N'Invoice Schemes', Default)
Set @FREEREPL = dbo.LookupDictionaryItem(N'Free Replacement', Default)
Set @PAYMENTADJ = dbo.LookupDictionaryItem(N'Payment Adjustment', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @SETTLED = dbo.LookupDictionaryItem(N'Settled', Default)
Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)

SELECT ClaimID As CID, "ClaimID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),   
	"Claim Date" = ClaimDate, "Claim Type" = case ClaimType  
	WHEN 1 THEN @EXPIRED
	WHEN 2 THEN @DAMAGE
	WHEN 3 THEN @MISCELL
	WHEN 4 then @SCHEME
	WHEN 5 THEN @ADJUSTMENT
	WHEN 6 THEN @INVOICESCHEME
	Else N''  
	END,  
	"VendorID" = ClaimsNote.VendorID, "Vendor Name" = Vendors.Vendor_Name,   
	"Value" = ClaimValue, "Balance" = IsNull(Balance, 0),   
	"Settlement Type" =   
	case SettlementType   
	When 1 then  
	@FREEREPL
	When 2 then  
	@PAYMENTADJ
	Else  
	N''  
	End,  
	"Settlement Date" = SettlementDate,  
	"Settlement Value" = SettlementValue, "Doc Ref" = DocumentReference,  
	"Status" = Case  
	When Status & 64 <> 0 then  
	@CANCELLED
	When Status & 128 <> 0 then  
	@SETTLED
	Else  
	@OPEN
	End,  
	"Remarks"  = Remarks  
	FROM ClaimsNote, Vendors, VoucherPrefix  
	WHERE ClaimDate BETWEEN @FROMDATE AND @TODATE  
	AND ClaimsNote.VendorID = Vendors.VendorID   
	And ClaimsNote.ClaimType & 15 =   
	(Case @ClaimType   
	When N'Expired' Then 1  
	When N'Damaged' Then 2  
	When N'Sampling' Then 3  
	--When N'Schemes' Then 4  
	--When N'Adjustments' Then 5  
	--When N'Invoice Schemes' Then 6
	Else ClaimsNote.ClaimType & 15  
	End)  
	AND VoucherPrefix.TranID = N'CLAIMS NOTE'  
	AND ClaimType In(1,2,3)
	ORDER BY ClaimDate, ClaimID, Vendors.Vendor_Name  

