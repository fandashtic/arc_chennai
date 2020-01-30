CREATE procedure spr_list_VanLoading_Details (@DocSerial int)
as
Select 	VanStatementDetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Batch" = VanStatementDetail.Batch_Number,
	"Expiry" = Batch_Products.Expiry, 
	"Sold Qty" = (Select Sum(InvoiceDetail.Quantity) 
	From InvoiceDetail, InvoiceAbstract	
	Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And	
	InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And 
	InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And	
	(InvoiceAbstract.Status & 128) = 0 And 
	InvoiceDetail.SalePrice = VanStatementDetail.SalePrice And 
	InvoiceDetail.Batch_Number = VanStatementDetail.Batch_Number), 
	"Total Qty" = Sum(VanStatementDetail.Quantity), 
	"Sale Price" = VanStatementDetail.SalePrice, 
	"Amount" = Sum(VanStatementDetail.Amount),
	"Pending" = Sum(VanStatementDetail.Pending)
From 	VanStatementDetail, Items, Batch_Products
Where 	VanStatementDetail.DocSerial = @DocSerial And
	VanStatementDetail.Product_Code = Batch_Products.Product_Code And
	VanStatementDetail.Product_Code = Items.Product_Code And
	VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
Group By
	VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,
	Batch_Products.Expiry, VanStatementDetail.SalePrice
