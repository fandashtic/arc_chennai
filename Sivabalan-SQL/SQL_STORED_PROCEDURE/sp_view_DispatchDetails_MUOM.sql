CREATE procedure [dbo].[sp_view_DispatchDetails_MUOM] (@DISPATCHID INT)                
AS                
SELECT DispatchDetail.Product_Code, Items.ProductName,                 
"Quantity" = Max(IsNull(DispatchDetail.UOMQty,0)) *     
    (Select Case When DispatchDetail.UOM = Max(Items.UOM1) Then Max(IsNull(Items.UOM1_Conversion,0))     
         When DispatchDetail.UOM = Max(Items.UOM2) Then Max(IsNull(Items.UOM2_Conversion,0))     
         Else 1 End),     
Batch_Products.Batch_Number, DispatchDetail.SalePrice, "UOM" = (Select Description From UOM Where UOM = DispatchDetail.UOM), Min(DispatchDetail.Batch_Code), Max(ItemCategories.Track_inventory), Max(ItemCategories.Price_Option), Batch_Products.Expiry,   
Batch_Products.PKD, DispatchDetail.FlagWord, Items.Track_Batches, "UOMID" = DispatchDetail.UOM, "UOMQty" = Max(DispatchDetail.UOMQty), "UOMPrice" = DispatchDetail.UOMPrice,"Serial" = DispatchDetail.Serial   
FROM  DispatchDetail, Batch_Products, Items, ItemCategories     
WHERE DispatchID = @DISPATCHID                 
 AND DispatchDetail.Product_Code = Items.Product_Code             
 AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code                
 AND Items.CategoryID = ItemCategories.CategoryID        
GROUP BY DispatchDetail.Product_Code, Items.ProductName,  DispatchDetail.SalePrice, DispatchDetail.Serial, DispatchDetail.UOM, DispatchDetail.UOMQty, DispatchDetail.UOMPrice,    
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, DispatchDetail.FlagWord, Items.Track_Batches     
Having IsNull(DispatchDetail.UOMQty, 0) > 0    
Order By DispatchDetail.Serial, DispatchDetail.UOMPrice Desc
