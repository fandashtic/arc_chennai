

CREATE  PROCEDURE sp_get_AdjustItems (@CATEGORYID INT )
as
select DISTINCT Items.Product_Code, categoryid, ProductName, Purchase_Price 
from items,Batch_Products 
where categoryid =  @CATEGORYID and Active = 1 
and Batch_Products.Product_Code = Items.Product_Code
order by categoryid


