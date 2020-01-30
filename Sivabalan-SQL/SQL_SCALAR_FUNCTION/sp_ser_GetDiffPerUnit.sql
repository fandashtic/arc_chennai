CREATE Function sp_ser_GetDiffPerUnit( @ItemCode varchar(15), @Invoiceid int, @CustomerId varchar(15), @Batch_Code int)
returns decimal(18,6)
as
begin
Declare @CustType int
declare @Price decimal(18,6)
Declare @CSPSET int
select @CSPSET = price_option from Itemcategories where Categoryid = (select Categoryid from items where Product_code = @ItemCode)
select @CustType = customercategory from Customer where CustomerId = @Customerid
-- 1-pts , 2 -ptr, 3 - comp
-- ptr or pts or company price (based on customer type ) - original (saleprice)
-- if csp set then ptr or pts can be taken from inv det or from item master
if @CSPSET = 1
begin
	select @Price = case @CustType
		when 1 then PTS
		when 2 then PTR
		else Company_Price 
	end
	from Batch_Products where Batch_Code = @Batch_Code
end
else
begin
	select @Price = case @CustType
		when 1 then PTS 
		when 2 then PTR 
		else Company_Price 
	end
	from Items where Product_Code = @ItemCode
end
return @Price
end







