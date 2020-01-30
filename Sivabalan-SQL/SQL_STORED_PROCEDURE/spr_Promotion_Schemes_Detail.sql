CREATE Procedure spr_Promotion_Schemes_Detail (@SchemeID int)
As
Select ItemSchemes.Product_Code,
"Item Code" = ItemSchemes.Product_Code,
"Item Name" = Items.ProductName
From ItemSchemes, Items
Where ItemSchemes.SchemeID = @SchemeID And
ItemSchemes.Product_Code = Items.Product_Code

Union

Select SchemeItems.FreeItem,
"Item Code" = SchemeItems.FreeItem,
"Item Name" = Items.ProductName
From SchemeItems, Items
Where SchemeItems.SchemeID = @SchemeID And
SchemeItems.FreeItem = Items.Product_Code


