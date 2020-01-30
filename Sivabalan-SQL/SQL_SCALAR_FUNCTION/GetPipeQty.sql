

CREATE function GetPipeQty(@Product_Code nvarchar(15)) 
returns decimal(18,6)
as
begin
	declare @TotalValue  as decimal(18,6)
	select @TotalValue = sum(Quantity * PurchasePrice) from batch_products where Product_Code = @Product_Code
	group by Product_Code
return @TotalValue
end


