CREATE Procedure sp_Get_ReconcileDocumentAbstract (@ReconcileID Integer)  
As  
Select "Document Type" = DocSerialType, "Document Reference" = DocumentReference, DamageStock,
"DamageDesc" = dbo.LookupDictionaryItem((Case DamageStock When 1 Then N'Damage' ELse N'Saleable' End), Default),
IsNull(StockStatus,0),
"StockStatusDesc" = dbo.LookupDictionaryItem((Case IsNull(StockStatus,0) When 1 Then N'All' When 1 Then N'With Stock' Else N'Without Stock' End), Default),
Isnull(Status, 0), IsNull(Description,N'') ,IsNull(UOM,N''), "DocID" = IsNull(DocID,0) From ReconcileAbstract  
Where ReconcileID = @ReconcileID  

