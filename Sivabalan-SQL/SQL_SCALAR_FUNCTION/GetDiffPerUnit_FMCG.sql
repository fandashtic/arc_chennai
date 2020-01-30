CREATE Function GetDiffPerUnit_FMCG ( @ItemCode nvarchar(15), @Invoiceid int, @CustomerId nvarchar(15), @Batch_Code int)  
returns decimal(18,6)  
as  
begin  
declare @Price Decimal(18,6)  
Declare @CSPSET int  
select @CSPSET = price_option from Itemcategories where Categoryid = (select Categoryid from items where Product_code = @ItemCode)  
-- 1-pts , 2 -ptr, 3 - comp  
-- ptr or pts or company price (based on customer type ) - original (saleprice)  
-- if csp set then ptr or pts can be taken from inv det or from item master  
if @CSPSET = 1  
begin  
 select @Price = SalePrice
 from Batch_Products where Batch_Code = @Batch_Code  
end  
else  
begin  
 select @Price = Sale_Price
 from Items where Product_Code = @ItemCode  
end  
return @Price  
end 
