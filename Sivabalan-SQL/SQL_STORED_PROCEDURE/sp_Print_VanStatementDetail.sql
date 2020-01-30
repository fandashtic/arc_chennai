CREATE procedure sp_Print_VanStatementDetail (@DocSerial int)
as
Select "Item Code" = VanStatementDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = VanStatementDetail.Batch_Number,
"Expiry" = Batch_Products.Expiry, "BF Qty" = VanStatementDetail.BFQty, 
"Quantity" = VanStatementDetail.Quantity, 
"Sale Price" = VanStatementDetail.SalePrice, 
"Sold Qty" = (Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
	InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
	InvoiceAbstract.Status & 128 = 0 And 
	Isnull(InvoiceDetail.Batch_Number,'') = IsNull(VanStatementDetail.Batch_Number,'')
	And InvoiceAbstract.InvoiceType in (1,3)
	And InvoiceDetail.SalePrice = VanStatementDetail.SalePrice), 
"UnSold Qty" = VanStatementDetail.Pending,VanStatementDetail.transferitemserial
From VanStatementDetail, Items, Batch_Products
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Batch_Products.Product_Code And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
Union All
Select "Item Code" = VanStatementDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = NULL,
"Expiry" = NULL, "BF Qty" = VanStatementDetail.BFQty, 
"Quantity" = VanStatementDetail.Quantity, 
"Sale Price" = VanStatementDetail.SalePrice, 
"Sold Qty" = (Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
	InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
	InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
	InvoiceAbstract.Status & 128 = 0 And
	Isnull(InvoiceDetail.Batch_Number,'') = IsNull(VanStatementDetail.Batch_Number,'')
	And InvoiceAbstract.InvoiceType in (1,3)
	And InvoiceDetail.SalePrice = VanStatementDetail.SalePrice),
"UnSold Qty" = VanStatementDetail.Pending,VanStatementDetail.transferitemserial
From VanStatementDetail, Items, ItemCategories
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code = 0 And
ItemCategories.CategoryID = Items.CategoryID And
ItemCategories.Track_Inventory = 0 
order by VanStatementDetail.transferitemserial

