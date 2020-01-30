CREATE VIEW [dbo].[V_Item_schemes_bak]  
([SchemeID],[Product_code],[PrimaryUOM])  
AS
SELECT ItemSchemes.SchemeID  
,ItemSchemes.Product_code  
,(Case Isnull(SI.PrimaryUOM, 0) when 0 then Items.UOM when 1 then Items.UOM1 when 2 then Items.UOM2 end)   
FROM ItemSchemes   
Inner Join Items On Items.product_code = ItemSchemes.product_code    
left Join (Select Distinct SchemeItems.SchemeID, SchemeItems.PrimaryUOM from SchemeItems) SI   
   On SI.SchemeID = ItemSchemes.SchemeID   
