CREATE procedure sp_print_redemptiondetail @DocSerial int
as
begin
select "Product Code" = redemptiondetail.Product_Code, "Product Name" = ProductName,
"Quantity" = Quantity, "Points" = Points
from redemptiondetail,items where DocSerial = @DocSerial 
and redemptiondetail.Product_code=Items.Product_code
end

