CREATE procedure [dbo].[sp_View_VanStatementDetail] (@DocSerial int)
as
Select VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,
Batch_Products.Expiry, 
(Select Sum(InvoiceDetail.Quantity) From InvoiceDetail, InvoiceAbstract
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
InvoiceDetail.Product_Code = VanStatementDetail.Product_Code And
InvoiceAbstract.ReferenceNumber = CAST(@DocSerial AS nvarchar) And
(InvoiceAbstract.Status & 128) = 0 And
(InvoiceAbstract.Status & 16) <> 0 And
InvoiceDetail.Batch_Code = VanStatementDetail.[ID] And
InvoiceDetail.Batch_Number = VanStatementDetail.Batch_Number), 
Sum(VanStatementDetail.Quantity), 
VanStatementDetail.SalePrice, Sum(VanStatementDetail.Amount),
Sum(VanStatementDetail.Pending)
From VanStatementDetail, Items, Batch_Products
Where VanStatementDetail.DocSerial = @DocSerial And
VanStatementDetail.Product_Code = Items.Product_Code And
VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code
Group By VanStatementDetail.Product_Code, Items.ProductName, VanStatementDetail.Batch_Number,
Batch_Products.Expiry, VanStatementDetail.[ID], VanStatementDetail.SalePrice
