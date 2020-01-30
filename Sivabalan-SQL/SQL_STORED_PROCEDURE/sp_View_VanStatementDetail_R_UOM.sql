Create procedure sp_View_VanStatementDetail_R_UOM(@DocSerial int)      
As      
 Select * into #TempVanStatDet From      
 (  
Select 
--"vtid" = [vtid], "ds" = [ds], "tis" = [tis], "up" = [up], 
--"umi" = [umi], 
"Item Code" = [Item Code], "Item Name" = [Item Name], 
"Batch" = [Batch], "Expiry" = Max([Expiry]), "BF Qty" = Sum([BF Qty]),
"Quantity" = Sum([Quantity]), "UOM" = [UOM], 
"Sale Price" = [Sale Price], "Sold Qty" = Max([Sold Qty]), "UnSold Qty" = Sum([UnSold Qty])
,"Item Serial" = [Item Serial]
From 
(
Select   
--"vanid" = VanStatementDetail.ID  ,   
"BC" = VanStatementDetail.Batch_Code,
"vtid" = VanStatementDetail.VanTransferID, 
"ds" = VanStatementDetail.DocSerial,
"tis" = VanStatementDetail.TransferItemSerial,
"up" = VanStatementDetail.UOMPrice,
"umi" = VanStatementDetail.UOM,
"Item Code"= IsNull((Select IsNull(Product_Code, '') From Items
Where Product_Code = VanStatementDetail.Product_Code), ''),
--VanStatementDetail.Product_Code,       
"Item Name"= IsNull((Select IsNull(ProductName, '') From Items
Where Product_Code = VanStatementDetail.Product_Code), ''),
"Batch"= VanStatementDetail.Batch_Number,      
"Expiry"= (Select Max(Expiry) From Batch_Products 
Where Batch_Code = VanStatementDetail.Batch_Code),
--Max(Batch_Products.Expiry), 
"BF Qty"= Sum(VanStatementDetail.BFQty),       
--"Quantity"= Max(VanStatementDetail.UOMQty),       
"Quantity"= Sum(VanStatementDetail.Quantity)
/
IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1)
,       
"UOM"= UOM.Description,       
"Sale Price"= VanStatementDetail.UOMPrice,       
"Sold Qty"= (IsNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract      
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And      
--InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And      
--InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And      
InvoiceAbstract.Status & 192 = 0     
--------------    
And InvoiceAbstract.Status & 16 <> 0 And    
InvoiceDetail.Batch_Code In (Select vsd.ID From VanStatementDetail vsd
Where vsd.Product_Code = VanStatementDetail.Product_Code And 
vsd.DocSerial = VanStatementDetail.DocSerial And 
vsd.VanTransferID = VanStatementDetail.VanTransferID And 
vsd.TransferItemSerial = VanStatementDetail.TransferItemSerial And 
vsd.UOMPrice = VanStatementDetail.UOMPrice And 
vsd.UOM = VanStatementDetail.UOM)

    
-----------    
),0))  
  
/IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1) 
,       
"UnSold Qty"= sum(VanStatementDetail.Pending)
/
IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1),
"Item Serial" = VanStatementDetail.TransferItemSerial

From VanStatementDetail, UOM      
Where VanStatementDetail.DocSerial = @DocSerial And      
--VanStatementDetail.Product_Code = Batch_Products.Product_Code And      
--VanStatementDetail.Product_Code = Items.Product_Code And      
--VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And      
VanStatementDetail.UOM = UOM.UOM       
Group By VanStatementDetail.Product_Code, VanStatementDetail.UOM, 
VanStatementDetail.VanTransferID, VanStatementDetail.TransferItemSerial, 
VanStatementDetail.UOMPrice, VanStatementDetail.Batch_Number, 
VanStatementDetail.Batch_Code, UOM.Description, VanStatementDetail.DocSerial
--order by VanStatementDetail.Product_Code
 ) ls
 Group By 
[vtid], [ds], [tis], [up], [umi], 
[Item Code], [Item Name], 
--[Expiry]
[Batch], [UOM], [Sale Price], [Item Serial]
--Order By [Item Code]

--order by VanStatementDetail.Product_Code
--, VanStatementDetail.ID    
  
Union All      

Select 
--"vtid" = [vtid], "ds" = [ds], "tis" = [tis], "up" = [up], 
--"umi" = [umi], 
"Item Code" = [Item Code], "Item Name" = [Item Name], 
"Batch" = [Batch], "Expiry" = Max([Expiry]), "BF Qty" = Sum([BF Qty]),
"Quantity" = Sum([Quantity]), "UOM" = [UOM], 
"Sale Price" = [Sale Price], "Sold Qty" = Max([Sold Qty]), "UnSold Qty" = Sum([UnSold Qty])
, "Item Serial" = [Item Serial]
From 
(
Select   
"BC" = VanStatementDetail.Batch_Code,
"vtid" = VanStatementDetail.VanTransferID, 
"ds" = VanStatementDetail.DocSerial,
"tis" = VanStatementDetail.TransferItemSerial,
"up" = VanStatementDetail.UOMPrice,
"umi" = VanStatementDetail.UOM,

"Item Code"= IsNull((Select IsNull(Product_Code, '') From Items
Where Product_Code = VanStatementDetail.Product_Code), ''),
--VanStatementDetail.Product_Code,       
"Item Name"= IsNull((Select IsNull(ProductName, '') From Items
Where Product_Code = VanStatementDetail.Product_Code), ''),

"Batch"= VanStatementDetail.Batch_Number,      
--"vanid" = VanStatementDetail.ID  ,   
"Expiry"= '', 
"BF Qty"= Sum(VanStatementDetail.BFQty),       

"Quantity"= Sum(VanStatementDetail.Quantity)
/
IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1)
,       

"UOM"= UOM.Description,       

--"Quantity"= Max(VanStatementDetail.UOMQty),       
"Sale Price"= VanStatementDetail.UOMPrice,       

"Sold Qty"= (IsNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract      
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And      
--InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And      
--InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And      
InvoiceAbstract.Status & 192 = 0     
--------------    
And InvoiceAbstract.Status & 16 <> 0 And    
InvoiceDetail.Batch_Code In (Select vsd.ID From VanStatementDetail vsd
Where vsd.Product_Code = VanStatementDetail.Product_Code And 
vsd.DocSerial = VanStatementDetail.DocSerial And 
vsd.VanTransferID = VanStatementDetail.VanTransferID And 
vsd.TransferItemSerial = VanStatementDetail.TransferItemSerial And 
vsd.UOMPrice = VanStatementDetail.UOMPrice And 
vsd.UOM = VanStatementDetail.UOM)

    
-----------    
),0))  
  
/IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1) 
,

"UnSold Qty"= sum(VanStatementDetail.Pending)
/
IsNull((Select Case VanStatementDetail.UOM When Items.UOM then 1       
When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End 
When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End End
From Items Where Product_Code = VanStatementDetail.Product_Code), 1)
, "Item Serial" = VanStatementDetail.TransferItemSerial

From VanStatementDetail, UOM, Items its, ItemCategories itcat
Where VanStatementDetail.DocSerial = @DocSerial And      
VanStatementDetail.Product_Code = its.Product_Code And  
VanStatementDetail.UOM = UOM.UOM And      
VanStatementDetail.Batch_Code = 0 And      
itcat.CategoryID = its.CategoryID And  
itcat.Track_Inventory = 0       
Group By 
VanStatementDetail.Product_Code, VanStatementDetail.UOM, 
VanStatementDetail.VanTransferID, VanStatementDetail.TransferItemSerial, 
VanStatementDetail.UOMPrice, VanStatementDetail.Batch_Number, 
VanStatementDetail.Batch_Code, UOM.Description, VanStatementDetail.DocSerial

 ) lss
 Group By 
[vtid], [ds], [tis], [up], [umi], 
[Item Code], [Item Name], 
--[Expiry]
[Batch], [UOM], [Sale Price], [Item Serial]

) As TmpTbale      

Select       
[Item Code]  As Product_Code,max([Item Name])  As ProductName,      
[Batch]  As Batch_Number,[Expiry] As Expiry,      
"Sold Qty" = max([Sold Qty]),      
"Total Qty" = sum([Quantity]),      
"SalePrice" = [Sale Price],       
"Amount" = sum([Quantity] * [Sale Price]),      
"Pending" = sum([UnSold Qty]),      
"UOM" = [UOM]      
From #TempVanStatDet       
Group By [Item Code],[UOM],[Batch],[Expiry],[Sale Price], [Item Serial]   
--, [vanid]
--order by [Item Code]      
order by [Item Serial]      
Drop Table #TempVanStatDet      
