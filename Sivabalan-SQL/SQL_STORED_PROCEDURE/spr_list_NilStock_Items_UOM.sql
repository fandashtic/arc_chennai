CREATE Procedure spr_list_NilStock_Items_UOM (@LessQty Decimal(18,6) = 0,@UOM nvarchar(25))          
as          
Declare @UOMCONV INT      
      
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
      
Else If @UOM = N'UOM1'          
Begin          
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,          
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)           
from InvoiceAbstract, InvoiceDetail           
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and          
InvoiceDetail.Product_Code = Items.Product_Code and          
InvoiceAbstract.Status & 128 = 0 and          
InvoiceAbstract.InvoiceType in (1, 2, 3)),          
"Pending Order Quantity" = (select sum(Pending)/Items.UOM1_Conversion from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),           
"Pending Order Value" = (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),          
"Current Stock" = cast(sum(Quantity) as nvarchar) + N' ' +(Select Um.Description from Uom Um Where UOM in (Select Itm.Uom from Items Itm Where Itm.Product_Code=Items.Product_Code)),      
"UOM1/UOM2"= cast(sum(Quantity)/Items.UOM1_Conversion as nvarchar) + N' ' + uom.[Description]          
from Items, Batch_Products bp, UOM          
where bp.Product_code = items.product_code and items.UOM1 = uom.[uom] and isNull(Items.UOM1_Conversion,0) > 0 and   
Items.Product_Code in (select Product_Code from Batch_Products           
group by Product_Code having sum(Quantity)/Items.UOM1_Conversion <= @LessQty) and items.active = 1        
group by Items.Product_Code, Items.ProductName, UOM.[Description] ,Items.UOM1_Conversion      
          
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
"Current Stock" = N'',          
"UOM1/UOM2"= N''      
from Items          
where isNull(Items.UOM1_Conversion,0) > 0 and      
Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and         
items.active = 1           
End          
      
Else If @UOM = N'UOM2'          
Begin          
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,          
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)           
from InvoiceAbstract, InvoiceDetail           
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and          
InvoiceDetail.Product_Code = Items.Product_Code and          
InvoiceAbstract.Status & 128 = 0 and          
InvoiceAbstract.InvoiceType in (1, 2, 3)),          
"Pending Order Quantity" = (select sum(Pending)/Items.UOM2_Conversion from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),           
"Pending Order Value" = (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),          
"Current Stock" = cast(sum(Quantity) as nvarchar) + N' ' +(Select Um.Description from Uom Um Where UOM in (Select Itm.Uom from Items Itm Where Itm.Product_Code=Items.Product_Code)),      
"UOM1/UOM2"= cast(sum(Quantity)/Items.UOM2_Conversion as nvarchar) + N' ' + uom.[Description]              
from Items, Batch_Products bp, UOM          
where bp.Product_code = items.product_code and items.UOM2 = uom.[uom] and isNull(Items.UOM2_Conversion,0) > 0 and        
Items.Product_Code in (select Product_Code from Batch_Products           
group by Product_Code having sum(Quantity)/Items.UOM2_Conversion <= @LessQty) and items.active = 1        
group by Items.Product_Code, Items.ProductName, UOM.[Description] ,Items.UOM2_Conversion      
          
union          
          
select Items.Product_Code, Items.Product_Code, Items.ProductName,          
(select max(InvoiceAbstract.InvoiceDate)           
from InvoiceAbstract, InvoiceDetail           
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and          
InvoiceDetail.Product_Code = Items.Product_Code and          
InvoiceAbstract.Status & 128 = 0 and          
InvoiceAbstract.InvoiceType in (1, 2, 3)),          
(select sum(Pending)/Items.UOM2_Conversion from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),           
(select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail           
where PODetail.Product_Code = Items.Product_Code and          
POAbstract.PONumber = PODetail.PONumber and          
POAbstract.Status & 128 = 0 and          
PODetail.Pending > 0),          
"Current Stock" = N'',          
"UOM1/UOM2"= N''      
from Items          
where isNull(Items.UOM2_Conversion,0) > 0 and      
Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and         
items.active = 1           
End          
    


