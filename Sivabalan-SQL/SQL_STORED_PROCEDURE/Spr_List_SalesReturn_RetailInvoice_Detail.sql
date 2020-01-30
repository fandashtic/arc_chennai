CREATE procedure [dbo].[Spr_List_SalesReturn_RetailInvoice_Detail] (@InvoiceID int)      
As      
Select InvoiceDetail.Product_Code,      
"Item Code" = InvoiceDetail.Product_Code,      
"Item Name" = Items.ProductName,      
--"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
--"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
--"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
"Batch" = InvoiceDetail.Batch_Number,      
"PKD" =  Batch_Products.PKD,      
"Expiry" = Batch_Products.Expiry,      
"Quantity" = 0 - Sum(InvoiceDetail.Quantity),      
"SalePrice" = InvoiceDetail.SalePrice,      
"Tax Suffered%" = IsNull(Max(InvoiceDetail.TaxSuffered), 0),      
"Discount%" = Sum(InvoiceDetail.DiscountPercentage),      
"Tax Applicable%" = IsNull(Avg(InvoiceDetail.TaxCode), 0) +       
IsNull(Avg(InvoiceDetail.TaxCode2), 0),      
"Amount (%c)" = 0 + Sum(abs(InvoiceDetail.Amount))      
From InvoiceDetail, Items, Batch_Products,Invoiceabstract      
Where InvoiceDetail.Product_Code = Items.Product_Code And  
Invoiceabstract.InvoiceID=InvoiceDetail.InvoiceID    and
InvoiceDetail.InvoiceID = @InvoiceID And      
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code And      
(InvoiceDetail.Quantity < 0 or Invoiceabstract.InvoiceType in(5,6))     
Group By InvoiceDetail.Product_Code, Items.ProductName,       
--dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
--dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
--dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
InvoiceDetail.Batch_Number,      
Batch_Products.PKD,    
Batch_Products.Expiry,      
InvoiceDetail.SalePrice
