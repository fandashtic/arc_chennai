CREATE procedure sp_list_products_UOM(@Vendor_ID nVarChar(15)) as  
Declare @MULTIPLE As NVarchar(50)
Set @MULTIPLE = dbo.LookupDictionaryItem(N'Multiple', Default)
select Product_code, ProductName, 
"OrderQty" = case Items.DefaultUOM / 8 when 3 then convert(nvarchar,dbo.GetQtyAsMultipleAsInt(dbo.GetQtyAsMultiple(Items.Product_Code,Cast(OrderQty As Int)))) else convert(nvarchar,OrderQty) end,
"Purchase_Price" = case Items.DefaultUOM / 8 
when 0 then  Purchase_Price 
when 1 then  Purchase_Price * Uom1_Conversion 
when 2 then  Purchase_Price * Uom2_Conversion 
when 3 then  Purchase_Price 
end,
case Items.DefaultUOM / 8 
when 0 then OrderQty *  Purchase_Price 
when 1 then OrderQty *  Purchase_Price * Uom1_Conversion 
when 2 then OrderQty *  Purchase_Price * Uom2_Conversion 
when 3 then OrderQty *  Purchase_Price 
end AS "Amount" ,
"Original_Price" = Purchase_Price,
"UOM" = case Items.DefaultUOM / 8 when 0 then 
(select uom.description from uom where uom.uom=items.uom)
when 1 then (select uom.description from uom where uom.uom=items.uom1)
when 2 then (select uom.description from uom where uom.uom=items.uom2)
when 3 then @MULTIPLE
end

from Items, ItemCategories  
where Preferred_Vendor = @Vendor_ID and   
ISNULL(OrderQty, 0) <> 0 and  
ISNULL(OrderQty,0) >= ISNULL(MinOrderQty, 0) AND   
Items.Active = 1 and  
Items.CategoryID = ItemCategories.CategoryID and  
ItemCategories.Track_Inventory = 1 And IsNull(MinOrderQty,0)>0  


