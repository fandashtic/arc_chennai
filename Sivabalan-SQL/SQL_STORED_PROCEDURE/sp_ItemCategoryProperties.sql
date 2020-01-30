Create Procedure sp_ItemCategoryProperties (@ItemCode nvarchar(20))
As
Select Properties.Property_Name From Properties, Category_Properties, Items
Where Items.Product_Code = @ItemCode And
Category_Properties.CategoryID = Items.CategoryID And
Category_Properties.PropertyID = Properties.PropertyID
