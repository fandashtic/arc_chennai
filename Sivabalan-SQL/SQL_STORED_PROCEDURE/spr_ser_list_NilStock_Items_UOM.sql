CREATE Procedure spr_ser_list_NilStock_Items_UOM (@LessQty Decimal(18,6) = 0,@UOM VarChar(25))          
as          
Declare @UOMCONV INT      
      
If @UOM = 'Sales UOM'      
Begin      
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,      

	"Last Sale Date" = (
		Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   

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
"Current Stock" = cast(sum(Quantity) as varchar) + ' ' + UOM.[Description]      
from Items, Batch_Products bp, UOM      
where bp.Product_code = items.product_code and items.uom = uom.[uom] and       
Items.Product_Code in (select Product_Code from Batch_Products       
group by Product_Code having sum(Quantity) <= @LessQty) and items.active = 1       
group by Items.Product_Code, Items.ProductName, UOM.[Description]    
      
union      
      
select Items.Product_Code, Items.Product_Code, Items.ProductName,      
(Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   

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
"Current Stock" = ''      
from Items      
where Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and       
items.active = 1       
End      
      
Else If @UOM = 'UOM1'          
Begin          
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,          
	 "Last Sale Date" = (
		Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   
      
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
"Current Stock" = cast(sum(Quantity) as varchar) + ' ' +(Select Um.Description from Uom Um Where UOM in (Select Itm.Uom from Items Itm Where Itm.Product_Code=Items.Product_Code)),      
"UOM1/UOM2"= cast(sum(Quantity)/Items.UOM1_Conversion as varchar) + ' ' + uom.[Description]          
from Items, Batch_Products bp, UOM          
where bp.Product_code = items.product_code and items.UOM1 = uom.[uom] and isNull(Items.UOM1_Conversion,0) > 0 and   
Items.Product_Code in (select Product_Code from Batch_Products           
group by Product_Code having sum(Quantity)/Items.UOM1_Conversion <= @LessQty) and items.active = 1        
group by Items.Product_Code, Items.ProductName, UOM.[Description] ,Items.UOM1_Conversion      
          
union          
          
select Items.Product_Code, Items.Product_Code, Items.ProductName,          
 (Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   

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
"Current Stock" = '',          
"UOM1/UOM2"= ''      
from Items          
where isNull(Items.UOM1_Conversion,0) > 0 and      
Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and         
items.active = 1           
End          
      
Else If @UOM = 'UOM2'          
Begin          
select Items.Product_Code, "Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,          
	 "Last Sale Date" = (
		Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   
      
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
"Current Stock" = cast(sum(Quantity) as varchar) + ' ' +(Select Um.Description from Uom Um Where UOM in (Select Itm.Uom from Items Itm Where Itm.Product_Code=Items.Product_Code)),      
"UOM1/UOM2"= cast(sum(Quantity)/Items.UOM2_Conversion as varchar) + ' ' + uom.[Description]              
from Items, Batch_Products bp, UOM          
where bp.Product_code = items.product_code and items.UOM2 = uom.[uom] and isNull(Items.UOM2_Conversion,0) > 0 and        
Items.Product_Code in (select Product_Code from Batch_Products           
group by Product_Code having sum(Quantity)/Items.UOM2_Conversion <= @LessQty) and items.active = 1        
group by Items.Product_Code, Items.ProductName, UOM.[Description] ,Items.UOM2_Conversion      
          
union          
          
select Items.Product_Code, Items.Product_Code, Items.ProductName,          
  (Select Max(invDate) from 
			(select Max(InvoiceAbstract.InvoiceDate) invDate 
		 	from InvoiceAbstract, InvoiceDetail  
			where InvoiceAbstract.Status & 128 = 0 and  
			InvoiceAbstract.InvoiceType in (1,2,3) and  
			InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
			InvoiceDetail.Product_Code = Items.Product_Code
			Union 
			select Max(ServiceInvoiceAbstract.serviceInvoiceDate) invDate 
			from ServiceInvoiceAbstract, ServiceInvoiceDetail  
			where ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND  
			Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0 and  
			ServiceInvoiceAbstract.ServiceInvoiceType in (1) and  
                        IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' and   
			ServiceInvoiceDetail.SpareCode = Items.Product_Code) invdt),   

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
"Current Stock" = '',          
"UOM1/UOM2"= ''      
from Items          
where isNull(Items.UOM2_Conversion,0) > 0 and 
Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and         
items.active = 1           
End          
    






