CREATE procedure [dbo].[sp_view_DispatchDetails](@DISPATCHID INT)             
AS          
SELECT DispatchDetail.Product_Code, Items.ProductName,           
SUM(DispatchDetail.Quantity), DispatchDetail.SalePrice,          
Batch_Products.Batch_Number, min(DispatchDetail.Batch_Code),Batch_Products.Expiry,       
Batch_Products.PKD, DispatchDetail.FlagWord  ,max(itemcategories.Track_inventory),max(itemcategories.Price_Option), Items.Track_Batches  
FROM DispatchDetail, Batch_Products, Items ,itemcategories         
WHERE DispatchID = @DISPATCHID           
AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code          
AND Items.CategoryID = itemcategories.CategoryID  
AND DispatchDetail.Product_Code = Items.Product_Code          
GROUP BY isnull(DispatchDetail.Serial,0),DispatchDetail.Product_Code, Items.ProductName, DispatchDetail.SalePrice,          
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD , DispatchDetail.FlagWord, Items.Track_Batches     
order by isnull(DispatchDetail.Serial,0)
