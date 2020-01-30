Create Procedure sp_print_ReconcileDocumentAbstract (@ReconcileID Integer)    
As   
Begin  
Declare @DAMAGE As NVarchar(50)  
Declare @SALEABLE As NVarchar(50)  
Declare @ALL_STOCK As NVarchar(50)  
Declare @WITH_STOCK As NVarchar(50)  
Declare @WITHOUT_STOCK As NVarchar(50)  
Declare @BASEUOM As NVarchar(50)  
Declare @UOM1 As NVarchar(50)  
Declare @UOM2 As NVarchar(50)  
Declare @ItemCount Int 

SET @DAMAGE = dbo.LookupDictionaryItem(N'Damage', Default)  
SET @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)  
SET @ALL_STOCK = dbo.LookupDictionaryItem(N'ALL', Default)  
SET @WITH_STOCK = dbo.LookupDictionaryItem(N'With Stock', Default)  
SET @WITHOUT_STOCK = dbo.LookupDictionaryItem(N'Without Stock', Default)  
SET @BASEUOM = dbo.LookupDictionaryItem(N'Base UOM', Default)   
SET @UOM1 = dbo.LookupDictionaryItem(N'UOM1', Default)   
SET @UOM2 = dbo.LookupDictionaryItem(N'UOM2', Default)   

Select @ItemCount = Count(*) From ReconcileDetail Where ReconcileID = @ReconcileID
   
Select "Document Type" = DocSerialType, "Document Reference" = DocumentReference,  "Description" = IsNull(Description,''),
"Document Date" = Convert(nVarchar(10), CreationDate,103) + N' ' + Convert(nVarchar(8), CreationDate,108),
"Damage" = (Case DamageStock When 1 Then @DAMAGE ELse @SALEABLE End), 
"Stock Status" = (Case StockStatus When 1 Then @ALL_STOCK When 2 Then @WITH_STOCK ELse @WITHOUT_STOCK End), 
"UOM" = (Case UOM When 1 Then @UOM2 When 2 Then @UOM1 ELse @BASEUOM End), 
"ITEM COUNT" = @ItemCount 
From ReconcileAbstract    
Where ReconcileID = @ReconcileID
End
