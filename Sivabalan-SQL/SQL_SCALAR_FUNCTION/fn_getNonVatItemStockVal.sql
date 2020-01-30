Create function fn_getNonVatItemStockVal(@prod_code nvarchar(30),@batch_code nvarchar(30))  
returns decimal(18,6)  
as  
begin  
declare @price as Decimal(18,6)
declare @amnt as decimal(18,6)
select @price=(case ApplicableOn When 1 then  SalePrice when 2 then  PTS When 3 then  PTR  
When 4 then  ECP when 5 then Company_Price    
when 6 then isnull((select MRP from Items where Product_Code=@prod_code),0) else  0 end),
@amnt=isnull((@price*Quantity),0)+isnull((@price*Quantity*TaxSuffered*0.01),0)
from Batch_Products B where B.Product_Code=@prod_code and B.Batch_Code=@batch_code  
return(@amnt)  
end  
 
