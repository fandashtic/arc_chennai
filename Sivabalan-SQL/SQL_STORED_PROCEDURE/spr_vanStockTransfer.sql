CREATE procedure spr_vanStockTransfer (@FromDate Datetime, @ToDate DateTime)
as
Declare @MLGodowntoVan NVarchar(50)
Declare @MLVantoVan NVarchar(50)
Declare @MLVantoGodown NVarchar(50)
Set @MLGodowntoVan = dbo.LookupDictionaryItem(N'Godown to Van', Default)
Set @MLVantoVan = dbo.LookupDictionaryItem(N'Van to Van', Default)
Set @MLVantoGodown = dbo.LookupDictionaryItem(N'Van to Godown', Default)

select DocSerial,"DocumentID" = docprefix + cast(documentid as nvarchar),
"DocumentReference" = DocumentReference,"DocumentDate" = DocumentDate,
"Transfer Type" = case TransferType when 0 then @MLGodowntoVan when 1 then 
@MLVantoVan when 2 then @MLVantoGodown end, 
"FromVan" = FromVanid, "ToVan" = TovanId from vantransferabstract 
where documentdate between @FromDate and @ToDate

