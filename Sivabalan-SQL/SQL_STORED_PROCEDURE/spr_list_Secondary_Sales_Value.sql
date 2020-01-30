CREATE Procedure spr_list_Secondary_Sales_Value  
(   
@From_Date DateTime,   
@To_Date DateTime  
 )  
AS  
Select Null, Final.Product_Code "Item Code", Sum(Final.NetValue) "Sale Value"  
From   
(  
select it.product_code ,it.productName,  "NetValue" = sum(dd.Quantity * dd.SalePrice)  
from dispatchabstract da  
Inner Join dispatchdetail dd On                         
 da.dispatchid = dd.dispatchid                   
Inner Join items it On  
 dd.product_code = it.product_code  
where    
   isnull(da.status, 0) & 64 = 0   
and   
   Da.DispatchDate between @From_Date And @To_Date  
group by it.product_code, it.productname  
  
Union  
  
select it.product_code ,it.productName,   
sum((Case ia.InvoiceType when 4 then -1 when 2 then 1 End) * ia.NetValue)  
from InvoiceAbstract ia  
Inner Join Invoicedetail Ind On  
 Ind.Invoiceid = Ia.Invoiceid  
Inner Join items it On  
 Ind.product_code = it.product_code  
Inner Join Batch_Products BP on 
 Ind.Batch_Code = BP.Batch_Code  
where    
   isnull(ia.Status,0) & 192 = 0 and ia.InvoiceType in (2, 4) and  
   ia.InvoiceDate between @From_Date And @To_Date  And
   isnull(BP.Damage, 0) = 0 
group by it.product_code, it.productname  
) Final  
Group By Final.Product_Code, Final.productName

