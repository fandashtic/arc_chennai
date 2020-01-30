CREATE procedure sp_ser_rpt_PendingItemAbstract(@ProductName nvarchar(255))                                  
as                                  
select 'Item Code' = product_code ,'Item Code' = product_code,'Item Name' = A.productname,'No of Items' = count(*) from  
(select item_information.product_code,productname,product_specification1  
from item_information,items   
where Items.ProductName like @ProductName  
and Item_information.Product_code  = items.product_code  
and (IsNull(Item_information.Product_Status, 0) & 2) <> 0   
group by item_information.Product_Code,items.ProductName,item_information.Product_Specification1)A  
group by A. product_code,A.productname  

