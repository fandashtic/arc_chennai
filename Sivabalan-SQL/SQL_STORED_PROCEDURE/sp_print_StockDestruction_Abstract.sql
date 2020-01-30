CREATE Procedure sp_print_StockDestruction_Abstract (@StockDestroyID as integer)  
As  
Declare @EXPIRED As NVarchar(50)
Declare @DAMAGES As NVarchar(50)
Declare @SCHEMES As NVarchar(50)
Declare @MISCELLANEOUS As NVarchar(50)
Declare @ADJUSTMENT As NVarchar(50)

Set @EXPIRED = dbo.LookupDictionaryItem(N'Expired', Default)
Set @DAMAGES = dbo.LookupDictionaryItem(N'Damages', Default)
Set @SCHEMES = dbo.LookupDictionaryItem(N'Schemes', Default)
Set @MISCELLANEOUS = dbo.LookupDictionaryItem(N'Miscellaneous', Default)
Set @ADJUSTMENT = dbo.LookupDictionaryItem(N'Adjustment', Default)


Select "StockDestruction ID" = StockDestructionAbstract.DocumentID,"StockDestruction Date" = DocumentDate,"Claims Date" = ClaimsNote.ClaimDate, "Total Value" = ClaimsNote.ClaimValue, 
"ClaimsID" = StockDestructionAbstract.ClaimReference, "Vendor ID" = ClaimsNote.VendorID, "Vendor Name" = Vendors.Vendor_Name, "Document No" = ClaimsNote.DocumentReference,
"Claims Type" = Case ClaimsNote.ClaimType  
When 1 Then @EXPIRED 
When 2 Then @DAMAGES
When 3 Then @SCHEMES  
When 4 Then @MISCELLANEOUS
When 5 Then @ADJUSTMENT
End,
"TIN Number" = TIN_Number
from StockDestructionAbstract, ClaimsNote, Vendors  
Where StockDestructionAbstract.DocSerial = @StockDestroyID  
and ClaimsNote.VendorID = Vendors.VendorID  
and StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID  


