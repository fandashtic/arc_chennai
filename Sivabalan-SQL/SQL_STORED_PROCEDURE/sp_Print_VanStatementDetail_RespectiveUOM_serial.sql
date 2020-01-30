CREATE procedure [dbo].[sp_Print_VanStatementDetail_RespectiveUOM_serial] (@DocSerial int)
as
Select * into #TempVanStatDet From
(Select "Item Code"= VanStatementDetail.Product_Code, 
"Item Name"= Max(Items.ProductName), "Batch"= Max(VanStatementDetail.Batch_Number),
"Expiry"= Max(Batch_Products.Expiry), "BF Qty"= Max(VanStatementDetail.BFQty), 
"Quantity"= Max(VanStatementDetail.UOMQty), 
"UOM"= Max(UOM.Description), 
"Sale Price"= Max(VanStatementDetail.UOMPrice), 
"Sold Qty"= IsNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
InvoiceAbstract.Status & 128 = 0),0), 
"UnSold Qty" = Sum(VanStatementDetail.Pending),VanStatementDetail.transferitemserial
From VanStatementDetail, Items, Batch_Products, UOM
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Batch_Products.Product_Code And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code = Batch_Products.Batch_Code And
VanStatementDetail.UOM *= UOM.UOM 
Group By VanStatementDetail.Product_Code,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial
Union All
Select "Item Code"= VanStatementDetail.Product_Code, 
"Item Name"= Max(Items.ProductName), "Batch"= Max(VanStatementDetail.Batch_Number),
"Expiry"= NULL, "BF Qty"= Max(VanStatementDetail.BFQty), 
"Quantity"= Max(VanStatementDetail.UOMQty), 
"UOM"= Max(UOM.Description), 
"Sale Price"= Max(VanStatementDetail.UOMPrice), 
"Sold Qty"= isNull((Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
InvoiceAbstract.Status & 128 = 0),0), 
"UnSold Qty"= Sum(VanStatementDetail.Pending),VanStatementDetail.transferitemserial
From VanStatementDetail, Items, UOM, ItemCategories
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.UOM *= UOM.UOM And
VanStatementDetail.Batch_Code = 0 And
ItemCategories.CategoryID = Items.CategoryID And
ItemCategories.Track_Inventory = 0 
Group By VanStatementDetail.Product_Code,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial)  As TmpTbale

Select "Item Code" = [Item Code],"Item Name" = max([Item Name]),"Batch" = [Batch],
"Expiry" = [Expiry],"BF Qty" = sum([BF Qty]), 
"Quantity" = sum([Quantity]),"UOM" = [UOM], 
"Sale Price" = [Sale Price], 
"Sold Qty" = max([Sold Qty]),
"UnSold Qty" = sum([UnSold Qty])
From #TempVanStatDet 
Group By [Item Code],[UOM],[Batch],[Expiry],[Sale Price]
order by [Item Code]
Drop Table #TempVanStatDet
