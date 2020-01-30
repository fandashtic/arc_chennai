Create Procedure mERP_sp_Get_StkTakingAbstract(@ReconcileID Int)    
As    
Select "Document Type" = DocSerialType, 
 "Document Reference" = DocumentReference,   
 "Damage" = dbo.LookupDictionaryItem((Case IsNull(DamageStock,0) When 1 Then N'Damage' ELse N'Saleable' End), Default), IsNull(DamageStock,0),
 "Stock Status" = Case Isnull(StockStatus, 0) When 1 then N'ALL' when 2 Then N'With Stock' when 3 then N'Without Stock' End, Isnull(StockStatus, 0), 
 CreationDate, "Status" = Isnull(Status, 0), IsNull(Description,N''), "DocID" = ISNull(DocId,0)  From ReconcileAbstract     
Where ReconcileID = @ReconcileID    
