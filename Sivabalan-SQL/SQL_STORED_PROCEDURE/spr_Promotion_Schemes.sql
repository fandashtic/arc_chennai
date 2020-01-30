Create Procedure spr_Promotion_Schemes
As
Declare @InvoiceBase nVarchar(100)
Declare @ItemBaseSame nVarchar(100)
Declare @ItemBaseDiff nVarchar(100)
set @InvoiceBase = dbo.LookupDictionaryItem(N'Invoice Based Free Items',default)
set @ItemBaseSame = dbo.LookupDictionaryItem(N'Item Based Same Item Free',default)
set @ItemBaseDiff = dbo.LookupDictionaryItem(N'Item Based Different Item Free',default)

Select Schemes.SchemeID,
"Scheme Name" = Schemes.SchemeName,
"Scheme Type" = Case Schemes.SchemeType 
When 3 Then
@InvoiceBase
When 17 Then
@ItemBaseSame
When 18 Then
@ItemBaseDiff
End,
"Description" = Schemes.SchemeDescription,
"Valid From" = Schemes.ValidFrom,
"Valid To" = Schemes.ValidTo
From Schemes
Where Schemes.SchemeType in (3, 17, 18) And
dbo.StripDateFromTime(Schemes.ValidTo) >= dbo.StripDateFromTime(GetDate()) And
Schemes.SchemeID In (Select Distinct SchemeID From ItemSchemes Group By SchemeID 
  Union Select Distinct SchemeID From schemeitems where freeitem != N'')


