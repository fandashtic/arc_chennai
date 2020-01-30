CREATE Procedure spr_list_Cost_of_Goods_Sold_General    
(       
@From_Date DateTime,       
@To_Date DateTime,  
@InvType nvarchar(20)  
 )      
AS      
DECLARE @InvCode int  
  
set @InvCode = 0  
if @InvType = 'All'  
 set @InvCode = 99  
else if  @InvType = 'Trade Invoice'  
 set @InvCode = 1  
else if @InvType = 'Retail sales'  
 set @InvCode = 2  
else if @InvType = 'Sales Return'  
 set @InvCode = 4  
  
if @InvCode = 99  
begin  
Select       
"Item Code" = Items.Product_Code, "Item Code" = Items.Product_Code, "Item name" = Items.ProductName,       
"Category" = ItemCategories.Category_Name, "Date of Sale" = dbo.StripDateFromTime(InvoiceAbstract.invoiceDate),       
"Sale price" = InvoiceDetail.SalePrice, "Total Units Sold" = case Invoiceabstract.InvoiceType when 4 then - Sum(InvoiceDetail.Quantity) else Sum(InvoiceDetail.Quantity) end, "Total Retail Value" = Sum(InvoiceDetail.Amount),       
"Purchase Price per Unit" = cast (Sum(InvoiceDetail.purchaseprice)/ (Case Sum(InvoiceDetail.Quantity) When 0 Then 1 Else Sum(InvoiceDetail.Quantity) End) as Decimal(18,6)),       
"Total Purchase Price" = Sum(InvoiceDetail.purchaseprice)      
from InvoiceAbstract, InvoiceDetail, Items, ItemCategories        
where Items.Product_Code = InvoiceDetail.Product_Code and       
Items.CategoryID = ItemCategories.CategoryID and      
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID       
and InvoiceDate between @From_Date and  @To_Date      
and (InvoiceAbstract.Status & 128) = 0      
Group by Items.Product_Code, Items.ProductName, ItemCategories.Category_Name,      
dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), InvoiceDetail.SalePrice, Invoiceabstract.InvoiceType
end  
else  
begin  
Select       
"Item Code" = Items.Product_Code, "Item Code" = Items.Product_Code, "Item name" = Items.ProductName,       
"Category" = ItemCategories.Category_Name, "Date of Sale" = dbo.StripDateFromTime(InvoiceAbstract.invoiceDate),       
"Sale price" = InvoiceDetail.SalePrice, "Total Units Sold" = case @InvCode when 4 then - Sum(InvoiceDetail.Quantity) else Sum(InvoiceDetail.Quantity) end, "Total Retail Value" = Sum(InvoiceDetail.Amount),       
"Purchase Price per Unit" = cast (Sum(InvoiceDetail.purchaseprice)/ (Case Sum(InvoiceDetail.Quantity) When 0 Then 1 Else Sum(InvoiceDetail.Quantity) End) as Decimal(18,6)),       
"Total Purchase Price" = Sum(InvoiceDetail.purchaseprice)      
from InvoiceAbstract, InvoiceDetail, Items, ItemCategories        
where Items.Product_Code = InvoiceDetail.Product_Code and       
Items.CategoryID = ItemCategories.CategoryID and      
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID       
and InvoiceDate between @From_Date and  @To_Date      
and InvoiceType = @InvCode  and (InvoiceAbstract.Status & 128) = 0      
Group by Items.Product_Code, Items.ProductName, ItemCategories.Category_Name,      
dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), InvoiceDetail.SalePrice      
end    
  
  


