CREATE PROCEDURE sp_view_DispatchDetails_MUOM_ITC(@DISPATCHID INT)                
AS                
SELECT DispatchDetail.Product_Code, Items.ProductName,                 
"Quantity" = Max(IsNull(DispatchDetail.UOMQty,0)) *     
    (Select Case When DispatchDetail.UOM = Max(Items.UOM1) Then Max(IsNull(Items.UOM1_Conversion,0))     
         When DispatchDetail.UOM = Max(Items.UOM2) Then Max(IsNull(Items.UOM2_Conversion,0))     
         Else 1 End),     
Batch_Products.Batch_Number, DispatchDetail.SalePrice, "UOM" = (Select Description From UOM Where UOM = DispatchDetail.UOM), Min(DispatchDetail.Batch_Code), Max(ItemCategories.Track_inventory), Max(ItemCategories.Price_Option), Batch_Products.Expiry,   
Batch_Products.PKD, DispatchDetail.FlagWord, Items.Track_Batches, "UOMID" = DispatchDetail.UOM, "UOMQty" = Max(DispatchDetail.UOMQty), "UOMPrice" = DispatchDetail.UOMPrice,"Serial" = DispatchDetail.Serial,
"OtherCG_Item"=IsNull(DispatchDetail.OtherCG_Item,0), IsNull(DispatchDetail.Serial,0) as Serial, 
IsNull(DispatchDetail.SchemeID,0) as SchemeID, IsNull(DispatchDetail.FreeSerial,0) as FreeSerial, Batch_Products.Free,
IsNull(DispatchDetail.CSchemeID,0) as CSchemeID,IsNull(DispatchDetail.SPLCATSCHEMEID,0) as SPLCATSCHEMEID,
DispatchDetail.SpecialCategoryScheme as  SpecialCategoryScheme,DispatchDetail.SPLCATSerial as SPLCATSerial,
DispatchDetail.MultipleSchemeDetails,DispatchDetail.MultipleSplCategorySchDetail
FROM  DispatchDetail
Left Outer Join  Batch_Products On DispatchDetail.Batch_Code = Batch_Products.Batch_Code                
Inner Join Items On DispatchDetail.Product_Code = Items.Product_Code             
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID            
WHERE DispatchID = @DISPATCHID                 
GROUP BY DispatchDetail.Product_Code, Items.ProductName,  DispatchDetail.SalePrice, DispatchDetail.Serial, DispatchDetail.UOM, DispatchDetail.UOMQty, DispatchDetail.UOMPrice,    
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, DispatchDetail.FlagWord, Items.Track_Batches, DispatchDetail.OtherCG_Item,
DispatchDetail.Serial, DispatchDetail.SchemeID, DispatchDetail.FreeSerial, Batch_Products.Free,
CSchemeID,   DispatchDetail.SPLCATSCHEMEID, DispatchDetail.SpecialCategoryScheme,DispatchDetail.SPLCATSerial,
DispatchDetail.MultipleSchemeDetails,DispatchDetail.MultipleSplCategorySchDetail 
Having IsNull(DispatchDetail.UOMQty, 0) > 0    
Order By DispatchDetail.Serial, DispatchDetail.UOMPrice Desc      
