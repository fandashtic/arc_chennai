CREATE VIEW   [V_SpecialCategory_item_bak]  
([Special_Cat_Code],[Product_Code],[CategoryID],[PrimaryUOM])  
AS  
SELECT distinct SCP.Special_Cat_Code   
,case when SC.CategoryType = 1 then SCP.Product_Code else Items.Product_Code end  
,SCP.CategoryID  
,(Case Isnull(SI.PrimaryUOM, 0) when 0 then Items.UOM when 1 then Items.UOM1 when 2 then Items.UOM2 end)  
 FROM  Special_Cat_Product SCP  
inner join Special_Category SC  on  SCP.Special_Cat_Code = SC.Special_Cat_Code  
left outer join Items on SCP.CategoryID = Items.categoryID    
left Join (Select Distinct SchemeItems.SchemeID, SchemeItems.PrimaryUOM from SchemeItems) SI   
  On SI.SchemeID = SC.SchemeID  
