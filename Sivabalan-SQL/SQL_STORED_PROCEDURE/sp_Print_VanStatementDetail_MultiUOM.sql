CREATE procedure sp_Print_VanStatementDetail_MultiUOM (@DocSerial int)
as
Select "Item Code" = VanStatementDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = VanStatementDetail.Batch_Number,
"Expiry" = Batch_Products.Expiry, 
"BF Qty" = Sum(VanStatementDetail.BFQty), 
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"UOMQuantity" = dbo.GetLastLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"Sale Price" = VanStatementDetail.SalePrice, 
"Sold Qty" = (Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
InvoiceAbstract.Status & 128 = 0), 
"UnSold Qty" = Sum(VanStatementDetail.Pending)
From VanStatementDetail, Items, Batch_Products
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Batch_Products.Product_Code And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
Group by VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,
VanStatementDetail.TransferItemSerial,Batch_Products.Expiry, VanStatementDetail.SalePrice
Union All
Select "Item Code"= VanStatementDetail.Product_Code, 
"Item Name"= Items.ProductName, "Batch" = VanStatementDetail.Batch_Number,
"Expiry"= NULL, 
"BF Qty"= Sum(VanStatementDetail.BFQty), 
"UOM2Quantity"= dbo.GetFirstLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOM2Description"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"UOM1Quantity"= dbo.GetSecondLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOM1Description"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"UOMQuantity"= dbo.GetLastLevelUOMQty(VanStatementDetail.Product_Code, Sum(VanStatementDetail.Quantity)),  
"UOMDescription"= (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  VanStatementDetail.Product_Code )),  
"Sale Price"= VanStatementDetail.SalePrice, 
"Sold Qty"= (Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
InvoiceAbstract.Status & 128 = 0), 
"UnSold Qty"= Sum(VanStatementDetail.Pending)
From VanStatementDetail, Items, ItemCategories
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code = 0 And
ItemCategories.CategoryID = Items.CategoryID And
ItemCategories.Track_Inventory = 0 
Group by VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,VanStatementDetail.TransferItemSerial,
VanStatementDetail.SalePrice
Order by VanStatementDetail.Product_Code
