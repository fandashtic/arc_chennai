CREATE procedure [dbo].[sp_get_VanStatementDetail_RUOM](@DocSerial int)
As
Select * into #TempVanStatDet From
(Select "Item Code"= VanStatementDetail.Product_Code, 
"Item Name"= Max(Items.ProductName), "Batch"= Max(VanStatementDetail.Batch_Number),
"Expiry"= Max(Batch_Products.Expiry),
"Quantity"= Sum(VanStatementDetail.Quantity)/(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1 
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End), 
"UOM"= Max(UOM.Description), 
"Sale Price"= Max(VanStatementDetail.UOMPrice), 
"UnSold Qty"= sum(VanStatementDetail.Pending)/(Case Max(VanStatementDetail.UOM) when max(Items.UOM) then 1 
When max(Items.UOM1) Then max(UOM1_Conversion) When max(Items.UOM2) Then max(UOM2_Conversion) End)
From VanStatementDetail
Left Outer Join Batch_Products on VanStatementDetail.Product_Code = Batch_Products.Product_Code and VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
Inner Join Items on VanStatementDetail.Product_Code = Items.Product_Code
Left Outer Join UOM on VanStatementDetail.UOM = UOM.UOM 
Where VanStatementDetail.DocSerial = @DocSerial 
--And
--VanStatementDetail.Product_Code *= Batch_Products.Product_Code And
--VanStatementDetail.Product_Code = Items.Product_Code And
--VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code And
--VanStatementDetail.UOM *= UOM.UOM 
Group By VanStatementDetail.Product_Code,VanStatementDetail.UOM,VanStatementDetail.VanTransferID,VanStatementDetail.TransferItemSerial) As TmpTbale

Select 
[Item Code]  As Product_Code,max([Item Name])  As ProductName,
[Batch]  As Batch,[Expiry] As Expiry,
"Pending" = sum([UnSold Qty]),
"Total Qty" = sum([Quantity]),
"SalePrice" = [Sale Price], 
"Amount" = sum([UnSold Qty]) * [Sale Price],
--"Amount" = sum([Quantity] * [Sale Price]),
"UOM" = [UOM],
"UOM QTY" = sum([Quantity]),
"UOM Price" =  [Sale Price]
From #TempVanStatDet 
Group By [Item Code],[UOM],[Batch],[Expiry],[Sale Price]
order by [Item Code]
Drop Table #TempVanStatDet
