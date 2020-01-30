CREATE Procedure sp_get_ItemProperties (@ItemCode nvarchar(20))
As
Select Properties.Property_Name, Item_Properties.Value
From Item_Properties, Properties
Where Item_Properties.Product_Code = @ItemCode And
Item_Properties.PropertyID = Properties.PropertyID
