
CREATE procedure spr_list_NilStock_Items (@LessQty Decimal(18,6) = 0, @UOM nvarchar(25))  
as  
If @UOM = N'Base UOM' 
	Set @UOM = N'Sales UOM' 

If @UOM = N'Sales UOM'  
Begin  
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,  
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
"Pending Order Quantity" = (select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
"Pending Order Value" = (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = cast(sum(Quantity) as nvarchar) + N' ' + UOM.[Description]  
from Items, Batch_Products bp, UOM  
where bp.Product_code = items.product_code and items.uom = uom.[uom] and   
Items.Product_Code in (select Product_Code from Batch_Products   
group by Product_Code having sum(Quantity) <= @LessQty) and items.active = 1   
group by Items.Product_Code, Items.ProductName, UOM.[Description]
  
union  
  
select Items.Product_Code, Items.Product_Code, Items.ProductName,  
(select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
(select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
(select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = N''  
from Items  
where Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and   
items.active = 1   
End  
Else If @UOM = N'Reporting UOM'  
Begin  
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,  
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
"Pending Order Quantity" = (select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
"Pending Order Value" = (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = cast(sum(cast(Quantity / ReportingUnit as decimal(18, 2))) as nvarchar) + N' ' + uom.[Description]  
from Items, Batch_Products bp, UOM  
where bp.Product_code = items.product_code and items.ReportingUOM = uom.[uom] and
Items.Product_Code in (select Product_Code from Batch_Products   
group by Product_Code having sum(Quantity) <= @LessQty) and items.active = 1
group by Items.Product_Code, Items.ProductName, UOM.[Description]
  
union  
  
select Items.Product_Code, Items.Product_Code, Items.ProductName,  
(select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
(select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
(select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = N''  
from Items  
where Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and   
items.active = 1   
End  
Else If @UOM = N'Conversion Factor'  
Begin  
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,  
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
"Pending Order Quantity" = (select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
"Pending Order Value" = (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = cast(sum(cast(Quantity * conversionfactor as decimal(18, 2))) as nvarchar) + N' ' + ct.[ConversionUnit]  
from Items, Batch_Products bp, conversiontable ct  
where bp.Product_code = items.product_code and items.conversionunit = ct.[conversionid]   
and Items.Product_Code in (select Product_Code from Batch_Products   
group by Product_Code having sum(Quantity) <= @LessQty) and items.active = 1   
group by Items.Product_Code, Items.ProductName, ct.[ConversionUnit]
  
union  
  
select Items.Product_Code, Items.Product_Code, Items.ProductName,  
(select max(InvoiceAbstract.InvoiceDate)   
from InvoiceAbstract, InvoiceDetail   
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
InvoiceDetail.Product_Code = Items.Product_Code and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceType in (1, 2, 3)),  
(select sum(Pending) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),   
(select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail   
where PODetail.Product_Code = Items.Product_Code and  
POAbstract.PONumber = PODetail.PONumber and  
POAbstract.Status & 128 = 0 and  
PODetail.Pending > 0),  
"Current Stock" = N''  
from Items  
where Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and   
items.active = 1   
End  
  
