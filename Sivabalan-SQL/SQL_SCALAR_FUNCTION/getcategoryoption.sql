CREATE function getcategoryoption(@categoryid integer)
returns int
as 
begin
declare @priceoption int
select @priceoption = [Price_Option]
from ItemCategories 
where [CategoryID]= @categoryid
return @priceoption
end


