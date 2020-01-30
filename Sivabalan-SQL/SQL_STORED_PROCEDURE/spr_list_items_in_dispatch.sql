CREATE PROCEDURE [dbo].[spr_list_items_in_dispatch](@DISPATCHID int)  
AS  
	SELECT  DispatchDetail.Product_Code, "Item Code" = DispatchDetail.Product_Code,  
	 "Item Name" = Items.ProductName, "Quantity" = SUM(DispatchDetail.Quantity), "Batch" = Batch_Products.Batch_Number,  
	 "Sale Price" = DispatchDetail.SalePrice  
	FROM DispatchDetail
	Inner Join Items ON DispatchDetail.Product_Code = Items.Product_Code
	Left Outer Join Batch_Products ON DispatchDetail.Batch_Code = Batch_Products.Batch_Code
	WHERE   DispatchDetail.DispatchID = @DISPATCHID	   
	GROUP BY isnull(DispatchDetail.Serial,0),DispatchDetail.Product_Code, Items.ProductName, Batch_Products.Batch_Number, DispatchDetail.SalePrice  
	order by isnull(DispatchDetail.Serial,0)  
