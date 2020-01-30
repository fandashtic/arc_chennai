Create procedure sp_Print_VanStatementDetail_RespectiveUOM (@DocSerial int)  
as  
Select * into #TempVanStatDet From  
(Select "Item Code"= VanStatementDetail.Product_Code,   
"Item Name"= Max(Items.ProductName), "Batch"= Max(VanStatementDetail.Batch_Number),  
"Expiry"= Max(Batch_Products.Expiry), "BF Qty"= Max(VanStatementDetail.BFQty),   
--"Quantity"= Max(VanStatementDetail.UOMQty),   
"Quantity"= Sum(VanStatementDetail.Quantity)/(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End),   
"UOM"= Max(UOM.Description),   
"Sale Price"= Max(VanStatementDetail.UOMPrice),   
"Sold Qty"= (IsNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract  
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And  
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And  
InvoiceAbstract.Status & 128 = 0),0)) /(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End),   
"UnSold Qty"= sum(VanStatementDetail.Pending) /(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End), 
"MRP Per Pack" = Isnull(Max(VanStatementDetail.MRPPerPack),0)
From VanStatementDetail
Inner Join Items On VanStatementDetail.Product_Code = Items.Product_Code 
Inner Join  Batch_Products On VanStatementDetail.Product_Code = Batch_Products.Product_Code
Left Outer Join UOM On VanStatementDetail.UOM = UOM.UOM    
Where VanStatementDetail.DocSerial = @DocSerial
Group By VanStatementDetail.Product_Code,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial  
Union All  
Select "Item Code"= VanStatementDetail.Product_Code,   
"Item Name"= Max(Items.ProductName), "Batch"= Max(VanStatementDetail.Batch_Number),  
"Expiry"= NULL, "BF Qty"= Max(VanStatementDetail.BFQty),   
--"Quantity"= Max(VanStatementDetail.UOMQty),   
"Quantity"= Sum(VanStatementDetail.Quantity)/(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End),   
"UOM"= Max(UOM.Description),   
"Sale Price"= Max(VanStatementDetail.UOMPrice),   
"Sold Qty"= (IsNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract  
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And  
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And  
InvoiceAbstract.Status & 128 = 0),0)) /(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End),   
"UnSold Qty" = Sum(VanStatementDetail.Pending) /(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1   
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End),
"MRP Per Pack" = Isnull(Max(VanStatementDetail.MRPPerPack),0)  
From VanStatementDetail
Inner Join Items On VanStatementDetail.Product_Code = Items.Product_Code 
Left Outer Join UOM On VanStatementDetail.UOM = UOM.UOM
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID 
Where VanStatementDetail.DocSerial = @DocSerial And VanStatementDetail.Batch_Code = 0 And  ItemCategories.Track_Inventory = 0   
Group By VanStatementDetail.Product_Code,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial) As TmpTbale  
  
Select   
"Item Code" = [Item Code],"Item Name" = max([Item Name]),"Batch" = [Batch],  
"Expiry" = [Expiry],"BF Qty" = sum([BF Qty]),   
"Quantity" = sum([Quantity]),"UOM" = [UOM],   
"Sale Price" = [Sale Price],   
"Sold Qty" = max([Sold Qty]), 
"UnSold Qty" = sum([UnSold Qty]),
"MRP Per Pack" = Max([MRP Per Pack])  
From #TempVanStatDet   
Group By [Item Code],[UOM],[Batch],[Expiry],[Sale Price]  
order by [Item Code]  
Drop Table #TempVanStatDet  
