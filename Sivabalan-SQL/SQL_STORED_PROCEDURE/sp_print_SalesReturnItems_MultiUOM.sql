CREATE procedure [dbo].[sp_print_SalesReturnItems_MultiUOM](@INVOICEID INT)

AS

SELECT "Item Code" = InvoiceDetail.Product_Code, 
"Item Name" = Items.ProductName, 
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),  
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),  
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),  
"UOMQuantity" = dbo.GetLastLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),  
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),  
"Sale Price" = SalePrice,
"Tax" = TaxCode, "Amount" = Isnull(Sum(Amount), 0)
FROM InvoiceDetail, Items, UOM
WHERE InvoiceID = @INVOICEID 
AND InvoiceDetail.Product_Code = Items.Product_Code
AND Items.UOM *= UOM.UOM
Group by InvoiceDetail.Product_Code, Items.ProductName, SalePrice, TaxCode
