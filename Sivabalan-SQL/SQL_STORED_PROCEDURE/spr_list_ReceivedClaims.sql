Create Procedure spr_list_ReceivedClaims(@FROMDATE DATETIME, @TODATE DATETIME)
as

Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @EXPIRED As NVarchar(50)
Declare @DAMAGES As NVarchar(50)
Declare @SCHEMES As NVarchar(50)
Declare @MISCELLANEOUS As NVarchar(50)
Declare @ADJUSTMENTS As NVarchar(50)

Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed', Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @EXPIRED = dbo.LookupDictionaryItem(N'Expired', Default)
Set @DAMAGES = dbo.LookupDictionaryItem(N'Damages', Default)
Set @SCHEMES = dbo.LookupDictionaryItem(N'Schemes', Default)
Set @MISCELLANEOUS = dbo.LookupDictionaryItem(N'Miscellaneous', Default)
Set @ADJUSTMENTS = dbo.LookupDictionaryItem(N'Adjustments', Default)

Select ClaimsNoteReceived.DocSerial,
"Claim Id"=ClaimsNoteReceived.ClaimId,
"Claim Date"=ClaimsNoteReceived.ClaimDate,
"Claim Type"=Case ClaimsNoteReceived.ClaimType
	When 1 then @EXPIRED
	When 2 then @DAMAGES
	When 3 then @SCHEMES
	When 4 then @MISCELLANEOUS
	When 5 then @ADJUSTMENTS
	Else N''	End,
"Customer ID"=Customer.CustomerId,
"Customer Name"=Customer.Company_Name,
"Value"=Isnull(ClaimsNoteReceived.ClaimValue,0),
"Doc Ref"=ClaimsNoteReceived.DocReference,
"Status" = Case 
When Isnull(Status,0) & 64 <> 0 then
@CANCELLED
When Isnull(Status,0) & 128 <> 0 then
@PROCESSED
Else
@NOTPROCESSED
End
From ClaimsNoteReceived,Customer
Where ClaimsNoteReceived.CustomerId=Customer.CustomerID
and ClaimsNoteReceived.ClaimDate between @fromdate and @todate



