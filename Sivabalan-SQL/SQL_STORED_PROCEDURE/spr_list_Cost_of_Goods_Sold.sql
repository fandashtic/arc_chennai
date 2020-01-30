CREATE Procedure spr_list_Cost_of_Goods_Sold
( 
@From_Date DateTime, 
@To_Date DateTime
 )
AS
Select 
"Item Code" = Items.Product_Code, "Item Code" = Items.Product_Code, "Item name" = Items.ProductName, 
"Category" = ItemCategories.Category_Name, "Date of Retail Sales" = dbo.StripDateFromTime(InvoiceAbstract.invoiceDate), 
"Retail price per Unit" = InvoiceDetail.SalePrice, "Total Units Sold" =Sum( InvoiceDetail.Quantity), "Total Retail Value" = Sum(InvoiceDetail.Amount), 
"Purchase Price per Unit" = cast (Sum(InvoiceDetail.purchaseprice)/ (Case Sum(InvoiceDetail.Quantity) When 0 Then 1 Else Sum(InvoiceDetail.Quantity) End) as Decimal(18,6)), 
"Total Purchase Price" = Sum(InvoiceDetail.purchaseprice)
from InvoiceAbstract, InvoiceDetail, Items, ItemCategories  
where Items.Product_Code = InvoiceDetail.Product_Code and 
Items.CategoryID = ItemCategories.CategoryID and
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
and InvoiceDate between @From_Date and  @To_Date
and InvoiceType = 2  and (InvoiceAbstract.Status & 128) = 0
Group by Items.Product_Code, Items.ProductName, ItemCategories.Category_Name,
dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), InvoiceDetail.SalePrice
