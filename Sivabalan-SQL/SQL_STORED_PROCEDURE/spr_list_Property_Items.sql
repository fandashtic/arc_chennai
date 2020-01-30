CREATE procedure spr_list_Property_Items(@PropertyID int)
as
select Items.Product_Code, "Item Name" = Items.ProductName, 
"Description" = Items.Description 
from Items, Item_Properties, Properties
where Properties.PropertyID = @PropertyID and
Properties.PropertyID = Item_Properties.PropertyID and
Item_Properties.Product_Code = Items.Product_Code
